//
//  ItemManager-Dictionary-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 26/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON


class ItemManager_Dictionary_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDictionary() {

        let dict = BrbonDictionary(content: [:])!
        
        guard let dm = ItemManager(value: dict) else { XCTFail(); return }
        
        XCTAssertTrue(dm.root.isDictionary)
        XCTAssertEqual(dm.root.count, 0)
        XCTAssertEqual(dm.root._itemByteCount, 24)
        
        var exp = Data(bytes: [
            0x12, 0x00, 0x00, 0x00,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = dm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == dm.root)
        }

        
        // Add an item to the dictionary
        
        XCTAssertEqual(dm.root.updateValue(Int16(0x3333), forName: "one"), .success)
        dm.data.printBytes()
        exp = Data(bytes: [
            0x12, 0x00, 0x00, 0x00,  0x30, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            // item 1
            0x04, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x33, 0x33, 0x00, 0x00,
            0xdc, 0x56, 0x03, 0x6f,  0x6e, 0x65, 0x00, 0x00
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = dm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == dm.root)
        }
        
        
        // Update the value that was previously added
        
        XCTAssertEqual(dm.root.updateValue("twotwotwotwo", forName: "one"), .success)

        exp = Data(bytes: [
            0x12, 0x00, 0x00, 0x00,  0x40, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,

            0x00, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            // item 1
            0x0D, 0x00, 0x00, 0x08,  0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0xdc, 0x56, 0x03, 0x6f,  0x6e, 0x65, 0x00, 0x00,
            
            0x0C, 0x00, 0x00, 0x00,  0x74, 0x77, 0x6f, 0x74,
            0x77, 0x6f, 0x74, 0x77,  0x6f, 0x74, 0x77, 0x6f
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = dm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == dm.root)
        }
    }
    
    func testDictionary2() {
        
        let dict = BrbonDictionary(content: [:])!
        
        guard let dm = ItemManager(value: dict) else { XCTFail(); return }
        
        XCTAssertTrue(dm.root.isDictionary)
        XCTAssertEqual(dm.root.count, 0)
        XCTAssertEqual(dm.root._itemByteCount, 24)
        
        var exp = Data(bytes: [
            0x12, 0x00, 0x00, 0x00,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,

            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = dm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == dm.root)
        }
        
        
        // Add three items to the dictionary
        
        XCTAssertEqual(dm.root.updateValue(Int16(0x3333), forName: "ooo"), .success)
        XCTAssertEqual(dm.root.updateValue(Int16(0x4444), forName: "nnn"), .success)
        XCTAssertEqual(dm.root.updateValue(Int16(0x5555), forName: "eee"), .success)
        
        let p1 = dm.root["ooo"].portal
        let p2 = dm.root["nnn"].portal
        let p3 = dm.root["eee"].portal
        
        XCTAssertEqual(p1.int16, 0x3333)
        XCTAssertEqual(p2.int16, 0x4444)
        XCTAssertEqual(p3.int16, 0x5555)
        
        exp = Data(bytes: [
            0x12, 0x00, 0x00, 0x00,  0x60, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x03, 0x00, 0x00, 0x00,
            
            0x04, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x33, 0x33, 0x00, 0x00,
            0x5d, 0xc1, 0x03, 0x6f,  0x6f, 0x6f, 0x00, 0x00,
            
            0x04, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x44, 0x44, 0x00, 0x00,
            0xcc, 0x51, 0x03, 0x6e,  0x6e, 0x6e, 0x00, 0x00,
            
            0x04, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x55, 0x55, 0x00, 0x00,
            0xfb, 0x64, 0x03, 0x65,  0x65, 0x65, 0x00, 0x00
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = dm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == dm.root)
        }
        
        
        // Update the middle value that was previously added
        
        XCTAssertEqual(dm.root.updateValue("twotwotwotwo", forName: "nnn"), .success)
        
        exp = Data(bytes: [
            0x12, 0x00, 0x00, 0x00,  0x70, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x03, 0x00, 0x00, 0x00,
            
            0x04, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x33, 0x33, 0x00, 0x00,
            0x5d, 0xc1, 0x03, 0x6f,  0x6f, 0x6f, 0x00, 0x00,

            0x0D, 0x00, 0x00, 0x08,  0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0xcc, 0x51, 0x03, 0x6e,  0x6e, 0x6e, 0x00, 0x00,
            0x0C, 0x00, 0x00, 0x00,  0x74, 0x77, 0x6f, 0x74,
            0x77, 0x6f, 0x74, 0x77,  0x6f, 0x74, 0x77, 0x6f,
            
            0x04, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x55, 0x55, 0x00, 0x00,
            0xfb, 0x64, 0x03, 0x65,  0x65, 0x65, 0x00, 0x00
            ])

        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = dm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == dm.root)
        }
        
        XCTAssertEqual(p1.int16, 0x3333)
        XCTAssertEqual(p2.string, "twotwotwotwo")
        XCTAssertEqual(p3.int16, 0x5555)
        
        
        // Remove first item
        
        XCTAssertEqual(dm.root.removeValue(forName: "ooo"), .success)
        
        exp = Data(bytes: [
            0x12, 0x00, 0x00, 0x00,  0x70, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x02, 0x00, 0x00, 0x00,
            
            0x0D, 0x00, 0x00, 0x08,  0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0xcc, 0x51, 0x03, 0x6e,  0x6e, 0x6e, 0x00, 0x00,
            0x0C, 0x00, 0x00, 0x00,  0x74, 0x77, 0x6f, 0x74,
            0x77, 0x6f, 0x74, 0x77,  0x6f, 0x74, 0x77, 0x6f,
            
            0x04, 0x00, 0x00, 0x08,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x55, 0x55, 0x00, 0x00,
            0xfb, 0x64, 0x03, 0x65,  0x65, 0x65, 0x00, 0x00
            ])
        dm.data.printBytes()

        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = dm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == dm.root)
        }
        
        XCTAssertFalse(p1.isValid)
        XCTAssertEqual(p2.string, "twotwotwotwo")
        XCTAssertEqual(p3.int16, 0x5555)
        
        
        // Remove last item
        
        XCTAssertEqual(dm.root.removeValue(forName: "eee"), .success)
        
        exp = Data(bytes: [
            0x12, 0x00, 0x00, 0x00,  0x40, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            0x0D, 0x00, 0x00, 0x08,  0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0xcc, 0x51, 0x03, 0x6e,  0x6e, 0x6e, 0x00, 0x00,
            0x0C, 0x00, 0x00, 0x00,  0x74, 0x77, 0x6f, 0x74,
            0x77, 0x6f, 0x74, 0x77,  0x6f, 0x74, 0x77, 0x6f,
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = dm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == dm.root)
        }
        
        XCTAssertFalse(p1.isValid)
        XCTAssertEqual(p2.string, "twotwotwotwo")
        XCTAssertFalse(p3.isValid)

        
        // Remove remaining item
        
        XCTAssertEqual(dm.root.removeValue(forName: "nnn"), .success)
        
        exp = Data(bytes: [
            0x12, 0x00, 0x00, 0x00,  0x18, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = dm.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == dm.root)
        }
        
        XCTAssertFalse(p1.isValid)
        XCTAssertFalse(p2.isValid)
        XCTAssertFalse(p3.isValid)
    }
}
