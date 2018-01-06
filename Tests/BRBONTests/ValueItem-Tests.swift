//
//  ValueItem-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 05/01/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class ValueItem_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateInByteBuffer_Bool() {
        
        var buffer = ValueItem.createInBuffer(true, endianness: machineEndianness)!
        
        var itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        var exp = Data(bytes: [
            0x81,   0,      0,      0,      // Type = .bool, Options = 0, Flags = 0, No name
            16,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            1,      0,      0,      0       // Value (1 byte), Filler (3 bytes)
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
        
        
        buffer = ValueItem.createInBuffer(false, name: "test", endianness: machineEndianness)!
        
        itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        exp = Data(bytes: [
            0x81,   0,      0,      8,      // Type = .bool, Options = 0, Flags = 0, Name field is 8 bytes.
            24,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            0,      0,      0,      0,      // Value (1 byte), Filler (3 bytes)
            0x2e,   0xf8,   4,      116,    // name hash (2 bytes), name field length, first name byte
            101,    115,    116,    0       // Name bytes (3), Filler (1 byte)
            ])
        
        XCTAssertEqual(itemData, exp)

        buffer.deallocate()
        
        
        buffer = ValueItem.createInBuffer(false, name: "test", fixedNameFieldLength: 10, endianness: machineEndianness)!
        
        itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        exp = Data(bytes: [
            0x81,   0,      0,      16,     // Type = .bool, Options = 0, Flags = 0, Name field is 16 bytes.
            32,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            0,      0,      0,      0,      // Value (1 byte), Filler (3 bytes)
            0x2e,   0xf8,   4,      116,    // name hash (2 bytes), name field length, first name byte
            101,    115,    116,    0,      // Name bytes (3), Filler (1 byte)
            0,      0,      0,      0,      // Filler
            0,      0,      0,      0       // Filler
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()

        
        buffer = ValueItem.createInBuffer(false, name: "test", fixedItemValueLength: 10, endianness: machineEndianness)!
        
        itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        exp = Data(bytes: [
            0x81,   0,      0,      8,      // Type = .bool, Options = 0, Flags = 0, Name field is 8 bytes.
            40,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            0,      0,      0,      0,      // Value (1 byte), Filler (3 bytes)
            0x2e,   0xf8,   4,      116,    // name hash (2 bytes), name field length, first name byte
            101,    115,    116,    0,      // Name bytes (3), Filler (1 byte)
            0,      0,      0,      0,      // Filler
            0,      0,      0,      0,      // Filler
            0,      0,      0,      0,      // Filler
            0,      0,      0,      0       // Filler
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()

        
        buffer = ValueItem.createInBuffer(false, name: "test", fixedNameFieldLength: 10, fixedItemValueLength: 5, endianness: machineEndianness)!
        
        itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        exp = Data(bytes: [
            0x81,   0,      0,      16,     // Type = .bool, Options = 0, Flags = 0, Name field is 16 bytes.
            40,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            0,      0,      0,      0,      // Value (1 byte), Filler (3 bytes)
            0x2e,   0xf8,   4,      116,    // name hash (2 bytes), name field length, first name byte
            101,    115,    116,    0,      // Name bytes (3), Filler (1 byte)
            0,      0,      0,      0,      // Filler
            0,      0,      0,      0,      // Filler
            0,      0,      0,      0,      // Filler
            0,      0,      0,      0       // Filler
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()

    }
    
    func testCreateValueItemByteBuffer_int8() {
        
        let buffer = ValueItem.createInBuffer(Int8(55), endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x82,   0,      0,      0,      // Type = .int8, Options = 0, Flags = 0, No name
            16,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parentoffset
            55,     0,      0,      0       // Value (1 byte), Filler (3 bytes)
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }
    
    func testCreateValueItemByteBuffer_int16() {
        
        let buffer = ValueItem.createInBuffer(Int16(0x1234), endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x83,   0,      0,      0,      // Type = .int16, Options = 0, Flags = 0, No name
            16,     0,      0,      0,      // Item length
            0,      0,      0,      0,      // Parent offset
            0x34,   0x12,   0,      0,      // Value (2 bytes), Filler (2 bytes)
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }
    
    func testCreateValueItemByteBuffer_int32() {
        
        let buffer = ValueItem.createInBuffer(Int32(0x12345678), endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x84,   0,      0,      0,      // Type = .int32, Options = 0, Flags = 0, No name
            16,     0,      0,      0,      // Item length
            0,      0,      0,      0,      // Parent offset
            0x78,   0x56,   0x34,   0x12    // Value
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }
    
    func testCreateValueItemByteBuffer_int64() {
        
        let buffer = ValueItem.createInBuffer(Int64(0x1234567887654321), endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x00,   0,      0,      0,      // Type = .int64, Options = 0, Flags = 0, No name
            24,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            0,      0,      0,      0,      // Count/Value (unused)
            0x21,   0x43,   0x65,   0x87,   // Value
            0x78,   0x56,   0x34,   0x12
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }
    
    func testCreateValueItemByteBuffer_uint8() {
        
        let buffer = ValueItem.createInBuffer(UInt8(55), endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x85,   0,      0,      0,      // Type = .uint8, Options = 0, Flags = 0, No name
            16,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parentoffset
            55,     0,      0,      0       // Value (1 byte), Filler (3 bytes)
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }
    
    func testCreateValueItemByteBuffer_uint16() {
        
        let buffer = ValueItem.createInBuffer(UInt16(0x1234), endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x86,   0,      0,      0,      // Type = .uint16, Options = 0, Flags = 0, No name
            16,     0,      0,      0,      // Item length
            0,      0,      0,      0,      // Parent offset
            0x34,   0x12,   0,      0,      // Value (2 bytes), Filler (2 bytes)
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }
    
    func testCreateValueItemByteBuffer_uint32() {
        
        let buffer = ValueItem.createInBuffer(UInt32(0x12345678), endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x87,   0,      0,      0,      // Type = .uint32, Options = 0, Flags = 0, No name
            16,     0,      0,      0,      // Item length
            0,      0,      0,      0,      // Parent offset
            0x78,   0x56,   0x34,   0x12    // Value
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }
    
    func testCreateValueItemByteBuffer_uint64() {
        
        let buffer = ValueItem.createInBuffer(UInt64(0x1234567887654321), endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x01,   0,      0,      0,      // Type = .uint64, Options = 0, Flags = 0, No name
            24,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            0,      0,      0,      0,      // Count/Value (unused)
            0x21,   0x43,   0x65,   0x87,   // Value
            0x78,   0x56,   0x34,   0x12
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }

    func testCreateValueItemByteBuffer_string() {
        
        let buffer = ValueItem.createInBuffer("test", endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x40,   0,      0,      0,      // Type = .string, Options = 0, Flags = 0, No name
            24,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            4,      0,      0,      0,      // Count/Value (count)
            116,    101,    115,    116,    // Value
            0,      0,      0,      0       // Value
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }

    func testCreateValueItemByteBuffer_binary() {
        
        let buffer = ValueItem.createInBuffer(Data(bytes: [1, 2, 3, 4, 5, 6, 7, 8, 9]), endianness: machineEndianness)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x44,   0,      0,      0,      // Type = .binary, Options = 0, Flags = 0, No name
            32,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            9,      0,      0,      0,      // Count/Value (count)
            1,      2,      3,      4,      // Value
            5,      6,      7,      8,      // Value
            9,      0,      0,      0,      // Value
            0,      0,      0,      0       // Value
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
    }

}
