//
//  UInt64-BrbonCoder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class UInt64_BrbonCoder_Tests: XCTestCase {

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
        
        let i: UInt64 = 0x1122334455667788
        
        
        // Properties
        
        XCTAssertEqual(i.brbonType, ItemType.uint64)
        XCTAssertEqual(i.valueByteCount, 8)
        XCTAssertEqual(i.itemByteCount(), 24)
        XCTAssertEqual(i.elementByteCount, 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt64.self).pointee, 0x1122334455667788)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x02, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11
            ])

        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x02, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11,
            0, 0, 0, 0, 0, 0, 0, 0
            ])
        
        XCTAssertEqual(data, exp2)
        
        i.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt64.self).pointee, 0x1122334455667788)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07, 0x07, 0x07, 0x07, 0x01, 0x01, 0x01, 0x01])
        
        XCTAssertEqual(UInt64(valuePtr: buffer.baseAddress!, machineEndianness), 0x0101010107070707)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(UInt64(itemPtr: buffer.baseAddress!, machineEndianness), 0x1122334455667788)
        
        buffer.copyBytes(from: [0x10, 0x10, 0x10, 0x10, 0x11, 0x11, 0x11, 0x11])
        
        XCTAssertEqual(UInt64(elementPtr: buffer.baseAddress!, machineEndianness), 0x1111111110101010)
    }
    
    func test_WithNameField() {
        
        
        // Instance
        
        let i: UInt64 = 0x1122334455667788
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")
        
        
        // Properties
        
        XCTAssertEqual(i.brbonType, ItemType.uint64)
        XCTAssertEqual(i.valueByteCount, 8)
        XCTAssertEqual(i.itemByteCount(nfd), 32)
        XCTAssertEqual(i.elementByteCount, 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt64.self).pointee, 0x1122334455667788)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x02, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11
            ])
        
        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x02, 0x00, 0x00, 0x08,
            0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        i.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt64.self).pointee, 0x1122334455667788)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07, 0x07, 0x07, 0x07, 0x01, 0x01, 0x01, 0x01])
        
        XCTAssertEqual(UInt64(valuePtr: buffer.baseAddress!, machineEndianness), 0x0101010107070707)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(UInt64(itemPtr: buffer.baseAddress!, machineEndianness), 0x1122334455667788)
        
        buffer.copyBytes(from: [0x10, 0x10, 0x10, 0x10, 0x11, 0x11, 0x11, 0x11])
        
        XCTAssertEqual(UInt64(elementPtr: buffer.baseAddress!, machineEndianness), 0x1111111110101010)
    }
}
