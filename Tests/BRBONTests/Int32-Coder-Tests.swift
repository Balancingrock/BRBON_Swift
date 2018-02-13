//
//  Int32-BrbonCoder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Int32_BrbonCoder_Tests: XCTestCase {

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
        
        let i: Int32 = 0x01020304
        
        
        // Properties
        
        XCTAssertEqual(i.brbonType, ItemType.int32)
        XCTAssertEqual(i.valueByteCount, 4)
        XCTAssertEqual(i.itemByteCount(), 16)
        XCTAssertEqual(i.elementByteCount, 4)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt32.self).pointee, 0x01020304)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x84, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x04, 0x03, 0x02, 0x01
            ])
        
        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), valueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x84, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x04, 0x03, 0x02, 0x01,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        i.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Int32.self).pointee, 0x01020304)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07, 0x07, 0x07, 0x07])
        
        XCTAssertEqual(Int32(valuePtr: buffer.baseAddress!, machineEndianness), 0x07070707)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(Int32(itemPtr: buffer.baseAddress!, machineEndianness), 0x01020304)
        
        buffer.copyBytes(from: [0x04, 0x04, 0x55, 0x55])
        
        XCTAssertEqual(Int32(elementPtr: buffer.baseAddress!, machineEndianness), 0x55550404)
    }
    
    func test_WithNameField() {
        
        
        // Instance
        
        let i: Int32 = 0x01020304
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")
        
        
        // Properties
        
        XCTAssertEqual(i.brbonType, ItemType.int32)
        XCTAssertEqual(i.valueByteCount, 4)
        XCTAssertEqual(i.itemByteCount(nfd), 24)
        XCTAssertEqual(i.elementByteCount, 4)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Int32.self).pointee, 0x01020304)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x84, 0x00, 0x00, 0x08,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x04, 0x03, 0x02, 0x01,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, valueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x84, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x04, 0x03, 0x02, 0x01,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        i.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Int32.self).pointee, 0x01020304)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07, 0x07, 0x07, 0x07])
        
        XCTAssertEqual(Int32(valuePtr: buffer.baseAddress!, machineEndianness), 0x07070707)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(Int32(itemPtr: buffer.baseAddress!, machineEndianness), 0x01020304)
        
        buffer.copyBytes(from: [0x04, 0x04, 0x55, 0x55])
        
        XCTAssertEqual(Int32(elementPtr: buffer.baseAddress!, machineEndianness), 0x55550404)
    }
}
