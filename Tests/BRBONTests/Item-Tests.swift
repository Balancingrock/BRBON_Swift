//
//  Item-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 07/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Item_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_BoolNoName() {

        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1000)
        defer { buffer.deallocate() }
        
        let ptr = buffer.baseAddress!
        
        let item = Item(basePtr: ptr, parentPtr: ptr)
        
        true.storeAsItem(atPtr: ptr, parentOffset: 0, machineEndianness)
        
        if let b = item.bool { XCTAssertTrue(b) } else { XCTFail() }
        
        item.bool = false
        
        if let b = item.bool { XCTAssertFalse(b) } else { XCTFail() }
        
        XCTAssertNil(item.uint8)
        XCTAssertNil(item.uint16)
        XCTAssertNil(item.uint32)
        XCTAssertNil(item.uint64)
        XCTAssertNil(item.int8)
        XCTAssertNil(item.int16)
        XCTAssertNil(item.int32)
        XCTAssertNil(item.int64)
        XCTAssertNil(item.float32)
        XCTAssertNil(item.float64)
        XCTAssertNil(item.binary)
        XCTAssertNil(item.string)
        
        XCTAssertEqual(ptr, item.typePtr)
        XCTAssertEqual(ptr.advanced(by: 1), item.optionsPtr)
        XCTAssertEqual(ptr.advanced(by: 2), item.flagsPtr)
        XCTAssertEqual(ptr.advanced(by: 3), item.nameFieldByteCountPtr)
        XCTAssertEqual(ptr.advanced(by: 4), item.itemByteCountPtr)
        XCTAssertEqual(ptr.advanced(by: 8), item.parentOffsetPtr)
        XCTAssertEqual(ptr, item.typePtr)
        XCTAssertEqual(ptr, item.typePtr)
        XCTAssertEqual(ptr, item.typePtr)
        XCTAssertEqual(ptr, item.typePtr)
        XCTAssertEqual(ptr, item.typePtr)
        
    }
}
