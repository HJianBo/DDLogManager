//
//  DDLogManager.swift
//  SwiftLog
//
//  Created by Heee on 16/1/27.
//  Copyright © 2016年 jianbo. All rights reserved.
//

import Foundation

@objc public enum DDLogLevel: UInt8 {
    
    /// 不显示日志
    case Off  = 0
    
    /// 显示 错误 日志
    case Error
    
    /// 显示 错误|警告 日志
    case Warning
    
    /// 显示 错误|警告|信息 日志
    case Info
    
    /// 显示 错误|警告|信息|调试 日志
    case Debug
    
    /// 显示 错误|警告|调试|信息|冗余 日志
    case Verbose
    
    
    var stringValue: String {
        return map[self]!
    }
    
    private var map: Dictionary<DDLogLevel, String> {
        return [.Off: "Off", .Error: "Error", .Warning: "Warn ", .Debug: "Debug", .Info: "Info ", .Verbose: "Verbs"]
    }
}


public func DDLogVerbose(format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .Verbose,
                            function: function.stringValue,
                                file: file.stringValue,
                                line: line)
}

public func DDLogInfo(format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .Info,
                            function: function.stringValue,
                                file: file.stringValue,
                                line: line)
}

public func DDLogDebug(format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .Debug,
                            function: function.stringValue,
                                file: file.stringValue,
                                line: line)
}

public func DDLogWarn(format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .Warning,
                            function: function.stringValue,
                                file: file.stringValue,
                                line: line)
}

public func DDLogError(format: String, function: StaticString = #function, file: StaticString = #file, line: Int = #line) {
    let manager = DDLogManager.sharedInstance
    
    manager.logMessage(format, level: .Error,
                            function: function.stringValue,
                                file: file.stringValue,
                                line: line)
}

public class DDLogManager {
    
    /// all logers
    var logers: Array<DDLoger>
    
    /// FIFO
    var logQueue: dispatch_queue_t
    
    public var defaultLevel: DDLogLevel = .Debug
    
    public class var sharedInstance: DDLogManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : DDLogManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DDLogManager()
        }
        
        return Static.instance!
    }
    
    public class func addLoger(loger: DDLoger) {
        DDLogManager.sharedInstance.logers.append(loger)
    }
    
    init() {
        logers = []
        logQueue = dispatch_queue_create("com.swiftlog.logmanager", DISPATCH_QUEUE_SERIAL)
    }
    
    func logMessage(format: String, level: DDLogLevel, function: String, file: String, line: Int) {
        let timestamp = NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970
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
    
    public var timestamp: NSTimeInterval
    
    public var level: DDLogLevel
    
    public var message: String
    
    public init(message msg: String, level lvl: DDLogLevel, function fctn: String, file fle: String, line l: Int, time t: NSTimeInterval) {
        function  = fctn
        file      = fle
        line      = l
        timestamp = t
        
        level     = lvl
        message   = msg
    }
}

