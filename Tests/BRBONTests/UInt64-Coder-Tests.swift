//
//  UInt64-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class UInt64_Coder_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test() {
        
        
        // Instance
        
        let i: UInt64 = 0x1122334455667788
        
        
        // Properties
        
        XCTAssertEqual(i.itemType, ItemType.uint64)
        XCTAssertEqual(i.valueByteCount, 8)
        
        
        // Buffer
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        _ = Darwin.memset(buffer.baseAddress, 0, 100)
        defer { buffer.deallocate() }
        
        
        // Store value
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt64.self).pointee, 0x1122334455667788)
        
        
        // Read value
        
        buffer.copyBytes(from: [0x07, 0x07, 0x07, 0x07, 0x01, 0x01, 0x01, 0x01])
        
        XCTAssertEqual(UInt64(fromPtr: buffer.baseAddress!, machineEndianness), 0x0101010107070707)

        
        // Store as item, no name, no initialValueByteCount

        i.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        var exp = Data(bytes: [
            0x0A, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11
            ])

        XCTAssertEqual(data, exp)
        
        
        // Store as item, no name, initialValueByteCount = 10

        i.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, initialValueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0A, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11,
            0, 0, 0, 0, 0, 0, 0, 0
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // The name field to be used
        
        let name = NameField("one")
        
        
        // Store as item, name = "one", no initialValueByteCount

        i.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0A, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x88, 0x77, 0x66, 0x55,
            0x44, 0x33, 0x22, 0x11
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item, name = "one", initialValueByteCount= 10

        i.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, initialValueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0A, 0x00, 0x00, 0x08,
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
        
        XCTAssertEqual(data, exp)
    }
}
