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

    func test01() {
        
        guard let dm = DictionaryManager.init() else { XCTFail("Could not create dictionary manager"); return }
        
        XCTAssertEqual(dm.count, 0)

        dm["bool"].bool = true
        dm["uint8"].uint8 = 0x12
        dm["uint16"].uint16 = 0x1234
        dm["uint32"].uint32 = 0x12345678
        dm["uint64"].uint64 = 0x123456789abcdef0
        dm["int8"].int8 = 0x22
        dm["int16"].int16 = 0x2234
        dm["int32"].int32 = 0x22345678
        dm["int64"].int64 = 0x223456789abcdef0
        dm["float32"].float32 = 12.34
        dm["float64"].float64 = 23.45
        dm["string"].string = "Text"
        dm["binary"].binary = Data(bytes: [0x12, 0x21])
        
        XCTAssertEqual(dm["bool"].bool, true)
        XCTAssertEqual(dm["uint8"].uint8, 0x12)
        XCTAssertEqual(dm["uint16"].uint16, 0x1234)
        XCTAssertEqual(dm["uint32"].uint32, 0x12345678)
        XCTAssertEqual(dm["uint64"].uint64, 0x123456789abcdef0)
        XCTAssertEqual(dm["int8"].int8, 0x22)
        XCTAssertEqual(dm["int16"].int16, 0x2234)
        XCTAssertEqual(dm["int32"].int32, 0x22345678)
        XCTAssertEqual(dm["int64"].int64, 0x223456789abcdef0)
        XCTAssertEqual(dm["float32"].float32, 12.34)
        XCTAssertEqual(dm["float64"].float64, 23.45)
        XCTAssertEqual(dm["string"].string, "Text")
        XCTAssertEqual(dm["binary"].binary, Data(bytes: [0x12, 0x21]))
    }
}
