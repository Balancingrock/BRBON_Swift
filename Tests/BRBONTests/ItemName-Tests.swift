//
//  ItemName-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 28/10/17.
//
//

import XCTest
import BRBON


class ItemName_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test() {

        if let name = ItemName("Test") {

            XCTAssertEqual(name.stringByteCount, 4)
            XCTAssertEqual(name.byteCount, 4 + 3)
            XCTAssertEqual(name.string, "Test")
            XCTAssertEqual(name.hash, 14373)
            XCTAssertEqual(name.endianBytes(.little), Data(bytes: [0x25, 0x38, 4, 84, 101, 115, 116]))

        } else {
            
            XCTFail("Creation of ItemName failed")
        }
        
        
        if let _ = ItemName("Test", fixedByteCount: 10) {
            XCTFail("Creation of ItemName should have failed")
        }

        
        if let name = ItemName("Test", fixedByteCount: 16) {
            
            XCTAssertEqual(name.stringByteCount, 4)
            XCTAssertEqual(name.byteCount, 7)
            XCTAssertEqual(name.string, "Test")
            XCTAssertEqual(name.hash, 14373)
            XCTAssertEqual(name.endianBytes(.little), Data(bytes: [0x25, 0x38, 4, 84, 101, 115, 116]))
            
        } else {
            
            XCTFail("Creation of ItemName failed")
        }

        
        if let name = ItemName("😀Test", fixedByteCount: 8) {
            
            XCTAssertEqual(name.stringByteCount, 5)
            XCTAssertEqual(name.byteCount, 8)
            XCTAssertEqual(name.string, "😀T")
            XCTAssertEqual(name.hash, 53647)
            XCTAssertEqual(name.endianBytes(.little), Data(bytes: [0x8F, 0xD1, 5, 0xf0, 0x9f, 0x98, 0x80, 84]))
            
        } else {
            
            XCTFail("Creation of ItemName failed")
        }

        
        var data = Data(bytes: [0x8F, 0xD1, 6, 84, 101, 0xf0, 0x9f, 0x98, 0x80, 84])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let name = ItemName(&bytePtr, count: &counter, endianness: .little) {
            
            XCTAssertEqual(name.stringByteCount, 6)
            XCTAssertEqual(name.byteCount, 9)
            XCTAssertEqual(name.string, "Te😀")
            XCTAssertEqual(name.hash, 37416)
            XCTAssertEqual(name.endianBytes(.little), Data(bytes: [0x28, 0x92, 6, 84, 101, 0xf0, 0x9f, 0x98, 0x80]))

        } else {
            XCTFail("Could not convert byte stream into ItemName")
        }
    }
    
    func testNormalize() {
        
        XCTAssertEqual(0, ItemName.normalizedByteCount(0))
        XCTAssertEqual(8, ItemName.normalizedByteCount(1))
        XCTAssertEqual(8, ItemName.normalizedByteCount(8))
        XCTAssertEqual(16, ItemName.normalizedByteCount(9))
        XCTAssertEqual(248, ItemName.normalizedByteCount(248))
        XCTAssertEqual(248, ItemName.normalizedByteCount(250))
    }
}
