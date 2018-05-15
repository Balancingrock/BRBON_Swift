//
//  Int32-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Int32_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoder() {
        
        let i = Int32(0x12345678)
        
        XCTAssertEqual(i.itemType, ItemType.int32)
        XCTAssertEqual(i.valueByteCount, 4)
        XCTAssertEqual(i.minimumValueFieldByteCount, 0)
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        i.copyBytes(to: buffer.baseAddress!, Endianness.little)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 4, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [0x78, 0x56, 0x34, 0x12])
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testDecoder() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        let data = Data(bytes: [0x78, 0x56, 0x34, 0x12])
        
        data.copyBytes(to: (buffer.baseAddress?.assumingMemoryBound(to: UInt8.self))!, count: data.count)
        
        let i = Int32(fromPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(i, Int32(0x12345678))
    }
    
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let i = Int32(0x12345678)
        
        let im = ItemManager.createManager(withValue: i)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.nameField)
        
        XCTAssertTrue(im.root.isInt32)
        XCTAssertEqual(im.root.int32, Int32(0x12345678))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        var exp = Data(bytes: [
            0x05, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x78, 0x56, 0x34, 0x12
            ])
        
        XCTAssertEqual(exp, im.data)
        
        
        // Assignment
        
        im.root.int32 = Int32(0x11112222)
        XCTAssertEqual(im.root.int32, Int32(0x11112222))
        
        exp = Data(bytes: [
            0x05, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x22, 0x22, 0x11, 0x11
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
