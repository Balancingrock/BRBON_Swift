// =====================================================================================================================
//
//  File:       ItemType.swift
//  Project:    BRBON
//
//  Version:    0.7.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2018 Marinus van der Lugt, All rights reserved.
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
// 0.7.0 - Code restructuring & simplification
//       - Added Color and Font
// 0.4.2 - Changed raw values and redone access levels
// 0.1.0 - Initial version
// =====================================================================================================================

import Foundation
import BRUtils


/// The identifier that describes the type stored in an item.

public enum ItemType: UInt8 {
    
    
    /// A null/nil item.
    
    case null           = 0x01
    
    
    /// A boolean
    
    case bool           = 0x02
    
    
    /// An integer of 8 bits
    
    case int8           = 0x03

    
    /// An integer of 16 bits

    case int16          = 0x04
    
    
    /// An integer of 32 bits

    case int32          = 0x05

    
    /// An integer of 64 bits

    case int64          = 0x06

    
    // An unsigned integer of 8 bits (a byte)
    
    case uint8          = 0x07
    
    
    // An unsigned integer of 16 bits

    case uint16         = 0x08
    
    
    // An unsigned integer of 32 bits

    case uint32         = 0x09

    
    /// An unsigned integer of 64 bits

    case uint64         = 0x0A
    
    
    // Floating point value represented in 32 bits
    
    case float32        = 0x0B

    
    /// Floating point value represented in 64 bits (Called a Double in Swift)

    case float64        = 0x0C
    

    /// A string coded in UTF8 of N bytes with space available for M bytes where M >= N.
    
    case string         = 0x0D
    
    
    /// A string preceded by a CRC-16 value for faster searching.
    
    case crcString      = 0x0E

    
    /// A sequence of bytes
    
    case binary         = 0x0F

    
    /// A sequence of bytes
    
    case crcBinary      = 0x10

    
    /// A sequence of items of the same type and length
    
    case array          = 0x11
    

    /// Sequence of named items. These items may vary in type, options and length but are identifyable by their (unique) name.
    
    case dictionary     = 0x12

    
    /// A sequence of other items that may or may not have a name and can be of different types.
    
    case sequence       = 0x13

    
    /// A table is an array with multiple columns.
    
    case table          = 0x14
    
    
    /// A UUID
    
    case uuid           = 0x15
    
    
    /// A Color
    
    case color          = 0x16
    
    
    /// A Font
    
    case font           = 0x17
    
    
    /// True if the value is stored in the small value field of an item.
    
    internal var usesSmallValue: Bool {
        switch self {
        case .null, .bool, .int8, .int16, .int32, .uint8, .uint16, .uint32, .float32, .color: return true
        case .int64, .uint64, .float64, .string, .crcString, .binary, .crcBinary, .array, .dictionary, .sequence, .table, .uuid, .font : return false
        }
    }
    
    
    /// True if the byte count of the value can change.
    
    internal var hasFlexibleLength: Bool {
        switch self {
        case .null, .bool, .int8, .int16, .int32, .uint8, .uint16, .uint32, .float32, .int64, .uint64, .float64, .uuid, .color: return false
        case .string, .crcString, .binary, .crcBinary, .array, .dictionary, .sequence, .table, .font: return true
        }
    }
    
    
    /// True if an item of this type can contain other items.
    
    internal var isContainer: Bool {
        switch self {
        case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32, .int64, .uint64, .float64, .string, .crcString, .binary, .crcBinary, .uuid, .color, .font: return false
        case .array, .dictionary, .sequence, .table: return true
        }
    }
    
    
    /// Create a new ItemType from memory content.
    
    internal init?(atPtr: UnsafeMutableRawPointer) {
        self.init(rawValue: atPtr.assumingMemoryBound(to: UInt8.self).pointee)
    }
}


// Extend the enum with some brbon coder operations

extension ItemType {
    
    internal func copyBytes(to ptr: UnsafeMutableRawPointer) {
        self.rawValue.copyBytes(to: ptr, machineEndianness)
    }
    
    internal static func readValue(atPtr: UnsafeMutableRawPointer) -> ItemType? {
        return ItemType(atPtr: atPtr)
    }
}
