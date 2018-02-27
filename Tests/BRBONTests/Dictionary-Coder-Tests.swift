//
//  Dictionary-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 13/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class Dictionary_Coder_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_01() {
        
        
        // Instance
        
        let b = BrbonDictionary()
        
        
        // Properties
        
        XCTAssertEqual(b.brbonType, ItemType.dictionary)
        XCTAssertEqual(b.valueByteCount, 0)
        XCTAssertEqual(b.itemByteCount(), 16)
        XCTAssertEqual(b.elementByteCount, 16)
        
        
        // Create a buffer for storage tests
        
        var buffer = UnsafeMutableRawBufferPointer.allocate(count: 1024)
        defer { buffer.deallocate() }
        
        b.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        let exp = Data(bytes: [
            0x42, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)

        XCTAssertEqual(data, exp)
    }

    func test_02() {
        
        
        // Instance
        
        let dict: Dictionary<String, IsBrbon> = ["one":UInt8(1), "two":UInt32(2), "three":true]
        let b = BrbonDictionary(content: dict)
        
        
        // Properties
        
        XCTAssertEqual(b.brbonType, ItemType.dictionary)
        XCTAssertEqual(b.valueByteCount, 72)
        XCTAssertEqual(b.itemByteCount(), 88)
        XCTAssertEqual(b.elementByteCount, 88)
        
        
        // Create a buffer for storage tests
        
        var buffer = UnsafeMutableRawBufferPointer.allocate(count: 1024)
        defer { buffer.deallocate() }
        
        b.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        let exp = Data(bytes: [
            0x42, 0x00, 0x00, 0x00,
            0x58, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00,
            
            0x85, 0x00, 0x00, 0x08,
            0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6f,
            0x6e, 0x65, 0x00, 0x00,
            
            0x81, 0x00, 0x00, 0x08,
            0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0xe7, 0x0b, 0x05, 0x74,
            0x68, 0x72, 0x65, 0x65,

            0x87, 0x00, 0x00, 0x08,
            0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x02, 0x00, 0x00, 0x00,
            0x27, 0xc6, 0x03, 0x74,
            0x77, 0x6f, 0x00, 0x00
        ])
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 88, deallocator: Data.Deallocator.none)
        
        // Note: This test may fail if the sequence of items in 'dict' changes
        XCTAssertEqual(data, exp)
    }

    func test_03() {
        
        
        // Instance
        
        let dict: Dictionary<String, IsBrbon> = ["three":true]
        let b = BrbonDictionary(content: dict)
        
        let nfd = NameFieldDescriptor("one")

        
        // Properties
        
        XCTAssertEqual(b.brbonType, ItemType.dictionary)
        XCTAssertEqual(b.valueByteCount, 24)
        XCTAssertEqual(b.itemByteCount(nfd), 48)
        XCTAssertEqual(b.elementByteCount, 40)
        
        
        // Create a buffer for storage tests
        
        var buffer = UnsafeMutableRawBufferPointer.allocate(count: 1024)
        defer { buffer.deallocate() }
        
        b.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, nameField: nfd, machineEndianness)
        
        let exp = Data(bytes: [
            0x42, 0x00, 0x00, 0x08,
            0x30, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            
            0xdc, 0x56, 0x03, 0x6f,
            0x6e, 0x65, 0x00, 0x00,
            
            0x81, 0x00, 0x00, 0x08,
            0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0xe7, 0x0b, 0x05, 0x74,
            0x68, 0x72, 0x65, 0x65
            ])
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 48, deallocator: Data.Deallocator.none)

        XCTAssertEqual(data, exp)
    }

}
