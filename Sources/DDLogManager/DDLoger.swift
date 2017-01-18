//
//  DDLoger.swift
//  SwiftLog
//
//  Created by Heee on 16/1/27.
//  Copyright © 2016年 jianbo. All rights reserved.
//

import Foundation
import Dispatch


public protocol DDLoger {
    
    var queue: DispatchQueue {get set}
    
    var formatter: DDLogFormatter? {get set}
    
    var level: DDLogLevel {get set}
    
    // execute the log message function in specific `queue`
    func logMessage(_ msg: DDLogMessage)
}


public final class DDTTYLoger: DDLoger {
    
    public static var sharedInstance = DDTTYLoger()
    
    public var queue: DispatchQueue
    
    public var formatter: DDLogFormatter?
    
    public var level: DDLogLevel
    
    public init() {
        queue = DispatchQueue(label: "com.logmanager.ttyloger")
        level = DDLogManager.sharedInstance.defaultLevel
    }
    
    public func logMessage(_ msg: DDLogMessage) {
        if formatter == nil {
            formatter = DDLogDefaultFormatter()
        }
        
        print(formatter!.formatMessage(msg))
    }
}


public final class DDFileLoger: DDLoger {
    
    public static var sharedInstance = DDFileLoger()
    
    public var queue: DispatchQueue
    
    public var formatter: DDLogFormatter?
    
    public var level: DDLogLevel
    
    public var folderName: String? {
        didSet {
            logFileManager.folderName = folderName
        }
    }
    
    var logFileManager: DDLogFileManager
    
    public init() {
        queue = DispatchQueue(label: "com.logmanager.fileloger", attributes: [])
        logFileManager = DDLogFileManager()
        
        level =  DDLogManager.sharedInstance.defaultLevel
    }
    
    public func logMessage(_ msg: DDLogMessage) {
        if formatter == nil {
            formatter = DDLogDefaultFormatter()
        }
        
        logFileManager.writeFile(formatter!.formatMessage(msg))
    }
}


/// log file manager
final class DDLogFileManager {
    
    var folderName: String?
    
    let maximumFileSize: Int = 1024 * 1024 // 1MB
    
    let fileManager = FileManager.default
    
    /**
     return default log directory
      - MaxOS: ~/Library/${ApplicationName}/Logs/${folderName}
      - iOS:   {AppSandBox}/Library/Logs/${folderName}
      - Linux: ???/${ApplicationName}/Logs/${folderName}
     */
    var defaultLogDirectory: String {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        
        // os(Linux), os(macOS), os(appleTV), os(watchOS)
        #if os(iOS)
            var path  = paths.first! + "/Logs"
        #else
            var path  = paths.first! + "/\(applicationName)/Logs"
        #endif
        

        if let subname = folderName {
            path += "/" + subname
        }
        
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
        // XXX: 如果使用排序来获取当前最新创建的日志文件, 可能会存在问题
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
    
    // TODO: add write cache
    func writeFile(_ str: String) {
        var message = str
        if !message.hasSuffix("\n") {
            message = message + "\n"
        }
        
        do {
            let fileAttr = try fileManager.attributesOfItem(atPath: lastLogFilePath)
            let fileSize = fileAttr[FileAttributeKey.size] as! Int
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
    
    @discardableResult func createNewLogFile() -> String {
        let path = "\(defaultLogDirectory)/\(currentDate).log"
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        
        return path
    }
    
    func isLogFile(_ filename: String) -> Bool {
        //let hasPrefix = fileName.hasPrefix(applicationName)
        let hasSuffix = filename.hasSuffix(".log")
        
        return hasSuffix
    }
    
    var applicationName: String {
        // XXX: application name
        //let d = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier")
        return "SwiftLog"
    }
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HHmmss.SSS"
        return formatter.string(from: Date(timeIntervalSinceNow: 0))
    }
}
