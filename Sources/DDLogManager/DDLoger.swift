//
//  DDLoger.swift
//  SwiftLog
//
//  Created by Heee on 16/1/27.
//  Copyright © 2016年 jianbo. All rights reserved.
//

import Foundation
import Dispatch

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}



public protocol DDLoger {
    
    var queue: DispatchQueue? {get set}
    
    var formatter: DDLogFormatter? {get set}
    
    var level: DDLogLevel? {get set}
    
    var isAsync: Bool {get set}
    
    func logMessage(_ msg: DDLogMessage)
}


open class DDTTYLoger: DDLoger {
    
    open static var sharedInstance = DDTTYLoger()
    
    open var queue: DispatchQueue?
    
    open var formatter: DDLogFormatter?
    
    open var level: DDLogLevel?
    
    open var isAsync: Bool
    
    init() {
        isAsync = false
    }
    
    open func logMessage(_ msg: DDLogMessage) {
        if queue == nil {
            queue = DDLogManager.sharedInstance.logQueue
        }
        
        if formatter == nil {
            formatter = DDLogDefaultFormatter()
        }
        
        if level == nil {
            level =  DDLogManager.sharedInstance.defaultLevel
        }
        
        guard level!.rawValue >= msg.level.rawValue else {
            return
        }
        
        let clouser = { [unowned self] in
            print(self.formatter!.formatMessage(msg))
        }
        
        if isAsync {
            queue!.async(execute: clouser)
        } else {
            clouser()
        }
    }
}


open class DDFileLoger: DDLoger {
    
    open var queue: DispatchQueue?
    
    open var formatter: DDLogFormatter?
    
    open var level: DDLogLevel?
    
    open var isAsync: Bool
    
    var logFileManager: DDLogFileManager
    
    open static var sharedInstance = DDFileLoger()
    
    public init() {
        queue = DispatchQueue(label: "com.swiftlog.fileloger", attributes: [])
        logFileManager = DDLogFileManager()
        isAsync = true
    }
    
    
    open func logMessage(_ msg: DDLogMessage) {
        if queue == nil {
            queue = DDLogManager.sharedInstance.logQueue
        }
        
        if formatter == nil {
            formatter = DDLogDefaultFormatter()
        }
        
        if level == nil {
            level =  DDLogManager.sharedInstance.defaultLevel
        }
        
        guard level!.rawValue >= msg.level.rawValue else {
            return
        }
        
        let clousre = { [unowned self] in
                        self.logFileManager.writeFile(self.formatter!.formatMessage(msg))
                    }
        
        
        if isAsync {
            queue!.async(execute: clousre)
        } else {
            queue!.sync(execute: clousre)
        }
    }
}


// filename:  appname 2015-01-02.log
class DDLogFileManager {
    
    let maximumFileSize: UInt = 1024 * 1024 // 1MB
    
    let fileManager = FileManager.default
    
    var defaultLogDirectory: String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path  = paths.first! + "/Logs"
        
        // create file path
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                DDLogError("\(error)")
            }
        }
        
        return path
    }
    
    var lastLogFilePath: String {
        if let lastFile = sortedLogFilePaths().first {
            return lastFile
        } else {
            // create file
            return createNewLogFile()
        }
    }
    
    init() {
    }
    
    func unsortedLogFileNames() -> Array<String> {
        var logFileNames = Array<String>()
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: defaultLogDirectory)
            for fileName in fileNames {
                if isLogFile(fileName) {
                    logFileNames.append(fileName)
                }
            }
        } catch {
            DDLogError("\(error)")
        }
        return logFileNames
    }
    
    func unsortedLogFilePaths() -> Array<String> {
        var logFilePaths = Array<String>()
        let fileNames = unsortedLogFileNames()
        for fileName in fileNames {
            logFilePaths.append("\(defaultLogDirectory)/\(fileName)")
        }
        return logFilePaths
    }
    
    func sortedLogFileNames() -> Array<String> {
        var logFileNames = unsortedLogFileNames()
        logFileNames.sort { (a, b) -> Bool in
            return a > b
        }
        return logFileNames
    }
    
    func sortedLogFilePaths() -> Array<String> {
        var logFilePaths = unsortedLogFilePaths()
        logFilePaths.sort { (a, b) -> Bool in
            return a > b
        }
        return logFilePaths
    }
    
    func writeFile(_ str: String) {
        var message = str
        if !message.hasSuffix("\n") {
            message = message + "\n"
        }
        
        do {
            let fileAttr = try fileManager.attributesOfItem(atPath: lastLogFilePath)
            let fileSize = fileAttr[FileAttributeKey.size] as? UInt
            if fileSize >= maximumFileSize {
                createNewLogFile()
            }
            
            let data = message.data(using: String.Encoding.utf8)!
            if let fileHandler =  FileHandle(forWritingAtPath: lastLogFilePath) {
                fileHandler.seekToEndOfFile()
                fileHandler.write(data)
            } else {
                DDLogError("SwiftLog open file handler error!!!!")
            }
        } catch {
            DDLogError("\(error)")
        }
    }
    
    func createNewLogFile() -> String {
        let path = "\(defaultLogDirectory)/\(applicationName)_\(currentDate).log"
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        
        return path
    }
    
    func isLogFile(_ name: String) -> Bool {
        // TODO:
        let fileName = name as NSString
        let hasPrefix = fileName.hasPrefix(applicationName)
        let hasSuffix = fileName.hasSuffix(".log")
        
        return (hasPrefix && hasSuffix)
    }
    
    var applicationName: String {
        // TODO: application name
        //let d = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier")
        return "SwiftLog"
    }
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm"
        return formatter.string(from: Date(timeIntervalSinceNow: 0))
    }
}

