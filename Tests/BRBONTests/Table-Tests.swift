//
//  Table-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 15/03/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Table_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_01_emptyTable() {
        
        
        // Create empty table
        
        guard let tm = ItemManager(rootItemType: .table) else { XCTFail(); return }
        
        
        // Basic portal properties
        
        XCTAssertNotNil(tm.root.itemPtr)
        XCTAssertNil(tm.root.index)
        XCTAssertNil(tm.root.column)
        XCTAssertNotNil(tm.root.manager)
        XCTAssertEqual(tm.root.endianness, machineEndianness)
        XCTAssertTrue(tm.root.isValid)
        XCTAssertEqual(tm.root.refCount, 0)

        
        // Item properties
        
        XCTAssertEqual(tm.root.itemType, .table)
        XCTAssertEqual(tm.root.options, ItemOptions.none)
        XCTAssertEqual(tm.root.flags, ItemFlags.none)
        XCTAssertEqual(tm.root.nameFieldByteCount, 0)
        
        XCTAssertEqual(tm.root.itemByteCount, 0x20)
        XCTAssertEqual(tm.root.parentOffset, 0)
        XCTAssertEqual(tm.root.countValue, 0)
        XCTAssertEqual(tm.root.name, nil)
        
        
        // Table item properties

        XCTAssertEqual(tm.root._tableRowCount, 0)
        XCTAssertEqual(tm.root._tableColumnCount, 0)
        XCTAssertEqual(tm.root._tableRowsOffset, 0x10)
        XCTAssertEqual(tm.root._tableRowByteCount, 0)
    }
    
    func test_02_tableWith1Column_NoRows() {
        
        guard let col = ColumnSpecification(name: "aa", initialNameFieldByteCount: nil, valueType: .uint8, initialValueByteCount: nil) else { XCTFail(); return }
        
        let table = BrbonTable(columnSpecifications: [col])
        
        guard let tm = ItemManager(value: table) else { XCTFail(); return }
        
        
        // Basic portal properties
        
        XCTAssertNotNil(tm.root.itemPtr)
        XCTAssertNil(tm.root.index)
        XCTAssertNil(tm.root.column)
        XCTAssertNotNil(tm.root.manager)
        XCTAssertEqual(tm.root.endianness, machineEndianness)
        XCTAssertTrue(tm.root.isValid)
        XCTAssertEqual(tm.root.refCount, 0)
        
        
        // Item properties
        
        XCTAssertEqual(tm.root.itemType, .table)
        XCTAssertEqual(tm.root.options, ItemOptions.none)
        XCTAssertEqual(tm.root.flags, ItemFlags.none)
        XCTAssertEqual(tm.root.nameFieldByteCount, 0)
        
        XCTAssertEqual(tm.root.itemByteCount, 0x38)
        XCTAssertEqual(tm.root.parentOffset, 0)
        XCTAssertEqual(tm.root.countValue, 0)
        XCTAssertEqual(tm.root.name, nil)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 0)
        XCTAssertEqual(tm.root._tableColumnCount, 1)
        XCTAssertEqual(tm.root._tableRowsOffset, 0x28)
        XCTAssertEqual(tm.root._tableRowByteCount, 8)
        
        
        // Column 1 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 0), "aa")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 0), ItemType.uint8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 0), 0x78E8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 0), 0)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 0), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 0), 0x20)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 0), 8)
    }
    
    func createTableWith3Rows() -> ItemManager? {
        guard let col1 = ColumnSpecification(name: "aa", initialNameFieldByteCount: nil, valueType: .uint8, initialValueByteCount: nil) else { return nil }
        guard let col2 = ColumnSpecification(name: "bb", initialNameFieldByteCount: nil, valueType: .int8, initialValueByteCount: nil) else { return nil }
        guard let col3 = ColumnSpecification(name: "cc", initialNameFieldByteCount: nil, valueType: .string, initialValueByteCount: nil) else { return nil }
        
        let table = BrbonTable(columnSpecifications: [col1, col2, col3])
        
        return ItemManager(value: table)
    }
    
    func test_03_tableWith3Columns_NoRows() {
        
        guard let tm = createTableWith3Rows() else { XCTFail(); return }
        
        
        // Basic portal properties
        
        XCTAssertNotNil(tm.root.itemPtr)
        XCTAssertNil(tm.root.index)
        XCTAssertNil(tm.root.column)
        XCTAssertNotNil(tm.root.manager)
        XCTAssertEqual(tm.root.endianness, machineEndianness)
        XCTAssertTrue(tm.root.isValid)
        XCTAssertEqual(tm.root.refCount, 0)
        
        
        // Item properties
        
        XCTAssertEqual(tm.root.itemType, .table)
        XCTAssertEqual(tm.root.options, ItemOptions.none)
        XCTAssertEqual(tm.root.flags, ItemFlags.none)
        XCTAssertEqual(tm.root.nameFieldByteCount, 0)
        
        XCTAssertEqual(tm.root.itemByteCount, 104)
        XCTAssertEqual(tm.root.parentOffset, 0)
        XCTAssertEqual(tm.root.countValue, 0)
        XCTAssertEqual(tm.root.name, nil)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 0)
        XCTAssertEqual(tm.root._tableColumnCount, 3)
        XCTAssertEqual(tm.root._tableRowsOffset, 88)
        XCTAssertEqual(tm.root._tableRowByteCount, 272)
        
        
        // Column 1 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 0), "aa")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 0), ItemType.uint8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 0), 0x78E8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 0), 0)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 0), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 0), 0x40)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 0), 8)

        
        // Column 2 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 1), "bb")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 1), ItemType.int8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 1), 0x89A8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 1), 0x48)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 1), 8)

        
        // Column 3 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 2), "cc")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 2), ItemType.string)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 2), 0xD968)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 2), 16)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 2), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 2), 0x50)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 2), 256)
    }

    func test_04_addColumn() {
        
        guard let tm = createTableWith3Rows() else { XCTFail(); return }
        
        XCTAssertEqual(tm.root.addColumn(withName: "dd", nameFieldByteCount: nil, valueType: ItemType.int64, valueByteCount: nil), Result.success)
        
        // Basic portal properties
        
        XCTAssertNotNil(tm.root.itemPtr)
        XCTAssertNil(tm.root.index)
        XCTAssertNil(tm.root.column)
        XCTAssertNotNil(tm.root.manager)
        XCTAssertEqual(tm.root.endianness, machineEndianness)
        XCTAssertTrue(tm.root.isValid)
        XCTAssertEqual(tm.root.refCount, 0)
        
        
        // Item properties
        
        XCTAssertEqual(tm.root.itemType, .table)
        XCTAssertEqual(tm.root.options, ItemOptions.none)
        XCTAssertEqual(tm.root.flags, ItemFlags.none)
        XCTAssertEqual(tm.root.nameFieldByteCount, 0)
        
        XCTAssertEqual(tm.root.itemByteCount, 128)
        XCTAssertEqual(tm.root.parentOffset, 0)
        XCTAssertEqual(tm.root.countValue, 0)
        XCTAssertEqual(tm.root.name, nil)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 0)
        XCTAssertEqual(tm.root._tableColumnCount, 4)
        XCTAssertEqual(tm.root._tableRowsOffset, 112)
        XCTAssertEqual(tm.root._tableRowByteCount, 280)
        
        
        // Column 1 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 0), "aa")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 0), ItemType.uint8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 0), 0x78E8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 0), 0)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 0), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 0), 0x50)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 0), 8)
        
        
        // Column 2 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 1), "bb")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 1), ItemType.int8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 1), 0x89A8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 1), 0x58)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 1), 8)
        
        
        // Column 3 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 2), "cc")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 2), ItemType.string)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 2), 0xD968)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 2), 16)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 2), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 2), 0x60)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 2), 256)

        
        // Column 4 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 3), "dd")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 3), ItemType.int64)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 3), 0x2B2B)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 3), 8+8+256)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 3), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 3), 0x68)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 3), 8)
    }
    
    func test_05_removeColumn() {
        
        guard let tm = createTableWith3Rows() else { XCTFail(); return }
        
        BRBON.allowFatalError = false
        XCTAssertEqual(tm.root.removeColumn("ee"), Result.columnNotFound)
        BRBON.allowFatalError = true
        
        XCTAssertEqual(tm.root.removeColumn("bb"), Result.success)
        
        
        // Basic portal properties
        
        XCTAssertNotNil(tm.root.itemPtr)
        XCTAssertNil(tm.root.index)
        XCTAssertNil(tm.root.column)
        XCTAssertNotNil(tm.root.manager)
        XCTAssertEqual(tm.root.endianness, machineEndianness)
        XCTAssertTrue(tm.root.isValid)
        XCTAssertEqual(tm.root.refCount, 0)
        
        
        // Item properties
        
        XCTAssertEqual(tm.root.itemType, .table)
        XCTAssertEqual(tm.root.options, ItemOptions.none)
        XCTAssertEqual(tm.root.flags, ItemFlags.none)
        XCTAssertEqual(tm.root.nameFieldByteCount, 0)
        
        XCTAssertEqual(tm.root.itemByteCount, 104)
        XCTAssertEqual(tm.root.parentOffset, 0)
        XCTAssertEqual(tm.root.countValue, 0)
        XCTAssertEqual(tm.root.name, nil)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 0)
        XCTAssertEqual(tm.root._tableColumnCount, 2)
        XCTAssertEqual(tm.root._tableRowsOffset, 64)
        XCTAssertEqual(tm.root._tableRowByteCount, 264)
        
        
        // Column 1 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 0), "aa")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 0), ItemType.uint8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 0), 0x78E8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 0), 0)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 0), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 0), 48)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 0), 8)
        
        
        // Column 2 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 1), "cc")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 1), ItemType.string)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 1), 0xD968)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 1), 56)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 1), 256)
    }
    
    func test_06_add1Row() {
        
        guard let tm = createTableWith3Rows() else { XCTFail(); return }

        XCTAssertEqual(tm.root.addRows(1), Result.success)
        
        
        // Basic portal properties
        
        XCTAssertNotNil(tm.root.itemPtr)
        XCTAssertNil(tm.root.index)
        XCTAssertNil(tm.root.column)
        XCTAssertNotNil(tm.root.manager)
        XCTAssertEqual(tm.root.endianness, machineEndianness)
        XCTAssertTrue(tm.root.isValid)
        XCTAssertEqual(tm.root.refCount, 0)
        
        
        // Item properties
        
        XCTAssertEqual(tm.root.itemType, .table)
        XCTAssertEqual(tm.root.options, ItemOptions.none)
        XCTAssertEqual(tm.root.flags, ItemFlags.none)
        XCTAssertEqual(tm.root.nameFieldByteCount, 0)
        
        XCTAssertEqual(tm.root.itemByteCount, 376)
        XCTAssertEqual(tm.root.parentOffset, 0)
        XCTAssertEqual(tm.root.countValue, 0)
        XCTAssertEqual(tm.root.name, nil)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 1)
        XCTAssertEqual(tm.root._tableColumnCount, 3)
        XCTAssertEqual(tm.root._tableRowsOffset, 88)
        XCTAssertEqual(tm.root._tableRowByteCount, 272)
        
        
        // Column 1 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 0), "aa")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 0), ItemType.uint8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 0), 0x78E8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 0), 0)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 0), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 0), 0x40)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 0), 8)
        
        // Column 1 value
        
        XCTAssertEqual(tm.root[0, "aa"].uint8, 0)
        
        
        // Column 2 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 1), "bb")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 1), ItemType.int8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 1), 0x89A8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 1), 0x48)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 1), 8)
        
        // Column 2 value
        
        XCTAssertEqual(tm.root[0, "bb"].int8, 0)

        
        // Column 3 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 2), "cc")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 2), ItemType.string)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 2), 0xD968)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 2), 16)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 2), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 2), 0x50)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 2), 256)

        // Column 3 value
        
        XCTAssertEqual(tm.root[0, "cc"].string, "")
    }
    
    func test_07_add3Rows() {
        
        guard let tm = createTableWith3Rows() else { XCTFail(); return }
        
        XCTAssertEqual(tm.root.addRows(3), Result.success)
        
        
        // Basic portal properties
        
        XCTAssertNotNil(tm.root.itemPtr)
        XCTAssertNil(tm.root.index)
        XCTAssertNil(tm.root.column)
        XCTAssertNotNil(tm.root.manager)
        XCTAssertEqual(tm.root.endianness, machineEndianness)
        XCTAssertTrue(tm.root.isValid)
        XCTAssertEqual(tm.root.refCount, 0)
        
        
        // Item properties
        
        XCTAssertEqual(tm.root.itemType, .table)
        XCTAssertEqual(tm.root.options, ItemOptions.none)
        XCTAssertEqual(tm.root.flags, ItemFlags.none)
        XCTAssertEqual(tm.root.nameFieldByteCount, 0)
        
        XCTAssertEqual(tm.root.itemByteCount, 920)
        XCTAssertEqual(tm.root.parentOffset, 0)
        XCTAssertEqual(tm.root.countValue, 0)
        XCTAssertEqual(tm.root.name, nil)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 3)
        XCTAssertEqual(tm.root._tableColumnCount, 3)
        XCTAssertEqual(tm.root._tableRowsOffset, 88)
        XCTAssertEqual(tm.root._tableRowByteCount, 272)
        
        
        // Column 1 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 0), "aa")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 0), ItemType.uint8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 0), 0x78E8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 0), 0)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 0), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 0), 0x40)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 0), 8)
        
        // Column 1 value
        
        XCTAssertEqual(tm.root[0, "aa"].uint8, 0)
        XCTAssertEqual(tm.root[1, "aa"].uint8, 0)
        XCTAssertEqual(tm.root[2, "aa"].uint8, 0)
        
        
        // Column 2 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 1), "bb")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 1), ItemType.int8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 1), 0x89A8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 1), 0x48)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 1), 8)
        
        // Column 2 value
        
        XCTAssertEqual(tm.root[0, "bb"].int8, 0)
        XCTAssertEqual(tm.root[1, "bb"].int8, 0)
        XCTAssertEqual(tm.root[2, "bb"].int8, 0)
        
        
        // Column 3 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 2), "cc")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 2), ItemType.string)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 2), 0xD968)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 2), 16)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 2), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 2), 0x50)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 2), 256)
        
        // Column 3 value
        
        XCTAssertEqual(tm.root[0, "cc"].string, "")
        XCTAssertEqual(tm.root[1, "cc"].string, "")
        XCTAssertEqual(tm.root[2, "cc"].string, "")
    }
    
    func test_08_fieldAccess() {
        
        guard let tm = createTableWith3Rows() else { XCTFail(); return }
        
        XCTAssertEqual(tm.root.addRows(3), Result.success)
        
        
        // Basic portal properties
        
        XCTAssertNotNil(tm.root.itemPtr)
        XCTAssertNil(tm.root.index)
        XCTAssertNil(tm.root.column)
        XCTAssertNotNil(tm.root.manager)
        XCTAssertEqual(tm.root.endianness, machineEndianness)
        XCTAssertTrue(tm.root.isValid)
        XCTAssertEqual(tm.root.refCount, 0)
        
        
        // Item properties
        
        XCTAssertEqual(tm.root.itemType, .table)
        XCTAssertEqual(tm.root.options, ItemOptions.none)
        XCTAssertEqual(tm.root.flags, ItemFlags.none)
        XCTAssertEqual(tm.root.nameFieldByteCount, 0)
        
        XCTAssertEqual(tm.root.itemByteCount, 920)
        XCTAssertEqual(tm.root.parentOffset, 0)
        XCTAssertEqual(tm.root.countValue, 0)
        XCTAssertEqual(tm.root.name, nil)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 3)
        XCTAssertEqual(tm.root._tableColumnCount, 3)
        XCTAssertEqual(tm.root._tableRowsOffset, 88)
        XCTAssertEqual(tm.root._tableRowByteCount, 272)
        
        
        // Column 1 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 0), "aa")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 0), ItemType.uint8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 0), 0x78E8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 0), 0)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 0), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 0), 0x40)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 0), 8)
        
        // Column 1 value
        
        XCTAssertEqual(tm.root[0, "aa"].uint8, 0)
        XCTAssertEqual(tm.root[1, "aa"].uint8, 0)
        XCTAssertEqual(tm.root[2, "aa"].uint8, 0)
        
        tm.root[0, "aa"] = UInt8(0x78)
        tm.root[1, "aa"] = UInt8(0x9A)
        tm.root[2, "aa"] = UInt8(0xBC)
        
        XCTAssertEqual(tm.root[0, "aa"].uint8, 0x78)
        XCTAssertEqual(tm.root[1, "aa"].uint8, 0x9A)
        XCTAssertEqual(tm.root[2, "aa"].uint8, 0xBC)

        
        // Column 2 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 1), "bb")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 1), ItemType.int8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 1), 0x89A8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 1), 0x48)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 1), 8)
        
        // Column 2 value
        
        XCTAssertEqual(tm.root[0, "bb"].int8, 0)
        XCTAssertEqual(tm.root[1, "bb"].int8, 0)
        XCTAssertEqual(tm.root[2, "bb"].int8, 0)
        
        tm.root[0, "bb"] = Int8(0x12)
        tm.root[1, "bb"] = Int8(0x34)
        tm.root[2, "bb"] = Int8(0x56)
        
        XCTAssertEqual(tm.root[0, "bb"].int8, 0x12)
        XCTAssertEqual(tm.root[1, "bb"].int8, 0x34)
        XCTAssertEqual(tm.root[2, "bb"].int8, 0x56)

        
        // Column 3 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 2), "cc")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 2), ItemType.string)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 2), 0xD968)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 2), 16)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 2), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 2), 0x50)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 2), 256)
        
        // Column 3 value
        
        XCTAssertEqual(tm.root[0, "cc"].string, "")
        XCTAssertEqual(tm.root[1, "cc"].string, "")
        XCTAssertEqual(tm.root[2, "cc"].string, "")
        
        tm.root[0, "cc"] = "1111"
        tm.root[1, "cc"] = "2222"
        tm.root[2, "cc"] = "3333"
        
        XCTAssertEqual(tm.root[0, "cc"].string, "1111")
        XCTAssertEqual(tm.root[1, "cc"].string, "2222")
        XCTAssertEqual(tm.root[2, "cc"].string, "3333")
    }

    func test_09_removeRows() {
        
        guard let tm = createTableWith3Rows() else { XCTFail(); return }
        
        XCTAssertEqual(tm.root.addRows(3), Result.success)
        
        tm.root[0, "aa"] = UInt8(0x78)
        tm.root[1, "aa"] = UInt8(0x9A)
        tm.root[2, "aa"] = UInt8(0xBC)

        tm.root[0, "bb"] = Int8(0x12)
        tm.root[1, "bb"] = Int8(0x34)
        tm.root[2, "bb"] = Int8(0x56)

        tm.root[0, "cc"] = "1111"
        tm.root[1, "cc"] = "2222"
        tm.root[2, "cc"] = "3333"

        XCTAssertEqual(tm.root.removeRow(1), Result.success)

        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 2)
        XCTAssertEqual(tm.root._tableColumnCount, 3)
        XCTAssertEqual(tm.root._tableRowsOffset, 88)
        XCTAssertEqual(tm.root._tableRowByteCount, 272)
        
        
        // Column 1 value
        
        XCTAssertEqual(tm.root[0, "aa"].uint8, 0x78)
        XCTAssertEqual(tm.root[1, "aa"].uint8, 0xBC)
        
        
        // Column 2 value
        
        XCTAssertEqual(tm.root[0, "bb"].int8, 0x12)
        XCTAssertEqual(tm.root[1, "bb"].int8, 0x56)
        
        
        // Column 3 value
        
        XCTAssertEqual(tm.root[0, "cc"].string, "1111")
        XCTAssertEqual(tm.root[1, "cc"].string, "3333")
        
        
        // Remove first row
        
        XCTAssertEqual(tm.root.removeRow(0), Result.success)
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 1)
        XCTAssertEqual(tm.root._tableColumnCount, 3)
        XCTAssertEqual(tm.root._tableRowsOffset, 88)
        XCTAssertEqual(tm.root._tableRowByteCount, 272)
        
        
        // Column 1 value
        
        XCTAssertEqual(tm.root[0, "aa"].uint8, 0xBC)
        
        
        // Column 2 value
        
        XCTAssertEqual(tm.root[0, "bb"].int8, 0x56)
        
        
        // Column 3 value
        
        XCTAssertEqual(tm.root[0, "cc"].string, "3333")

        
        // Remove first row (again)
        
        XCTAssertEqual(tm.root.removeRow(0), Result.success)
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 0)
        XCTAssertEqual(tm.root._tableColumnCount, 3)
        XCTAssertEqual(tm.root._tableRowsOffset, 88)
        XCTAssertEqual(tm.root._tableRowByteCount, 272)
    }

    func test_10_removeColumns() {
        
        guard let tm = createTableWith3Rows() else { XCTFail(); return }
        
        XCTAssertEqual(tm.root.addRows(3), Result.success)
        
        tm.root[0, "aa"] = UInt8(0x78)
        tm.root[1, "aa"] = UInt8(0x9A)
        tm.root[2, "aa"] = UInt8(0xBC)

        tm.root[0, "bb"] = Int8(0x12)
        tm.root[1, "bb"] = Int8(0x34)
        tm.root[2, "bb"] = Int8(0x56)

        tm.root[0, "cc"] = "1111"
        tm.root[1, "cc"] = "2222"
        tm.root[2, "cc"] = "3333"

        XCTAssertEqual(tm.root.removeColumn("bb"), Result.success)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 3)
        XCTAssertEqual(tm.root._tableColumnCount, 2)
        XCTAssertEqual(tm.root._tableRowsOffset, 64)
        XCTAssertEqual(tm.root._tableRowByteCount, 264)
        
        
        // Column 1 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 0), "aa")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 0), ItemType.uint8)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 0), 0x78E8)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 0), 0)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 0), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 0), 48)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 0), 8)
        
        // Column 1 values
        
        XCTAssertEqual(tm.root[0, "aa"].uint8, 0x78)
        XCTAssertEqual(tm.root[1, "aa"].uint8, 0x9A)
        XCTAssertEqual(tm.root[2, "aa"].uint8, 0xBC)
        
        
        // Column 2 properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 1), "cc")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 1), ItemType.string)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 1), 0xD968)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 1), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 1), 56)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 1), 256)
        
        // Column 2 values
        
        XCTAssertEqual(tm.root[0, "cc"].string, "1111")
        XCTAssertEqual(tm.root[1, "cc"].string, "2222")
        XCTAssertEqual(tm.root[2, "cc"].string, "3333")
        
        
        // Remove the first column
        
        XCTAssertEqual(tm.root.removeColumn("aa"), Result.success)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 3)
        XCTAssertEqual(tm.root._tableColumnCount, 1)
        XCTAssertEqual(tm.root._tableRowsOffset, 40)
        XCTAssertEqual(tm.root._tableRowByteCount, 256)
        
        
        // Column properties
        
        XCTAssertEqual(tm.root._tableGetColumnName(for: 0), "cc")
        XCTAssertEqual(tm.root._tableGetColumnType(for: 0), ItemType.string)
        XCTAssertEqual(tm.root._tableGetColumnNameCrc(for: 0), 0xD968)
        XCTAssertEqual(tm.root._tableGetColumnValueOffset(for: 0), 0)
        XCTAssertEqual(tm.root._tableGetColumnNameByteCount(for: 0), 8)
        XCTAssertEqual(tm.root._tableGetColumnNameUtf8Offset(for: 0), 32)
        XCTAssertEqual(tm.root._tableGetColumnValueFieldByteCount(for: 0), 256)
        
        // Column values
        
        XCTAssertEqual(tm.root[0, "cc"].string, "1111")
        XCTAssertEqual(tm.root[1, "cc"].string, "2222")
        XCTAssertEqual(tm.root[2, "cc"].string, "3333")

        
        // Remove the first column again
        
        XCTAssertEqual(tm.root.removeColumn("cc"), Result.success)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 0)
        XCTAssertEqual(tm.root._tableColumnCount, 0)
        XCTAssertEqual(tm.root._tableRowsOffset, 16)
        XCTAssertEqual(tm.root._tableRowByteCount, 0)
    }

    func test_11_insertRow() {
        
        guard let tm = createTableWith3Rows() else { XCTFail(); return }
        
        XCTAssertEqual(tm.root.addRows(3), Result.success)
        
        tm.root[0, "aa"] = UInt8(0x78)
        tm.root[1, "aa"] = UInt8(0x9A)
        tm.root[2, "aa"] = UInt8(0xBC)
        
        tm.root[0, "bb"] = Int8(0x12)
        tm.root[1, "bb"] = Int8(0x34)
        tm.root[2, "bb"] = Int8(0x56)
        
        tm.root[0, "cc"] = "1111"
        tm.root[1, "cc"] = "2222"
        tm.root[2, "cc"] = "3333"
        
        XCTAssertEqual(tm.root.insertRows(at: 1), Result.success)
        
        
        // Table item properties
        
        XCTAssertEqual(tm.root._tableRowCount, 4)
        XCTAssertEqual(tm.root._tableColumnCount, 3)
        XCTAssertEqual(tm.root._tableRowsOffset, 88)
        XCTAssertEqual(tm.root._tableRowByteCount, 272)
        
        
        // Column 1 value
        
        XCTAssertEqual(tm.root[0, "aa"].uint8, 0x78)
        XCTAssertEqual(tm.root[1, "aa"].uint8, 0x0)
        XCTAssertEqual(tm.root[2, "aa"].uint8, 0x9A)
        XCTAssertEqual(tm.root[3, "aa"].uint8, 0xBC)
        
        
        // Column 2 value
        
        XCTAssertEqual(tm.root[0, "bb"].int8, 0x12)
        XCTAssertEqual(tm.root[1, "bb"].int8, 0x0)
        XCTAssertEqual(tm.root[2, "bb"].int8, 0x34)
        XCTAssertEqual(tm.root[3, "bb"].int8, 0x56)
        
        
        // Column 3 value
        
        XCTAssertEqual(tm.root[0, "cc"].string, "1111")
        XCTAssertEqual(tm.root[1, "cc"].string, "")
        XCTAssertEqual(tm.root[2, "cc"].string, "2222")
        XCTAssertEqual(tm.root[3, "cc"].string, "3333")
    }
    
    
    func test_12_tableWithArray() {
        
        func fieldInitialiser(_ portal: Portal) {
            switch portal.column! {
            case 0:
                portal.createFieldArray(at: portal.index!, in: portal.column!, elementType: .int16, valueByteCount: 32)
            case 1:
                portal.int8 = 5
            default: XCTFail("Column index not supported")
            }
        }
        
        guard let col1 = ColumnSpecification(name: "aa", initialNameFieldByteCount: nil, valueType: .array, initialValueByteCount: 32) else { XCTFail(); return }
        guard let col2 = ColumnSpecification(name: "bb", initialNameFieldByteCount: nil, valueType: .int8, initialValueByteCount: nil) else { XCTFail(); return }

        guard let im = ItemManager(rootItemType: .table) else { XCTFail(); return }
        
        XCTAssertEqual(im.root.addColumns([col1, col2]), .success)
        
        XCTAssertEqual(im.root.addRows(2, defaultValues: fieldInitialiser), .success)
        
        XCTAssertEqual(im.root[1, "aa"].append(Int16(66)), .success)
        
        XCTAssertEqual(im.root[1, "aa"].countValue, 1)
        
        XCTAssertEqual(im.root[1, "aa"][0].int16, 66)
        
        
        // Grow the second array so it has to increase the byte count
        
        for _ in 1 ... 15 {
            XCTAssertEqual(im.root[1, "aa"].append(Int16(0x77)), .success) // filling the available space
        }

        XCTAssertEqual(im.root[1, "aa"].append(Int16(0x77)), .success) // increases byte count

        XCTAssertEqual(im.root[1, "aa"].countValue, 17)
        
        XCTAssertEqual(im.root[1, "aa"][0].int16, 66)

        XCTAssertEqual(im.root[0, "bb"].int8, 5)
    }
}
