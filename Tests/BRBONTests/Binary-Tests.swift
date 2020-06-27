//
//  Binary-Tests.swift
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
        
        let b = Data([0x01, 0x02, 0x03])
        
        XCTAssertEqual(b.itemType, .binary)
        XCTAssertEqual(b.valueByteCount, 7)
        XCTAssertEqual(b.minimumValueFieldByteCount, 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        #if swift(>=5.0)
        _ = memset(buffer!.baseAddress!, 0, 128)
        #else
        _ = memset(buffer.baseAddress, 0, 128)
        #endif
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 7, deallocator: Data.Deallocator.none)
        
        let exp = Data([0x03, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03])
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let b = Data([0x11, 0x22, 0x33])

        let im = ItemManager.createManager(withValue: b)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isBinary)
        XCTAssertEqual(im.root.binary, Data([0x11, 0x22, 0x33]))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        XCTAssertNil(im.root.itemName)
        
        
        // Buffer content
        
        let exp = Data([
            0x0F, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00, 0x11, 0x22, 0x33, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
