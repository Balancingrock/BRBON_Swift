//
//  ArrayManager-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 19/01/18.
//
//

import XCTest
import BRBON

class ArrayManager_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDefaultInit() {

        guard let mng = ArrayManager(elementType: ItemType.bool, initialCount: 10) else { XCTFail(); return }
        
        XCTAssertEqual(mng.count, 0) // Number of items should be zero
        XCTAssertEqual(mng.itemLength, 24) // 16 bytes + 2x4 bytes
        XCTAssertEqual(mng.availableItemBytes, 0)
        XCTAssertEqual(mng.availableBufferBytes, 1000)
    }
    
    func testAccess() {
        
        guard let arr = ArrayManager(elementType: ItemType.bool, initialCount: 10) else { XCTFail(); return }

        arr.append(element: UInt8(6))
        
        XCTAssert(arr[0].uint8, 6)
    }
}
