//
//  ItemManager-Array-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 14/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class ItemManager_Array_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFailedInit() {

        XCTAssertNil(ItemManager(rootItemType: .array))
        
    }
    
    func testInit() {
        
        guard let am = ItemManager(rootItemType: .array, elementType: .null) else { XCTFail(); return }
        
        var exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x80, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        var data = am.data

        XCTAssertEqual(data, exp)

        
        guard let am1 = ItemManager(rootItemType: .array, elementType: .null, itemValueByteCount: 20) else { XCTFail(); return }
        
        exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x80, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
            ])
        
        data = am1.data

        XCTAssertEqual(data, exp)
        
        
        guard let am2 = ItemManager(rootItemType: .array, elementType: .int8) else { XCTFail(); return }
        
        exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x82, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00
            ])
        
        data = am2.data
        
        XCTAssertEqual(data, exp)
    }
    
    func testAppend() {
        
        
        // Create array manager
        
        guard let am = ItemManager(rootItemType: .array, elementType: .int32) else { XCTFail(); return }
        
        var exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x84, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00
            ])
        
        var data = am.data
        
        XCTAssertEqual(data, exp)

        
        // Append once
        
        XCTAssertEqual(am.root.append(Int32(0x12345678)), .success)
        
        exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0x84, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x00, 0x00, 0x00, 0x00 // don't care, will not get compared
            ])
        
        data = am.data

        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = am.getPortal(for: UnsafeMutableRawPointer(mutating: ptr), parentPtr: nil)
            XCTAssertTrue(p == am.root)
        }

        
        // Append twice
        
        XCTAssertEqual(am.root.append(Int32(0x44553366)), .success)

        exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x02, 0x00, 0x00, 0x00,
            0x84, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00,
            0x78, 0x56, 0x34, 0x12,
            0x66, 0x33, 0x55, 0x44
            ])
        
        data = am.data
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = am.getPortal(for: UnsafeMutableRawPointer(mutating: ptr), parentPtr: nil)
            XCTAssertTrue(p == am.root)
        }

        
        // Append wrong type
        
        XCTAssertEqual(am.root.append(Int64(0x44553366)), .typeConflict)

        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = am.getPortal(for: UnsafeMutableRawPointer(mutating: ptr), parentPtr: nil)
            XCTAssertTrue(p == am.root)
        }
    }
    
    func testRemove() {
        
        
        // Create array manager with three elements
        
        guard let am = ItemManager(rootItemType: .array, elementType: .int64) else { XCTFail(); return }

        XCTAssertEqual(am.root.append(Int64(0x1111111111111111)), .success)
        XCTAssertEqual(am.root.append(Int64(0x2222222222222222)), .success)
        XCTAssertEqual(am.root.append(Int64(0x3333333333333333)), .success)
        XCTAssertEqual(am.root.append(Int64(0x4444444444444444)), .success)

        var exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x38, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0x08, 0x00, 0x00, 0x00,
            0x11, 0x11, 0x11, 0x11,
            0x11, 0x11, 0x11, 0x11,
            0x22, 0x22, 0x22, 0x22,
            0x22, 0x22, 0x22, 0x22,
            0x33, 0x33, 0x33, 0x33,
            0x33, 0x33, 0x33, 0x33,
            0x44, 0x44, 0x44, 0x44,
            0x44, 0x44, 0x44, 0x44
            ])
        
        var data = am.data

        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = am.getPortal(for: UnsafeMutableRawPointer(mutating: ptr), parentPtr: nil)
            XCTAssertTrue(p == am.root)
        }

        let portal1 = am.root[0].portal
        let portal2 = am.root[1].portal
        let portal3 = am.root[2].portal
        let portal4 = am.root[3].portal
        
        XCTAssertEqual(portal1.int64, 0x1111111111111111)
        XCTAssertEqual(portal2.int64, 0x2222222222222222)
        XCTAssertEqual(portal3.int64, 0x3333333333333333)
        XCTAssertEqual(portal4.int64, 0x4444444444444444)
        
        
        // Remove second entry
        
        XCTAssertEqual(am.root.remove(at: 1), .success)
        
        exp = Data(bytes: [
            0x41, 0x00, 0x00, 0x00,
            0x38, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00,
            0x01, 0x00, 0x00, 0x00,
            0x08, 0x00, 0x00, 0x00,
            0x11, 0x11, 0x11, 0x11,
            0x11, 0x11, 0x11, 0x11,
            0x33, 0x33, 0x33, 0x33,
            0x33, 0x33, 0x33, 0x33,
            0x44, 0x44, 0x44, 0x44,
            0x44, 0x44, 0x44, 0x44,
            0x00, 0x00, 0x00, 0x00, // Not used
            0x00, 0x00, 0x00, 0x00  // Not used
            ])
        
        data = am.data
        data.printBytes()
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = am.getPortal(for: UnsafeMutableRawPointer(mutating: ptr), parentPtr: nil)
            XCTAssertTrue(p == am.root)
        }

        XCTAssertEqual(portal1.int64, 0x1111111111111111)
        XCTAssertNil(portal2.int64)
        XCTAssertEqual(portal3.int64, 0x3333333333333333)
        XCTAssertEqual(portal4.int64, 0x4444444444444444)
    }
}
