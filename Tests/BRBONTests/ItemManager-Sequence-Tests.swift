//
//  ItemManager-Sequence-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 01/03/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class ItemManager_Sequence_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_1() {

        let bs = BrbonSequence()
        
        guard let sm = ItemManager(value: bs) else { XCTFail() ; return }
        
        var exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x00,  0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = sm.getPortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == sm.root)
        }


        // Add an item
        
        XCTAssertEqual(sm.root.append(UInt32(0x12345678)), .success)
        
        exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x00,  0x20, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            0x87, 0x00, 0x00, 0x00,  0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x78, 0x56, 0x34, 0x12
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = sm.getPortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == sm.root)
        }

        
        // Add a second item
        
        XCTAssertEqual(sm.root.append(Int16(0x6666), forName:"aaa"), .success)
        
        exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x00,  0x38, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x02, 0x00, 0x00, 0x00,
            
            0x87, 0x00, 0x00, 0x00,  0x10, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x78, 0x56, 0x34, 0x12,
            
            0x83, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x66, 0x66, 0x00, 0x00,
            0xb9, 0xa6, 0x03, 0x61,  0x61, 0x61, 0x00, 0x00
            ])
                
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = sm.getPortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == sm.root)
        }

        let portal = sm.root["aaa"].portal
        
        XCTAssertEqual(portal.int16, 0x6666)
        
        
        // Replace the first item
        
        sm.root[0] = "aaa"
        
        exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x00,  0x40, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x02, 0x00, 0x00, 0x00,
            
            0x40, 0x00, 0x00, 0x00,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x03, 0x00, 0x00, 0x00,
            0x61, 0x61, 0x61, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x83, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x66, 0x66, 0x00, 0x00,
            0xb9, 0xa6, 0x03, 0x61,  0x61, 0x61, 0x00, 0x00
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = sm.getPortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == sm.root)
        }
        
        XCTAssertEqual(portal.int16, 0x6666)

        
        // Delete the first item
        
        let portal2 = sm.root[0].portal
        XCTAssertEqual(portal2.string, "aaa")
        
        XCTAssertEqual(sm.root.remove(at: 0), .success)
        
        exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x00,  0x40, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            0x83, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x66, 0x66, 0x00, 0x00,
            0xb9, 0xa6, 0x03, 0x61,  0x61, 0x61, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = sm.getPortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == sm.root)
        }
        
        XCTAssertEqual(portal.int16, 0x6666)
        XCTAssertFalse(portal2.isValid)

        
        
        // Insert an item before the first item
        
        XCTAssertEqual(sm.root.insert(UInt64(0x1020304050607080), atIndex: 0), .success)
        
        exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x00,  0x40, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x02, 0x00, 0x00, 0x00,
            
            0x02, 0x00, 0x00, 0x00,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x80, 0x70, 0x60, 0x50,  0x40, 0x30, 0x20, 0x10,

            0x83, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x66, 0x66, 0x00, 0x00,
            0xb9, 0xa6, 0x03, 0x61,  0x61, 0x61, 0x00, 0x00
            ])
        
        sm.data.printBytes()
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = sm.getPortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == sm.root)
        }
        
        XCTAssertEqual(portal.int16, 0x6666)

    }
}
