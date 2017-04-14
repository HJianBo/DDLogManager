import XCTest
@testable import DDLogManager

class DDLogManagerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Init
        DDLogManager.addLoger(DDTTYLoger.sharedInstance) // TTY  = Xcode console
        DDLogManager.addLoger(DDFileLoger.sharedInstance) // File = Written log to file
        
        // ...

        DDLogVerbose("This is verbose log message.")
        DDLogDebug("This is debug log message.")
        DDLogInfo("This is info log message.")
        DDLogWarn("This is warning log message.")
        DDLogError("This is error log message.")
    }
}
