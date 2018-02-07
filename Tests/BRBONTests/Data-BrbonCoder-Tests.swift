//
//  Data-BrbonCoder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Data_BrbonCoder_Tests: XCTestCase {

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
        
        let d = Data(bytes: [0x10, 0x22, 0x03])
        
        
        // Properties
        
        XCTAssertEqual(d.brbonType, ItemType.binary)
        XCTAssertEqual(d.valueByteCount, 3)
        XCTAssertEqual(d.itemByteCount(), 24)
        XCTAssertEqual(d.elementByteCount, 7)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        d.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 0x10)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 1).assumingMemoryBound(to: UInt8.self).pointee, 0x22)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 2).assumingMemoryBound(to: UInt8.self).pointee, 0x03)
        
        d.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x44, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x03, 0x00, 0x00, 0x00,
            0x10, 0x22, 0x03, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        d.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x44, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x03, 0x00, 0x00, 0x00,
            0x10, 0x22, 0x03, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        d.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt32.self).pointee, 3)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 4).assumingMemoryBound(to: UInt8.self).pointee, 0x10)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 5).assumingMemoryBound(to: UInt8.self).pointee, 0x22)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 6).assumingMemoryBound(to: UInt8.self).pointee, 0x03)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07, 0x80])
        
        data = Data.readValue(atPtr: buffer.baseAddress!, count: 2, machineEndianness)
        XCTAssertEqual(data, Data(bytes: [0x07, 0x80]))
        
        buffer.copyBytes(from: exp)
        
        data = Data.readFromItem(atPtr: buffer.baseAddress!, machineEndianness)
        XCTAssertEqual(data, Data(bytes: [0x10, 0x22, 0x03]))
        
        buffer.copyBytes(from: [0x02, 0, 0, 0, 0x07, 0x80])
        
        data = Data.readFromElement(atPtr: buffer.baseAddress!, machineEndianness)
        XCTAssertEqual(data, Data(bytes: [0x07, 0x80]))
    }
    
    func test_WithNameField() {
        
        
        // Instance
        
        let d = Data(bytes: [0x10, 0x22, 0x03])
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")
        
        
        // Properties
        
        XCTAssertEqual(d.brbonType, ItemType.binary)
        XCTAssertEqual(d.valueByteCount, 3)
        XCTAssertEqual(d.itemByteCount(nfd), 32)
        XCTAssertEqual(d.elementByteCount, 7)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        d.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 0x10)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 1).assumingMemoryBound(to: UInt8.self).pointee, 0x22)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 2).assumingMemoryBound(to: UInt8.self).pointee, 0x03)
        
        d.storeAsItem(atPtr: buffer.baseAddress!, nameField: nfd, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x44, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x03, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x10, 0x22, 0x03, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        d.storeAsItem(atPtr: buffer.baseAddress!, nameField: nfd, parentOffset: 0x12345678, valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x44, 0x00, 0x00, 0x08,
            0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x03, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x10, 0x22, 0x03, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        d.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt32.self).pointee, 3)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 4).assumingMemoryBound(to: UInt8.self).pointee, 0x10)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 5).assumingMemoryBound(to: UInt8.self).pointee, 0x22)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 6).assumingMemoryBound(to: UInt8.self).pointee, 0x03)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x07, 0x80])
        
        data = Data.readValue(atPtr: buffer.baseAddress!, count: 2, machineEndianness)
        XCTAssertEqual(data, Data(bytes: [0x07, 0x80]))
        
        buffer.copyBytes(from: exp)
        
        data = Data.readFromItem(atPtr: buffer.baseAddress!, machineEndianness)
        XCTAssertEqual(data, Data(bytes: [0x10, 0x22, 0x03]))
        
        buffer.copyBytes(from: [0x02, 0, 0, 0, 0x07, 0x80])
        
        data = Data.readFromElement(atPtr: buffer.baseAddress!, machineEndianness)
        XCTAssertEqual(data, Data(bytes: [0x07, 0x80]))
    }
}
