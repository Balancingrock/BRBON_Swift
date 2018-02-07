//
//  Int64-BrbonCoder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Int64_BrbonCoder_Tests: XCTestCase {

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
        
        let i: Int64 = 0x1122334455667788
        
        
        // Properties
        
        XCTAssertEqual(i.brbonType, ItemType.int64)
        XCTAssertEqual(i.valueByteCount, 8)
        XCTAssertEqual(i.itemByteCount(), 24)
        XCTAssertEqual(i.elementByteCount, 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Int64.self).pointee, 0x1122334455667788)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x01, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11
            ])
        data.printBytes()
        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x01, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11,
            0, 0, 0, 0, 0, 0, 0, 0
            ])
        
        XCTAssertEqual(data, exp2)
        
        i.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Int64.self).pointee, 0x1122334455667788)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07, 0x07, 0x07, 0x07, 0x01, 0x01, 0x01, 0x01])
        
        XCTAssertEqual(Int64.readValue(atPtr: buffer.baseAddress!, machineEndianness), 0x0101010107070707)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(Int64.readFromItem(atPtr: buffer.baseAddress!, machineEndianness), 0x1122334455667788)
        
        buffer.copyBytes(from: [0x10, 0x10, 0x10, 0x10, 0x11, 0x11, 0x11, 0x11])
        
        XCTAssertEqual(Int64.readFromElement(atPtr: buffer.baseAddress!, machineEndianness), 0x1111111110101010)
    }
    
    func test_WithNameField() {
        
        
        // Instance
        
        let i: Int64 = 0x1122334455667788
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")
        
        
        // Properties
        
        XCTAssertEqual(i.brbonType, ItemType.int64)
        XCTAssertEqual(i.valueByteCount, 8)
        XCTAssertEqual(i.itemByteCount(nfd), 32)
        XCTAssertEqual(i.elementByteCount, 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Int64.self).pointee, 0x1122334455667788)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, nameField: nfd, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x01, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11
            ])
        
        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, nameField: nfd, parentOffset: 0x12345678, valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x01, 0x00, 0x00, 0x08,
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
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Int64.self).pointee, 0x1122334455667788)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07, 0x07, 0x07, 0x07, 0x01, 0x01, 0x01, 0x01])
        
        XCTAssertEqual(Int64.readValue(atPtr: buffer.baseAddress!, machineEndianness), 0x0101010107070707)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(Int64.readFromItem(atPtr: buffer.baseAddress!, machineEndianness), 0x1122334455667788)
        
        buffer.copyBytes(from: [0x10, 0x10, 0x10, 0x10, 0x11, 0x11, 0x11, 0x11])
        
        XCTAssertEqual(Int64.readFromElement(atPtr: buffer.baseAddress!, machineEndianness), 0x1111111110101010)
    }
}
