//
//  Item-Array-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 09/11/17.
//
//

import XCTest
import BRBON


class Item_Array_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateAppend() {

        let array = Item.array(elementType: .uint8, elementByteCount: 1)
        
        XCTAssertEqual(array.type, .array)
        XCTAssertTrue(array.isArray)
        XCTAssertNil(array.uint8)
        XCTAssertEqual(array.count, 0)
        XCTAssertNil(array.parent)
        XCTAssertEqual(array.byteCount, 16)
        XCTAssertEqual(array.nameByteCount, 0)
        XCTAssertEqual(array.valueByteCount, 8)
        XCTAssertNil(array.unusedByteCount)
        XCTAssertNil(array.fixedNameByteCount)
        XCTAssertNil(array.fixedItemByteCount)
        XCTAssertNil(array.name)
        XCTAssertEqual(array.elementType, .uint8)
        XCTAssertEqual(array.elementByteCount, 1)
        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0, 0, 0, 8, 0, 0, 0, 0x01, 0, 0, 0x06, 0, 0, 0, 0]))

        var data = Data(bytes: [0x0D, 0, 0, 0, 8, 0, 0, 0, 0x01, 0, 0, 0x06, 0, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let item = Item(&bytePtr, count: &counter, endianness: .little) {
            
            XCTAssertEqual(item.type, .array)
            XCTAssertNil(item.uint8)
            XCTAssertNil(item.parent)
            XCTAssertEqual(item.byteCount, 16)
            XCTAssertEqual(item.nameByteCount, 0)
            XCTAssertEqual(item.valueByteCount, 8)
            XCTAssertNil(item.unusedByteCount)
            XCTAssertNil(item.fixedNameByteCount)
            XCTAssertNil(item.fixedItemByteCount)
            XCTAssertNil(item.name)
            XCTAssertEqual(item.elementType, .uint8)
            XCTAssertEqual(item.elementByteCount, 1)
            item.endianBytes(.little).printBytes()
            XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x0D, 0, 0, 0, 8, 0, 0, 0, 0x01, 0, 0, 0x06, 0, 0, 0, 0]))
            
        } else {
            XCTFail()
        }
        
        
        // Attempt to append the wrong item type
        
        let element1 = Item.int8(100)
        
        XCTAssertFalse(array.append(element1))
        
        XCTAssertEqual(array.type, .array)
        XCTAssertTrue(array.isArray)
        XCTAssertNil(array.uint8)
        XCTAssertEqual(array.count, 0)
        XCTAssertNil(array.parent)
        XCTAssertEqual(array.byteCount, 16)
        XCTAssertEqual(array.nameByteCount, 0)
        XCTAssertEqual(array.valueByteCount, 8)
        XCTAssertNil(array.unusedByteCount)
        XCTAssertNil(array.fixedNameByteCount)
        XCTAssertNil(array.fixedItemByteCount)
        XCTAssertNil(array.name)
        XCTAssertEqual(array.elementType, .uint8)
        XCTAssertEqual(array.elementByteCount, 1)
        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0, 0, 0, 8, 0, 0, 0, 0x01, 0, 0, 0x06, 0, 0, 0, 0]))

        
        // Attempt to append the right type but with a name
        
        let element1a = Item.uint8(200, name: "Test")
        XCTAssertFalse(array.append(element1a))
        XCTAssertEqual(array.count, 0)

        
        // Attempt an item of the right kind, without a name but with a fixed name byte count
        
        let element1b = Item.uint8(200)
        element1b.fixedNameByteCount = 16
        XCTAssertFalse(array.append(element1b))
        XCTAssertEqual(array.count, 0)

        
        // Append the right kind of element
        
        let element2 = Item.uint8(200)

        XCTAssertTrue(array.append(element2))
        
        XCTAssertEqual(array.type, .array)
        XCTAssertTrue(array.isArray)
        XCTAssertNil(array.uint8)
        XCTAssertEqual(array.count, 1)
        XCTAssertNil(array.parent)
        XCTAssertEqual(array.byteCount, 24)
        XCTAssertEqual(array.nameByteCount, 0)
        XCTAssertEqual(array.valueByteCount, 16)
        XCTAssertNil(array.unusedByteCount)
        XCTAssertNil(array.fixedNameByteCount)
        XCTAssertNil(array.fixedItemByteCount)
        XCTAssertNil(array.name)
        XCTAssertEqual(array.elementType, .uint8)
        XCTAssertEqual(array.elementByteCount, 1)
        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0, 0, 0, 16, 0, 0, 0, 0x01, 0, 0, 0x06, 1, 0, 0, 0, 0xC8, 0, 0, 0, 0, 0, 0, 0]))

        if let parent = element2.parent {
            XCTAssertTrue(parent === array)
        } else {
            XCTFail()
        }
    
        // Fix the item count
        
        array.fixedItemByteCount = 24
        XCTAssertEqual(array.fixedItemByteCount, 24)
        XCTAssertEqual(array.unusedByteCount, 7)
        
        // Add 7 more items
        
        XCTAssertTrue(array.append(Item.uint8(1)))
        XCTAssertTrue(array.append(Item.uint8(2)))
        XCTAssertTrue(array.append(Item.uint8(3)))
        XCTAssertTrue(array.append(Item.uint8(4)))
        XCTAssertTrue(array.append(Item.uint8(5)))
        XCTAssertTrue(array.append(Item.uint8(6)))
        XCTAssertTrue(array.append(Item.uint8(7)))
        
        // The eigth should fail due to bytecount constraints
        
        XCTAssertFalse(array.append(Item.uint8(8)))

        // Nullify the limit
        
        array.fixedItemByteCount = nil

        // Try again
        
        XCTAssertTrue(array.append(Item.uint8(8)))

        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0, 0, 0, 24, 0, 0, 0, 0x01, 0, 0, 0x06, 9, 0, 0, 0, 0xC8, 1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0]))

        
        // Append a wrong named item
        
        XCTAssertFalse(array.append(Item.uint8(6, name: "Test")))
    }
    
    func testInsert() {
        
        let array = Item.array(elementType: .string, elementByteCount: 8, fixedItemByteCount: 40)!
        
        XCTAssertEqual(array.type, .array)
        XCTAssertTrue(array.isArray)
        XCTAssertEqual(array.count, 0)
        XCTAssertNil(array.parent)
        XCTAssertEqual(array.byteCount, 40)
        XCTAssertEqual(array.nameByteCount, 0)
        XCTAssertEqual(array.valueByteCount, 8)
        XCTAssertEqual(array.unusedByteCount, 24)
        XCTAssertNil(array.fixedNameByteCount)
        XCTAssertEqual(array.fixedItemByteCount, 40)
        XCTAssertNil(array.name)
        XCTAssertEqual(array.elementType, .string)
        XCTAssertEqual(array.elementByteCount, 8)
        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))

        XCTAssertTrue(array.append(Item.string("aa")))
        XCTAssertTrue(array.append(Item.string("bb")))
        
        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 2, 0, 0, 0, 2, 0, 0, 0, 97, 97, 0, 0, 2, 0, 0, 0, 98, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))

        XCTAssertTrue(array.insert(Item.string("cc"), at: 0))
        
        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 3, 0, 0, 0, 2, 0, 0, 0, 99, 99, 0, 0, 2, 0, 0, 0, 97, 97, 0, 0, 2, 0, 0, 0, 98, 98, 0, 0]))

        var data = Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 3, 0, 0, 0, 2, 0, 0, 0, 99, 99, 0, 0, 2, 0, 0, 0, 97, 97, 0, 0, 2, 0, 0, 0, 98, 98, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let item = Item(&bytePtr, count: &counter, endianness: .little) {
            
            XCTAssertEqual(array.type, .array)
            XCTAssertTrue(array.isArray)
            XCTAssertEqual(array.count, 3)
            XCTAssertNil(array.parent)
            XCTAssertEqual(array.byteCount, 40)
            XCTAssertEqual(array.nameByteCount, 0)
            XCTAssertEqual(array.valueByteCount, 32)
            XCTAssertEqual(array.unusedByteCount, 0)
            XCTAssertNil(array.fixedNameByteCount)
            XCTAssertEqual(array.fixedItemByteCount, 40)
            XCTAssertNil(array.name)
            XCTAssertEqual(array.elementType, .string)
            XCTAssertEqual(array.elementByteCount, 8)
            XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 3, 0, 0, 0, 2, 0, 0, 0, 99, 99, 0, 0, 2, 0, 0, 0, 97, 97, 0, 0, 2, 0, 0, 0, 98, 98, 0, 0]))
            
        } else {
            XCTFail()
        }
    }
    
    func testReplace() {
        
        let array = Item.array(elementType: .string, elementByteCount: 8, fixedItemByteCount: 40)!
        
        XCTAssertEqual(array.type, .array)
        XCTAssertTrue(array.isArray)
        XCTAssertEqual(array.count, 0)
        XCTAssertNil(array.parent)
        XCTAssertEqual(array.byteCount, 40)
        XCTAssertEqual(array.nameByteCount, 0)
        XCTAssertEqual(array.valueByteCount, 8)
        XCTAssertEqual(array.unusedByteCount, 24)
        XCTAssertNil(array.fixedNameByteCount)
        XCTAssertEqual(array.fixedItemByteCount, 40)
        XCTAssertNil(array.name)
        XCTAssertEqual(array.elementType, .string)
        XCTAssertEqual(array.elementByteCount, 8)
        XCTAssertTrue(array.append(Item.string("aa")))
        XCTAssertTrue(array.append(Item.string("bb")))
        
        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 2, 0, 0, 0, 2, 0, 0, 0, 97, 97, 0, 0, 2, 0, 0, 0, 98, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        
        if let rep = array.replace(Item.string("dd"), at: 1) {
            
            XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 2, 0, 0, 0, 2, 0, 0, 0, 97, 97, 0, 0, 2, 0, 0, 0, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))

            XCTAssertEqual(rep.string, "bb")
            XCTAssertNil(rep.parent)
            
        } else {
            XCTFail()
        }
    }
    
    
    func testRemove() {
        
        let array = Item.array(elementType: .string, elementByteCount: 8, fixedItemByteCount: 40)!
        
        XCTAssertEqual(array.type, .array)
        XCTAssertTrue(array.isArray)
        XCTAssertEqual(array.count, 0)
        XCTAssertNil(array.parent)
        XCTAssertEqual(array.byteCount, 40)
        XCTAssertEqual(array.nameByteCount, 0)
        XCTAssertEqual(array.valueByteCount, 8)
        XCTAssertEqual(array.unusedByteCount, 24)
        XCTAssertNil(array.fixedNameByteCount)
        XCTAssertEqual(array.fixedItemByteCount, 40)
        XCTAssertNil(array.name)
        XCTAssertEqual(array.elementType, .string)
        XCTAssertEqual(array.elementByteCount, 8)
        XCTAssertTrue(array.append(Item.string("aa")))
        XCTAssertTrue(array.append(Item.string("bb")))
        
        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 2, 0, 0, 0, 2, 0, 0, 0, 97, 97, 0, 0, 2, 0, 0, 0, 98, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        
        if let rep = array.remove(at: 0) {
            
            XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 1, 0, 0, 0, 2, 0, 0, 0, 98, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
            
            XCTAssertEqual(rep.string, "aa")
            XCTAssertNil(rep.parent)
            
        } else {
            XCTFail()
        }
    }

    
    func testRemoveAll() {
        
        let array = Item.array(elementType: .string, elementByteCount: 8, fixedItemByteCount: 40)!
        
        
        XCTAssertTrue(array.append(Item.string("aa")))
        XCTAssertTrue(array.append(Item.string("bb")))
        
        XCTAssertTrue(array.removeAll())

        XCTAssertEqual(array.type, .array)
        XCTAssertTrue(array.isArray)
        XCTAssertEqual(array.count, 0)
        XCTAssertNil(array.parent)
        XCTAssertEqual(array.byteCount, 40)
        XCTAssertEqual(array.nameByteCount, 0)
        XCTAssertEqual(array.valueByteCount, 8)
        XCTAssertEqual(array.unusedByteCount, 24)
        XCTAssertNil(array.fixedNameByteCount)
        XCTAssertEqual(array.fixedItemByteCount, 40)
        XCTAssertNil(array.name)
        XCTAssertEqual(array.elementType, .string)
        XCTAssertEqual(array.elementByteCount, 8)
        XCTAssertEqual(array.endianBytes(.little), Data(bytes: [0x0D, 0x40, 0, 0, 32, 0, 0, 0, 8, 0, 0, 0x0C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
    }
    
    func testSubscript() {
        
        let array = Item.array(elementType: .string, elementByteCount: 8, fixedItemByteCount: 40)!
        
        
        XCTAssertTrue(array.append(Item.string("aa")))
        XCTAssertTrue(array.append(Item.string("bb")))

        XCTAssertEqual(array[0]?.string, "aa")
        XCTAssertEqual(array[1]?.string, "bb")
        array[0] = Item.string("cc")
        XCTAssertEqual(array[0]?.string, "cc")
        XCTAssertEqual(array[1]?.string, "bb")
        XCTAssertEqual(array.count, 2)

    }
}
