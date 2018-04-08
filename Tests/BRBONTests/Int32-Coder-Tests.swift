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

    func test() {
        
        
        // Instance
        
        let i: Int32 = 0x01020304
        
        
        // Properties
        
        XCTAssertEqual(i.itemType, ItemType.int32)
        XCTAssertEqual(i.valueByteCount, 4)
        
        
        // Buffer
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        i.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt32.self).pointee, 0x01020304)
        
        
        // Read
        
        buffer.copyBytes(from: [0x07, 0x07, 0x07, 0x07])
        
        XCTAssertEqual(Int32(fromPtr: buffer.baseAddress!, machineEndianness), 0x07070707)

        
        // Store as item without name, without initial byte count

        i.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)
        
        var exp = Data(bytes: [
            0x05, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x04, 0x03, 0x02, 0x01
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item without name, with initial byte count 5

        i.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, initialValueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x05, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x04, 0x03, 0x02, 0x01,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // The name field to be used
        
        let name = NameField("one")
        
        
        // Store as item with name, without initial byte count

        i.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x05, 0x00, 0x00, 0x08,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x04, 0x03, 0x02, 0x01,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item with name, with initial byte count 5

        i.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, initialValueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x05, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x04, 0x03, 0x02, 0x01,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
    }
}
