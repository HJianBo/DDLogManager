import XCTest
@testable import DDLogManager

class DDLogManagerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(DDLogManager().text, "Hello, World!")
    }


    static var allTests : [(String, (DDLogManagerTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
