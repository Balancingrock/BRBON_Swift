//
//  BrCrcString-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 02/03/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class BrCrcString_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBrString() {
        
        let b = BRCrcString("one")
        
        XCTAssertEqual(b?.string, "one")
        XCTAssertEqual(b?.utf8Code, "one".data(using: .utf8))
        XCTAssertTrue(b?.crcIsValid ?? false)
        XCTAssertEqual(b?.crc, UInt32(0x7A6C86F1)) // https://www.lammertbies.nl/comm/info/crc-calculation.html
    }
    
    
    func testEquatable() {
        
        let b = BRCrcString("one")
        let c = BRCrcString("one")
        
        XCTAssertEqual(b, c)
    }
    
    
    func testCoder() {
        
        let b = BRCrcString("one")
        
        XCTAssertEqual(b?.itemType, .crcString)
        XCTAssertEqual(b?.valueByteCount, 11)
        XCTAssertEqual(b?.minimumValueFieldByteCount, 16)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b?.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 11, deallocator: Data.Deallocator.none)
        
        let exp = Data([0xf1, 0x86, 0x6c, 0x7a, 0x03, 0x00, 0x00, 0x00, 0x6f, 0x6e, 0x65])
        
        XCTAssertEqual(data, exp)
    }

    
    func testPortalNoName() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        guard let b = BRCrcString("test") else { XCTFail(); return } // 0x74 0x65 0x73 0x74
        
        let im = ItemManager.createManager(withValue: b)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isCrcString)
        XCTAssertEqual(im.root.crcString, b)
        XCTAssertEqual(im.root.string, "test")
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        let exp = Data([
            0x0E, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x0C, 0x7E, 0x7F, 0xD8, 0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74, 0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}

