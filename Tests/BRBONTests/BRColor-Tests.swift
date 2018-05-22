//
//  BRColor-Tests.swift
//  BRBONTests
//
//  Created by Rien van der lugt on 14/05/2018.
//

import XCTest
import BRUtils
@testable import BRBON


class BRColor_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBrColor() {
        
        let b = BRColor(NSColor.blue)
        
        XCTAssertEqual(b.redComponent, UInt8(0))
        XCTAssertEqual(b.greenComponent, UInt8(0))
        XCTAssertEqual(b.blueComponent, UInt8(255))
        XCTAssertEqual(b.alphaComponent, UInt8(255))
        
        XCTAssertEqual(b.color, NSColor.blue)
    }
    
    
    func testEquatable() {
        
        let b = BRColor(NSColor.blue)
        let c = BRColor(NSColor(red: 0, green: 0, blue: 1, alpha: 1))
        let d = BRColor(NSColor.red)

        
        XCTAssertEqual(b, c)
        XCTAssertNotEqual(b, d)
    }
    
    
    func testCoder() {
        
        let b = BRColor(NSColor.blue)

        XCTAssertEqual(b.itemType, .color)
        XCTAssertEqual(b.valueByteCount, 4)
        XCTAssertEqual(b.minimumValueFieldByteCount, 0)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 4, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [0x00, 0x00, 0xFf, 0xFF])
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let b = BRColor(NSColor.blue)

        let im = ItemManager.createManager(withValue: b)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isColor)
        XCTAssertEqual(im.root.color, BRColor(NSColor.blue))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        var exp = Data(bytes: [
            0x16, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF
            ])
        
        XCTAssertEqual(exp, im.data)
        
        
        // Assignment
        
        im.root.color = BRColor(NSColor.red)
        XCTAssertEqual(im.root.color, BRColor(NSColor.red))
        
        exp = Data(bytes: [
            0x16, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0xFF
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
