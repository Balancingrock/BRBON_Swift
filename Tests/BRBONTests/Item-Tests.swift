//
//  Item-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/11/17.
//
//

import XCTest
@testable import BRBON

extension Data {
    
    func printBytes() {
        
        let str = self.reduce("") {
            return $0 + "0x\(String($1, radix: 16, uppercase: false)), "
        }
        print(str)
    }
}

class Item_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDefaultInit() {
        
        let item = Item(ItemValue(true))
        
        XCTAssertEqual(item.header.type, .bool)
        XCTAssertNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .bool)
        XCTAssertEqual(item.type, .bool)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 16)
        XCTAssertEqual(item.nameByteCount, 0)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item._fixedItemByteCount, 0)
        XCTAssertNil(item.name)
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x01, 0, 0, 0, 8, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0]))
        
        
        let dup = item.duplicate
        
        XCTAssertEqual(dup.header.type, .bool)
        XCTAssertNil(dup._name)
        XCTAssertNotNil(dup._value)
        XCTAssertEqual(dup._value.type, .bool)
        XCTAssertEqual(dup.type, .bool)
        XCTAssertNil(dup.parent)
        XCTAssertEqual(dup.byteCount, 16)
        XCTAssertEqual(dup.nameByteCount, 0)
        XCTAssertEqual(dup.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(dup.fixedNameByteCount)
        XCTAssertNil(dup.fixedItemByteCount)
        XCTAssertEqual(dup._fixedItemByteCount, 0)
        XCTAssertNil(dup.name)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x01, 0, 0, 0, 8, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0]))

        
        var data = Data(bytes: [0x01, 0, 0, 0, 8, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let anItem = Item(&bytePtr, count: &counter, endianness: .little) {
            
            XCTAssertEqual(anItem.header.type, .bool)
            XCTAssertNil(anItem._name)
            XCTAssertNotNil(anItem._value)
            XCTAssertEqual(anItem._value.type, .bool)
            XCTAssertEqual(anItem.type, .bool)
            XCTAssertNil(anItem.parent)
            XCTAssertEqual(anItem.byteCount, 16)
            XCTAssertEqual(anItem.nameByteCount, 0)
            XCTAssertEqual(anItem.valueByteCount, 8)
            XCTAssertNil(item.unusedByteCount)
            XCTAssertNil(anItem.fixedNameByteCount)
            XCTAssertNil(anItem.fixedItemByteCount)
            XCTAssertEqual(anItem._fixedItemByteCount, 0)
            XCTAssertNil(anItem.name)
            XCTAssertEqual(anItem.endianBytes(.little), Data(bytes: [0x01, 0, 0, 0, 8, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0]))

        } else {
            XCTFail()
        }
    }
    
    func testInitWithName() {
        
        let item = Item(ItemValue(UInt16(4660)), name: ItemName("Test"))
        
        XCTAssertEqual(item.header.type, .uint16)
        XCTAssertNotNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .uint16)
        XCTAssertEqual(item.type, .uint16)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 24)
        XCTAssertEqual(item.nameByteCount, 8)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item._fixedItemByteCount, 0)
        XCTAssertEqual(item.name, "Test")
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x07, 0, 0, 8, 16, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 0x34, 0x12, 0, 0, 0, 0, 0, 0]))
        
        
        let dup = item.duplicate
        
        XCTAssertEqual(dup.header.type, .uint16)
        XCTAssertNotNil(dup._name)
        XCTAssertNotNil(dup._value)
        XCTAssertEqual(dup._value.type, .uint16)
        XCTAssertEqual(dup.type, .uint16)
        XCTAssertNil(dup.parent)
        XCTAssertEqual(dup.byteCount, 24)
        XCTAssertEqual(dup.nameByteCount, 8)
        XCTAssertEqual(dup.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(dup.fixedNameByteCount)
        XCTAssertNil(dup.fixedItemByteCount)
        XCTAssertEqual(dup._fixedItemByteCount, 0)
        XCTAssertEqual(dup.name, "Test")
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x07, 0, 0, 8, 16, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 0x34, 0x12, 0, 0, 0, 0, 0, 0]))
        
        
        var data = Data(bytes: [0x07, 0, 0, 8, 16, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 0x34, 0x12, 0, 0, 0, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let anItem = Item(&bytePtr, count: &counter, endianness: .little) {
            
            XCTAssertEqual(anItem.header.type, .uint16)
            XCTAssertNotNil(anItem._name)
            XCTAssertNotNil(anItem._value)
            XCTAssertEqual(anItem._value.type, .uint16)
            XCTAssertEqual(anItem.type, .uint16)
            XCTAssertNil(anItem.parent)
            XCTAssertEqual(anItem.byteCount, 24)
            XCTAssertEqual(anItem.nameByteCount, 8)
            XCTAssertEqual(anItem.valueByteCount, 8)
            XCTAssertNil(item.unusedByteCount)
            XCTAssertNil(anItem.fixedNameByteCount)
            XCTAssertNil(anItem.fixedItemByteCount)
            XCTAssertEqual(anItem._fixedItemByteCount, 0)
            XCTAssertEqual(anItem.name, "Test")
            XCTAssertEqual(anItem.endianBytes(.little), Data(bytes: [0x07, 0, 0, 8, 16, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 0x34, 0x12, 0, 0, 0, 0, 0, 0]))
            
        } else {
            XCTFail()
        }
    }
    
    func testChangeName() {
        
        let item = Item(ItemValue(UInt16(4660)), name: ItemName("Test"))
        
        XCTAssertEqual(item.header.type, .uint16)
        XCTAssertNotNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .uint16)
        XCTAssertEqual(item.type, .uint16)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 24)
        XCTAssertEqual(item.nameByteCount, 8)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item._fixedItemByteCount, 0)
        XCTAssertEqual(item.name, "Test")
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x07, 0, 0, 8, 16, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 0x34, 0x12, 0, 0, 0, 0, 0, 0]))

        
        item.name = "Aap"
        
        XCTAssertEqual(item.header.type, .uint16)
        XCTAssertNotNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .uint16)
        XCTAssertEqual(item.type, .uint16)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 24)
        XCTAssertEqual(item.nameByteCount, 8)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item._fixedItemByteCount, 0)
        XCTAssertEqual(item.name, "Aap")
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x07, 0, 0, 8, 16, 0, 0, 0, 0x78, 0x60, 3, 65, 97, 112, 0, 0, 0x34, 0x12, 0, 0, 0, 0, 0, 0]))

        
        item.name = "AapAap"
        
        XCTAssertEqual(item.header.type, .uint16)
        XCTAssertNotNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .uint16)
        XCTAssertEqual(item.type, .uint16)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 32)
        XCTAssertEqual(item.nameByteCount, 16)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item._fixedItemByteCount, 0)
        XCTAssertEqual(item.name, "AapAap")
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x07, 0, 0, 16, 24, 0, 0, 0, 0xd0, 0x79, 6, 65, 97, 112, 65, 97, 112, 0, 0, 0, 0, 0, 0, 0, 0x34, 0x12, 0, 0, 0, 0, 0, 0]))

        
        item.name = nil
        
        XCTAssertEqual(item.header.type, .uint16)
        XCTAssertNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .uint16)
        XCTAssertEqual(item.type, .uint16)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 16)
        XCTAssertEqual(item.nameByteCount, 0)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item._fixedItemByteCount, 0)
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x07, 0, 0, 0, 8, 0, 0, 0, 0x34, 0x12, 0, 0, 0, 0, 0, 0]))
    }
    
    func testFixedNameLength() {
        
        let item = Item(ItemValue(true))
        item.fixedNameByteCount = 16
        
        XCTAssertEqual(item.header.type, .bool)
        XCTAssertNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .bool)
        XCTAssertEqual(item.type, .bool)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 32)
        XCTAssertEqual(item.nameByteCount, 16)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertEqual(item.fixedNameByteCount, 16)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item._fixedItemByteCount, 0)
        XCTAssertNil(item.name)
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x01, 0x20, 0, 16, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0]))

        
        var data = Data(bytes: [0x01, 0x20, 0, 16, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let anItem = Item(&bytePtr, count: &counter, endianness: .little) {

            XCTAssertEqual(anItem.header.type, .bool)
            XCTAssertNil(anItem._name)
            XCTAssertNotNil(anItem._value)
            XCTAssertEqual(anItem._value.type, .bool)
            XCTAssertEqual(anItem.type, .bool)
            XCTAssertNil(anItem.parent)
            XCTAssertEqual(anItem.byteCount, 32)
            XCTAssertEqual(anItem.nameByteCount, 16)
            XCTAssertEqual(anItem.valueByteCount, 8)
            XCTAssertNil(item.unusedByteCount)
            XCTAssertEqual(anItem.fixedNameByteCount, 16)
            XCTAssertNil(anItem.fixedItemByteCount)
            XCTAssertEqual(anItem._fixedItemByteCount, 0)
            XCTAssertNil(anItem.name)
            XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x01, 0x20, 0, 16, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0]))
        }
        
        
        item.fixedNameByteCount = 8
        
        XCTAssertEqual(item.fixedNameByteCount, 8)
        
        item.fixedNameByteCount = 18

        XCTAssertEqual(item.fixedNameByteCount, 8)

        item.fixedNameByteCount = 16
        XCTAssertEqual(item.fixedNameByteCount, 16)
        
        item.name = "AapAap"
        item.fixedNameByteCount = 8
        XCTAssertEqual(item.fixedNameByteCount, 16)

        item.fixedNameByteCount = 248
        XCTAssertEqual(item.fixedNameByteCount, 248)
        
        item.fixedNameByteCount = 253
        XCTAssertEqual(item.fixedNameByteCount, 248)
    }
    
    func testFixedItemSize() {
        
        var item = Item(ItemValue(true), fixedItemByteCount: 32)
        
        XCTAssertEqual(item.header.type, .bool)
        XCTAssertNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .bool)
        XCTAssertEqual(item.type, .bool)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 32)
        XCTAssertEqual(item.nameByteCount, 0)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertEqual(item.unusedByteCount, 23)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertEqual(item.fixedItemByteCount, 32)
        XCTAssertEqual(item._fixedItemByteCount, 32)
        XCTAssertNil(item.name)
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x01, 0x40, 0, 0, 24, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))

        
        item.fixedItemByteCount = nil
        
        XCTAssertEqual(item.header.type, .bool)
        XCTAssertNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .bool)
        XCTAssertEqual(item.type, .bool)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 16)
        XCTAssertEqual(item.nameByteCount, 0)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item._fixedItemByteCount, 0)
        XCTAssertNil(item.name)
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x01, 0, 0, 0, 8, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0]))

        
        var data = Data(bytes: [0x01, 0x40, 0, 0, 24, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let anItem = Item(&bytePtr, count: &counter, endianness: .little) {
            
            XCTAssertEqual(anItem.header.type, .bool)
            XCTAssertNil(anItem._name)
            XCTAssertNotNil(anItem._value)
            XCTAssertEqual(anItem._value.type, .bool)
            XCTAssertEqual(anItem.type, .bool)
            XCTAssertNil(anItem.parent)
            XCTAssertEqual(anItem.byteCount, 32)
            XCTAssertEqual(anItem.nameByteCount, 0)
            XCTAssertEqual(anItem.valueByteCount, 8)
            XCTAssertEqual(anItem.unusedByteCount, 23)
            XCTAssertNil(anItem.fixedNameByteCount)
            XCTAssertEqual(anItem.fixedItemByteCount, 32)
            XCTAssertEqual(anItem._fixedItemByteCount, 32)
            XCTAssertNil(anItem.name)
            XCTAssertEqual(anItem.endianBytes(.little), Data(bytes: [0x01, 0x40, 0, 0, 24, 0, 0, 0, 0x01, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        }
        
        
        item = Item(ItemValue("AapAapAap"))
        
        XCTAssertEqual(item.header.type, .string)
        XCTAssertNil(item._name)
        XCTAssertNotNil(item._value)
        XCTAssertEqual(item._value.type, .string)
        XCTAssertEqual(item.type, .string)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 24)
        XCTAssertEqual(item.nameByteCount, 0)
        XCTAssertEqual(item.valueByteCount, 16)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item._fixedItemByteCount, 0)
        XCTAssertNil(item.name)
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x0C, 0x0, 0, 0, 16, 0, 0, 0, 0x09, 0, 0, 0, 65, 97, 112, 65, 97, 112, 65, 97, 112, 0, 0, 0]))

        
        item.fixedItemByteCount = 6
        XCTAssertEqual(item._fixedItemByteCount, 0)
        
        item.fixedItemByteCount = 8
        XCTAssertEqual(item._fixedItemByteCount, 24)

        item.fixedItemByteCount = 32
        XCTAssertEqual(item._fixedItemByteCount, 32)
    }
}
