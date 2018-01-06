//
//  ItemManager-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 04/01/18.
//
//

import XCTest
@testable import BRBON

class ItemManager_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        
        let itemManager = ItemManager.newDictionary()
        
        var data = itemManager!.asData

        var exp = Data(bytes:
            [0x0e,  0, 0, 0,     // Header, type = dictionary
             0,     0, 0, 0,     // Parent offset = 0
             4,     0, 0, 0,     // NVR Length = 4 bytes
             0,     0, 0, 0])    // Number of items = 0
        
        XCTAssertEqual(data.count, 16)
        XCTAssertEqual(data, exp)
        
        
        XCTAssertTrue(itemManager!.add(UInt8(34), at: ["test"]))
        
        exp = Data(bytes: [
            
            0x0e,   0,      0,      0,     // Header, type = dictionary
            0,      0,      0,      0,     // Parent offset = 0
            24,     0,      0,      0,     // NVR Length = 4 bytes
            1,      0,      0,      0,     // Number of items = 0
                
            // Item 1
            0x06,   0,      0,      8,      // Uint8 with 8 byte name area
            0,      0,      0,      0,      // Offset of parent
            16,     0,      0,      0,      // 16 bytes of NVR
            0,      0,                      // Hash of name
                            4,              // Number of ascii bytes = 4
            116,    101,    115,    116,    // Name = "test"
                                    0,      // Even out on 8 byte boundary
            22,     0,      0,      0,      // Value byte plus filler
            0,      0,      0,      0
        ])

        data = itemManager!.asData
        
        XCTAssertEqual(data.count, 32)
        XCTAssertEqual(data, exp)

    }
}
