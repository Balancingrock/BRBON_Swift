//
//  Item-Values.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/01/18.
//
//

import Foundation
import BRUtils


// MARK: - Value related derviates

extension Item {

    var isNull: Bool { return type == .null }
    var isBool: Bool { return type == .bool }
    var isUInt8: Bool { return type == .uint8 }
    var isUInt16: Bool { return type == .uint16 }
    var isUInt32: Bool { return type == .uint32 }
    var isUInt64: Bool { return type == .uint64 }
    var isInt8: Bool { return type == .int8 }
    var isInt16: Bool { return type == .int16 }
    var isInt32: Bool { return type == .int32 }
    var isInt64: Bool { return type == .int64 }
    var isFloat32: Bool { return type == .float32 }
    var isFloat64: Bool { return type == .float64 }
    var isString: Bool { return type == .string }
    var isBinary: Bool { return type == .binary }
    var isArray: Bool { return type == .array }
    var isDictionary: Bool { return type == .dictionary }
    var isSequence: Bool { return type == .sequence }
    
    var bool: Bool? {
        get { return Bool(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var uint8: UInt8? {
        get { return UInt8(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var uint16: UInt16? {
        get { return UInt16(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var uint32: UInt32? {
        get { return UInt32(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var uint64: UInt64? {
        get { return UInt64(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var int8: Int8? {
        get { return Int8(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var int16: Int16? {
        get { return Int16(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var int32: Int32? {
        get { return Int32(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var int64: Int64? {
        get { return Int64(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var float32: Float32? {
        get { return Float32(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var float64: Float64? {
        get { return Float64(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var string: String? {
        get { return String(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }
    
    var binary: Data? {
        get { return Data(valuePtr, endianness) }
        set { newValue?.brbonBytes(toPtr: valuePtr, endianness) }
    }    
}
