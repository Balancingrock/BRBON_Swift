//
//  Array-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 13/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Array_Coder_Tests: XCTestCase {

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
        
        let ia: Array<Int8> = [1, 2, 3, 4, 5]
        let a = BrbonArray(content: ia, type: ItemType.int8)
        
        
        // Properties
        
        XCTAssertEqual(a.brbonType, ItemType.array)
        XCTAssertEqual(a.valueByteCount, 13)
        XCTAssertEqual(a.itemByteCount(), 32)
        XCTAssertEqual(a.elementByteCount, 32)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        var success = a.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), machineEndianness)
        
        XCTAssertEqual(success, .success)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)

        let exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x05, 0x00, 0x00, 0x00,
            0x82, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        success = a.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), valueByteCount: 10, machineEndianness)
        
        XCTAssertEqual(success, .success)

        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)

        let exp2 = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x05, 0x00, 0x00, 0x00,
            0x82, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
    }
    
    func test_WithNameField() {
        
        
        // Instance
        
        let ia: Array<Int8> = [1, 2, 3, 4, 5]
        let a = BrbonArray(content: ia, type: ItemType.int8)
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")
        
        
        // Properties
        
        XCTAssertEqual(a.brbonType, ItemType.array)
        XCTAssertEqual(a.valueByteCount, 13)
        XCTAssertEqual(a.itemByteCount(nfd), 40)
        XCTAssertEqual(a.elementByteCount, 32)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        a.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x08,
            0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x05, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x82, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        a.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, valueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 48, deallocator: Data.Deallocator.none)

        let exp2 = Data(bytes: [
            0x41, 0x00, 0x00, 0x08,
            0x30, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x05, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x82, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
    }
    
    func test_varLengthElements() {
        
        
        // Instance
        
        let ia: Array<String> = ["aa", "bbbbbbb", "ccccccccc"]
        let a = BrbonArray(content: ia, type: ItemType.string)
        
        
        // Properties
        
        XCTAssertEqual(a.brbonType, ItemType.array)
        XCTAssertEqual(a.valueByteCount, 56)
        XCTAssertEqual(a.itemByteCount(), 72)
        XCTAssertEqual(a.elementByteCount, 72)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        a.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 72, deallocator: Data.Deallocator.none)

        let exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x48, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x03, 0x00, 0x00, 0x00,
            0x40, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,
            0x02, 0x00, 0x00, 0x00,
            0x61, 0x61, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x07, 0x00, 0x00, 0x00,
            0x62, 0x62, 0x62, 0x62,
            0x62, 0x62, 0x62, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x09, 0x00, 0x00, 0x00,
            0x63, 0x63, 0x63, 0x63,
            0x63, 0x63, 0x63, 0x63,
            0x63, 0x00, 0x00, 0x00,
            ])
        
        XCTAssertEqual(data, exp)
    }
}
