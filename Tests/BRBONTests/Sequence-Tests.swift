//
//  Sequence-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 28/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class Sequence_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func test() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        let sm = ItemManager.createSequenceManager(endianness: Endianness.little)
        
        
        // Properties
        
        XCTAssertEqual(sm.root.itemType, ItemType.sequence)
        XCTAssertEqual(sm.root.count, 0)
        
        
        // Data structure
        
        var exp = Data(bytes: [
            0x13, 0x00, 0x00, 0x00,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(sm.data, exp)
        
        
        // Add a Null
        //
        // Should be successful and a portal can be created
        
        XCTAssertEqual(sm.root.appendItem(Null()), .success)
        
        let noNameNull: Portal = sm.root[0]
        
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)

        exp = Data(bytes: [
            0x13, 0x00, 0x00, 0x00,  0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            0x01, 0x00, 0x00, 0x00,  0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            ])
        
        XCTAssertEqual(sm.data, exp)
        
        
        // Add a Null with a name
        //
        // Should be successful and a portal can be created.
        // Existing portals remain valid.

        XCTAssertEqual(sm.root.appendItem(Null(), withName: "null"), .success)
        
        let nameNull: Portal = sm.root[1]
        
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)
        XCTAssertTrue(nameNull.isValid)
        XCTAssertTrue(nameNull.isNull)

        exp = Data(bytes: [
            0x13, 0x00, 0x00, 0x00,  0x40, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x02, 0x00, 0x00, 0x00,
            
            0x01, 0x00, 0x00, 0x00,  0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x01, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x20, 0x1f, 0x04, 0x6e,  0x75, 0x6c, 0x6c, 0x00,

            ])

        XCTAssertEqual(sm.data, exp)

        
        // Append an item
        //
        // Should be successful and a portal can be created.
        // Existing portals remain valid.

        let dm = ItemManager.createDictionaryManager()
        
        XCTAssertEqual(sm.root.appendItem(dm), .success)
        
        let noNameDict: Portal = sm.root[2]
        
        XCTAssertTrue(noNameDict.isValid)
        XCTAssertTrue(noNameDict.isDictionary)
        
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)
        XCTAssertTrue(nameNull.isValid)
        XCTAssertTrue(nameNull.isNull)

        
        // Append a named item
        //
        // Should be successful and a portal can be created.
        // Existing portals remain valid.

        let am = ItemManager.createArrayManager(elementType: .uint8, endianness: Endianness.little)
        
        XCTAssertEqual(sm.root.appendItem(am, withName: "array"), .success)
        
        let namedArray: Portal = sm.root[3]
        
        XCTAssertTrue(namedArray.isValid)
        XCTAssertTrue(namedArray.isArray)
        
        XCTAssertTrue(noNameDict.isValid)
        XCTAssertTrue(noNameDict.isDictionary)
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)
        XCTAssertTrue(nameNull.isValid)
        XCTAssertTrue(nameNull.isNull)

        
        // Add a child object to the noNameDict
        //
        // Should be success and all portals remain valid.
        
        XCTAssertEqual(noNameDict.updateItem(UInt8(0x55), withNameField: NameField("five")), .success)
        
        let fivePortal: Portal = noNameDict["five"]
        
        XCTAssertTrue(fivePortal.isValid)
        XCTAssertEqual(fivePortal.uint8, 0x55)

        XCTAssertTrue(namedArray.isValid)
        XCTAssertTrue(namedArray.isArray)
        XCTAssertTrue(noNameDict.isValid)
        XCTAssertTrue(noNameDict.isDictionary)
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)
        XCTAssertTrue(nameNull.isValid)
        XCTAssertTrue(nameNull.isNull)

        
        // Remove the noNameDict
        //
        // The noNameDict and fivePortal should become invalid, the others should remain valid.
        
        XCTAssertEqual(sm.root.removeItem(atIndex: 2), .success)
        
        XCTAssertFalse(noNameDict.isValid)
        XCTAssertFalse(fivePortal.isValid)
        
        XCTAssertTrue(namedArray.isValid)
        XCTAssertTrue(namedArray.isArray)
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)
        XCTAssertTrue(nameNull.isValid)
        XCTAssertTrue(nameNull.isNull)

        
        // Insert a dictionary item, and then add an item to this new dictionary
        //
        // All other portals remain valid
        
        XCTAssertEqual(sm.root.insertItem(atIndex: 2, withValue: dm), .success)
        
        let newDict: Portal = sm.root[2]
        
        XCTAssertEqual(newDict.updateItem(UInt8(0x66), withNameField: NameField("six")), .success)
        
        let sixPortal: Portal = newDict["six"]
        
        XCTAssertTrue(newDict.isValid)
        XCTAssertTrue(sixPortal.isValid)
        
        XCTAssertTrue(namedArray.isValid)
        XCTAssertTrue(namedArray.isArray)
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)
        XCTAssertTrue(nameNull.isValid)
        XCTAssertTrue(nameNull.isNull)

        
        // Replace the new dictionary portal
        //
        // Both the newDict and sixPortal become invalid, the others remain valid.
        
        XCTAssertEqual(sm.root.replaceItem(atIndex: 2, withValue: Int16(0x7989)), .success)
        
        XCTAssertFalse(newDict.isValid)
        XCTAssertFalse(sixPortal.isValid)
        
        XCTAssertTrue(namedArray.isValid)
        XCTAssertTrue(namedArray.isArray)
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)
        XCTAssertTrue(nameNull.isValid)
        XCTAssertTrue(nameNull.isNull)

        
        // Add elements to the array item
        
        XCTAssertEqual(namedArray.appendElement(UInt8(0x44)), .success)
        
        let arr0: Portal = namedArray[0]
        
        XCTAssertTrue(arr0.isValid)
        
        XCTAssertTrue(namedArray.isValid)
        XCTAssertTrue(namedArray.isArray)
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)
        XCTAssertTrue(nameNull.isValid)
        XCTAssertTrue(nameNull.isNull)

        
        // Replace the array
        
        XCTAssertEqual(sm.root.replaceItem(atIndex: 3, withValue: am), .success)
        
        XCTAssertFalse(arr0.isValid)
        XCTAssertFalse(namedArray.isValid)
        
        XCTAssertTrue(noNameNull.isValid)
        XCTAssertTrue(noNameNull.isNull)
        XCTAssertTrue(nameNull.isValid)
        XCTAssertTrue(nameNull.isNull)

        
    }
}
