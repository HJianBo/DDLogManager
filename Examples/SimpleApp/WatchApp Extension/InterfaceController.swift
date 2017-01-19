//
//  InterfaceController.swift
//  WatchApp Extension
//
//  Created by HJianBo on 2017/1/19.
//  Copyright © 2017年 beidouapp. All rights reserved.
//

import WatchKit
import Foundation
import DDLogManager

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        DDLogManager.addLoger(DDTTYLoger.sharedInstance)
        DDLogManager.addLoger(DDFileLoger.sharedInstance)
        
        
        DDLogVerbose("this is verbose log")
        DDLogInfo("this is info log")
        DDLogDebug("this is debug log")
        DDLogWarn("this is warn log")
        DDLogError("this is error log")
        for i in 0..<100 {
            DDLogInfo("\(i)")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
