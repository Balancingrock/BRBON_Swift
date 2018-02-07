//
//  Float64-BrbonCoder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Float64_BrbonCoder_Tests: XCTestCase {

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
        
        let i: Float64 = 1.23
        
        
        // Properties
        
        XCTAssertEqual(i.brbonType, ItemType.float64)
        XCTAssertEqual(i.valueByteCount, 8)
        XCTAssertEqual(i.itemByteCount(), 24)
        XCTAssertEqual(i.elementByteCount, 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Float64.self).pointee, 1.23)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)

        let exp = Data(bytes: [
            0x03, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xae, 0x47, 0xe1, 0x7a,
            0x14, 0xae, 0xf3, 0x3f
            ])
        
        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)

        let exp2 = Data(bytes: [
            0x03, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xae, 0x47, 0xe1, 0x7a,
            0x14, 0xae, 0xf3, 0x3f,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        i.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Float64.self).pointee, 1.23)
        
        
        // Reading
        
        buffer.copyBytes(from: [0xae, 0x47, 0xe1, 0x7a, 0x14, 0xae, 0xf3, 0x3f])
        
        XCTAssertEqual(Float64.readValue(atPtr: buffer.baseAddress!, machineEndianness), 1.23)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(Float64.readFromItem(atPtr: buffer.baseAddress!, machineEndianness), 1.23)
        
        buffer.copyBytes(from: [0xae, 0x47, 0xe1, 0x7a, 0x14, 0xae, 0xf3, 0x3f])
        
        XCTAssertEqual(Float64.readFromElement(atPtr: buffer.baseAddress!, machineEndianness), 1.23)
    }
    
    func test_WithNameField() {
        
        
        // Instance
        
        let i: Float64 = 1.23
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")
        
        
        // Properties
        
        XCTAssertEqual(i.brbonType, ItemType.float64)
        XCTAssertEqual(i.valueByteCount, 8)
        XCTAssertEqual(i.itemByteCount(nfd), 32)
        XCTAssertEqual(i.elementByteCount, 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Float64.self).pointee, 1.23)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, nameField: nfd, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        data.printBytes()
        let exp = Data(bytes: [
            0x03, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0xae, 0x47, 0xe1, 0x7a,
            0x14, 0xae, 0xf3, 0x3f,
            ])
        
        XCTAssertEqual(data, exp)
        
        i.storeAsItem(atPtr: buffer.baseAddress!, nameField: nfd, parentOffset: 0x12345678, valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x03, 0x00, 0x00, 0x08,
            0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0xae, 0x47, 0xe1, 0x7a,
            0x14, 0xae, 0xf3, 0x3f,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        i.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: Float64.self).pointee, 1.23)
        
        
        // Reading
        
        buffer.copyBytes(from: [0xae, 0x47, 0xe1, 0x7a, 0x14, 0xae, 0xf3, 0x3f])
        
        XCTAssertEqual(Float64.readValue(atPtr: buffer.baseAddress!, machineEndianness), 1.23)
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(Float64.readFromItem(atPtr: buffer.baseAddress!, machineEndianness), 1.23)
        
        buffer.copyBytes(from: [0xae, 0x47, 0xe1, 0x7a, 0x14, 0xae, 0xf3, 0x3f])
        
        XCTAssertEqual(Float64.readFromElement(atPtr: buffer.baseAddress!, machineEndianness), 1.23)
    }
}
