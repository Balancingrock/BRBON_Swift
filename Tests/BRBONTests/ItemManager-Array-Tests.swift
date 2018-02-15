//
//  ItemManager-Array-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 14/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class ItemManager_Array_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFailedInit() {

        XCTAssertNil(ItemManager(rootItemType: .array))
        
    }
    
    func testInit() {
        
        guard let am = ItemManager(rootItemType: .array, elementType: .null) else { XCTFail(); return }
        
    }
}
