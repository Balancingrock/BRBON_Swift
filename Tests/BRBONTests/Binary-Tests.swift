//
//  Binary-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Binary_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testCoder() {
        
        var b = Data(bytes: [0x01, 0x02, 0x03])
        
        XCTAssertEqual(b.itemType, .binary)
        XCTAssertEqual(b.valueByteCount, 7)
        XCTAssertEqual(b.minimumValueFieldByteCount, 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 7, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [0x03, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03])
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testDecoder() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        let data = Data(bytes: [0x03, 0x00, 0x00, 0x00, 0x11, 0x22, 0x33])
        
        data.copyBytes(to: (buffer.baseAddress?.assumingMemoryBound(to: UInt8.self))!, count: data.count)
        
        let b = Data(fromPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(b, Data(bytes: [0x11, 0x22, 0x33]))
    }

    
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let b = Data(bytes: [0x11, 0x22, 0x33])

        let im = ItemManager.createManager(withValue: b)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.nameField)
        
        XCTAssertTrue(im.root.isBinary)
        XCTAssertEqual(im.root.binary, Data(bytes: [0x11, 0x22, 0x33]))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        XCTAssertEqual(im.root.valueType, ItemType.binary)
        XCTAssertNil(im.root.itemName)
        
        
        // Buffer content
        
        let exp = Data(bytes: [
            0x0F, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00, 0x11, 0x22, 0x33, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}