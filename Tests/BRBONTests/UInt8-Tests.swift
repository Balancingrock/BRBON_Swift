//
//  UInt8-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 06/02/18.
//
//

import XCTest
import BRUtils
#if os(Linux)
    import Glibc
#endif

@testable import BRBON


class UInt8_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoder() {
        
        let i = UInt8(12.0)
        
        XCTAssertEqual(i.itemType, ItemType.uint8)
        XCTAssertEqual(i.valueByteCount, 1)
        XCTAssertEqual(i.minimumValueFieldByteCount, 0)
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        #if swift(>=5.0)
        _ = memset(buffer.baseAddress!, 0, 128)
        #else
        _ = memset(buffer.baseAddress, 0, 128)
        #endif
        defer { buffer.deallocate() }
        
        i.copyBytes(to: buffer.baseAddress!, Endianness.little)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 1, deallocator: Data.Deallocator.none)
        
        let exp = Data([0x0c])
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let i = UInt8(12)
        
        let im = ItemManager.createManager(withValue: i)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isUInt8)
        XCTAssertEqual(im.root.uint8, UInt8(12))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        var exp = Data([
            0x07, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
        
        
        // Assignment
        
        im.root.uint8 = UInt8(11)
        XCTAssertEqual(im.root.uint8, UInt8(11))
        
        exp = Data([
            0x07, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x0B, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
