import XCTest
import BRUtils
@testable import BRBON

class BRBONTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCTAssertEqual(BRBON().text, "Hello, World!")
    }


    static var allTests : [(String, (BRBONTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}

extension Data {
    
    func printBytes() {
        
        let str = self.reduce("") {
            return $0 + "0x\(String($1, radix: 16, uppercase: false)), "
        }
        print(str)
    }
}
