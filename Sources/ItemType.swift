// =====================================================================================================================
//
//  File:       ItemType.swift
//  Project:    BRBON
//
//  Version:    0.3.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2017 Marinus van der Lugt, All rights reserved.
//
//  License:    Use or redistribute this code any way you like with the following two provision:
//
//  1) You ACCEPT this source code AS IS without any guarantees that it will work as intended. Any liability from its
//  use is YOURS.
//
//  2) You WILL NOT seek damages from the author or balancingrock.nl.
//
//  I also ask you to please leave this header with the source code.
//
//  I strongly believe that voluntarism is the way for societies to function optimally. Thus I have choosen to leave it
//  up to you to determine the price for this code. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  wishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to check the website http://www.balancingrock.nl before payment)
//
//  For private and non-profit use the suggested price is the price of 1 good cup of coffee, say $4.
//  For commercial use the suggested price is the price of 1 good meal, say $20.
//
//  You are however encouraged to pay more ;-)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// History
//
// 0.3.0  - Changed raw values
// 0.1.0  - Initial version
// =====================================================================================================================

import Foundation
import BRUtils


/// The identifier that describes the actual value.

public enum ItemType: UInt8 {
    
    
    /// ============================================
    /// These types do not use the count/value field
    /// ============================================
    
    
    /// An integer of 64 bits

    case int64          = 0x01

    
    /// An unsigned integer of 64 bits

    case uint64         = 0x02
    
    
    /// Floating point value represented in 64 bits (Called a Double in Swift)

    case float64        = 0x03
    

    /// =====================================================
    /// These types do use the count/value field as a counter
    /// =====================================================

    
    /// A string coded in UTF8 of N bytes with space available for M bytes where M >= N.
    
    case string         = 0x40
    
    
    /// A sequence of items of the same type and length
    
    case array          = 0x41
    

    /// Sequence of named items. These items may vary in type, options and length but are identifyable by their (unique) name.
    
    case dictionary     = 0x42

    
    /// A sequence of other items that may or may not have a name and can be of different types.
    
    case sequence       = 0x43

    
    /// A sequence of bytes (UInt8)
    
    case binary         = 0x44
    

    /// ===================================================
    /// These types do use the count/value field as a value
    /// ===================================================

    /// A null/nil item.
    
    case null           = 0x80
    
    
    /// A boolean
    
    case bool           = 0x81
    
    
    /// An integer of 8 bits
    
    case int8           = 0x82

    
    /// An integer of 16 bits

    case int16          = 0x83
    
    
    /// An integer of 32 bits

    case int32          = 0x84
    
    
    // An unsigned integer of 8 bits (a byte)
    
    case uint8          = 0x85
    
    
    // An unsigned integer of 16 bits

    case uint16         = 0x86
    
    
    // An unsigned integer of 32 bits

    case uint32         = 0x87
    
    
    // Floating point value represented in 32 bits
    
    case float32        = 0x88

    
    public var useValueCountFieldAsCount: Bool { return (self.rawValue & 0x40) != 0 }
    
    public var useValueCountFieldAsValue: Bool { return (self.rawValue & 0x80) != 0 }
    
    public var defaultByteSize: UInt32 {
        switch self {
        case .null: return 0
        case .bool, .int8, .uint8: return 1
        case .int16, .uint16: return 2
        case .int32, .uint32, .float32: return 4
        case .int64, .uint64, .float64: return 8
        case .string, .binary: return 256
        case .array, .dictionary, .sequence: return 1024
        }
    }
    
    public static func typeFor(_ value: BrbonBytes) -> ItemType? {
        switch value {
        case is Bool: return .bool
        case is Int8: return .int8
        case is UInt8: return .uint8
        case is Int16: return .int16
        case is UInt16: return .uint16
        case is Int32: return .int32
        case is UInt32: return .uint32
        case is Int64: return .int64
        case is UInt64: return .uint64
        case is Float32: return .float32
        case is Float64: return .float64
        case is String: return .string
        case is Array<BrbonBytes>: return .array
        case is Dictionary<String, BrbonBytes>: return .dictionary
        case is Data: return .binary
        default: return nil
        }
    }
}


// Extend the enum with the brbon protocol

extension ItemType: BrbonBytes {
    
    public func brbonCount() -> UInt32 {
        return 1
    }
    
    public func brbonType() -> ItemType {
        return .null
    }
    
    public func brbonBytes(_ endianness: Endianness) -> Data {
        return Data(bytes: [self.rawValue])
    }
    
    public func brbonBytes(toPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.rawValue.brbonBytes(toPtr: toPtr, endianness)
    }
    
    public init?(_ fromPtr: UnsafeRawPointer, _ endianness: Endianness) {
        let v = UInt8.init(fromPtr, endianness)
        self.init(rawValue: v)
    }
}
