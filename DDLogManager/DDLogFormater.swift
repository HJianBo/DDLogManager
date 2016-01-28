//
//  DDLogFormater.swift
//  SwiftLog
//
//  Created by Heee on 16/1/27.
//  Copyright © 2016年 jianbo. All rights reserved.
//

import Foundation

public protocol DDLogFormatter {
    
    func formatMessage(msg: DDLogMessage) -> String
}


class DDLogDefaultFormatter: DDLogFormatter {
    
    func formatMessage(msg: DDLogMessage) -> String {
        let fileName  = msg.file.componentsSeparatedByString("/").last!
        let date      = NSDate(timeIntervalSince1970: msg.timestamp)
        let datefmter = NSDateFormatter()
        
        datefmter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return "\(datefmter.stringFromDate(date)) [\(fileName): \(msg.line)][\(msg.level.stringValue)]: \(msg.message)"
    }
}
