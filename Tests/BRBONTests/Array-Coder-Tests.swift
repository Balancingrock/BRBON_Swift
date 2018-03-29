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

    func test_1() {
        
        
        // Instance
        
        let ia: Array<Int8> = [1, 2, 3, 4, 5]
        let a = BrbonArray(content: ia, type: ItemType.int8)
        
        
        // Properties
        
        XCTAssertEqual(a.itemType, ItemType.array)
        XCTAssertEqual(a.valueByteCount, 21)
        
        
        // Buffer
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        _ = Darwin.memset(buffer.baseAddress, 0, 100)
        defer { buffer.deallocate() }
        
        
        // Store as item, no name, no initialValueByteCount
        
        a.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)

        var exp = Data(bytes: [
            0x11, 0x00, 0x00, 0x00,  0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,

            0x00, 0x00, 0x00, 0x00,  0x03, 0x00, 0x00, 0x00,
            0x05, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            0x01, 0x02, 0x03, 0x04,  0x05, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item, no name, initialValueByteCount = 25

        a.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, initialValueByteCount: 25, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 48, deallocator: Data.Deallocator.none)

        exp = Data(bytes: [
            0x11, 0x00, 0x00, 0x00,  0x30, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,

            0x00, 0x00, 0x00, 0x00,  0x03, 0x00, 0x00, 0x00,
            0x05, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            0x01, 0x02, 0x03, 0x04,  0x05, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)

        
        // The name field to be used
        
        let name = NameField("one")
        
        
        // Store as item, name = "one", no initialValueByteCount
        
        a.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 48, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x11, 0x00, 0x00, 0x08,  0x30, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,

            0xdc, 0x56, 0x03, 0x6F,  0x6E, 0x65, 0x00, 0x00,

            0x00, 0x00, 0x00, 0x00,  0x03, 0x00, 0x00, 0x00,
            0x05, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            0x01, 0x02, 0x03, 0x04,  0x05, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item, name = "one", initialValueByteCount = 25

        a.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, initialValueByteCount: 25, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 56, deallocator: Data.Deallocator.none)

        exp = Data(bytes: [
            0x11, 0x00, 0x00, 0x08,  0x38, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,
            
            0xdc, 0x56, 0x03, 0x6F,  0x6E, 0x65, 0x00, 0x00,

            0x00, 0x00, 0x00, 0x00,  0x03, 0x00, 0x00, 0x00,
            0x05, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            0x01, 0x02, 0x03, 0x04,  0x05, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
    }
    
    func test_varLengthElements() {
        
        
        // Instance
        
        let ia: Array<String> = ["aa", "bbbbbbb", "ccccccccc"]
        let a = BrbonArray(content: ia, type: ItemType.string)
        
        
        // Properties
        
        XCTAssertEqual(a.itemType, ItemType.array)
        XCTAssertEqual(a.valueByteCount, 64)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        _ = Darwin.memset(buffer.baseAddress, 0, 100)
        defer { buffer.deallocate() }
        
        
        // Store as item
        
        a.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 80, deallocator: Data.Deallocator.none)

        let exp = Data(bytes: [
            0x11, 0x00, 0x00, 0x00,  0x50, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,

            0x00, 0x00, 0x00, 0x00,  0x0D, 0x00, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00,  0x10, 0x00, 0x00, 0x00,
            
            0x02, 0x00, 0x00, 0x00,  0x61, 0x61, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x07, 0x00, 0x00, 0x00,  0x62, 0x62, 0x62, 0x62,
            0x62, 0x62, 0x62, 0x00,  0x00, 0x00, 0x00, 0x00,

            0x09, 0x00, 0x00, 0x00,  0x63, 0x63, 0x63, 0x63,
            0x63, 0x63, 0x63, 0x63,  0x63, 0x00, 0x00, 0x00,
            ])

        XCTAssertEqual(data, exp)
    }
}
