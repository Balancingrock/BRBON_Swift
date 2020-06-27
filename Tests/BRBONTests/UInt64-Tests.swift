//
//  UInt64-Tests.swift
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

class UInt64_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoder() {
        
        let i = UInt64(0x1122334455667788)
        
        XCTAssertEqual(i.itemType, ItemType.uint64)
        XCTAssertEqual(i.valueByteCount, 8)
        XCTAssertEqual(i.minimumValueFieldByteCount, 8)
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        #if swift(>=5.0)
        _ = memset(buffer.baseAddress!, 0, 128)
        #else
        _ = memset(buffer.baseAddress, 0, 128)
        #endif
        defer { buffer.deallocate() }
        
        i.copyBytes(to: buffer.baseAddress!, Endianness.little)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 8, deallocator: Data.Deallocator.none)
        
        let exp = Data([0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11])
        
        XCTAssertEqual(data, exp)
    }
    
        
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let i = UInt64(0x1122334455667788)
        
        let im = ItemManager.createManager(withValue: i)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isUInt64)
        XCTAssertEqual(im.root.uint64, UInt64(0x1122334455667788))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        var exp = Data([
            0x0A, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11
            ])
        
        XCTAssertEqual(exp, im.data)
        
        
        // Assignment
        
        im.root.uint64 = UInt64(0x1111222233334444)
        XCTAssertEqual(im.root.uint64, UInt64(0x1111222233334444))
        
        exp = Data([
            0x0A, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x44, 0x44, 0x33, 0x33, 0x22, 0x22, 0x11, 0x11
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
