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
        
    }
}
