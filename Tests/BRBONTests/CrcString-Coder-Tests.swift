//
//  CrcString-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 02/03/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class CrcString_Coder_Tests: XCTestCase {

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
        
        var s = CrcString("test") // 0x74 0x65 0x73 0x74
        
        
        // Properties
        
        XCTAssertEqual(s.itemType, ItemType.crcString)
        XCTAssertEqual(s.valueByteCount, 12)
        
        
        // Buffer
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        _ = Darwin.memset(buffer.baseAddress, 0, 100)
        defer { buffer.deallocate() }


        // Store value

        s.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 12, deallocator: Data.Deallocator.none)
        
        var exp = Data(bytes: [
            0x0C, 0x7E, 0x7F, 0xD8,
            0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74
            ])
        
        XCTAssertEqual(data, exp)

        
        // Read value
        
        buffer.copyBytes(from: [
            0x0C, 0x7E, 0x7F, 0xD8,
            0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74
            ])
        
        let str = CrcString(fromPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(str.string, "test")

        
        // Store as item, no name, no initialValueByteCount
        
        s.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0E, 0x00, 0x00, 0x00,  0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,

            0x0C, 0x7E, 0x7F, 0xD8,  0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74,  0x00, 0x00, 0x00, 0x00
            ])
        data.printBytes()
        XCTAssertEqual(data, exp)

        
        // Store as item, no name, initialValueByteCount = 18
        
        s.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, initialValueByteCount: 18, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0E, 0x00, 0x00, 0x00,  0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,
            
            0x0C, 0x7E, 0x7F, 0xD8,  0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)

        
        // The name field to be used
        
        let name = NameField("one")
        
        
        // Store as item, name = "one", no initialValueByteCount

        s.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0E, 0x00, 0x00, 0x08,  0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,

            0xdc, 0x56, 0x03, 0x6F,  0x6E, 0x65, 0x00, 0x00,
            0x0C, 0x7E, 0x7F, 0xD8,  0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74,  0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item, name = "one", initialValueByteCount = 18

        s.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, initialValueByteCount: 18, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 48, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0E, 0x00, 0x00, 0x08,  0x30, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,
            
            0xdc, 0x56, 0x03, 0x6F,  0x6E, 0x65, 0x00, 0x00,
            0x0C, 0x7E, 0x7F, 0xD8,  0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
    }
}
