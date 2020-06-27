//
//  BRString-Tests.swift
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

class BRString_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testBrString() {
        
        let b = BRString("one")
        
        XCTAssertEqual(b?.string, "one")
        XCTAssertEqual(b?.utf8Code, "one".data(using: .utf8))
    }
    
    
    func testEquatable() {
        
        let b = BRString("one")
        let c = BRString("one")
        
        XCTAssertEqual(b, c)
    }
    
    
    func testCoder() {
        
        let b = BRString("one")
        
        XCTAssertEqual(b?.itemType, .string)
        XCTAssertEqual(b?.valueByteCount, 7)
        XCTAssertEqual(b?.minimumValueFieldByteCount, 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        #if swift(>=5.0)
        _ = memset(buffer.baseAddress!, 0, 128)
        #else
        _ = memset(buffer.baseAddress, 0, 128)
        #endif
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b?.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 7, deallocator: Data.Deallocator.none)
        
        let exp = Data([0x03, 0x00, 0x00, 0x00, 0x6f, 0x6e, 0x65])
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testPortalNoName() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        guard let b = BRString("test") else { XCTFail(); return } // 0x74 0x65 0x73 0x74
        
        let im = ItemManager.createManager(withValue: b)
        
        
        // Portal Properties

        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isString)
        XCTAssertEqual(im.root.brString, b)
        XCTAssertEqual(im.root.string, "test")
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        XCTAssertNil(im.root.itemName)
        
        
        // Buffer content
        
        let exp = Data([
            0x0D, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00, 0x74, 0x65, 0x73, 0x74
            ])

        XCTAssertEqual(exp, im.data)

    }
    
    func testPortalWithName() {

        guard let s = BRString("test") else { XCTFail(); return } // 0x74 0x65 0x73 0x74

        guard let one = NameField("one") else { XCTFail(); return }
        let im = ItemManager.createManager(withValue: s, withNameField: one)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertEqual(im.root.itemNameField, one)

        XCTAssertTrue(im.root.isString)
        XCTAssertEqual(im.root.brString, s)
        XCTAssertEqual(im.root.string, "test")
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        XCTAssertEqual(im.root.itemName, "one")

        
        // Buffer content
        
        let exp = Data([
            0x0D, 0x00, 0x00, 0x08, 0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F, 0x6E, 0x65, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00, 0x74, 0x65, 0x73, 0x74
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
