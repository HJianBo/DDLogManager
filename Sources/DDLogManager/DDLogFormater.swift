//
//  DDLogFormater.swift
//  SwiftLog
//
//  Created by Heee on 16/1/27.
//  Copyright © 2016年 jianbo. All rights reserved.
//

import Foundation

public protocol DDLogFormatter {
    
    func formatMessage(_ msg: DDLogMessage) -> String
}

class DDLogDefaultFormatter: DDLogFormatter {
    
    func formatMessage(_ msg: DDLogMessage) -> String {
        let fileName  = msg.file.components(separatedBy: "/").last!
        let date      = Date(timeIntervalSince1970: msg.timestamp)
        let datefmter = DateFormatter()
        
        datefmter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        return "\(datefmter.string(from: date)) [\(fileName):\(String(format:"%3d",msg.line))][\(msg.level.stringValue)]: \(msg.message)"
    }
}
