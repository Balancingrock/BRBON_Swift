//
//  ArrayManager-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 19/01/18.
//
//

import XCTest
@testable import BRBON

class ArrayManager_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDefaultInit() {

        
        guard let am = ArrayManager.init(elementType: .bool, initialCount: 0) else { XCTFail("Could not create array manager"); return }
        
        XCTAssertEqual(am.count, 0) // Number of items should be zero
        XCTAssertEqual(am.byteCount, 24) // 16 bytes + 2x4 bytes
        
        
        guard let am1 = ArrayManager.init(elementType: .bool, initialCount: 1) else { XCTFail("Could not create array manager"); return }
        
        XCTAssertEqual(am1.count, 1) // Number of items should be zero
        XCTAssertEqual(am1.byteCount, 32) // 16 bytes + 2x4 bytes + 1 value byte + 7 reserved bytes

        
        guard let am2 = ArrayManager.init(elementType: .bool, initialCount: 8) else { XCTFail("Could not create array manager"); return }
        
        XCTAssertEqual(am2.count, 8) // Number of items should be zero
        XCTAssertEqual(am2.byteCount, 32) // 16 bytes + 2x4 bytes + 8 value byte

        
        guard let am3 = ArrayManager.init(elementType: .bool, initialCount: 8, name: "Test") else { XCTFail("Could not create array manager"); return }
        
