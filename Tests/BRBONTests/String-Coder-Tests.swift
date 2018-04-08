//
//  String-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class String_Coder_Tests: XCTestCase {

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
        
        var s = "test" // 0x74 0x65 0x73 0x74
        
        
        // Properties
        
        XCTAssertEqual(s.itemType, ItemType.string)
        XCTAssertEqual(s.valueByteCount, 8)
        
        
        // Buffer
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store value
        
        s.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 8, deallocator: Data.Deallocator.none)
        
        var exp = Data(bytes: [
            0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74,
            ])

        XCTAssertEqual(data, exp)

        
        // Read value
        
        buffer.copyBytes(from: [0x04, 0x00, 0x00, 0x00, 0x74, 0x65, 0x73, 0x74])
        
        let str = String(fromPtr: buffer.baseAddress!, machineEndianness)
        XCTAssertEqual(str, "test")

        
        // Store as item, no name, no initialValueByteCount

        s.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)

        exp = Data(bytes: [
            0x0D, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item, no name, initialValueByteCount = 10

        s.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, initialValueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        let exp2 = Data(bytes: [
            0x0D, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00,
            0x74, 0x65, 0x73, 0x74,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp2)
        
        
        // Instance
        
        s = "testtest" // 0x74 0x65 0x73 0x74 0x74 0x65 0x73 0x74
        
        
        // The name field to be used
        
        let name = NameField("one")
        

        // Store as item, name = "one", no initialValueByteCount

        s.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0D, 0x00, 0x00, 0x08,  0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,
            
            0xdc, 0x56, 0x03, 0x6F,  0x6E, 0x65, 0x00, 0x00,
            
            0x08, 0x00, 0x00, 0x00,  0x74, 0x65, 0x73, 0x74,
            0x74, 0x65, 0x73, 0x74,  0x00, 0x00, 0x00, 0x00
            ])

        XCTAssertEqual(data, exp)
        
        
        // Store as item, name = "one", initialValueByteCount = 17

        s.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, initialValueByteCount: 17, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 48, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0D, 0x00, 0x00, 0x08,  0x30, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,
            
            0xdc, 0x56, 0x03, 0x6F,  0x6E, 0x65, 0x00, 0x00,
            
            0x08, 0x00, 0x00, 0x00,  0x74, 0x65, 0x73, 0x74,
            0x74, 0x65, 0x73, 0x74,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
    }
}
