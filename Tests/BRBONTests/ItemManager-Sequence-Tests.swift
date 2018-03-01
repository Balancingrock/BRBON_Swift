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

        
        // Replace item that was added
        
        sm.root[0] = "aaa"
        
        exp = Data(bytes: [
            0x43, 0x00, 0x00, 0x00,  0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            0x40, 0x00, 0x00, 0x00,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x03, 0x00, 0x00, 0x00,
            0x61, 0x61, 0x61, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        sm.data.printBytes()
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = sm.getPortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == sm.root)
        }

    }
}
