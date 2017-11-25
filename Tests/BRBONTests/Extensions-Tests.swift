//
//  Extensions-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 28/10/17.
//
//

import XCTest

class Extensions_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInt8() {
        
        let data = Data(bytes: [10, 11, 12])
        var bytePtr = (data as NSData).bytes
        
        var i8 = bytePtr.advanceInt8()
        
        XCTAssertEqual(i8, 10)
        
        i8 = bytePtr.advanceInt8()
        
        XCTAssertEqual(i8, 11)

        i8 = bytePtr.advanceInt8()
        
        XCTAssertEqual(i8, 12)
    }
    
    func testUInt8() {
        
        let data = Data(bytes: [10, 11, 12])
        var bytePtr = (data as NSData).bytes
        
        var i8 = bytePtr.advanceUInt8()
        
        XCTAssertEqual(i8, 10)
        
        i8 = bytePtr.advanceUInt8()
        
        XCTAssertEqual(i8, 11)
        
        i8 = bytePtr.advanceUInt8()
        
        XCTAssertEqual(i8, 12)
    }

    func testInt16() {
        
        var data = Data(Int16(1234).endianBytes(.little))
        data.append(Int16(-5678).endianBytes(.big))
        var bytePtr = (data as NSData).bytes
        
        var i = bytePtr.advanceInt16(endianness: .little)
        
        XCTAssertEqual(i, 1234)
        
        i = bytePtr.advanceInt16(endianness: .big)
        
        XCTAssertEqual(i, -5678)
    }

    func testUInt16() {
        
        var data = Data(UInt16(1234).endianBytes(.little))
        data.append(UInt16(5678).endianBytes(.big))
        var bytePtr = (data as NSData).bytes
        
        var i = bytePtr.advanceUInt16(endianness: .little)
        
        XCTAssertEqual(i, 1234)
        
        i = bytePtr.advanceUInt16(endianness: .big)
        
        XCTAssertEqual(i, 5678)
    }

    func testInt32() {
        
        var data = Data(Int32(127734).endianBytes(.little))
        data.append(Int32(-563378).endianBytes(.big))
        var bytePtr = (data as NSData).bytes
        
        var i = bytePtr.advanceInt32(endianness: .little)
        
        XCTAssertEqual(i, 127734)
        
        i = bytePtr.advanceInt32(endianness: .big)
        
        XCTAssertEqual(i, -563378)
    }

    func testUInt32() {
        
        var data = Data(UInt32(127734).endianBytes(.little))
        data.append(UInt32(563378).endianBytes(.big))
        var bytePtr = (data as NSData).bytes
        
        var i = bytePtr.advanceUInt32(endianness: .little)
        
        XCTAssertEqual(i, 127734)
        
        i = bytePtr.advanceUInt32(endianness: .big)
        
        XCTAssertEqual(i, 563378)
    }

    func testInt64() {
        
        var data = Data(Int64(127111734).endianBytes(.little))
        data.append(Int64(-563111378).endianBytes(.big))
        var bytePtr = (data as NSData).bytes
        
        var i = bytePtr.advanceInt64(endianness: .little)
        
        XCTAssertEqual(i, 127111734)
        
        i = bytePtr.advanceInt64(endianness: .big)
        
        XCTAssertEqual(i, -563111378)
    }
    
    func testUInt64() {
        
        var data = Data(UInt64(127111734).endianBytes(.little))
        data.append(UInt64(563111378).endianBytes(.big))
        var bytePtr = (data as NSData).bytes
        
        var i = bytePtr.advanceUInt64(endianness: .little)
        
        XCTAssertEqual(i, 127111734)
        
        i = bytePtr.advanceUInt64(endianness: .big)
        
        XCTAssertEqual(i, 563111378)
    }

    func testData() {
        
        let data = Data(bytes: [0, 1, 2, 3, 4])
        var bytePtr = (data as NSData).bytes
        
        let f = bytePtr.advanceData(count: 3)
        
        XCTAssertEqual(f, Data(bytes: [0, 1, 2]))
    }

    func testUtf8() {
        
        let str = "Test"
        let data = str.data(using: .utf8)!
        var bytePtr = (data as NSData).bytes
        
        let f = bytePtr.advanceUtf8(count: 4)
        
        XCTAssertEqual(f, "Test")

    }
}
