//
//  Endianness-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 28/10/17.
//
//

import XCTest


class Endianness_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testBool() {
        
        
        // Encoding test 'true'
        
        var b: Bool = true
        
        var bytes = b.endianBytes(.little)
        var comp = Data(bytes: [1])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Encoding test 'false'
        
        b = false
        
        bytes = b.endianBytes(.little)
        comp = Data(bytes: [0])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding from [0]
        
        bytes = Data(bytes: [0])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 1)
        var c = UInt32(bytes.count)
        if let a = Bool(&p, count: &c, endianness: .little) {
            XCTAssertFalse(a)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected a bool")
        }
        
        
        // Decoding from [1]
        
        bytes = Data(bytes: [1])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let a = Bool(&p, count: &c, endianness: .little) {
            XCTAssertTrue(a)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected a bool")
        }
        
        
        // Decoding from [2]
        
        bytes = Data(bytes: [2])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = Bool(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding with count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = Bool(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding with count = 2
        
        bytes = Data(bytes: [0, 1])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = Bool(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testUInt8() {
        
        
        // Encoding test
        
        let b: UInt8 = 0xAA
        
        var bytes = b.endianBytes(.little)
        let comp = Data(bytes: [0xAA])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding test
        
        bytes = Data(bytes: [0xAA])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 1)
        var c = UInt32(bytes.count)
        if let a = UInt8(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 0xAA)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an UInt8")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = UInt8(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 2
        
        bytes = Data(bytes: [0, 2])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = UInt8(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testInt8() {
        
        
        // Encoding test
        
        let b: Int8 = 42
        
        var bytes = b.endianBytes(.little)
        let comp = Data(bytes: [42])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding test positive
        
        bytes = Data(bytes: [42])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 1)
        var c = UInt32(bytes.count)
        if let a = Int8(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 42)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an Int8")
        }
        
        
        // Decoding test negative
        
        bytes = Data(bytes: [0xAA])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let a = Int8(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, -86)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an Int8")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = Int8(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 2
        
        bytes = Data(bytes: [0, 2])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = Int8(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testUInt16() {
        
        
        // Encoding little
        
        var b: UInt16 = 0x1122
        
        var bytes = b.endianBytes(.little)
        var comp = Data(bytes: [0x22, 0x11])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Encoding big
        
        b = 0x1122
        
        bytes = b.endianBytes(.big)
        comp = Data(bytes: [0x11, 0x22])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding little
        
        bytes = Data(bytes: [0x22, 0x11])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 2)
        var c = UInt32(bytes.count)
        if let a = UInt16(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 0x1122)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an UInt16")
        }
        
        
        // Decoding big
        
        bytes = Data(bytes: [0x11, 0x22])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 2)
        c = UInt32(bytes.count)
        if let a = UInt16(&p, count: &c, endianness: .big) {
            XCTAssertEqual(a, 0x1122)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an UInt16")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = UInt16(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 3
        
        bytes = Data(bytes: [0, 2, 3])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = UInt16(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testInt16() {
        
        
        // Encoding little
        
        var b: Int16 = 0x1122
        
        var bytes = b.endianBytes(.little)
        var comp = Data(bytes: [0x22, 0x11])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Encoding big
        
        b = 0x1122
        
        bytes = b.endianBytes(.big)
        comp = Data(bytes: [0x11, 0x22])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding little
        
        bytes = Data(bytes: [0x22, 0x11])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 2)
        var c = UInt32(bytes.count)
        if let a = Int16(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 0x1122)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an Int16")
        }
        
        
        // Decoding big
        
        bytes = Data(bytes: [0x11, 0x22])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 2)
        c = UInt32(bytes.count)
        if let a = Int16(&p, count: &c, endianness: .big) {
            XCTAssertEqual(a, 0x1122)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an Int16")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = Int16(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 3
        
        bytes = Data(bytes: [0, 2, 3])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = Int16(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testUInt32() {
        
        
        // Encoding little
        
        var b: UInt32 = 0x11223344
        
        var bytes = b.endianBytes(.little)
        var comp = Data(bytes: [0x44, 0x33, 0x22, 0x11])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Encoding big
        
        b = 0x11223344
        
        bytes = b.endianBytes(.big)
        comp = Data(bytes: [0x11, 0x22, 0x33, 0x44])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding little
        
        bytes = Data(bytes: [0x44, 0x33, 0x22, 0x11])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 4)
        var c = UInt32(bytes.count)
        if let a = UInt32(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 0x11223344)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an UInt32")
        }
        
        
        // Decoding big
        
        bytes = Data(bytes: [0x11, 0x22, 0x33, 0x44])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 4)
        c = UInt32(bytes.count)
        if let a = UInt32(&p, count: &c, endianness: .big) {
            XCTAssertEqual(a, 0x11223344)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an UInt32")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = UInt32(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 5
        
        bytes = Data(bytes: [0, 1, 2, 3, 4])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = UInt32(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testInt32() {
        
        
        // Encoding little
        
        var b: Int32 = 0x11223344
        
        var bytes = b.endianBytes(.little)
        var comp = Data(bytes: [0x44, 0x33, 0x22, 0x11])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Encoding big
        
        b = 0x11223344
        
        bytes = b.endianBytes(.big)
        comp = Data(bytes: [0x11, 0x22, 0x33, 0x44])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding little
        
        bytes = Data(bytes: [0x44, 0x33, 0x22, 0x11])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 4)
        var c = UInt32(bytes.count)
        if let a = Int32(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 0x11223344)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an Int32")
        }
        
        
        // Decoding big
        
        bytes = Data(bytes: [0x11, 0x22, 0x33, 0x44])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 4)
        c = UInt32(bytes.count)
        if let a = Int32(&p, count: &c, endianness: .big) {
            XCTAssertEqual(a, 0x11223344)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an Int32")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = Int32(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 5
        
        bytes = Data(bytes: [0, 1, 2, 3, 4])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = Int32(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testUInt64() {
        
        
        // Encoding little
        
        var b: UInt64 = 0x1122334455667788
        
        var bytes = b.endianBytes(.little)
        var comp = Data(bytes: [0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Encoding big
        
        b = 0x1122334455667788
        
        bytes = b.endianBytes(.big)
        comp = Data(bytes: [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding little
        
        bytes = Data(bytes: [0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 8)
        var c = UInt32(bytes.count)
        if let a = UInt64(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 0x1122334455667788)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an UInt64")
        }
        
        
        // Decoding big
        
        bytes = Data(bytes: [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 8)
        c = UInt32(bytes.count)
        if let a = UInt64(&p, count: &c, endianness: .big) {
            XCTAssertEqual(a, 0x1122334455667788)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an UInt64")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = UInt64(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 9
        
        bytes = Data(bytes: [0, 1, 2, 3, 4, 5, 6, 7, 8])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = UInt64(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testInt64() {
        
        
        // Encoding little
        
        var b: Int64 = 0x1122334455667788
        
        var bytes = b.endianBytes(.little)
        var comp = Data(bytes: [0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Encoding big
        
        b = 0x1122334455667788
        
        bytes = b.endianBytes(.big)
        comp = Data(bytes: [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding little
        
        bytes = Data(bytes: [0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 8)
        var c = UInt32(bytes.count)
        if let a = Int64(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 0x1122334455667788)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an Int64")
        }
        
        
        // Decoding big
        
        bytes = Data(bytes: [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 8)
        c = UInt32(bytes.count)
        if let a = Int64(&p, count: &c, endianness: .big) {
            XCTAssertEqual(a, 0x1122334455667788)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected an Int64")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = Int64(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 9
        
        bytes = Data(bytes: [0, 1, 2, 3, 4, 5, 6, 7, 8])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = Int64(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testFloat32() {
        
        
        // Encoding little
        
        var b: Float32 = 1.25e10
        
        var bytes = b.endianBytes(.little)
        var comp = Data(bytes: [0xb7, 0x43, 0x3a, 0x50])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Encoding big
        
        b = 1.25e10
        
        bytes = b.endianBytes(.big)
        comp = Data(bytes: [0x50, 0x3a, 0x43, 0xb7])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding little
        
        bytes = Data(bytes: [0xb7, 0x43, 0x3a, 0x50])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 4)
        var c = UInt32(bytes.count)
        if let a = Float32(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 1.25e10)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected a Float32")
        }
        
        
        // Decoding big
        
        bytes = Data(bytes: [0x50, 0x3a, 0x43, 0xb7])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 4)
        c = UInt32(bytes.count)
        if let a = Float32(&p, count: &c, endianness: .big) {
            XCTAssertEqual(a, 1.25e10)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected a Float32")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = Float32(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 5
        
        bytes = Data(bytes: [0, 2, 3, 4, 5])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = Float32(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
    
    func testFloat64() {
        
        
        // Encoding little
        
        var b: Float64 = 1.25e10
        
        var bytes = b.endianBytes(.little)
        var comp = Data(bytes: [0x00, 0x00, 0x00, 0xe8, 0x76, 0x48, 0x07, 0x42])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Encoding big
        
        b = 1.25e10
        
        bytes = b.endianBytes(.big)
        comp = Data(bytes: [0x42, 0x07, 0x48, 0x76, 0xe8, 0x00, 0x00, 0x00])
        
        XCTAssertEqual(bytes, comp)
        
        
        // Decoding little
        
        bytes = Data(bytes: [0x00, 0x00, 0x00, 0xe8, 0x76, 0x48, 0x07, 0x42])
        var p = (bytes as NSData).bytes
        var p1 = p.advanced(by: 8)
        var c = UInt32(bytes.count)
        if let a = Float64(&p, count: &c, endianness: .little) {
            XCTAssertEqual(a, 1.25e10)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected a Float64")
        }
        
        
        // Decoding big
        
        bytes = Data(bytes: [0x42, 0x07, 0x48, 0x76, 0xe8, 0x00, 0x00, 0x00])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 8)
        c = UInt32(bytes.count)
        if let a = Float64(&p, count: &c, endianness: .big) {
            XCTAssertEqual(a, 1.25e10)
            XCTAssertEqual(c, 0)
            XCTAssertEqual(p, p1)
        } else {
            XCTFail("Expected a Float64")
        }
        
        
        // Decoding test, count = 0
        
        bytes = Data(bytes: [])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        if let _ = Float64(&p, count: &c, endianness: .little) {
            XCTFail("Expected a failure")
        }
        
        
        // Decoding test, count = 9
        
        bytes = Data(bytes: [0, 1, 2, 3, 4, 5, 6, 7, 8])
        p = (bytes as NSData).bytes
        p1 = p.advanced(by: 1)
        c = UInt32(bytes.count)
        guard let _ = Float64(&p, count: &c, endianness: .little) else { XCTFail("Expected success"); return }
        XCTAssertEqual(c, 1)
    }
}
