//
//  Float32-Coder-Tests.swift
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

class Float32_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoder() {
        
        let f = Float32(12.0)
        
        XCTAssertEqual(f.itemType, ItemType.float32)
        XCTAssertEqual(f.valueByteCount, 4)
        XCTAssertEqual(f.minimumValueFieldByteCount, 0)
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        #if swift(>=5.0)
        _ = memset(buffer.baseAddress!, 0, 128)
        #else
        _ = memset(buffer.baseAddress, 0, 128)
        #endif
        defer { buffer.deallocate() }

        f.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 4, deallocator: Data.Deallocator.none)
        
        let exp = Data([0x00, 0x00, 0x40, 0x41]) // https://www.h-schmidt.net/FloatConverter/IEEE754.html
        
        XCTAssertEqual(data, exp)
    }
    
        
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let f = Float32(12.0)
        
        let im = ItemManager.createManager(withValue: f)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isFloat32)
        XCTAssertEqual(im.root.float32, Float32(12.0))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        var exp = Data([
            0x0B, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x41
            ])
        
        XCTAssertEqual(exp, im.data)
        
        
        // Assignment
        
        im.root.float32 = Float32(21.0)
        XCTAssertEqual(im.root.float32, Float(21.0))
        
        exp = Data([
            0x0B, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa8, 0x41
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
