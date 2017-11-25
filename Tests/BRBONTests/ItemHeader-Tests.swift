//
//  ItemHeader-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/11/17.
//
//

import XCTest
import BRBON


class ItemHeader_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test() {

        var header = ItemHeader(.null)
        
        XCTAssertEqual(header.type, .null)
        XCTAssertEqual(header.nameLength, 0)
        XCTAssertNil(header.fixedNameByteCount)
        XCTAssertEqual(header.endianBytes(.little), Data(bytes: [0, 0, 0, 0]))
        
        
        header = ItemHeader(.bool, options: ItemOptions(0xE0)!, nameLength: 16)
        
        XCTAssertEqual(header.type, .bool)
        XCTAssertEqual(header.nameLength, 16)
        XCTAssertEqual(header.fixedNameByteCount, 16)
        XCTAssertEqual(header.endianBytes(.little), Data(bytes: [0x01, 0xE0, 0, 0x10]))

        
        header = ItemHeader(.bool, nameLength: 16)
        
        XCTAssertEqual(header.type, .bool)
        XCTAssertEqual(header.nameLength, 16)
        XCTAssertNil(header.fixedNameByteCount)
        XCTAssertEqual(header.endianBytes(.little), Data(bytes: [0x01, 0x00, 0, 0x10]))

        
        var data = Data(bytes: [0x01, 0x00, 0, 0x10])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let header = ItemHeader(&bytePtr, count: &counter, endianness: .little) {
        
            XCTAssertEqual(header.type, .bool)
            XCTAssertEqual(header.nameLength, 16)
            XCTAssertNil(header.fixedNameByteCount)
            XCTAssertEqual(header.endianBytes(.little), Data(bytes: [0x01, 0x00, 0, 0x10]))
            XCTAssertEqual(counter, 0)
            
        } else {
            XCTFail()
        }

        
        data = Data(bytes: [0x01, 0xE0, 0, 0x10, 3])
        bytePtr = (data as NSData).bytes
        counter = UInt32(data.count)
        
        if let header = ItemHeader(&bytePtr, count: &counter, endianness: .little) {
            
            XCTAssertEqual(header.type, .bool)
            XCTAssertEqual(header.nameLength, 16)
            XCTAssertEqual(header.fixedNameByteCount, 16)
            XCTAssertEqual(header.endianBytes(.little), Data(bytes: [0x01, 0xE0, 0, 0x10]))
            XCTAssertEqual(counter, 1)
            
        } else {
            XCTFail()
        }

        
        data = Data(bytes: [0x01, 0xE0, 1, 0x10, 3])
        bytePtr = (data as NSData).bytes
        counter = UInt32(data.count)
        
        if let _ = ItemHeader(&bytePtr, count: &counter, endianness: .little) {
            XCTFail()
        }

        
        data = Data(bytes: [0x21, 0xE0, 0, 0x10, 3])
        bytePtr = (data as NSData).bytes
        counter = UInt32(data.count)
        
        if let _ = ItemHeader(&bytePtr, count: &counter, endianness: .little) {
            XCTFail()
        }

    }
}
