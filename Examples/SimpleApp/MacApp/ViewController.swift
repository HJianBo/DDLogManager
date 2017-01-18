//
//  ViewController.swift
//  MacApp
//
//  Created by HJianBo on 2017/1/18.
//  Copyright © 2017年 beidouapp. All rights reserved.
//

import Cocoa
import DDLogManager

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

