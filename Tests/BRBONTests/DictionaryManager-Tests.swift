//
//  DictionaryManager-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 29/01/18.
//
//

import XCTest
import BRBON


class DictionaryManager_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDefaultInit() {
        
        guard let dm = DictionaryManager.init() else { XCTFail("Could not create dictionary manager"); return }
        
        XCTAssertEqual(dm.count, 0)

    }
}
