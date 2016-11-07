//
//  DDLogManager.swift
//  SwiftLog
//
//  Created by Heee on 16/1/27.
//  Copyright © 2016年 jianbo. All rights reserved.
//

import Foundation
import Dispatch

@objc public enum DDLogLevel: UInt8 {
    
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

open class DDLogManager {

    static var sharedInstance = DDLogManager()
    
    /// all logers
    var logers: Array<DDLoger>
    
    /// FIFO
    var logQueue: DispatchQueue
    
    open var defaultLevel: DDLogLevel = .debug
    
    open class func addLoger(_ loger: DDLoger) {
        DDLogManager.sharedInstance.logers.append(loger)
    }
    
    init() {
        logers = []
        logQueue = DispatchQueue(label: "com.swiftlog.logmanager", attributes: DispatchQueue.Attributes.concurrent)
    }
    
    func logMessage(_ format: String, level: DDLogLevel, function: String, file: String, line: Int) {
        let timestamp = Date(timeIntervalSinceNow: 0).timeIntervalSince1970
        let message = DDLogMessage(message: format, level: level, function: function, file: file, line: line, time: timestamp)
        
        for loger in logers {
            loger.logMessage(message)
        }
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

