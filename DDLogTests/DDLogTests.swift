//
//  DDLogTests.swift
//  DDLogTests
//
//  Created by Heee on 16/1/28.
//  Copyright © 2016年 jianbo. All rights reserved.
//

import XCTest

import DDLogManager

class DDLogTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        DDLogManager.addLoger(DDTTYLoger.sharedInstance)
        
        let queue = DispatchQueue(label: "com.ddlog.unittest", attributes: DispatchQueue.Attributes.concurrent)
        for i in 0...1000 {
            //dispatch_sync(queue, { NSLog("\(i). This is debug message") })
            queue.async { DDLogDebug("\(i). This is debug message") }
        }
    }
}
