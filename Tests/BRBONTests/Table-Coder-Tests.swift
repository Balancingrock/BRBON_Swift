//
//  Table-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 04/03/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Table_Coder_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_1() {

        let t = BrbonTable(columnSpecifications: [])
        
        // Properties
        
        XCTAssertEqual(t.itemType, ItemType.table)
        XCTAssertEqual(t.valueByteCount, 16)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }

        
        // Store as item
        
        XCTAssertEqual(t.storeAsItem(atPtr: buffer.baseAddress!, options: ItemOptions.none, flags: ItemFlags.none, nameField: nil, parentOffset: 0, initialValueByteCount: nil, machineEndianness), Result.success)
        
        let exp = Data(bytes: [
            0x46, 0x00, 0x00, 0x00,  0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
        ])
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 32, deallocator: Data.Deallocator.none)
        data.printBytes()
        XCTAssertEqual(exp, data)
    }
    
    func test_2() {
        
        let col = ColumnSpecification(fieldType: .bool, nameFieldDescriptor: NameFieldDescriptor("aaa")!, initialValueByteCount: 8)
        let t = BrbonTable(columnSpecifications: [col])
        
        // Properties
        
        XCTAssertEqual(t.itemType, ItemType.table)
        XCTAssertEqual(t.valueByteCount, 16 + 16 + 8)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        
        // Store as item
        
        XCTAssertEqual(t.storeAsItem(atPtr: buffer.baseAddress!, options: ItemOptions.none, flags: ItemFlags.none, nameField: nil, parentOffset: 0, initialValueByteCount: nil, machineEndianness), Result.success)
        
        let exp = Data(bytes: [
            0x46, 0x00, 0x00, 0x00,  0x38, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            0x28, 0x00, 0x00, 0x00,  0x08, 0x00, 0x00, 0x00,
            
            0xb9, 0xa6, 0x08, 0x81,  0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x08, 0x00, 0x00, 0x00,
            
            0x03, 0x61, 0x61, 0x61
            ])
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 52, deallocator: Data.Deallocator.none)
        
        XCTAssertEqual(exp, data)
    }

}
