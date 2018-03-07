//
//  NameFieldDescriptor-Tests.swift
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

    func test() {
        
        var nfd = NameFieldDescriptor("A long name")
        
        XCTAssertEqual(nfd!.crc, 0xa64c) // CRC value from https://www.lammertbies.nl/comm/info/nl_crc-calculation.html. (CRC-16)
        XCTAssertEqual(nfd!.byteCount, 11 + 3 + 2)
        XCTAssertEqual(nfd!.data, "A long name".data(using: .utf8))
        
        nfd = NameFieldDescriptor("A long name", fixedLength: 37)
        XCTAssertEqual(nfd!.byteCount, 40)
        
        XCTAssertNil(NameFieldDescriptor("A long name", fixedLength: 3))
        
        // Note coding and decoding is tested in the type-BrbonCoders-Tests
    }
}
