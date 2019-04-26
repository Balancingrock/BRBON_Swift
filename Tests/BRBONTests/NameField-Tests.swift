//
//  NameField-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class NameFieldDescriptor_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPositive() {
        
        guard let nfd = NameField("one") else { XCTFail(); return }
        
        XCTAssertEqual(nfd.crc, 0x56dc) // CRC value from https://www.lammertbies.nl/comm/info/nl_crc-calculation.html. (CRC-16)
        XCTAssertEqual(nfd.byteCount, 8)
        XCTAssertEqual(nfd.data, Data([0x6f, 0x6e, 0x65]))
        XCTAssertEqual(nfd.string, "one")

        
        guard let nfd1 = NameField("two") else { XCTFail(); return }
        
        XCTAssertNotEqual(nfd, nfd1)
        
        
        guard let nfd2 = NameField("one") else { XCTFail(); return }

        XCTAssertEqual(nfd, nfd2)

        
        guard let nfd3 = NameField("one", fixedByteCount: 16) else { XCTFail(); return }
        
        XCTAssertEqual(nfd3.crc, 0x56dc)
        XCTAssertEqual(nfd3.byteCount, 16)
        XCTAssertEqual(nfd3.data, Data([0x6f, 0x6e, 0x65]))
        XCTAssertEqual(nfd3.string, "one")
        
        XCTAssertNotNil(NameField("012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345"))
        XCTAssertNotNil(NameField("1234567890123", fixedByteCount: 16))
        XCTAssertNotNil(NameField("1234567890123", fixedByteCount: 248))
    }
    
    func testNegative() {
        
        XCTAssertNil(NameField(nil))
        XCTAssertNil(NameField(""))
        XCTAssertNotNil(NameField("0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456"))
        XCTAssertNil(NameField("one", fixedByteCount: 15))
        XCTAssertNil(NameField("1234567890123", fixedByteCount: 15))
        XCTAssertNil(NameField("one", fixedByteCount: 7))
        XCTAssertNil(NameField("one", fixedByteCount: 249))
    }
}
