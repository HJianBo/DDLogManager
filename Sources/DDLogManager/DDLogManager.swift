//
//  DDLogManager.swift
//  SwiftLog
//
//  Created by Heee on 16/1/27.
//  Copyright © 2016年 jianbo. All rights reserved.
//

import Foundation
import Dispatch

public enum DDLogLevel: UInt8 {
    
    /// 不显示日志
    case off  = 0
    
    /// 显示 错误 日志
    case error
    
    /// 显示 错误|警告 日志
    case warning
    
    /// 显示 错误|警告|信息 日志
    case info
    
    /// 显示 错误|警告|信息|调试 日志
    case debug
    
    /// 显示 错误|警告|调试|信息|冗余 日志
    case verbose
    
    
    var stringValue: String {
        return map[self]!
    }
    
    fileprivate var map: Dictionary<DDLogLevel, String> {
        return [.off: "Off", .error: "Error", .warning: "Warn ", .debug: "Debug", .info: "Info ", .verbose: "Verbs"]
    }
}

extension DDLogLevel: Comparable {
}

public func > (lhs: DDLogLevel, rhs: DDLogLevel) -> Bool {
    return lhs.rawValue > rhs.rawValue
}

public func >= (lhs: DDLogLevel, rhs: DDLogLevel) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

public func < (lhs: DDLogLevel, rhs: DDLogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func <= (lhs: DDLogLevel, rhs: DDLogLevel) -> Bool {
    return lhs.rawValue <= rhs.rawValue
}


public func DDLogVerbose(_ format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .verbose,
                            function: String(describing: function),
                                file: String(describing: file),
                                line: line)
}

public func DDLogInfo(_ format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .info,
                            function: String(describing: function),
                                file: String(describing: file),
                                line: line)
}

public func DDLogDebug(_ format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .debug,
                            function: String(describing: function),
                                file: String(describing: file),
                                line: line)
}

public func DDLogWarn(_ format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .warning,
                            function: String(describing: function),
                                file: String(describing: file),
                                line: line)
}

public func DDLogError(_ format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .error,
                            function: String(describing: function),
                                file: String(describing: file),
                                line: line)
}

// MAX QUEUE SIZE
private let MAX_LOG_QUEUE_SIZE = 1000

private let LOG_QUEUE_SPECIFI_KEY = DispatchSpecificKey<String>()

private let LOG_QUEUE_SPECIFI_VALUE = "LOG_QUEUE_SPECIFI_VALUE"

open class DDLogManager {
    
    static var sharedInstance = DDLogManager()
    
    /// all logers
    var logers: Array<DDLoger>
    
    /// FIFO
    var logQueue: DispatchQueue
    
    /// control queue size
    var logSemaphore: DispatchSemaphore
    
    /// ???
    var logGroup: DispatchGroup
    
    open var defaultLevel: DDLogLevel = .debug
    
    open class func addLoger(_ loger: DDLoger) {
        DDLogManager.sharedInstance.logers.append(loger)
    }
    
    init() {
        logers = []
        logQueue = DispatchQueue(label: "com.logmanager.manager")
        logQueue.setSpecific(key: LOG_QUEUE_SPECIFI_KEY, value: LOG_QUEUE_SPECIFI_VALUE)
        
        logSemaphore = DispatchSemaphore(value: MAX_LOG_QUEUE_SIZE)
        
        logGroup = DispatchGroup()
    }
    
    func logMessage(_ format: String, level: DDLogLevel, function: String, file: String, line: Int) {
        let timestamp = Date(timeIntervalSinceNow: 0).timeIntervalSince1970
        let message = DDLogMessage(message: format,
                                   level: level,
                                   function: function,
                                   file: file,
                                   line: line,
                                   time: timestamp)
        queuelog(message: message)
    }
    
    func queuelog(message: DDLogMessage) {
        let result = logSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        // waiting for queue
        if result == .success {
            let clouser = {
                self.lt_log(message: message)
            }
            logQueue.async { clouser() }
        } else {
            // false ???
        }
    }
    
    func lt_log(message: DDLogMessage) {
        
        // Execute the given log message on each of our loggers.
        assert(DispatchQueue.getSpecific(key: LOG_QUEUE_SPECIFI_KEY) == LOG_QUEUE_SPECIFI_VALUE,
               "This method should only be run on the logging thread/queue")
        
        for loger in logers {
            //logGroup.enter()
            guard loger.level >= message.level else {
                continue
            }
            loger.queue.async {
                loger.logMessage(message)
            }
            //logGroup.leave()
            
        }
        
        logSemaphore.signal()
    }
}


public struct DDLogMessage {
    
    public var function: String
    
    public var file: String
    
    public var line: Int
    
    public var timestamp: TimeInterval
    
    public var level: DDLogLevel
    
    public var message: String
    
    public init(message msg: String, level lvl: DDLogLevel, function fctn: String, file fle: String, line l: Int, time t: TimeInterval) {
        function  = fctn
        file      = fle
        line      = l
        timestamp = t
        
        level     = lvl
        message   = msg
    }
}

