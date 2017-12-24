//
//  ItemValue-Tests.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 22/11/17.
//
//

import XCTest
@testable import BRBON

class ItemValue_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNull() {
        
        let itemValue = ItemValue(null: true)
        
        XCTAssertEqual(itemValue.type, .null)
        XCTAssertNil(itemValue.any)
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 0)
        XCTAssertEqual(itemValue.endianBytes(.little), Data())
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .null)
        XCTAssertNil(dup.any)
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 0)
        XCTAssertEqual(dup.endianBytes(.little), Data())
    }
    
    func testBool() {
        
        var itemValue = ItemValue(true)
        
        XCTAssertEqual(itemValue.type, .bool)
        if let val = itemValue.any as? Bool {
            XCTAssertEqual(val, true)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 1)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x01]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .bool)
        if let val = dup.any as? Bool {
            XCTAssertEqual(val, true)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 1)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x01]))
        
        
        itemValue = ItemValue(false)
        
        XCTAssertEqual(itemValue.type, .bool)
        if let val = itemValue.any as? Bool {
            XCTAssertEqual(val, false)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 1)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x00]))

        
        var data = Data(bytes: [0x01, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .bool) {
            
            XCTAssertEqual(value.type, .bool)
            if let val = value.any as? Bool {
                XCTAssertEqual(val, true)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 1)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x01]))
            XCTAssertEqual(counter, 3)
        }
    }

    func testUInt8() {
        
        let itemValue = ItemValue(UInt8(4))
        
        XCTAssertEqual(itemValue.type, .uint8)
        if let val = itemValue.any as? UInt8 {
            XCTAssertEqual(val, 4)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 1)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x04]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .uint8)
        if let val = dup.any as? UInt8 {
            XCTAssertEqual(val, 4)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 1)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x04]))
        
        
        var data = Data(bytes: [0x05, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .uint8) {
            
            XCTAssertEqual(value.type, .uint8)
            if let val = value.any as? UInt8 {
                XCTAssertEqual(val, 5)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 1)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x05]))
            XCTAssertEqual(counter, 3)
        }
    }

    func testInt8() {
        
        let itemValue = ItemValue(Int8(4))
        
        XCTAssertEqual(itemValue.type, .int8)
        if let val = itemValue.any as? Int8 {
            XCTAssertEqual(val, 4)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 1)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x04]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .int8)
        if let val = dup.any as? Int8 {
            XCTAssertEqual(val, 4)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 1)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x04]))
        
        
        var data = Data(bytes: [0x05, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .int8) {
            
            XCTAssertEqual(value.type, .int8)
            if let val = value.any as? Int8 {
                XCTAssertEqual(val, 5)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 1)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x05]))
            XCTAssertEqual(counter, 3)
        }
    }

    func testUInt16() {
        
        let itemValue = ItemValue(UInt16(404))
        
        XCTAssertEqual(itemValue.type, .uint16)
        if let val = itemValue.any as? UInt16 {
            XCTAssertEqual(val, 404)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 2)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x94, 0x01]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .uint16)
        if let val = dup.any as? UInt16 {
            XCTAssertEqual(val, 404)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 2)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x94, 0x01]))
        
        
        var data = Data(bytes: [0x94, 0x01, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .uint16) {
            
            XCTAssertEqual(value.type, .uint16)
            if let val = value.any as? UInt16 {
                XCTAssertEqual(val, 404)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 2)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x94, 0x01]))
            XCTAssertEqual(counter, 2)
        }
    }
    
    func testInt16() {
        
        let itemValue = ItemValue(Int16(404))
        
        XCTAssertEqual(itemValue.type, .int16)
        if let val = itemValue.any as? Int16 {
            XCTAssertEqual(val, 404)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 2)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x94, 0x01]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .int16)
        if let val = dup.any as? Int16 {
            XCTAssertEqual(val, 404)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 2)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x94, 0x01]))
        
        
        var data = Data(bytes: [0x94, 0x01, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .int16) {
            
            XCTAssertEqual(value.type, .int16)
            if let val = value.any as? Int16 {
                XCTAssertEqual(val, 404)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 2)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x94, 0x01]))
            XCTAssertEqual(counter, 2)
        }
    }

    func testUInt32() {
        
        let itemValue = ItemValue(UInt32(4040404))
        
        XCTAssertEqual(itemValue.type, .uint32)
        if let val = itemValue.any as? UInt32 {
            XCTAssertEqual(val, 4040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 4)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0xD4, 0xA6, 0x3D, 0x00]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .uint32)
        if let val = dup.any as? UInt32 {
            XCTAssertEqual(val, 4040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 4)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0xD4, 0xA6, 0x3D, 0x00]))
        
        
        var data = Data(bytes: [0xD4, 0xA6, 0x3D, 0x00, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .uint32) {
            
            XCTAssertEqual(value.type, .uint32)
            if let val = value.any as? UInt32 {
                XCTAssertEqual(val, 4040404)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 4)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0xD4, 0xA6, 0x3D, 0x00]))
            XCTAssertEqual(counter, 2)
        }
    }
    
    func testInt32() {
        
        let itemValue = ItemValue(Int32(4040404))
        
        XCTAssertEqual(itemValue.type, .int32)
        if let val = itemValue.any as? Int32 {
            XCTAssertEqual(val, 4040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 4)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0xD4, 0xA6, 0x3D, 0x00]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .int32)
        if let val = dup.any as? Int32 {
            XCTAssertEqual(val, 4040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 4)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0xD4, 0xA6, 0x3D, 0x00]))
        
        
        var data = Data(bytes: [0xD4, 0xA6, 0x3D, 0x00, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .int32) {
            
            XCTAssertEqual(value.type, .int32)
            if let val = value.any as? Int32 {
                XCTAssertEqual(val, 4040404)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 4)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0xD4, 0xA6, 0x3D, 0x00]))
            XCTAssertEqual(counter, 2)
        }
    }

    func testUInt64() {
        
        let itemValue = ItemValue(UInt64(4040404040404))
        
        XCTAssertEqual(itemValue.type, .uint64)
        if let val = itemValue.any as? UInt64 {
            XCTAssertEqual(val, 4040404040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 8)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0xD4, 0xFA, 0xD8, 0xBA, 0xAC, 0x03, 0, 0]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .uint64)
        if let val = dup.any as? UInt64 {
            XCTAssertEqual(val, 4040404040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 8)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0xD4, 0xFA, 0xD8, 0xBA, 0xAC, 0x03, 0, 0]))
        
        
        var data = Data(bytes: [0xD4, 0xFA, 0xD8, 0xBA, 0xAC, 0x03, 0, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .uint64) {
            
            XCTAssertEqual(value.type, .uint64)
            if let val = value.any as? UInt64 {
                XCTAssertEqual(val, 4040404040404)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 8)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0xD4, 0xFA, 0xD8, 0xBA, 0xAC, 0x03, 0, 0]))
            XCTAssertEqual(counter, 2)
        }
    }
    
    func testInt64() {
        
        let itemValue = ItemValue(Int64(4040404040404))
        
        XCTAssertEqual(itemValue.type, .int64)
        if let val = itemValue.any as? Int64 {
            XCTAssertEqual(val, 4040404040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 8)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0xD4, 0xFA, 0xD8, 0xBA, 0xAC, 0x03, 0, 0]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .int64)
        if let val = dup.any as? Int64 {
            XCTAssertEqual(val, 4040404040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 8)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0xD4, 0xFA, 0xD8, 0xBA, 0xAC, 0x03, 0, 0]))
        
        
        var data = Data(bytes: [0xD4, 0xFA, 0xD8, 0xBA, 0xAC, 0x03, 0, 0, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .int64) {
            
            XCTAssertEqual(value.type, .int64)
            if let val = value.any as? Int64 {
                XCTAssertEqual(val, 4040404040404)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 8)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0xD4, 0xFA, 0xD8, 0xBA, 0xAC, 0x03, 0, 0]))
            XCTAssertEqual(counter, 2)
        }
    }

    func testFloat32() {
        
        let itemValue = ItemValue(Float32(40404))
        
        XCTAssertEqual(itemValue.type, .float32)
        if let val = itemValue.any as? Float32 {
            XCTAssertEqual(val, 40404)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 4)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x00, 0xd4, 0x1D, 0x47]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .float32)
        if let val = dup.any as? Float32 {
            XCTAssertEqual(val, 40404)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 4)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x00, 0xd4, 0x1D, 0x47]))
        
        
        var data = Data(bytes: [0x00, 0xd4, 0x1D, 0x47, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .float32) {
            
            XCTAssertEqual(value.type, .float32)
            if let val = value.any as? Float32 {
                XCTAssertEqual(val, 40404)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 4)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x00, 0xd4, 0x1D, 0x47]))
            XCTAssertEqual(counter, 2)
        }
    }

    func testFloat64() {
        
        let itemValue = ItemValue(Float64(4040404040404))
        
        XCTAssertEqual(itemValue.type, .float64)
        if let val = itemValue.any as? Float64 {
            XCTAssertEqual(val, 4040404040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 8)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x00, 0xa0, 0xd6, 0xc7, 0xd6, 0x65, 0x8d, 0x42]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .float64)
        if let val = dup.any as? Float64 {
            XCTAssertEqual(val, 4040404040404)
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 8)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x00, 0xa0, 0xd6, 0xc7, 0xd6, 0x65, 0x8d, 0x42]))
        
        
        var data = Data(bytes: [0x00, 0xa0, 0xd6, 0xc7, 0xd6, 0x65, 0x8d, 0x42, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .float64) {
            
            XCTAssertEqual(value.type, .float64)
            if let val = value.any as? Float64 {
                XCTAssertEqual(val, 4040404040404)
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 8)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x00, 0xa0, 0xd6, 0xc7, 0xd6, 0x65, 0x8d, 0x42]))
            XCTAssertEqual(counter, 2)
        }
    }

    func testString() {
        
        let itemValue = ItemValue("Test")
        
        XCTAssertEqual(itemValue.type, .string)
        if let val = itemValue.any as? String {
            XCTAssertEqual(val, "Test")
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 8)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x04, 0x0, 0x0, 0x0, 84, 101, 115, 116]))
        
        
        let dup = itemValue.duplicate
        
        XCTAssertEqual(dup.type, .string)
        if let val = dup.any as? String {
            XCTAssertEqual(val, "Test")
        } else {
            XCTFail()
        }
        XCTAssertNil(dup.array)
        XCTAssertNil(dup.elementType)
        XCTAssertNil(dup.elementByteCount)
        XCTAssertEqual(dup.byteCount, 8)
        XCTAssertEqual(dup.endianBytes(.little), Data(bytes: [0x04, 0x0, 0x0, 0x0, 84, 101, 115, 116]))
        
        
        var data = Data(bytes: [0x04, 0x0, 0x0, 0x0, 84, 101, 115, 116, 0, 0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .string) {
            
            XCTAssertEqual(value.type, .string)
            if let val = value.any as? String {
                XCTAssertEqual(val, "Test")
            } else {
                XCTFail()
            }
            XCTAssertNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 8)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x04, 0x0, 0x0, 0x0, 84, 101, 115, 116]))
            XCTAssertEqual(counter, 2)
        }
    }

    func testArray() {
        
        var itemValue = ItemValue(array: [], elementType: .int8, elementByteCount: 1)
        
        XCTAssertEqual(itemValue.type, .array)
        XCTAssertNil(itemValue.any)
        XCTAssertNotNil(itemValue.array)
        XCTAssertEqual(itemValue.elementType, .int8)
        XCTAssertEqual(itemValue.elementByteCount, 1)
        XCTAssertEqual(itemValue.byteCount, 8)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x1, 0x0, 0x0, 0x02, 0x0, 0x0, 0x0, 0x0]))
        
        var item1 = Item(ItemValue(Int8(5)))
        itemValue.array.append(item1)
        var item2 = Item(ItemValue(Int8(3)))
        itemValue.array.append(item2)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x1, 0x0, 0x0, 0x02, 0x2, 0x0, 0x0, 0x0, 0x5, 0x3]))

        
        var data = Data(bytes: [0x1, 0x0, 0x0, 0x02, 0x2, 0x0, 0x0, 0x0, 0x5, 0x3])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)

        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .array) {
            
            XCTAssertEqual(value.type, .array)
            XCTAssertNil(value.any)
            XCTAssertNotNil(value.array)
            XCTAssertEqual(value.elementType, .int8)
            XCTAssertEqual(value.elementByteCount, 1)
            XCTAssertEqual(value.byteCount, 10)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x1, 0x0, 0x0, 0x02, 0x2, 0x0, 0x0, 0x0, 0x5, 0x3]))
        }
        
        
        itemValue = ItemValue(array: [], elementType: .int8, elementByteCount: 2)
        
        XCTAssertEqual(itemValue.type, .array)
        XCTAssertNil(itemValue.any)
        XCTAssertNotNil(itemValue.array)
        XCTAssertEqual(itemValue.elementType, .int8)
        XCTAssertEqual(itemValue.elementByteCount, 2)
        XCTAssertEqual(itemValue.byteCount, 8)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x2, 0x0, 0x0, 0x02, 0x0, 0x0, 0x0, 0x0]))
        
        item1 = Item(ItemValue(Int8(5)))
        itemValue.array.append(item1)
        item2 = Item(ItemValue(Int8(3)))
        itemValue.array.append(item2)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x2, 0x0, 0x0, 0x02, 0x2, 0x0, 0x0, 0x0, 0x5, 0x0, 0x3, 0x0]))

        
        data = Data(bytes: [0x2, 0x0, 0x0, 0x02, 0x2, 0x0, 0x0, 0x0, 0x5, 0x0, 0x3, 0x0])
        bytePtr = (data as NSData).bytes
        counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .array) {
            
            XCTAssertEqual(value.type, .array)
            XCTAssertNil(value.any)
            XCTAssertNotNil(value.array)
            XCTAssertEqual(value.array.count, 2)
            XCTAssertEqual(value.elementType, .int8)
            XCTAssertEqual(value.elementByteCount, 2)
            XCTAssertEqual(value.byteCount, 12)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x2, 0x0, 0x0, 0x02, 0x2, 0x0, 0x0, 0x0, 0x5, 0x0, 0x3, 0x0]))
        }

    }

    func testDictionary() {
        
        let itemValue = ItemValue(dictionary: [])

        XCTAssertEqual(itemValue.type, .dictionary)
        XCTAssertNil(itemValue.any)
        XCTAssertNotNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 8)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x0, 0x0, 0x0, 0x00, 0x0, 0x0, 0x0, 0x0]))

        let item1 = Item(ItemValue(Int8(5)))
        itemValue.array.append(item1)
        //let item2 = Item(ItemValue(Int8(3)))
        //itemValue.array.append(item2)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x1, 0x0, 0x0, 0x00, 0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x8, 0x0, 0x0, 0x0, 0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]))

        
        var data = Data(bytes: [0x1, 0x0, 0x0, 0x00, 0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x8, 0x0, 0x0, 0x0, 0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .dictionary) {
            
            XCTAssertEqual(value.type, .dictionary)
            XCTAssertNil(value.any)
            XCTAssertNotNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 24)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x1, 0x0, 0x0, 0x00, 0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x8, 0x0, 0x0, 0x0, 0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]))
        }
    }
    
    func testSequence() {
        
        let itemValue = ItemValue(sequence: [])
        
        XCTAssertEqual(itemValue.type, .sequence)
        XCTAssertNil(itemValue.any)
        XCTAssertNotNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 8)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x0, 0x0, 0x0, 0x00, 0x0, 0x0, 0x0, 0x0]))
        
        let item1 = Item(ItemValue(Int8(5)))
        itemValue.array.append(item1)
        //let item2 = Item(ItemValue(Int8(3)))
        //itemValue.array.append(item2)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x1, 0x0, 0x0, 0x00, 0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x8, 0x0, 0x0, 0x0, 0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]))
        
        
        var data = Data(bytes: [0x1, 0x0, 0x0, 0x00, 0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x8, 0x0, 0x0, 0x0, 0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .sequence) {
            
            XCTAssertEqual(value.type, .sequence)
            XCTAssertNil(value.any)
            XCTAssertNotNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 24)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x1, 0x0, 0x0, 0x00, 0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x8, 0x0, 0x0, 0x0, 0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]))
        }
    }

    func testBinary() {
        
        var itemValue = ItemValue(Data())
        
        XCTAssertEqual(itemValue.type, .binary)
        if let val = itemValue.any as? Data {
            XCTAssertEqual(val, Data())
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 8)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]))


        itemValue = ItemValue(Data(bytes: [1, 2, 3, 4, 5]))
        
        XCTAssertEqual(itemValue.type, .binary)
        if let val = itemValue.any as? Data {
            XCTAssertEqual(val, Data(bytes: [1, 2, 3, 4, 5]))
        } else {
            XCTFail()
        }
        XCTAssertNil(itemValue.array)
        XCTAssertNil(itemValue.elementType)
        XCTAssertNil(itemValue.elementByteCount)
        XCTAssertEqual(itemValue.byteCount, 13)
        XCTAssertEqual(itemValue.endianBytes(.little), Data(bytes: [0x05, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 1, 2, 3, 4, 5]))

        
        var data = Data(bytes: [0x05, 0x0, 0x0, 0x0, 1, 2, 3, 4, 5])
        var bytePtr = (data as NSData).bytes
        var counter = UInt32(data.count)
        
        if let value = ItemValue(&bytePtr, count: &counter, endianness: .little, type: .sequence) {
            
            XCTAssertEqual(value.type, .sequence)
            XCTAssertNil(value.any)
            XCTAssertNotNil(value.array)
            XCTAssertNil(value.elementType)
            XCTAssertNil(value.elementByteCount)
            XCTAssertEqual(value.byteCount, 9)
            XCTAssertEqual(value.endianBytes(.little), Data(bytes: [0x05, 0x0, 0x0, 0x0, 1, 2, 3, 4, 5]))
        }
    }
}
