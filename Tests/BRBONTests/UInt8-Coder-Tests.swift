//
//  UInt8-BrbonCoder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 06/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class UInt8_BrbonCoder_Tests: XCTestCase {

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

        let i: UInt8 = 5
        
        
        // Properties

        XCTAssertEqual(i.brbonType, ItemType.uint8)
        XCTAssertEqual(i.valueByteCount, 1)
        XCTAssertEqual(i.itemByteCount(), 16)
        XCTAssertEqual(i.elementByteCount, 1)
        
        
        // Storing

        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 5)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x85, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x05, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), valueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x85, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x05, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)

        i.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 5)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07])
        
        XCTAssertEqual(UInt8(valuePtr: buffer.baseAddress!, machineEndianness), 7)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(UInt8(itemPtr: buffer.baseAddress!, machineEndianness), 5)
        
        buffer.copyBytes(from: [1])
        
        XCTAssertEqual(UInt8(elementPtr: buffer.baseAddress!, machineEndianness), 1)

    }

    func test_WithNameField() {
        
        
        // Instance
        
        let i: UInt8 = 5
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")

        
        // Properties
        
        XCTAssertEqual(i.brbonType, ItemType.uint8)
        XCTAssertEqual(i.valueByteCount, 1)
        XCTAssertEqual(i.itemByteCount(nfd), 24)
        XCTAssertEqual(i.elementByteCount, 1)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 5)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x85, 0x00, 0x00, 0x08,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x05, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, valueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)

        let exp2 = Data(bytes: [
            0x85, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x05, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)

        i.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 5)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07])
        
        XCTAssertEqual(UInt8(valuePtr: buffer.baseAddress!, machineEndianness), 7)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(UInt8(itemPtr: buffer.baseAddress!, machineEndianness), 5)
        
        buffer.copyBytes(from: [1])
        
        XCTAssertEqual(UInt8(elementPtr: buffer.baseAddress!, machineEndianness), 1)
    }
}
