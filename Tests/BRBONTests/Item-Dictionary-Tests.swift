//
//  Item-Dictionary-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 09/11/17.
//
//

import XCTest
import BRBON


class Item_Dictionary_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test() {

        
        // Create dictionary
        
        guard let dict = Item.dictionary(fixedItemByteCount: 64) else { XCTFail(); return }
        
        
        // Test initial state
        
        XCTAssertEqual(dict.type, .dictionary)
        XCTAssertTrue(dict.isDictionary)
        XCTAssertEqual(dict.count, 0)
        XCTAssertNil(dict.parent)
        XCTAssertEqual(dict.byteCount, 64)
        XCTAssertEqual(dict.nameByteCount, 0)
        XCTAssertEqual(dict.valueByteCount, 8)
        XCTAssertEqual(dict.unusedByteCount, 48)
        XCTAssertNil(dict.fixedNameByteCount)
        XCTAssertEqual(dict.fixedItemByteCount, 64)
        XCTAssertNil(dict.name)
        XCTAssertNil(dict.elementType)
        XCTAssertNil(dict.elementByteCount)

        XCTAssertEqual(dict.endianBytes(.little), Data(bytes: [0x0E, 0x40, 0, 0, 56, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        
        
        // Failure to add an item because the name is missing
        
        XCTAssertFalse(dict.add(Item.uint8(4)))
        XCTAssertEqual(dict.count, 0)
        XCTAssertEqual(dict.unusedByteCount, 48)

        
        // Add an item
        
        XCTAssertTrue(dict.add(Item.uint8(4), for: "aa"))
        XCTAssertEqual(dict.count, 1)
        XCTAssertEqual(dict.unusedByteCount, 24)
        
        
        // Retrieve the item

        if let aa = dict.item(for: "aa") {
            XCTAssertNotNil(aa.parent)
            if let aav = aa.uint8 {
                XCTAssertEqual(aav, 4)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
        
        
        // Overwrite an item
        
        XCTAssertTrue(dict.add(Item.uint8(5), for: "aa"))
        XCTAssertEqual(dict.count, 1)
        XCTAssertEqual(dict.unusedByteCount, 24)
        
        
        // Retrieve the item
        
        if let aa = dict.item(for: "aa") {
            XCTAssertNotNil(aa.parent)
            if let aav = aa.uint8 {
                XCTAssertEqual(aav, 5)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }

        
        // Add a second item
        
        XCTAssertTrue(dict.add(Item.int8(3), for: "bb"))
        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict.unusedByteCount, 0)

        
        // Fail to find a non-existing name
        
        XCTAssertNil(dict.item(for: "cc"))
        
        
        // Fail to remove item for non-existing name
        
        XCTAssertNil(dict.remove(with: "cc"))

        
        // Remove succesful
        
        guard let aa = dict.remove(with: "aa") else { XCTFail(); return }
        
        XCTAssertNil(aa.parent)
        if let aav = aa.uint8 {
            XCTAssertEqual(aav, 5)
        } else {
            XCTFail()
        }
        XCTAssertEqual(dict.count, 1)

        
        // Add the item again
        
        XCTAssertTrue(dict.add(aa))
        XCTAssertEqual(dict.count, 2)
        XCTAssertNotNil(aa.parent)
        

        // And remove it again
        
        if let aaa = dict.remove(aa) {
            XCTAssertNil(aaa.parent)
            if let aav = aaa.uint8 {
                XCTAssertEqual(aav, 5)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
        XCTAssertEqual(dict.count, 1)


        // Test subscript access
        
        XCTAssertNil(dict["cc"])
        if let bb = dict["bb"] {
            XCTAssertTrue(bb.isInt8)
            dict["bb"]?.int8 = 7
            XCTAssertEqual(dict["bb"]?.int8 ?? 0, 7)
        } else {
            XCTFail()
        }
        
        
        // Adding through subscript
        
        dict["aa"] = aa
        XCTAssertEqual(dict.count, 2)

        dict.endianBytes(.little).printBytes()
        
    }
    
    func testFromBytes() {
        
        let data = Data(bytes: [0xe, 0x40, 0x0, 0x0, 0x38, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x8, 0x10, 0x0, 0x0, 0x0, 0xa8, 0x89, 0x2, 0x62, 0x62, 0x0, 0x0, 0x0, 0x7, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x6, 0x0, 0x0, 0x8, 0x10, 0x0, 0x0, 0x0, 0xe8, 0x78, 0x2, 0x61, 0x61, 0x0, 0x0, 0x0, 0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])
        var ptr = (data as NSData).bytes
        var cnt = UInt32(data.count)
        
        if let dict = Item(&ptr, count: &cnt, endianness: .little) {
            XCTAssertEqual(dict.count, 2)
            XCTAssertEqual(dict["aa"]?.uint8 ?? 0, 5)
            XCTAssertEqual(dict["bb"]?.int8 ?? 0, 7)
        } else {
            XCTFail()
        }
    }
}
