//
//  Float64-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Float64_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoder() {
        
        let f = Float64(1.23)
        
        XCTAssertEqual(f.itemType, ItemType.float64)
        XCTAssertEqual(f.valueByteCount, 8)
        XCTAssertEqual(f.minimumValueFieldByteCount, 8)
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        f.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 8, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [0xae, 0x47, 0xe1, 0x7a, 0x14, 0xae, 0xf3, 0x3f]) // https://www.h-schmidt.net/FloatConverter/IEEE754.html
        
        XCTAssertEqual(data, exp)
    }
    
        
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let f = Float64(1.23)
        
        let im = ItemManager.createManager(withValue: f)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isFloat64)
        XCTAssertEqual(im.root.float64, Float64(1.23))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        var exp = Data(bytes: [
            0x0C, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0xae, 0x47, 0xe1, 0x7a, 0x14, 0xae, 0xf3, 0x3f
            ])
        
        XCTAssertEqual(exp, im.data)
        
        
        // Assignment
        
        im.root.float64 = Float64(21.0)
        XCTAssertEqual(im.root.float64, Float64(21.0))
        
        exp = Data(bytes: [
            0x0C, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x35, 0x40
            ])
                
        XCTAssertEqual(exp, im.data)
    }
}
