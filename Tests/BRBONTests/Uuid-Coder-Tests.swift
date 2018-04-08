//
//  Uuid-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 31/03/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class Uuid_Coder_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        
        
        // Instance
        
        let u = UUID(uuidString: "01234567-1234-1234-1234-123456789011")!
        
        
        // Properties
        
        XCTAssertEqual(u.itemType, ItemType.uuid)
        XCTAssertEqual(u.valueByteCount, 16)
        
        
        // Buffer
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store value
        
        u.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)
        
        var exp = Data(bytes: [0x1, 0x23, 0x45, 0x67, 0x12, 0x34, 0x12, 0x34, 0x12, 0x34, 0x12, 0x34, 0x56, 0x78, 0x90, 0x11])
        
        XCTAssertEqual(data, exp)
        
        
        // Read value
        
        buffer.copyBytes(from: exp)
        
        XCTAssertEqual(UUID(fromPtr: buffer.baseAddress!, machineEndianness), UUID(uuidString: "01234567-1234-1234-1234-123456789011")!)
        
        
        // Store as item, no name, no initialValueByteCount
        
        u.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x15, 0x00, 0x00, 0x00,  0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,
            
            0x01, 0x23, 0x45, 0x67,  0x12, 0x34, 0x12, 0x34,
            0x12, 0x34, 0x12, 0x34,  0x56, 0x78, 0x90, 0x11
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item, no name, initialValueByteCount = 5
        
        u.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, initialValueByteCount: 21, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x15, 0x00, 0x00, 0x00,  0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,
            
            0x01, 0x23, 0x45, 0x67,  0x12, 0x34, 0x12, 0x34,
            0x12, 0x34, 0x12, 0x34,  0x56, 0x78, 0x90, 0x11,
            
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // The name field to be used
        
        let name = NameField("one")
        
        
        // Store as item, name = "one", no initialValueByteCount
        
        u.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x15, 0x00, 0x00, 0x08,  0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,
            
            0xdc, 0x56, 0x03, 0x6F,  0x6E, 0x65, 0x00, 0x00,

            0x01, 0x23, 0x45, 0x67,  0x12, 0x34, 0x12, 0x34,
            0x12, 0x34, 0x12, 0x34,  0x56, 0x78, 0x90, 0x11
            ])

        XCTAssertEqual(data, exp)
        
        
        // Store as item, name = "one", initialValueByteCount = 5
        
        u.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, initialValueByteCount: 21, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 48, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x15, 0x00, 0x00, 0x08,  0x30, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,  0x00, 0x00, 0x00, 0x00,
            
            0xdc, 0x56, 0x03, 0x6F,  0x6E, 0x65, 0x00, 0x00,
            
            0x01, 0x23, 0x45, 0x67,  0x12, 0x34, 0x12, 0x34,
            0x12, 0x34, 0x12, 0x34,  0x56, 0x78, 0x90, 0x11,
            
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
    }
}
