//
//  Sequence-Coder-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 28/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class Sequence_Coder_Tests: XCTestCase {

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
        
        let b = BrbonSequence()
        
        
        // Properties
        
        XCTAssertEqual(b.brbonType, ItemType.sequence)
        XCTAssertEqual(b.valueByteCount, 0)
        XCTAssertEqual(b.itemByteCount(), 16)
        XCTAssertEqual(b.elementByteCount, 16)
        
        
        // Create a buffer for storage tests
        
        var buffer = UnsafeMutableRawBufferPointer.allocate(count: 1024)
        defer { buffer.deallocate() }
        
        b.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        let exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x00,
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
        let b = BrbonSequence(dict: dict)
        
        
        // Properties
        
        XCTAssertEqual(b.brbonType, ItemType.sequence)
        XCTAssertEqual(b.valueByteCount, 72)
        XCTAssertEqual(b.itemByteCount(), 88)
        XCTAssertEqual(b.elementByteCount, 88)
        
        
        // Create a buffer for storage tests
        
        var buffer = UnsafeMutableRawBufferPointer.allocate(count: 1024)
        defer { buffer.deallocate() }
        
        b.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!, machineEndianness)
        
        let exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x00,
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

    func test_3() {
        
        
        // Instance
        
        let ia: Array<Int8> = [1, 2]
        let a = BrbonSequence(array: ia)
        
        
        // The name field to be used
        
        let nfd = NameFieldDescriptor("one")
        
        
        // Properties
        
        XCTAssertEqual(a.brbonType, ItemType.sequence)
        XCTAssertEqual(a.valueByteCount, 32)
        XCTAssertEqual(a.itemByteCount(nfd), 56)
        XCTAssertEqual(a.elementByteCount, 48)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 100)
        defer { buffer.deallocate() }
        
        a.storeAsItem(atPtr: buffer.baseAddress!, bufferPtr: buffer.baseAddress!, parentPtr: buffer.baseAddress!.advanced(by: 0x12345678), nameField: nfd, machineEndianness)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 56, deallocator: Data.Deallocator.none)
        
        let exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x08,
            0x38, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x02, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6F,
            0x6E, 0x65, 0x00, 0x00,
            
            0x82, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            
            0x82, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x02, 0x00, 0x00, 0x00
            ])
        
        data.printBytes()

        XCTAssertEqual(data, exp)
    }
}
