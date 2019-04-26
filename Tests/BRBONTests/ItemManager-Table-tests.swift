//
//  ItemManager-Table-tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 08/03/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class ItemManager_Table_tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This me[]thod is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_1() {

        ItemManager.startWithZeroedBuffers = true
        
        // Create a table
        
        var columns: Array<ColumnSpecification> = []
        let tm = ItemManager.createTableManager(columns: &columns, endianness: Endianness.little)
        
        var exp = Data([
            0x14, 0x00, 0x00, 0x00,  0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafeRawBufferPointer) -> () in
            let p = tm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr.baseAddress!))
            XCTAssertTrue(p == tm.root)
        }
        
        
        // Add a column
        
        XCTAssertEqual(tm.root.addColumn(type: .bool, nameField: NameField("aa")!, byteCount: 1), .success)
        
        exp = Data([
            0x14, 0x00, 0x00, 0x00,  0x38, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00, // RowCount
            0x01, 0x00, 0x00, 0x00, // ColumnCount
            0x28, 0x00, 0x00, 0x00, // RowsOffset
            0x08, 0x00, 0x00, 0x00, // RowByteCount
            
            0xe8, 0x78,             // CRC
            0x08,                   // NameFieldByteCount
            0x02,                   // ColumnType
            0x20, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x00, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0x02, 0x61, 0x61, 0x00, 0x00,  0x00, 0x00, 0x00 // UTF8 Area
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafeRawBufferPointer) -> () in
            let p = tm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr.baseAddress!))
            XCTAssertTrue(p == tm.root)
        }

        
        // Add a second column
        
        XCTAssertEqual(tm.root.addColumn(type: .int64, nameField: NameField("bb")!, byteCount: 8), .success)

        exp = Data([
            0x14, 0x00, 0x00, 0x00,  0x50, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00, // RowCount
            0x02, 0x00, 0x00, 0x00, // ColumnCount
            0x40, 0x00, 0x00, 0x00, // RowsOffset
            0x10, 0x00, 0x00, 0x00, // RowByteCount
            
            0xe8, 0x78,             // CRC
            0x08,                   // NameFieldByteCount
            0x02,                   // ColumnType
            0x30, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x00, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0xa8, 0x89,             // CRC
            0x08,                   // NameFieldByteCount
            0x06,                   // ColumnType
            0x38, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x08, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount

            0x02, 0x61, 0x61, 0x00, 0x00,  0x00, 0x00, 0x00, // UTF8 Area
            0x02, 0x62, 0x62, 0x00, 0x00,  0x00, 0x00, 0x00  // UTF8 Area
            ])

        exp.withUnsafeBytes() { (ptr: UnsafeRawBufferPointer) -> () in
            let p = tm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr.baseAddress!))
            XCTAssertTrue(p == tm.root)
        }

        
        // Add a third column
        
        XCTAssertEqual(tm.root.addColumn(type: .uint16, nameField: NameField("cc")!, byteCount: 8), .success)
        
        exp = Data([
            0x14, 0x00, 0x00, 0x00,  0x68, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00, // RowCount
            0x03, 0x00, 0x00, 0x00, // ColumnCount
            0x58, 0x00, 0x00, 0x00, // RowsOffset
            0x18, 0x00, 0x00, 0x00, // RowByteCount
            
            0xe8, 0x78,             // CRC
            0x08,                   // NameFieldByteCount
            0x02,                   // ColumnType
            0x40, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x00, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0xa8, 0x89,             // CRC
            0x08,                   // NameFieldByteCount
            0x06,                   // ColumnType
            0x48, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x08, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0x68, 0xd9,             // CRC
            0x08,                   // NameFieldByteCount
            0x08,                   // ColumnType
            0x50, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x10, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount

            0x02, 0x61, 0x61, 0x00, 0x00,  0x00, 0x00, 0x00, // UTF8 Area
            0x02, 0x62, 0x62, 0x00, 0x00,  0x00, 0x00, 0x00, // UTF8 Area
            0x02, 0x63, 0x63, 0x00, 0x00,  0x00, 0x00, 0x00  // UTF8 Area
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafeRawBufferPointer) -> () in
            let p = tm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr.baseAddress!))
            XCTAssertTrue(p == tm.root)
        }

        
        // Add a single row
        
        XCTAssertEqual(tm.root.addRows(1), .success)
        
        exp = Data([
            0x14, 0x00, 0x00, 0x00,  0x80, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x01, 0x00, 0x00, 0x00, // RowCount
            0x03, 0x00, 0x00, 0x00, // ColumnCount
            0x58, 0x00, 0x00, 0x00, // RowsOffset
            0x18, 0x00, 0x00, 0x00, // RowByteCount
            
            0xe8, 0x78,             // CRC
            0x08,                   // NameFieldByteCount
            0x02,                   // ColumnType (bool)
            0x40, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x00, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0xa8, 0x89,             // CRC
            0x08,                   // NameFieldByteCount
            0x06,                   // ColumnType (int64)
            0x48, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x08, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0x68, 0xd9,             // CRC
            0x08,                   // NameFieldByteCount
            0x08,                   // ColumnType (uint16)
            0x50, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x10, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0x02, 0x61, 0x61, 0x00,  0x00, 0x00, 0x00, 0x00, // UTF8 Area
            0x02, 0x62, 0x62, 0x00,  0x00, 0x00, 0x00, 0x00, // UTF8 Area
            0x02, 0x63, 0x63, 0x00,  0x00, 0x00, 0x00, 0x00, // UTF8 Area
            
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])

        exp.withUnsafeBytes() { (ptr: UnsafeRawBufferPointer) -> () in
            let p = tm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr.baseAddress!))
            XCTAssertTrue(p == tm.root)
        }

        
        // Set a field value
        
        tm.root[0, "aa"] = true
        tm.root[0, "bb"] = Int64(0x123456789abcdef0)
        tm.root[0, "cc"] = UInt16(0x6666)
        
        exp = Data([
            0x14, 0x00, 0x00, 0x00,  0x80, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x01, 0x00, 0x00, 0x00, // RowCount
            0x03, 0x00, 0x00, 0x00, // ColumnCount
            0x58, 0x00, 0x00, 0x00, // RowsOffset
            0x18, 0x00, 0x00, 0x00, // RowByteCount
            
            0xe8, 0x78,             // CRC
            0x08,                   // NameFieldByteCount
            0x02,                   // ColumnType (bool)
            0x40, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x00, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0xa8, 0x89,             // CRC
            0x08,                   // NameFieldByteCount
            0x06,                   // ColumnType (int64)
            0x48, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x08, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0x68, 0xd9,             // CRC
            0x08,                   // NameFieldByteCount
            0x08,                   // ColumnType (uint16)
            0x50, 0x00, 0x00, 0x00, // ColumnNameUtf8Offset
            0x10, 0x00, 0x00, 0x00, // ColumnValueOffset
            0x08, 0x00, 0x00, 0x00, // ColumnValueByteCount
            
            0x02, 0x61, 0x61, 0x00,  0x00, 0x00, 0x00, 0x00, // UTF8 Area
            0x02, 0x62, 0x62, 0x00,  0x00, 0x00, 0x00, 0x00, // UTF8 Area
            0x02, 0x63, 0x63, 0x00,  0x00, 0x00, 0x00, 0x00, // UTF8 Area
            
            0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0xF0, 0xDE, 0xBC, 0x9A,  0x78, 0x56, 0x34, 0x12,
            0x66, 0x66, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafeRawBufferPointer) -> () in
            let p = tm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr.baseAddress!))
            XCTAssertTrue(p == tm.root)
        }

        XCTAssertEqual(tm.root[0, "aa"].bool, true)
        XCTAssertEqual(tm.root[0, "bb"].int64, 0x123456789abcdef0)
        XCTAssertEqual(tm.root[0, "cc"].uint16, 0x6666)
        
        XCTAssertEqual(tm.root[0, "aa"], true)
        XCTAssertEqual(tm.root[0, "bb"], Int64(0x123456789abcdef0))
        XCTAssertEqual(tm.root[0, "cc"], UInt16(0x6666))
    }
}
