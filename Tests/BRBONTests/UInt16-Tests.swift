//
//  UInt16-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils

#if os(Linux)
    import Glibc
#endif

@testable import BRBON

class UInt16_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoder() {
        
        let i = UInt16(0x1234)
        
        XCTAssertEqual(i.itemType, ItemType.uint16)
        XCTAssertEqual(i.valueByteCount, 2)
        XCTAssertEqual(i.minimumValueFieldByteCount, 0)
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        #if swift(>=5.0)
        _ = memset(buffer.baseAddress!, 0, 128)
        #else
        _ = memset(buffer.baseAddress, 0, 128)
        #endif
        defer { buffer.deallocate() }
        
        i.copyBytes(to: buffer.baseAddress!, Endianness.little)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 2, deallocator: Data.Deallocator.none)
        
        let exp = Data([0x34, 0x12])
        
        XCTAssertEqual(data, exp)
    }
    
        
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let i = UInt16(0x1234)
        
        let im = ItemManager.createManager(withValue: i)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isUInt16)
        XCTAssertEqual(im.root.uint16, UInt16(0x1234))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        var exp = Data([
            0x08, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x34, 0x12, 0x00, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
        
        
        // Assignment
        
        im.root.uint16 = UInt16(0x5678)
        XCTAssertEqual(im.root.uint16, UInt16(0x5678))
        
        exp = Data([
            0x08, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x78, 0x56, 0x00, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
