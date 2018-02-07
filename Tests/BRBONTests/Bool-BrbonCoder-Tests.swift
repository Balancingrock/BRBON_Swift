//
//  Bool-BrbonCoder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 06/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Bool_BrbonCoder_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_NoNameField() {
        
        
        // Instance
        
        let b: Bool = true
        
        
        // Properties
        
        XCTAssertEqual(b.brbonType, ItemType.bool)
        XCTAssertEqual(b.valueByteCount, 1)
        XCTAssertEqual(b.itemByteCount(), 16)
        XCTAssertEqual(b.elementByteCount, 1)

        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        b.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 1)
        
        b.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x81, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x01, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        b.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, valueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x81, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x01, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        b.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 1)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x00])
        
        XCTAssertEqual(Bool.readValue(atPtr: buffer.baseAddress!, machineEndianness), false)

        buffer.copyBytes(from: [0x01])
        
        XCTAssertEqual(Bool.readValue(atPtr: buffer.baseAddress!, machineEndianness), true)

        buffer.copyBytes(from: [0x56])
        
        XCTAssertEqual(Bool.readValue(atPtr: buffer.baseAddress!, machineEndianness), false)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(Bool.readFromItem(atPtr: buffer.baseAddress!, machineEndianness), true)
        
        buffer.copyBytes(from: [0])
        
        XCTAssertEqual(Bool.readFromElement(atPtr: buffer.baseAddress!, machineEndianness), false)
    }
    
    func test_WithNameField() {
        
        
        // Instance
        
        let b: Bool = true
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")
        
        
        // Properties
        
        XCTAssertEqual(b.brbonType, ItemType.bool)
        XCTAssertEqual(b.valueByteCount, 1)
        XCTAssertEqual(b.itemByteCount(nfd), 24)
        XCTAssertEqual(b.elementByteCount, 1)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        b.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 1)
        
        b.storeAsItem(atPtr: buffer.baseAddress!, nameField: nfd, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)

        let exp = Data(bytes: [
            0x81, 0x00, 0x00, 0x08,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x01, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        b.storeAsItem(atPtr: buffer.baseAddress!, nameField: nfd, parentOffset: 0x12345678, valueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)

        let exp2 = Data(bytes: [
            0x81, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x01, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)

        b.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 1)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x00])
        
        XCTAssertEqual(Bool.readValue(atPtr: buffer.baseAddress!, machineEndianness), false)
        
        buffer.copyBytes(from: [0x01])
        
        XCTAssertEqual(Bool.readValue(atPtr: buffer.baseAddress!, machineEndianness), true)
        
        buffer.copyBytes(from: [0x56])
        
        XCTAssertEqual(Bool.readValue(atPtr: buffer.baseAddress!, machineEndianness), false)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(Bool.readFromItem(atPtr: buffer.baseAddress!, machineEndianness), true)
        
        buffer.copyBytes(from: [0])
        
        XCTAssertEqual(Bool.readFromElement(atPtr: buffer.baseAddress!, machineEndianness), false)
    }


}