        XCTAssertEqual(am3.count, 8) // Number of items should be zero
        XCTAssertEqual(am3.byteCount, 40) // 16 bytes + 2x4 bytes + 2 name hash, 1 name count, 4 name data, 1 name reserved + 8 value bytes
    }
    
    func testAppendBoolReject() {
        
        let am = ArrayManager.init(elementType: .bool, initialCount: 0)!
        
        XCTAssertEqual(am.count, 0)       // Number of items should be zero
        XCTAssertEqual(am.byteCount, 24)    // 16 bytes + 2x4 bytes
        
        XCTAssertEqual(am.append(UInt8(1)), Result.typeConflict)
        XCTAssertEqual(am.append(UInt16(1)), Result.typeConflict)
        XCTAssertEqual(am.append(UInt32(1)), Result.typeConflict)
        XCTAssertEqual(am.append(UInt64(1)), Result.typeConflict)
        XCTAssertEqual(am.append(Int8(1)), Result.typeConflict)
        XCTAssertEqual(am.append(Int16(1)), Result.typeConflict)
        XCTAssertEqual(am.append(Int32(1)), Result.typeConflict)
        XCTAssertEqual(am.append(Int64(1)), Result.typeConflict)
        XCTAssertEqual(am.append("test"), Result.typeConflict)
        XCTAssertEqual(am.append(Data(count: 10)), Result.typeConflict)
        
        XCTAssertEqual(am.count, 0)
        XCTAssertEqual(am.byteCount, 24)
    }

    func testAppendUInt8() {
        
        guard let am = ArrayManager.init(elementType: .uint8, initialCount: 0) else { XCTFail("Could not create array manager"); return }
        
        XCTAssertEqual(am.count, 0)       // Number of items should be zero
        XCTAssertEqual(am.byteCount, 24)    // 16 bytes + 2x4 bytes

        XCTAssertEqual(am.append(UInt8(1)), Result.success)
        
        XCTAssertEqual(am.count, 1)
        XCTAssertEqual(am.byteCount, 32)    // 16 bytes + 2x4 bytes + 1 value + 7 reserved
        
        XCTAssertEqual(am[0].uint8 ?? 0, 1)

        XCTAssertEqual(am.append(UInt8(2)), Result.success)
        XCTAssertEqual(am.append(UInt8(3)), Result.success)
        XCTAssertEqual(am.append(UInt8(4)), Result.success)
        XCTAssertEqual(am.append(UInt8(5)), Result.success)
        XCTAssertEqual(am.append(UInt8(6)), Result.success)
        XCTAssertEqual(am.append(UInt8(7)), Result.success)
        XCTAssertEqual(am.append(UInt8(8)), Result.success)
        
        XCTAssertEqual(am.count, 8)
        XCTAssertEqual(am.byteCount, 32)    // 16 bytes + 2x4 bytes + 8 value

        XCTAssertEqual(am.append(UInt8(9)), Result.success)

        XCTAssertEqual(am.count, 9)
        XCTAssertEqual(am.byteCount, 40)    // 16 bytes + 2x4 bytes + 9 value + 7 reserved
    }
    
    func testAppendUInt16() {
        
        guard let am = ArrayManager.init(elementType: .uint16, initialCount: 0) else { XCTFail("Could not create array manager"); return }
        
        XCTAssertEqual(am.count, 0)       // Number of items should be zero
        XCTAssertEqual(am.byteCount, 24)    // 16 bytes + 2x4 bytes
        
        XCTAssertEqual(am.append(UInt16(1)), Result.success)
        
        XCTAssertEqual(am.count, 1)
        XCTAssertEqual(am.byteCount, 32)    // 16 bytes + 2x4 bytes + 2 value + 6 reserved
        
        XCTAssertEqual(am[0].uint16 ?? 0, 1)
        
        XCTAssertEqual(am.append(UInt16(2)), Result.success)
        XCTAssertEqual(am.append(UInt16(3)), Result.success)
        XCTAssertEqual(am.append(UInt16(4)), Result.success)
        
        XCTAssertEqual(am.count, 4)
        XCTAssertEqual(am.byteCount, 32)    // 16 bytes + 2x4 bytes + 8 value
        
        XCTAssertEqual(am.append(UInt16(5)), Result.success)
        
        XCTAssertEqual(am.count, 5)
        XCTAssertEqual(am.byteCount, 40)    // 16 bytes + 2x4 bytes + 10 value + 6 reserved
    }

    func testArraySubscript() {
        
        guard let am = ArrayManager.init(elementType: .uint16, initialCount: 0) else { XCTFail("Could not create array manager"); return }

        XCTAssertEqual(am.append(UInt16(1)), Result.success)
        XCTAssertEqual(am.append(UInt16(2)), Result.success)

        am[1] = UInt16(3)
        
        XCTAssertEqual(am[1].uint16, 3)
        
        
        guard let am1 = ArrayManager.init(elementType: .float32, initialCount: 6) else { XCTFail("Could not create array manager"); return }

        am1[3] = Float32(11.23)
        
        XCTAssertEqual(am1[2], Float32(0.0))
        XCTAssertEqual(am1[3], Float32(11.23))
        XCTAssertEqual(am1[4], Float32(0.0))
    }
    
    func testRemoveAt() {
        
        guard let am = ArrayManager.init(elementType: .uint16, initialCount: 0) else { XCTFail("Could not create array manager"); return }
        
        XCTAssertEqual(am.append(UInt16(1)), Result.success)
        XCTAssertEqual(am.append(UInt16(2)), Result.success)
        XCTAssertEqual(am.append(UInt16(3)), Result.success)
        XCTAssertEqual(am.append(UInt16(4)), Result.success)
        XCTAssertEqual(am.append(UInt16(5)), Result.success)
        XCTAssertEqual(am.append(UInt16(6)), Result.success)

        XCTAssertEqual(am.remove(at: 3), Result.success)

        XCTAssertEqual(am.count, 5)
        
        XCTAssertEqual(am[2].uint16, 3)
        XCTAssertEqual(am[3].uint16, 5)
        XCTAssertEqual(am[4].uint16, 6)
    }
    
    func testInsertAt() {
        
        guard let am = ArrayManager.init(elementType: .uint16, initialCount: 0) else { XCTFail("Could not create array manager"); return }
        
        XCTAssertEqual(am.append(UInt16(1)), Result.success)
        XCTAssertEqual(am.append(UInt16(2)), Result.success)
        XCTAssertEqual(am.append(UInt16(3)), Result.success)
        XCTAssertEqual(am.append(UInt16(4)), Result.success)
        XCTAssertEqual(am.append(UInt16(5)), Result.success)
        XCTAssertEqual(am.append(UInt16(6)), Result.success)

        XCTAssertEqual(am.insert(UInt16(7), at: 4), Result.success)
        
        XCTAssertEqual(am.count, 7)
        
        XCTAssertEqual(am[3].uint16, 4)
        XCTAssertEqual(am[4].uint16, 7)
        XCTAssertEqual(am[5].uint16, 5)
        XCTAssertEqual(am[6].uint16, 6)

    }
    
    func testCreateNewElements() {
        
        guard let am = ArrayManager.init(elementType: .uint16, initialCount: 0) else { XCTFail("Could not create array manager"); return }
        
        XCTAssertEqual(am.append(UInt16(1)), Result.success)
        XCTAssertEqual(am.append(UInt16(2)), Result.success)

        XCTAssertEqual(am.createNewElements(), Result.success)
        
        XCTAssertEqual(am.count, 3)
        
        XCTAssertEqual(am[0].uint16, 1)
        XCTAssertEqual(am[1].uint16, 2)
        XCTAssertEqual(am[2].uint16, 0)

        XCTAssertEqual(am.createNewElements(amount: 4, value: UInt16(7)), Result.success)

        XCTAssertEqual(am.count, 7)

        XCTAssertEqual(am[0].uint16, 1)
        XCTAssertEqual(am[1].uint16, 2)
        XCTAssertEqual(am[2].uint16, 0)
        XCTAssertEqual(am[3].uint16, 7)
        XCTAssertEqual(am[4].uint16, 7)
        XCTAssertEqual(am[5].uint16, 7)
        XCTAssertEqual(am[6].uint16, 7)

    }
}
