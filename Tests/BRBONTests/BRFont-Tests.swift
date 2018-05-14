//
//  BRFont-Tests.swift
//  BRBONTests
//
//  Created by Rien van der lugt on 14/05/2018.
//

import XCTest
import BRUtils
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
        
        let b = BRFont(NSFont(name: "Courier", size: 12.0)!)
        
        XCTAssertEqual(b?.fontNameUtf8Code, "Courier".data(using: .utf8))
        XCTAssertEqual(b?.familyNameUtf8Code, "Courier".data(using: .utf8))
        XCTAssertEqual(b?.pointSize, Float32(12.0))
    }
    
    
    func testEquatable() {
        
        let b = BRFont(NSFont(name: "Courier", size: 12.0)!)
        let c = BRFont(NSFont(name: "Courier", size: 12.0)!)
        let d = BRFont(NSFont(name: "Courier", size: 11.0)!)


        XCTAssertEqual(b, c)
        XCTAssertNotEqual(b, d)
    }
    
    
    func testCoder() {
        
        let b = BRFont(NSFont(name: "Courier", size: 12.0)!)

        XCTAssertEqual(b?.itemType, .font)
        XCTAssertEqual(b?.valueByteCount, 20)
        XCTAssertEqual(b?.minimumValueFieldByteCount, 24)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b?.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 20, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [0x00, 0x00, 0x40, 0x41, 0x07, 0x07, 0x43, 0x6f, 0x75, 0x72, 0x69, 0x65, 0x72, 0x43, 0x6f, 0x75, 0x72, 0x69, 0x65, 0x72]) // https://www.h-schmidt.net/FloatConverter/IEEE754.html
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        guard let b = BRFont(NSFont(name: "Courier", size: 12.0)!) else { XCTFail(); return }

        let im = ItemManager.createManager(withValue: b)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.nameField)
        
        XCTAssertTrue(im.root.isFont)
        XCTAssertEqual(im.root.font, BRFont(NSFont(name: "Courier", size: 12.0)!))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        XCTAssertEqual(im.root.valueType, ItemType.font)
        
        
        // Buffer content
        
        let exp = Data(bytes: [
            0x17, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x40, 0x41, 0x07, 0x07, 0x43, 0x6f,
            0x75, 0x72, 0x69, 0x65, 0x72, 0x43, 0x6f, 0x75,
            0x72, 0x69, 0x65, 0x72, 0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
