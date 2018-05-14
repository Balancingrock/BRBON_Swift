//
//  Uuid-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 31/03/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class Uuid_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testCoder() {
        
        let u = UUID(uuidString: "01234567-1234-1234-1234-123456789011")!

        XCTAssertEqual(u.itemType, .uuid)
        XCTAssertEqual(u.valueByteCount, 16)
        XCTAssertEqual(u.minimumValueFieldByteCount, 16)
        
        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        u.copyBytes(to: buffer.baseAddress!, Endianness.little)
        
        let data = Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)
        data.printBytes()
        let exp = Data(bytes: [0x01, 0x23, 0x45, 0x67, 0x12, 0x34, 0x12, 0x34, 0x12, 0x34, 0x12, 0x34, 0x56, 0x78, 0x90, 0x11])
        
        XCTAssertEqual(data, exp)
    }
    
    
    func testPortal() {
        
        ItemManager.startWithZeroedBuffers = true
        
        
        // Instance
        
        guard let u = UUID(uuidString: "01234567-1234-1234-1234-123456789011") else { XCTFail(); return }

        let im = ItemManager.createManager(withValue: u)
        
        
        // Portal Properties
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertNil(im.root.nameField)
        
        XCTAssertTrue(im.root.isUuid)
        XCTAssertEqual(im.root.uuid, UUID(uuidString: "01234567-1234-1234-1234-123456789011"))
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        XCTAssertEqual(im.root.valueType, ItemType.uuid)
        
        
        // Buffer content
        
        var exp = Data(bytes: [
            0x15, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x01, 0x23, 0x45, 0x67, 0x12, 0x34, 0x12, 0x34,
            0x12, 0x34, 0x12, 0x34, 0x56, 0x78, 0x90, 0x11
            ])
        
        XCTAssertEqual(exp, im.data)
        
        
        // Assignment
        
        im.root.uuid = UUID(uuidString: "01234567-5234-1234-1234-523456789011")
        XCTAssertEqual(im.root.uuid, UUID(uuidString: "01234567-5234-1234-1234-523456789011"))
        
        exp = Data(bytes: [
            0x15, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x01, 0x23, 0x45, 0x67, 0x52, 0x34, 0x12, 0x34,
            0x12, 0x34, 0x52, 0x34, 0x56, 0x78, 0x90, 0x11
            ])
        
        XCTAssertEqual(exp, im.data)
    }
}
