//
//  ItemType.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/11/17.
//
//

import XCTest
import BRBON

class ItemType: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test() {
        
        var data = Data(bytes: [0x05])
        var bytePtr = (data as NSData).bytes
        var count = UInt32(1)
        if let t = BRBON.ItemType(&bytePtr, count: &count, endianness: .little) {
            XCTAssertTrue(t == .int64)
            XCTAssertEqual(t.endianBytes(.little), Data(bytes: [0x05]))
            XCTAssertEqual(count, 0)
        } else {
            XCTFail("Decoding should have been possible")
        }
        
        data = Data(bytes: [0x11])
        bytePtr = (data as NSData).bytes
        count = UInt32(1)
        if let _ = BRBON.ItemType(&bytePtr, count: &count, endianness: .little) {
            XCTFail("Decoding should have been impossible")
        }
    }
}
