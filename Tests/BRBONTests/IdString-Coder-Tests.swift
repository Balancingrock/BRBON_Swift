//
//  IdString-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 02/03/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class IdString_Coder_Tests: XCTestCase {

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
        
        let s = BrbonString("test") // 0x74 0x65 0x73 0x74
        
        
        // Properties
        
        XCTAssertEqual(s.brbonType, ItemType.brbonString)
        XCTAssertEqual(s.valueByteCount, 10)
        XCTAssertEqual(s.itemByteCount(), 32)
        XCTAssertEqual(s.elementByteCount, 16)
        
        
        // Store as value
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        XCTAssertEqual(s.storeValue(atPtr: buffer.baseAddress!, machineEndianness), .success)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 10, deallocator: Data.Deallocator.none)
        
        var exp = Data(bytes: [
            0x04, 0x00, 0x00, 0x00,
            0x2e, 0xf8, 0x74, 0x65,
            0x73, 0x74
            ])
        
        XCTAssertEqual(data, exp)

        
        // Store as item
        
        XCTAssertEqual(s.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), machineEndianness), .success)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 26, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x45, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00,
            0x2e, 0xf8, 0x74, 0x65,
            0x73, 0x74
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item
        
        s.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 10, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x04, 0x00, 0x00, 0x00,
            0x2e, 0xf8, 0x74, 0x65,
            0x73, 0x74
            ])
        
        XCTAssertEqual(data, exp)

        
        // Reading as value
        
        buffer.copyBytes(from: [
            0x04, 0x00, 0x00, 0x00,
            0x2e, 0xf8, 0x74, 0x65,
            0x73, 0x74
            ])
        
        var str = BrbonString(valuePtr: buffer.baseAddress!, count: 4, machineEndianness)
        XCTAssertEqual(str.string, "test")
        
        
        // Reading as item
        
        buffer.copyBytes(from: [
            0x40, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00,
            0x2e, 0xf8, 0x74, 0x65,
            0x73, 0x74, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        str = BrbonString(itemPtr: buffer.baseAddress!, machineEndianness)
        XCTAssertEqual(str.string, "test")
        
        
        // Reading as element
        
        buffer.copyBytes(from: [
            0x04, 0x00, 0x00, 0x00,
            0x2e, 0xf8, 0x74, 0x65,
            0x73, 0x74
            ])

        str = BrbonString(elementPtr: buffer.baseAddress!, machineEndianness)
        XCTAssertEqual(str.string, "test")
    }
    
    func test_WithNameField() {
        
        
        // Instance
        
        let s = "testtest" // 0x74 0x65 0x73 0x74 0x74 0x65 0x73 0x74
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")
        
        
        // Properties
        
        XCTAssertEqual(s.brbonType, ItemType.string)
        XCTAssertEqual(s.valueByteCount, 8)
        XCTAssertEqual(s.itemByteCount(), 24)
        XCTAssertEqual(s.elementByteCount, 16)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        s.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 0x74)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 1).assumingMemoryBound(to: UInt8.self).pointee, 0x65)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 2).assumingMemoryBound(to: UInt8.self).pointee, 0x73)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 3).assumingMemoryBound(to: UInt8.self).pointee, 0x74)
        
        s.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x40, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x08, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74,
            0x74, 0x65, 0x73, 0x74
            ])
        
        XCTAssertEqual(data, exp)
        
        s.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x40, 0x00, 0x00, 0x08,
            0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x08, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74,
            0x74, 0x65, 0x73, 0x74,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        s.storeAsElement(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt32.self).pointee, 8)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 4).assumingMemoryBound(to: UInt8.self).pointee, 0x74)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 5).assumingMemoryBound(to: UInt8.self).pointee, 0x65)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 6).assumingMemoryBound(to: UInt8.self).pointee, 0x73)
        XCTAssertEqual(buffer.baseAddress!.advanced(by: 7).assumingMemoryBound(to: UInt8.self).pointee, 0x74)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x74, 0x65, 0x73, 0x74, 0x74, 0x65, 0x73, 0x74])
        
        var str = String(valuePtr: buffer.baseAddress!, count: 8, machineEndianness)
        XCTAssertEqual(str, "testtest")
        
        buffer.copyBytes(from: exp)
        
        str = String(itemPtr: buffer.baseAddress!, machineEndianness)
        XCTAssertEqual(str, "testtest")
        
        buffer.copyBytes(from: [0x08, 0, 0, 0, 0x74, 0x65, 0x73, 0x74, 0x74, 0x65, 0x73, 0x74])
        
        str = String(elementPtr: buffer.baseAddress!, machineEndianness)
        XCTAssertEqual(str, "testtest")
    }
}
