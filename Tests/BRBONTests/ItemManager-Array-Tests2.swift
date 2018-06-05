//
//  ItemManager-Array-Tests2.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 23/02/18.
//
//

import XCTest
import BRUtils
@testable import BRBON

class ItemManager_Array_Tests2: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThreeArraysInArray() {
        
        ItemManager.startWithZeroedBuffers = true
        
        // Create empty array manager
        
        let am = ItemManager.createArrayManager(withNameField: nil, elementType: .array, elementByteCount: 32, elementCount: 0, endianness: Endianness.little)
        
        
        // Append three array's the middle one with strings
        
        let arr1 = ItemManager.createArrayManager(values: [UInt32(0x11111111), UInt32(0x22222222)])
        let arr2 = ItemManager.createArrayManager(values: ["1111", "2222", "3333"])
        let arr3 = ItemManager.createArrayManager(values: [UInt8(0x48), UInt8(0x49), UInt8(0x4A), UInt8(0x4B)])
        
        XCTAssertEqual(am.root.appendElements([arr1, arr2, arr3]), .success)
        
        let exp = Data(bytes: [
            0x11, 0x00, 0x00, 0x00,  0xC8, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x11, 0x00, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00,  0x38, 0x00, 0x00, 0x00,
            
            
            // Element 1
            0x11, 0x00, 0x00, 0x00,  0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x09, 0x00, 0x00, 0x00,
            0x02, 0x00, 0x00, 0x00,  0x04, 0x00, 0x00, 0x00,
            
            0x11, 0x11, 0x11, 0x11,  0x22, 0x22, 0x22, 0x22,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            
            // Element 2
            0x11, 0x00, 0x00, 0x00,  0x38, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x0D, 0x00, 0x00, 0x00,
            0x03, 0x00, 0x00, 0x00,  0x08, 0x00, 0x00, 0x00,
            
            0x04, 0x00, 0x00, 0x00,  0x31, 0x31, 0x31, 0x31,
            0x04, 0x00, 0x00, 0x00,  0x32, 0x32, 0x32, 0x32,
            0x04, 0x00, 0x00, 0x00,  0x33, 0x33, 0x33, 0x33,
            
            
            // Element 3
            0x11, 0x00, 0x00, 0x00,  0x28, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            
            0x00, 0x00, 0x00, 0x00,  0x07, 0x00, 0x00, 0x00,
            0x04, 0x00, 0x00, 0x00,  0x01, 0x00, 0x00, 0x00,
            
            0x48, 0x49, 0x4A, 0x4B,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00
            
            ])
        
        exp.withUnsafeBytes() { (ptr: UnsafePointer<UInt8>) -> () in
            let p = am.getActivePortal(for: UnsafeMutableRawPointer(mutating: ptr))
            XCTAssertTrue(p == am.root)
        }
        
        guard let portal1 = am.root[0][1].portal else { XCTFail(); return }
        guard let portal2 = am.root[1][0].portal else { XCTFail(); return }
        guard let portal3 = am.root[1][1].portal else { XCTFail(); return }
        guard let portal4 = am.root[1][2].portal else { XCTFail(); return }
        guard let portal5 = am.root[2][2].portal else { XCTFail(); return }
        
        XCTAssertEqual(portal1.uint32, 0x22222222)
        XCTAssertEqual(portal2.string, "1111")
        XCTAssertEqual(portal3.string, "2222")
        XCTAssertEqual(portal4.string, "3333")
        XCTAssertEqual(portal5.uint8, 0x4A)
        
        portal3.string = "44444444"
        
        XCTAssertEqual(portal1.uint32, 0x22222222)
        XCTAssertEqual(portal2.string, "1111")
        XCTAssertEqual(portal3.string, "44444444")
        XCTAssertEqual(portal4.string, "3333")
        XCTAssertEqual(portal5.uint8, 0x4A)
    }
}
