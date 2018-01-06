//
//  ItemManager-Ptr-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 04/01/18.
//
//

import XCTest
@testable import BRBON

class ItemManager_Ptr_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateValueItemByteBuffer_Bool() {
        
        let itemManager = ItemManager.newDictionary()!
        
        var buffer = itemManager.createValueItemByteBuffer(true, parentOffset: 34)!
        
        var itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        var exp = Data(bytes: [
            0x01,                           // Type = .bool
                    0,                      // Options = 0
                            0,              // Flags = 0
                                    0,      // No name
            0,      0,      0,      0,      // Zero
            34,     0,      0,      0,      // Parentoffset = 34
            4,      0,      0,      0,      // NVR Length
            1,                              // Value
                    0,      0,      0       // Filler
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
        
        
        buffer = itemManager.createValueItemByteBuffer(false, name: "test", parentOffset: 34)!
        
        itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        exp = Data(bytes: [
            0x01,                           // Type = .bool
                    0,                      // Options = 0
                            0,              // Flags = 0
                                    8,      // Name field is 8 bytes.
            0,      0,      0,      0,      // Zero
            34,     0,      0,      0,      // Parentoffset = 34
            12,     0,      0,      0,      // NVR Length
            0x2e,   0xf8,                   // name hash
                            4,
                                    116,    // Name bytes
            101,    115,    116,            // Name bytes
                                    0,      // Name field filler
            0,                              // Value
                    0,      0,      0       // Filler
            ])
        
        XCTAssertEqual(itemData, exp)

    }
    
    func testCreateValueItemByteBuffer_int8() {
        
        let itemManager = ItemManager.newDictionary()!
        
        var buffer = itemManager.createValueItemByteBuffer(Int8(55), parentOffset: 34)!
        
        var itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        var exp = Data(bytes: [
            0x02,                           // Type = .int8
                    0,                      // Options = 0
                            0,              // Flags = 0
                                    0,      // No name
            0,      0,      0,      0,      // Zero
            34,     0,      0,      0,      // Parentoffset = 34
            4,      0,      0,      0,      // NVR Length
            55,                             // Value
                    0,      0,      0       // Filler
            ])
        
        XCTAssertEqual(itemData, exp)
        
        buffer.deallocate()
        
        
        buffer = itemManager.createValueItemByteBuffer(Int8(66), name: "test", parentOffset: 34)!
        
        itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        exp = Data(bytes: [
            0x02,                           // Type = .int8
                    0,                      // Options = 0
                            0,              // Flags = 0
                                    8,      // Name field is 8 bytes.
            0,      0,      0,      0,      // Zero
            34,     0,      0,      0,      // Parentoffset = 34
            12,     0,      0,      0,      // NVR Length
            0x2e,   0xf8,                   // name hash
                            4,
                                    116,    // Name bytes
            101,    115,    116,            // Name bytes
                                    0,      // Name field filler
            66,                             // Value
                    0,      0,      0       // Filler
            ])
        
        XCTAssertEqual(itemData, exp)
    }
    
    func testCreateValueItemByteBuffer_int16() {
        
        let itemManager = ItemManager.newDictionary()!
        
        let buffer = itemManager.createValueItemByteBuffer(Int16(0x1234), parentOffset: 34)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x03,                           // Type = .int16
                    0,                      // Options = 0
                            0,              // Flags = 0
                                    0,      // No name
            0,      0,      0,      0,      // Zero
            34,     0,      0,      0,      // Parentoffset = 34
            4,      0,      0,      0,      // NVR Length
            0x34,    0x12,                  // Value
                            0,      0       // Filler
            ])
        
        XCTAssertEqual(itemData, exp)
    }

    func testCreateValueItemByteBuffer_int32() {
        
        let itemManager = ItemManager.newDictionary()!
        
        let buffer = itemManager.createValueItemByteBuffer(Int32(0x12345678), parentOffset: 34)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x04,                           // Type = .int32
                    0,                      // Options = 0
                            0,              // Flags = 0
                                    0,      // No name
            0,      0,      0,      0,      // Zero
            34,     0,      0,      0,      // Parentoffset = 34
            4,      0,      0,      0,      // NVR Length
            0x78,   0x56,   0x34,   0x12    // Value
            ])
        
        XCTAssertEqual(itemData, exp)
    }

    func testCreateValueItemByteBuffer_int64() {
        
        let itemManager = ItemManager.newDictionary()!
        
        let buffer = itemManager.createValueItemByteBuffer(Int64(0x1234567887654321), parentOffset: 34)!
        
        let itemData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x05,                           // Type = .int64
                    0,                      // Options = 0
                            0,              // Flags = 0
                                    0,      // No name
            34,     0,      0,      0,      // Parentoffset = 34
            8,      0,      0,      0,      // NVR Length
            0x21,   0x43,   0x65,   0x87,   // Value
            0x78,   0x56,   0x34,   0x12
            ])
        
        XCTAssertEqual(itemData, exp)
    }

}
