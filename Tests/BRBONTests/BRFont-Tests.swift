//
//  BRFont-Tests.swift
//  BRBONTests
//
//  Created by Rien van der lugt on 14/05/2018.
//

import XCTest
import BRUtils

#if os(Linux)
    import Glibc
#endif

@testable import BRBON


class BRFont_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBrFont() {
        
        let b = BRFont(familyNameUtf8Code: "Courier".data(using: .utf8)!, fontNameUtf8Code: "Courier".data(using: .utf8)!, pointSize: 12.0)
        
        XCTAssertEqual(b.fontNameUtf8Code, "Courier".data(using: .utf8))
        XCTAssertEqual(b.familyNameUtf8Code, "Courier".data(using: .utf8))
        XCTAssertEqual(b.pointSize, Float32(12.0))
    }
    
    
    func testEquatable() {
        
        let b = BRFont(familyNameUtf8Code: "Courier".data(using: .utf8)!, fontNameUtf8Code: "Courier".data(using: .utf8)!, pointSize: 12.0)
        let c = BRFont(familyNameUtf8Code: "Courier".data(using: .utf8)!, fontNameUtf8Code: "Courier".data(using: .utf8)!, pointSize: 12.0)
        let d = BRFont(familyNameUtf8Code: "Courier".data(using: .utf8)!, fontNameUtf8Code: "Courier".data(using: .utf8)!, pointSize: 11.0)


        XCTAssertEqual(b, c)
        XCTAssertNotEqual(b, d)
    }
    
    
    func testCoder() {
        
        let b = BRFont(familyNameUtf8Code: "Courier".data(using: .utf8)!, fontNameUtf8Code: "Courier".data(using: .utf8)!, pointSize: 12.0)

        XCTAssertEqual(b.itemType, .font)
        XCTAssertEqual(b.valueByteCount, 20)
        XCTAssertEqual(b.minimumValueFieldByteCount, 24)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        #if swift(>=5.0)
        _ = memset(buffer.baseAddress!, 0, 128)
        #else
        _ = memset(buffer.baseAddress, 0, 128)
        #endif
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 20, deallocator: Data.Deallocator.none)
        
        let exp = Data([0x00, 0x00, 0x40, 0x41, 0x07, 0x07, 0x43, 0x6f, 0x75, 0x72, 0x69, 0x65, 0x72, 0x43, 0x6f, 0x75, 0x72, 0x69, 0x65, 0x72]) // https://www.h-schmidt.net/FloatConverter/IEEE754.html
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let b = BRFont(familyNameUtf8Code: "Courier".data(using: .utf8)!, fontNameUtf8Code: "Courier".data(using: .utf8)!, pointSize: 12.0)

        let im = ItemManager.createManager(withValue: b)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.itemNameField)
        
        XCTAssertTrue(im.root.isFont)
        XCTAssertEqual(im.root.font, BRFont(familyNameUtf8Code: "Courier".data(using: .utf8)!, fontNameUtf8Code: "Courier".data(using: .utf8)!, pointSize: 12.0))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        
        
        // Buffer content
        
        let exp = Data([
            0x17, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x40, 0x41, 0x07, 0x07, 0x43, 0x6f,
            0x75, 0x72, 0x69, 0x65, 0x72, 0x43, 0x6f, 0x75,
            0x72, 0x69, 0x65, 0x72, 0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
