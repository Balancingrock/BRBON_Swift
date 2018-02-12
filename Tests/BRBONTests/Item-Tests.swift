//
//  Item-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Item_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_BoolNoName() {

        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        true.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.bool { XCTAssertTrue(b) } else { XCTFail() }
        
        item.bool = false
        
        if let b = item.bool { XCTAssertFalse(b) } else { XCTFail() }
        
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(ptr, item.typePtr)
        XCTAssertEqual(ptr.advanced(by: 1), item.optionsPtr)
        XCTAssertEqual(ptr.advanced(by: 2), item.flagsPtr)
        XCTAssertEqual(ptr.advanced(by: 3), item.nameFieldByteCountPtr)
        XCTAssertEqual(ptr.advanced(by: 4), item.itemByteCountPtr)
        XCTAssertEqual(ptr.advanced(by: 8), item.parentOffsetPtr)
        XCTAssertEqual(ptr.advanced(by: 12), item.childCountPtr)
        XCTAssertEqual(ptr.advanced(by: 16), item.nameHashPtr)
        XCTAssertEqual(ptr.advanced(by: 18), item.nameCountPtr)
        XCTAssertEqual(ptr.advanced(by: 19), item.nameDataPtr)
        XCTAssertEqual(ptr.advanced(by: 12), item.valuePtr)
        
        XCTAssertEqual(item.type, ItemType.bool)
        item.type = .uint8
        XCTAssertEqual(item.type, ItemType.uint8)
        item.type = .bool
        XCTAssertEqual(item.type, ItemType.bool)

        XCTAssertEqual(item.options, ItemOptions.none)

        XCTAssertEqual(item.flags, ItemFlags.none)
        
        XCTAssertEqual(item.nameFieldByteCount, 0)
        item.nameFieldByteCount = 45
        XCTAssertEqual(item.nameFieldByteCount, 45)
        item.nameFieldByteCount = 0
        
        XCTAssertEqual(item.byteCount, 16)
        item.byteCount = 0x12345678
        XCTAssertEqual(item.byteCount, 0x12345678)
        item.byteCount = 16
        
        XCTAssertEqual(item.parentOffset, 0)
        item.parentOffset = 0x12345678
        XCTAssertEqual(item.parentOffset, 0x12345678)
        item.parentOffset = 0

        XCTAssertEqual(item.count, 0)
        item.count = 0x12345678
        XCTAssertEqual(item.count, 0x12345678)
        item.count = 0
        
        XCTAssertEqual(item.nameHash, 0)
        XCTAssertEqual(item.nameCount, 0)
        XCTAssertEqual(item.nameData, Data())
        XCTAssertEqual(item.name, "")
        
        XCTAssertFalse(item.isNull)
        XCTAssertTrue(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)

        XCTAssertNil(item.parentItem)
        
        XCTAssertEqual(item.availableValueByteCount, 0)
        XCTAssertEqual(item.usedValueByteCount, 0)
    }
    
    func test_BoolWithName() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        let nfd = NameFieldDescriptor("one", fixedLength: 10)
        
        true.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, nameField: nfd, machineEndianness)
        
        if let b = item.bool { XCTAssertTrue(b) } else { XCTFail() }
        
        item.bool = false
        
        if let b = item.bool { XCTAssertFalse(b) } else { XCTFail() }
        
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(ptr, item.typePtr)
        XCTAssertEqual(ptr.advanced(by: 1), item.optionsPtr)
        XCTAssertEqual(ptr.advanced(by: 2), item.flagsPtr)
        XCTAssertEqual(ptr.advanced(by: 3), item.nameFieldByteCountPtr)
        XCTAssertEqual(ptr.advanced(by: 4), item.itemByteCountPtr)
        XCTAssertEqual(ptr.advanced(by: 8), item.parentOffsetPtr)
        XCTAssertEqual(ptr.advanced(by: 12), item.childCountPtr)
        XCTAssertEqual(ptr.advanced(by: 16), item.nameHashPtr)
        XCTAssertEqual(ptr.advanced(by: 18), item.nameCountPtr)
        XCTAssertEqual(ptr.advanced(by: 19), item.nameDataPtr)
        XCTAssertEqual(ptr.advanced(by: 12), item.valuePtr)
        
        XCTAssertEqual(item.type, ItemType.bool)
        item.type = .uint8
        XCTAssertEqual(item.type, ItemType.uint8)
        item.type = .bool
        XCTAssertEqual(item.type, ItemType.bool)
        
        XCTAssertEqual(item.options, ItemOptions.none)
        
        XCTAssertEqual(item.flags, ItemFlags.none)
        
        XCTAssertEqual(item.nameFieldByteCount, 16)
        
        XCTAssertEqual(item.byteCount, 32)
        
        XCTAssertEqual(item.parentOffset, 0)
        
        XCTAssertEqual(item.count, 0) // Bool false = 0
        
        XCTAssertEqual(item.nameHash, 0x56dc)
        XCTAssertEqual(item.nameCount, 3)
        XCTAssertEqual(item.nameData, Data(bytes: [0x6f, 0x6e, 0x65]))
        XCTAssertEqual(item.name, "one")
        
        XCTAssertFalse(item.isNull)
        XCTAssertTrue(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertNil(item.parentItem)
        
        XCTAssertEqual(item.availableValueByteCount, 0)
        XCTAssertEqual(item.usedValueByteCount, 0)
    }
    
    func test_UInt8() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        UInt8(44).storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.uint8 { XCTAssertEqual(b, 44) } else { XCTFail() }
        
        item.uint8 = 55
        
        if let b = item.uint8 { XCTAssertEqual(b, 55) } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(item.type, ItemType.uint8)
        
        XCTAssertEqual(item.count, 55)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertTrue(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 0)
        XCTAssertEqual(item.usedValueByteCount, 0)
    }

    func test_UInt16() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        UInt16(44).storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.uint16 { XCTAssertEqual(b, 44) } else { XCTFail() }
        
        item.uint16 = 0x5533
        
        if let b = item.uint16 { XCTAssertEqual(b, 0x5533) } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(item.type, ItemType.uint16)
        
        XCTAssertEqual(item.count, 0x5533)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertTrue(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 0)
        XCTAssertEqual(item.usedValueByteCount, 0)
    }

    func test_UInt32() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        UInt32(44).storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.uint32 { XCTAssertEqual(b, 44) } else { XCTFail() }
        
        item.uint32 = 0x55332211
        
        if let b = item.uint32 { XCTAssertEqual(b, 0x55332211) } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(item.type, ItemType.uint32)
        
        XCTAssertEqual(item.count, 0x55332211)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertTrue(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 0)
        XCTAssertEqual(item.usedValueByteCount, 0)
    }

    func test_UInt64() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        UInt64(44).storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.uint64 { XCTAssertEqual(b, 44) } else { XCTFail() }
        
        item.uint64 = 0x55332211
        
        if let b = item.uint64 { XCTAssertEqual(b, 0x55332211) } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(item.type, ItemType.uint64)
        
        XCTAssertEqual(item.count, 0)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertTrue(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 8)
        XCTAssertEqual(item.usedValueByteCount, 8)
    }

    func test_Int8() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        Int8(44).storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.int8 { XCTAssertEqual(b, 44) } else { XCTFail() }
        
        item.int8 = 55
        
        if let b = item.int8 { XCTAssertEqual(b, 55) } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(item.type, ItemType.int8)
        
        XCTAssertEqual(item.count, 55)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertTrue(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 0)
        XCTAssertEqual(item.usedValueByteCount, 0)
    }
    
    func test_Int16() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        Int16(44).storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.int16 { XCTAssertEqual(b, 44) } else { XCTFail() }
        
        item.int16 = 0x5533
        
        if let b = item.int16 { XCTAssertEqual(b, 0x5533) } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(item.type, ItemType.int16)
        
        XCTAssertEqual(item.count, 0x5533)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertTrue(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 0)
        XCTAssertEqual(item.usedValueByteCount, 0)
    }
    
    func test_Int32() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        Int32(44).storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.int32 { XCTAssertEqual(b, 44) } else { XCTFail() }
        
        item.int32 = 0x55332211
        
        if let b = item.int32 { XCTAssertEqual(b, 0x55332211) } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(item.type, ItemType.int32)
        
        XCTAssertEqual(item.count, 0x55332211)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertTrue(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 0)
        XCTAssertEqual(item.usedValueByteCount, 0)
    }
    
    func test_Int64() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        Int64(44).storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.int64 { XCTAssertEqual(b, 44) } else { XCTFail() }
        
        item.int64 = 0x55332211
        
        if let b = item.int64 { XCTAssertEqual(b, 0x55332211) } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(item.type, ItemType.int64)
        
        XCTAssertEqual(item.count, 0)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertTrue(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 8)
        XCTAssertEqual(item.usedValueByteCount, 8)
    }

    func test_Binary() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        Data(bytes: [0x01, 0x20, 0x33]).storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.binary { XCTAssertEqual(b, Data(bytes: [0x01, 0x20, 0x33])) } else { XCTFail() }
        
        item.binary = Data(bytes: [0x41, 0x40, 0x43, 0x44])
        
        if let b = item.binary { XCTAssertEqual(b, Data(bytes: [0x41, 0x40, 0x43, 0x44])) } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(item.type, ItemType.binary)
        
        XCTAssertEqual(item.count, 4)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertTrue(item.isBinary)
        XCTAssertFalse(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 8)
        XCTAssertEqual(item.usedValueByteCount, 4)
    }

    func test_String() {
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: nil)
        
        "Hello".storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        if let b = item.string { XCTAssertEqual(b, "Hello") } else { XCTFail() }
        
        item.string = "Bye"
        
        if let b = item.string { XCTAssertEqual(b, "Bye") } else { XCTFail() }
        
        XCTAssertNil(item.bool)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        
        XCTAssertEqual(item.type, ItemType.string)
        
        XCTAssertEqual(item.count, 3)
        
        XCTAssertFalse(item.isNull)
        XCTAssertFalse(item.isBool)
        XCTAssertFalse(item.isUInt8)
        XCTAssertFalse(item.isUInt16)
        XCTAssertFalse(item.isUInt32)
        XCTAssertFalse(item.isUInt64)
        XCTAssertFalse(item.isInt8)
        XCTAssertFalse(item.isInt16)
        XCTAssertFalse(item.isInt32)
        XCTAssertFalse(item.isInt64)
        XCTAssertFalse(item.isFloat32)
        XCTAssertFalse(item.isFloat64)
        XCTAssertFalse(item.isBinary)
        XCTAssertTrue(item.isString)
        XCTAssertFalse(item.isArray)
        XCTAssertFalse(item.isDictionary)
        XCTAssertFalse(item.isSequence)
        
        XCTAssertEqual(item.availableValueByteCount, 8)
        XCTAssertEqual(item.usedValueByteCount, 3)
    }

}
