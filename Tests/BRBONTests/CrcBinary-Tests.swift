//
//  CrcBinary-Tests.swift
//  BRBONTests
//
//  Created by Rien van der lugt on 14/05/2018.
//

import XCTest
import BRUtils
@testable import BRBON

class CrcBinary_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoder() {
        
        let b = BRCrcBinary(Data([0x01, 0x02, 0x03]))
        
        XCTAssertEqual(b.itemType, .crcBinary)
        XCTAssertEqual(b.valueByteCount, 11)
        XCTAssertEqual(b.minimumValueFieldByteCount, 16)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 11, deallocator: Data.Deallocator.none)
        
        let exp = Data([0x1D, 0x80, 0xBC, 0x55, 0x03, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03])
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let b = BRCrcBinary(Data([0x01, 0x02, 0x03]))
        
        let im = ItemManager.createManager(withValue: b)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isCrcBinary)
        XCTAssertEqual(im.root.crcBinary, BRCrcBinary(Data([0x01, 0x02, 0x03])))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        let exp = Data([
            0x10, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x1D, 0x80, 0xBC, 0x55, 0x03, 0x00, 0x00, 0x00,
            0x01, 0x02, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
