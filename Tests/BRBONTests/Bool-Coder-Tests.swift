//
//  Bool-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 06/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Bool_Coder_Tests: XCTestCase {

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
        
        var b: Bool = true
        
        
        // Properties
        
        XCTAssertEqual(b.itemType, .bool)
        XCTAssertEqual(b.valueByteCount, 1)

        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        _ = Darwin.memset(buffer.baseAddress, 0, 100)
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 1)
        
        
        // Store as item without name, with initial byte count
        
        b.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)
        
        var exp = Data(bytes: [
            0x02, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x01, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item without name, with initial byte count 5
        
        b.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, initialValueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x02, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x01, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Change value
        
        b = true
        
        
        // The name field to be used
        
        let name = NameField("one")
        
        
        // Store as item with name, without initial byte count
        
        b.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)

        exp = Data(bytes: [
            0x02, 0x00, 0x00, 0x08,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x01, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item with name and initial byte count 5
        
        b.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, initialValueByteCount: 5, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)

        exp = Data(bytes: [
            0x02, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x01, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        data.printBytes()

        XCTAssertEqual(data, exp)
        
        
        // Reading
        
        buffer.copyBytes(from: [0x00])
        
        XCTAssertEqual(Bool(fromPtr: buffer.baseAddress!, machineEndianness), false)
        
        buffer.copyBytes(from: [0x01])
        
        XCTAssertEqual(Bool(fromPtr: buffer.baseAddress!, machineEndianness), true)
        
        buffer.copyBytes(from: [0x56])
        
        XCTAssertEqual(Bool(fromPtr: buffer.baseAddress!, machineEndianness), true)
    }
}
