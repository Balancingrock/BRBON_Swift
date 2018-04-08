//
//  Data-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Data_Coder_Tests: XCTestCase {

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
        
        let d = Data(bytes: [0x10, 0x22, 0x03])
        
        
        // Properties
        
        XCTAssertEqual(d.itemType, ItemType.binary)
        XCTAssertEqual(d.valueByteCount, 7)
        
        
        // Buffer
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store value
        
        d.storeValue(atPtr: buffer.baseAddress!, machineEndianness)
        
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: 7, deallocator: Data.Deallocator.none)
        
        var exp = Data(bytes: [ 0x03, 0x00, 0x00, 0x00, 0x10, 0x22, 0x03 ])
        
        XCTAssertEqual(data, exp)
        
        
        // Read value
        
        buffer.copyBytes(from: [0x02, 0x00, 0x00, 0x00, 0x07, 0x80])
        
        data = Data(fromPtr: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(data, Data(bytes: [0x07, 0x80]))

        
        // Store as item, no name, no initialValueByteCount
        
        d.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 24, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0F, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00,
            0x10, 0x22, 0x03, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        
        
        // Store as item, no name, initialValueByteCount = 10

        d.storeAsItem(atPtr: buffer.baseAddress!, parentOffset: 0x12345678, initialValueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0F, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00,
            0x10, 0x22, 0x03, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        

        // The name field to be used
        
        let name = NameField("one")
        
        
        // Store as item, name = "one", no initialValueByteCount

        d.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, initialValueByteCount: nil, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0F, 0x00, 0x00, 0x08,
            0x20, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00,
            0x10, 0x22, 0x03, 0x00
            ])
        
        XCTAssertEqual(data, exp)
        

        // Store as item, name = "one", initialValueByteCount = 10

        d.storeAsItem(atPtr: buffer.baseAddress!, name: name, parentOffset: 0x12345678, initialValueByteCount: 10, machineEndianness)
        
        data = Data(bytesNoCopy: buffer.baseAddress!, count: 40, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x0F, 0x00, 0x00, 0x08,
            0x28, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00,
            0x10, 0x22, 0x03, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
    }
}
