//
//  DDLoger.swift
//  SwiftLog
//
//  Created by Heee on 16/1/27.
//  Copyright © 2016年 jianbo. All rights reserved.
//

import Foundation


public protocol DDLoger {
    
    var queue: dispatch_queue_t? {get set}
    
    var formatter: DDLogFormatter? {get set}
    
    var level: DDLogLevel? {get set}
    
    var isAsync: Bool {get set}
    
    func logMessage(msg: DDLogMessage)
}


public class DDTTYLoger: DDLoger {
    
    public var queue: dispatch_queue_t?
    
    public var formatter: DDLogFormatter?
    
    public var level: DDLogLevel?
    
    public var isAsync: Bool
    
    public class var sharedInstance: DDTTYLoger {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : DDTTYLoger? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DDTTYLoger()
        }
        
        return Static.instance!
    }
    
    init() {
        isAsync = true
    }
    
    public func logMessage(msg: DDLogMessage) {
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
            dispatch_async(queue!, clouser)
        } else {
            dispatch_sync(queue!, clouser)
        }
    }
}


public class DDFileLoger: DDLoger {
    
    public var queue: dispatch_queue_t?
    
    public var formatter: DDLogFormatter?
    
    public var level: DDLogLevel?
    
    public var isAsync: Bool
    
    var logFileManager: DDLogFileManager
    
    public class var sharedInstance: DDFileLoger {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : DDFileLoger? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DDFileLoger()
        }
        
        return Static.instance!
    }
    
    public init() {
        queue = dispatch_queue_create("com.swiftlog.fileloger", DISPATCH_QUEUE_SERIAL)
        logFileManager = DDLogFileManager()
        isAsync = true
    }
    
    
    public func logMessage(msg: DDLogMessage) {
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
            dispatch_async(queue!, clousre)
        } else {
            dispatch_sync(queue!, clousre)
        }
    }
}


// filename:  appname 2015-01-02.log
class DDLogFileManager {
    
    let maximumFileSize: UInt = 1024 * 1024 // 1MB
    
    let fileManager = NSFileManager.defaultManager()
    
    var defaultLogDirectory: String {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let path  = paths.first!.stringByAppendingString("/Logs")
        
        // create file path
        if !fileManager.fileExistsAtPath(path) {
            do {
                try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
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
            let fileNames = try fileManager.contentsOfDirectoryAtPath(defaultLogDirectory)
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
        logFileNames.sortInPlace { (a, b) -> Bool in
            return a > b
        }
        return logFileNames
    }
    
    func sortedLogFilePaths() -> Array<String> {
        var logFilePaths = unsortedLogFilePaths()
        logFilePaths.sortInPlace { (a, b) -> Bool in
            return a > b
        }
        return logFilePaths
    }
    
    func writeFile(str: String) {
        var message = str
        if !message.hasSuffix("\n") {
            message = message + "\n"
        }
        
        do {
            let fileAttr = try fileManager.attributesOfItemAtPath(lastLogFilePath)
            let fileSize = fileAttr[NSFileSize] as? UInt
            if fileSize >= maximumFileSize {
                createNewLogFile()
            }
            
            let data = message.dataUsingEncoding(NSUTF8StringEncoding)!
            if let fileHandler =  NSFileHandle(forWritingAtPath: lastLogFilePath) {
                fileHandler.seekToEndOfFile()
                fileHandler.writeData(data)
            } else {
                DDLogError("SwiftLog open file handler error!!!!")
            }
        } catch {
            DDLogError("\(error)")
        }
    }
    
    func createNewLogFile() -> String {
        let path = "\(defaultLogDirectory)/\(applicationName)_\(currentDate).log"
        fileManager.createFileAtPath(path, contents: nil, attributes: nil)
        
        return path
    }
    
    func isLogFile(name: String) -> Bool {
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
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm"
        return formatter.stringFromDate(NSDate(timeIntervalSinceNow: 0))
    }
}

