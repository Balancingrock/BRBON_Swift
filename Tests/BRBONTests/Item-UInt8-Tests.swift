//
//  Item-UInt8-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/11/17.
//
//

import XCTest
import BRBON

class Item_UInt8_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test() {
        
        var item = Item.uint8(200)
            
        XCTAssertEqual(item.type, .uint8)
        XCTAssertEqual(item.uint8, 200)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 16)
        XCTAssertEqual(item.nameByteCount, 0)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertNil(item.name)
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x06, 0, 0, 0, 8, 0, 0, 0, 200, 0, 0, 0, 0, 0, 0, 0]))
        
        
        item = Item.uint8(200, name: "Test")!
        
        XCTAssertEqual(item.type, .uint8)
        XCTAssertEqual(item.uint8, 200)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 24)
        XCTAssertEqual(item.nameByteCount, 8)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item.name, "Test")
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x06, 0, 0, 8, 16, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 200, 0, 0, 0, 0, 0, 0, 0]))

        
        item = Item.uint8(200, name: "Test", fixedItemByteCount: 32)!
        
        XCTAssertEqual(item.type, .uint8)
        XCTAssertEqual(item.uint8, 200)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 32)
        XCTAssertEqual(item.nameByteCount, 8)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertEqual(item.unusedByteCount, 15)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertEqual(item.fixedItemByteCount, 32)
        XCTAssertEqual(item.name, "Test")
        item.endianBytes(.little).printBytes()
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x06, 0x40, 0, 8, 24, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))

        
        item = Item(UInt8(200))
        
        XCTAssertEqual(item.type, .uint8)
        XCTAssertEqual(item.uint8, 200)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 16)
        XCTAssertEqual(item.nameByteCount, 0)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertNil(item.name)
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x06, 0, 0, 0, 8, 0, 0, 0, 200, 0, 0, 0, 0, 0, 0, 0]))

        
        item = Item(UInt8(200), name: "Test")!
        
        XCTAssertEqual(item.type, .uint8)
        XCTAssertEqual(item.uint8, 200)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 24)
        XCTAssertEqual(item.nameByteCount, 8)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item.name, "Test")
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x06, 0, 0, 8, 16, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 200, 0, 0, 0, 0, 0, 0, 0]))

        
        item.uint8 = nil
        
        XCTAssertEqual(item.type, .uint8)
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 24)
        XCTAssertEqual(item.nameByteCount, 8)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item.name, "Test")
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x06, 0x80, 0, 8, 16, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 200, 0, 0, 0, 0, 0, 0, 0]))

        
        item.uint8 = 180
        
        XCTAssertEqual(item.type, .uint8)
        XCTAssertEqual(item.uint8, 180)
        XCTAssertNil(item.parent)
        XCTAssertEqual(item.byteCount, 24)
        XCTAssertEqual(item.nameByteCount, 8)
        XCTAssertEqual(item.valueByteCount, 8)
        XCTAssertNil(item.unusedByteCount)
        XCTAssertNil(item.fixedNameByteCount)
        XCTAssertNil(item.fixedItemByteCount)
        XCTAssertEqual(item.name, "Test")
        XCTAssertEqual(item.endianBytes(.little), Data(bytes: [0x06, 0, 0, 8, 16, 0, 0, 0, 0x25, 0x38, 4, 84, 101, 115, 116, 0, 180, 0, 0, 0, 0, 0, 0, 0]))
    }
}
