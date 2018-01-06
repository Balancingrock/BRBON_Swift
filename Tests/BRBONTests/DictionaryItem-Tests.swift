//
//  DictionaryItem-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 06/01/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class DictionaryItem_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateInBuffer() {
        
        let buffer = DictionaryItem.createInBuffer(endianness: machineEndianness)!
        
        let dictData = Data.init(bytes: buffer.baseAddress!, count: buffer.count)
        
        let exp = Data(bytes: [
            0x42,   0,      0,      0,      // Type = .dictionary, options = 0, flags = 0, name area = 0
            16,     0,      0,      0,      // Item length = 16
            0,      0,      0,      0,      // Parent offset = 0
            0,      0,      0,      0,      // Count/Value = count = 0
            ])
        
        XCTAssertEqual(dictData, exp)
    }

}
