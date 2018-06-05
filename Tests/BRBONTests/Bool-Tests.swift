//
//  Bool-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 06/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class Bool_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoder() {
        
        
        // Instance
        
        var b: Bool = true
        
        
        // Properties
        
        XCTAssertEqual(b.itemType, .bool)
        XCTAssertEqual(b.valueByteCount, 1)
        XCTAssertEqual(b.minimumValueFieldByteCount, 0)

        
        // Storing
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 128, alignment: 8)
        _ = Darwin.memset(buffer.baseAddress, 0, 128)
        defer { buffer.deallocate() }
        
        
        // Store as value
        
        b.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 1)

        b = false
        
        b.copyBytes(to: buffer.baseAddress!, machineEndianness)
        
        XCTAssertEqual(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee, 0)
    }
    
    
    func testPortalPublic() {
        
        ItemManager.startWithZeroedBuffers = true
        
        let imt = ItemManager.createManager(withValue: true)
        
        XCTAssertTrue(imt.root.isValid)
        XCTAssertTrue(imt.root.isBool)
        XCTAssertTrue(imt.root.bool ?? false)
        
        XCTAssertEqual(imt.root.itemType, ItemType.bool)
        XCTAssertEqual(imt.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(imt.root.itemFlags, ItemFlags.none)
        XCTAssertEqual(imt.root._itemNameFieldByteCount, 0)
        XCTAssertEqual(imt.root._itemByteCount, itemHeaderByteCount)
        XCTAssertEqual(imt.root._itemParentOffset, 0)
        XCTAssertEqual(imt.root._itemSmallValue(Endianness.little), 1)
        
        var data = imt.data // Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)
        
        var exp = Data(bytes: [
            0x02, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)

        
        let imf = ItemManager.createManager(withValue: false)

        XCTAssertTrue(imf.root.isValid)
        XCTAssertTrue(imf.root.isBool)
        XCTAssertFalse(imf.root.bool ?? true)
        
        XCTAssertEqual(imf.root.itemType, ItemType.bool)
        XCTAssertEqual(imf.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(imf.root.itemFlags, ItemFlags.none)
        XCTAssertEqual(imf.root._itemNameFieldByteCount, 0)
        XCTAssertEqual(imf.root._itemByteCount, itemHeaderByteCount)
        XCTAssertEqual(imf.root._itemParentOffset, 0)
        XCTAssertEqual(imf.root._itemSmallValue(Endianness.little), 0)

        data = imf.data // Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)
        
        exp = Data(bytes: [
            0x02, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)

        guard let one = NameField("one") else { XCTFail(); return }
        let im = ItemManager.createManager(withValue: true, withNameField: one)
        
        XCTAssertTrue(im.root.isValid)
        XCTAssertNil(im.root.index)
        XCTAssertNil(im.root.column)
        XCTAssertEqual(im.root.count, 0)
        XCTAssertEqual(im.root.itemNameField, one)
        
        XCTAssertTrue(im.root.isBool)
        XCTAssertEqual(im.root.bool, true)
        
        XCTAssertEqual(im.root.itemOptions, ItemOptions.none)
        XCTAssertEqual(im.root.itemFlags, ItemFlags.none)
        XCTAssertEqual(im.root.itemName, "one")

        data = im.data // Data(bytesNoCopy: buffer.baseAddress!, count: 16, deallocator: Data.Deallocator.none)

        exp = Data(bytes: [
            0x02, 0x00, 0x00, 0x08, 0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6f, 0x6e, 0x65, 0x00, 0x00
            ])
        
        XCTAssertEqual(data, exp)
    }
}
