//
//  ItemOptions-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 28/10/17.
//
//

import XCTest
@testable import BRBON

class ItemOptions_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSetReset() {
        
        var options = ItemOptions()
        
        XCTAssertFalse(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x00]))

        
        options.isNil = false
        
        XCTAssertFalse(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x00]))

        
        options.isNil = true
        
        XCTAssertTrue(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x80]))

        
        options.isNil = false
        
        XCTAssertFalse(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x00]))

        
        options.fixedItemByteCount = false
        
        XCTAssertFalse(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x00]))

        
        options.fixedItemByteCount = true
        
        XCTAssertFalse(options.isNil)
        XCTAssertTrue(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x40]))

        
        options.fixedItemByteCount = false
        
        XCTAssertFalse(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x00]))

        
        options.fixedNameByteCount = false
        
        XCTAssertFalse(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x00]))
        
        
        options.fixedNameByteCount = true
        
        XCTAssertFalse(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertTrue(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x20]))
        
        
        options.fixedNameByteCount = false
        
        XCTAssertFalse(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x00]))
    }
    
    func testCreation() {
        
        guard var options = ItemOptions(0x80) else { XCTFail() ; return }
        
        XCTAssertTrue(options.isNil)
        XCTAssertFalse(options.fixedItemByteCount)
        XCTAssertFalse(options.fixedNameByteCount)
        XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x80]))

        
        guard var options1 = ItemOptions(0x40) else { XCTFail() ; return }
        
        XCTAssertFalse(options1.isNil)
        XCTAssertTrue(options1.fixedItemByteCount)
        XCTAssertFalse(options1.fixedNameByteCount)
        XCTAssertEqual(options1.endianBytes(.little), Data(bytes: [0x40]))

        
        guard var options2 = ItemOptions(0x20) else { XCTFail() ; return }
        
        XCTAssertFalse(options2.isNil)
        XCTAssertFalse(options2.fixedItemByteCount)
        XCTAssertTrue(options2.fixedNameByteCount)
        XCTAssertEqual(options2.endianBytes(.little), Data(bytes: [0x20]))

        
        guard var options3 = ItemOptions(0xE0) else { XCTFail() ; return }
        
        XCTAssertTrue(options3.isNil)
        XCTAssertTrue(options3.fixedItemByteCount)
        XCTAssertTrue(options3.fixedNameByteCount)
        XCTAssertEqual(options3.endianBytes(.little), Data(bytes: [0xE0]))

        
        if let _ = ItemOptions(0x10) { XCTFail() }
        if let _ = ItemOptions(0x08) { XCTFail() }
        if let _ = ItemOptions(0x04) { XCTFail() }
        if let _ = ItemOptions(0x02) { XCTFail() }
        if let _ = ItemOptions(0x01) { XCTFail() }
        if let _ = ItemOptions(0xFF) { XCTFail() }
        if let _ = ItemOptions(0x88) { XCTFail() }
    }
    
    func testDecoding() {
    
        
        var data = Data(bytes: [0b1000_0000])
        var bytePtr = (data as NSData).bytes
        var count = UInt32(1)
        if let options = ItemOptions(&bytePtr, count: &count, endianness: .little) {
            XCTAssertTrue(options.isNil)
            XCTAssertFalse(options.fixedItemByteCount)
            XCTAssertFalse(options.fixedNameByteCount)
            XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x80]))
            XCTAssertEqual(count, 0)
        } else {
            XCTFail("Decoding should have been possible")
        }
        
        
        data = Data(bytes: [0b0100_0000])
        bytePtr = (data as NSData).bytes
        count = 1
        if let options = ItemOptions(&bytePtr, count: &count, endianness: .little) {
            XCTAssertFalse(options.isNil)
            XCTAssertTrue(options.fixedItemByteCount)
            XCTAssertFalse(options.fixedNameByteCount)
            XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x40]))
            XCTAssertEqual(count, 0)
        } else {
            XCTFail("Decoding should have been possible")
        }

        
        data = Data(bytes: [0b0010_0000])
        bytePtr = (data as NSData).bytes
        count = 1
        if let options = ItemOptions(&bytePtr, count: &count, endianness: .little) {
            XCTAssertFalse(options.isNil)
            XCTAssertFalse(options.fixedItemByteCount)
            XCTAssertTrue(options.fixedNameByteCount)
            XCTAssertEqual(options.endianBytes(.little), Data(bytes: [0x20]))
            XCTAssertEqual(count, 0)
        } else {
            XCTFail("Decoding should have been possible")
        }

        
        data = Data(bytes: [0b0001_0000])
        bytePtr = (data as NSData).bytes
        count = 1
        if let _ = ItemOptions(&bytePtr, count: &count, endianness: .little) {
            XCTFail("Decoding should have been impossible")
        }

        
        data = Data(bytes: [0b0000_1000])
        bytePtr = (data as NSData).bytes
        count = 1
        if let _ = ItemOptions(&bytePtr, count: &count, endianness: .little) {
            XCTFail("Decoding should have been impossible")
        }

        
        data = Data(bytes: [0b0000_0100])
        bytePtr = (data as NSData).bytes
        count = 1
        if let _ = ItemOptions(&bytePtr, count: &count, endianness: .little) {
            XCTFail("Decoding should have been impossible")
        }

        
        data = Data(bytes: [0b0000_0010])
        bytePtr = (data as NSData).bytes
        count = 1
        if let _ = ItemOptions(&bytePtr, count: &count, endianness: .little) {
            XCTFail("Decoding should have been impossible")
        }

        
        data = Data(bytes: [0b0000_0001])
        bytePtr = (data as NSData).bytes
        count = 1
        if let _ = ItemOptions(&bytePtr, count: &count, endianness: .little) {
            XCTFail("Decoding should have been impossible")
        }
    }
}
