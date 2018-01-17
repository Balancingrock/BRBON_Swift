//
//  DictionaryManager-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 06/01/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class DictionaryManager_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateInBuffer() {
        
        let dict = DictionaryManager(endianness: machineEndianness)!
        
        let dictData = dict.asData
        
        let exp = Data(bytes: [
            0x42,   0,      0,      0,      // Type = .dictionary, options = 0, flags = 0, name area = 0
            16,     0,      0,      0,      // Item length = 16
            0,      0,      0,      0,      // Parent offset = 0
            0,      0,      0,      0,      // Count/Value = count = 0
            ])
        
        XCTAssertEqual(dictData, exp)
    }

    func testCount() {
        
        let dict = DictionaryManager(endianness: machineEndianness)!
        
        XCTAssertEqual(dict.count, 0)
        
        dict.incrementCounter()
        
        XCTAssertEqual(dict.count, 1)
        
        let data = dict.asData

        let exp = Data(bytes: [
            0x42,   0,      0,      0,      // Type = .dictionary, options = 0, flags = 0, name area = 0
            16,     0,      0,      0,      // Item length = 16
            0,      0,      0,      0,      // Parent offset = 0
            1,      0,      0,      0,      // Count/Value = count = 0
            ])
        
        XCTAssertEqual(exp, data)
        
        dict.decrementCounter()
        
        XCTAssertEqual(dict.count, 0)

        dict.decrementCounter()
        
        XCTAssertEqual(dict.count, 0)
    }
    
    func testAddValue() {
        
        let dict = DictionaryManager(initialBufferSize: 20, bufferIncrements: 5, endianness: machineEndianness)!
        XCTAssertEqual(dict.count, 0)
        XCTAssertEqual(dict.itemLength, 16)

        XCTAssertTrue(dict.add(true, name: "one"))
        
        XCTAssertEqual(dict.count, 1)
        XCTAssertEqual(dict.itemLength, 40)

        var exp = Data(bytes: [
            0x42,   0,      0,      0,      // Type = .dictionary, options = 0, flags = 0, name area = 0
            0x28,   0,      0,      0,      // Item length = 40
            0,      0,      0,      0,      // Parent offset = 0
            1,      0,      0,      0,      // Count/Value = count = 0
            0x81,   0,      0,      8,      // Type = .bool, Options = 0, Flags = 0, Name field is 8 bytes.
            24,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            1,      0,      0,      0,      // Value (1 byte), Filler (3 bytes)
            0xdc,   0x56,   3,      111,    // name hash (2 bytes), name field length, first name byte
            110,    101,    0,      0       // Name bytes (3), Filler (1 byte)
            ])
        
        var data = dict.asData
        
        XCTAssertEqual(exp, data)

        XCTAssertTrue(dict.add(UInt8(5), name: "two"))
        
        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict.itemLength, 64)
        
        exp = Data(bytes: [
            0x42,   0,      0,      0,      // Type = .dictionary, options = 0, flags = 0, name area = 0
            0x40,   0,      0,      0,      // Item length = 64
            0,      0,      0,      0,      // Parent offset = 0
            2,      0,      0,      0,      // Count/Value = count = 0
            0x81,   0,      0,      8,      // Type = .bool, Options = 0, Flags = 0, Name field is 8 bytes.
            24,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            1,      0,      0,      0,      // Value (1 byte), Filler (3 bytes)
            0xdc,   0x56,   3,      111,    // name hash (2 bytes), name field length, first name byte
            110,    101,    0,      0,      // Name bytes (3), Filler (1 byte)
            0x85,   0,      0,      8,      // Type = .uint8, Options = 0, Flags = 0, Name field is 8 bytes.
            24,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            5,      0,      0,      0,      // Value (1 byte), Filler (3 bytes)
            0x27,   0xc6,   3,      116,    // name hash (2 bytes), name field length, first name byte
            119,    111,    0,      0       // Name bytes (3), Filler (1 byte)
            ])

        data = dict.asData
        
        XCTAssertEqual(exp, data)
        
        XCTAssertTrue(dict.add(UInt8(5), name: "one")) // Must override the existing "one", though the new "one" will be placed at the end.
        
        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict.itemLength, 64)

        exp = Data(bytes: [
            0x42,   0,      0,      0,      // Type = .dictionary, options = 0, flags = 0, name area = 0
            0x40,   0,      0,      0,      // Item length = 64
            0,      0,      0,      0,      // Parent offset = 0
            2,      0,      0,      0,      // Count/Value = count = 0
            0x85,   0,      0,      8,      // Type = .uint8, Options = 0, Flags = 0, Name field is 8 bytes.
            24,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            5,      0,      0,      0,      // Value (1 byte), Filler (3 bytes)
            0x27,   0xc6,   3,      116,    // name hash (2 bytes), name field length, first name byte
            119,    111,    0,      0,       // Name bytes (3), Filler (1 byte)
            0x85,   0,      0,      8,      // Type = .unit, Options = 0, Flags = 0, Name field is 8 bytes.
            24,     0,      0,      0,      // Item Length
            0,      0,      0,      0,      // Parent offset
            5,      0,      0,      0,      // Value (1 byte), Filler (3 bytes)
            0xdc,   0x56,   3,      111,    // name hash (2 bytes), name field length, first name byte
            110,    101,    0,      0,      // Name bytes (3), Filler (1 byte)
            ])
        
        data = dict.asData
        
        XCTAssertEqual(exp, data)
    }
    
    func testSubscript() {
        
        guard let dict = DictionaryManager() else { XCTFail(); return }
        
        dict.add(true, name: "one")
        dict.add(UInt8(2), name: "two")
        dict.add(UInt16(3), name: "three")
        dict.add(UInt32(4), name: "four")
        dict.add(UInt64(5), name: "five")
        dict.add(Int8(6), name: "six")
        dict.add(Int16(7), name: "seven")
        dict.add(Int32(8), name: "eight")
        dict.add(Int64(9), name: "nine")
        dict.add(Float32(10.0), name: "ten")
        dict.add(Float64(11.0), name: "eleven")
        dict.add("twelve", name: "twelve")
        dict.add(Data(count: 13), name: "thirtheen")
        
        XCTAssertEqual(dict["one"]?.bool, true)
        XCTAssertEqual(dict["two"]?.uint8, 2)
        XCTAssertEqual(dict["three"]?.uint16, 3)
        XCTAssertEqual(dict["four"]?.uint32, 4)
        XCTAssertEqual(dict["five"]?.uint64, 5)
        XCTAssertEqual(dict["six"]?.int8, 6)
        XCTAssertEqual(dict["seven"]?.int16, 7)
        XCTAssertEqual(dict["eight"]?.int32, 8)
        XCTAssertEqual(dict["nine"]?.int64, 9)
        XCTAssertEqual(dict["ten"]?.float32, 10.0)
        XCTAssertEqual(dict["eleven"]?.float64, 11.0)
        XCTAssertEqual(dict["twelve"]?.string, "twelve")
        XCTAssertEqual(dict["thirtheen"]?.binary, Data(count: 13))
        
        dict["one"] = false
        dict["two"] = UInt8(3)
        dict["three"] = UInt16(4)
        dict["four"] = UInt32(5)
        dict["five"] = UInt64(6)
        dict["six"] = Int8(7)
        dict["seven"] = Int16(8)
        dict["eight"] = Int32(9)
        dict["nine"] = Int64(10)
        dict["ten"] = Float32(11.0)
        dict["eleven"] = Float64(12.0)
        dict["twelve"] = "thi"
        dict["thirtheen"] = Data(count: 5)
        
        XCTAssertEqual(dict["one"]?.bool, false)
        XCTAssertEqual(dict["two"]?.uint8, 3)
        XCTAssertEqual(dict["three"]?.uint16, 4)
        XCTAssertEqual(dict["four"]?.uint32, 5)
        XCTAssertEqual(dict["five"]?.uint64, 6)
        XCTAssertEqual(dict["six"]?.int8, 7)
        XCTAssertEqual(dict["seven"]?.int16, 8)
        XCTAssertEqual(dict["eight"]?.int32, 9)
        XCTAssertEqual(dict["nine"]?.int64, 10)
        XCTAssertEqual(dict["ten"]?.float32, 11.0)
        XCTAssertEqual(dict["eleven"]?.float64, 12.0)
        XCTAssertEqual(dict["twelve"]?.string, "thi")
        XCTAssertEqual(dict["thirtheen"]?.binary, Data(count: 5))
        
        dict["twelve"] = "twelve"
        dict["thirtheen"] = Data(count: 13)

        XCTAssertEqual(dict["twelve"]?.string, "twelve")
        XCTAssertEqual(dict["thirtheen"]?.binary, Data(count: 13))

        // These updates should fail because they are larger than will fit the existing item
        
        dict["twelve"] = "twelvetwelve"
        dict["thirtheen"] = Data(count: 20)
        
        XCTAssertEqual(dict["twelve"]?.string, "twelve")
        XCTAssertEqual(dict["thirtheen"]?.binary, Data(count: 13))
        
        
        /// Creation through subscript
        
        guard let newDict = DictionaryManager() else { XCTFail(); return }
        
        newDict["one"] = true
        newDict["two"] = UInt8(2)
        newDict["three"] = UInt16(4)
        newDict["four"] = UInt32(5)
        newDict["five"] = UInt64(6)
        newDict["six"] = Int8(7)
        newDict["seven"] = Int16(8)
        newDict["eight"] = Int32(9)
        newDict["nine"] = Int64(10)
        newDict["ten"] = Float32(11.0)
        newDict["eleven"] = Float64(12.0)
        newDict["twelve"] = "thi"
        newDict["thirtheen"] = Data(count: 5)

        XCTAssertEqual(newDict["one"]?.bool, true)
        XCTAssertEqual(newDict["two"]?.uint8, 2)
        XCTAssertEqual(newDict["three"]?.uint16, 4)
        XCTAssertEqual(newDict["four"]?.uint32, 5)
        XCTAssertEqual(newDict["five"]?.uint64, 6)
        XCTAssertEqual(newDict["six"]?.int8, 7)
        XCTAssertEqual(newDict["seven"]?.int16, 8)
        XCTAssertEqual(newDict["eight"]?.int32, 9)
        XCTAssertEqual(newDict["nine"]?.int64, 10)
        XCTAssertEqual(newDict["ten"]?.float32, 11.0)
        XCTAssertEqual(newDict["eleven"]?.float64, 12.0)
        XCTAssertEqual(newDict["twelve"]?.string, "thi")
        XCTAssertEqual(newDict["thirtheen"]?.binary, Data(count: 5))
        
        
        // Test nil usage
        
        let null: Bool? = nil
        dict["null"] = null
        dict["t2"] = Int16(16)
        
        XCTAssertTrue(dict["null"]?.isNull ?? false)
        XCTAssertEqual(dict["t2"]?.int16, 16)
        
    }
    
    func testRemoval() {
        
        func again() -> DictionaryManager {
            let dict = DictionaryManager()!
            dict["one"] = false
            dict["two"] = UInt8(3)
            dict["three"] = UInt16(4)
            return dict
        }
        
        var dict = again()
        
        var d1: ValueItem = dict["one"]!
        var d2: ValueItem = dict["two"]!
        var d3: ValueItem = dict["three"]!

        XCTAssertTrue(d1.isValid)
        XCTAssertTrue(d2.isValid)
        XCTAssertTrue(d3.isValid)
        
        XCTAssertTrue(dict.removeItem(name: "two"))
        
        XCTAssertEqual(dict.count, 2)
        
        XCTAssertTrue(d1.isValid)
        XCTAssertFalse(d2.isValid)
        XCTAssertTrue(d3.isValid)

        XCTAssertEqual(d1.bool, false)
        XCTAssertNil(d2.uint8)
        XCTAssertEqual(d3.uint16, 4)
        
        
        dict = again()
        
        d1 = dict["one"]!
        d2 = dict["two"]!
        d3 = dict["three"]!

        XCTAssertTrue(d1.isValid)
        XCTAssertTrue(d2.isValid)
        XCTAssertTrue(d3.isValid)
        
        XCTAssertTrue(dict.removeItem(name: "one"))
        
        XCTAssertEqual(dict.count, 2)
        
        XCTAssertFalse(d1.isValid)
        XCTAssertTrue(d2.isValid)
        XCTAssertTrue(d3.isValid)

        XCTAssertNil(d1.bool)
        XCTAssertEqual(d2.uint8, 3)
        XCTAssertEqual(d3.uint16, 4)

        
        dict = again()
        
        d1 = dict["one"]!
        d2 = dict["two"]!
        d3 = dict["three"]!
        
        XCTAssertTrue(d1.isValid)
        XCTAssertTrue(d2.isValid)
        XCTAssertTrue(d3.isValid)
        
        XCTAssertTrue(dict.removeItem(name: "three"))
        
        XCTAssertEqual(dict.count, 2)
        
        XCTAssertTrue(d1.isValid)
        XCTAssertTrue(d2.isValid)
        XCTAssertFalse(d3.isValid)
        
        XCTAssertEqual(d1.bool, false)
        XCTAssertEqual(d2.uint8, 3)
        XCTAssertNil(d3.uint16)

        
        dict = again()
        
        d1 = dict["one"]!
        d2 = dict["two"]!
        d3 = dict["three"]!
        
        XCTAssertTrue(d1.isValid)
        XCTAssertTrue(d2.isValid)
        XCTAssertTrue(d3.isValid)
        
        XCTAssertTrue(dict.removeItem(name: "three"))
        XCTAssertTrue(dict.removeItem(name: "one"))
        
        XCTAssertEqual(dict.count, 1)
        
        XCTAssertFalse(d1.isValid)
        XCTAssertTrue(d2.isValid)
        XCTAssertFalse(d3.isValid)
        
        XCTAssertNil(d1.bool)
        XCTAssertEqual(d2.uint8, 3)
        XCTAssertNil(d3.uint16)
        
        XCTAssertTrue(dict.removeItem(name: "two"))
        XCTAssertNil(d2.uint8)
        XCTAssertEqual(dict.count, 0)
    }
    
}
