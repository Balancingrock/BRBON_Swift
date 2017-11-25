// =====================================================================================================================
//
//  File:       Protocols.swift
//  Project:    BRBON
//
//  Version:    0.1.0
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
// 0.1.0  - Initial version
// =====================================================================================================================

import Foundation
import BRUtils


/// This protocol is used to encode/decode types from a byte stream.

public protocol EndianBytes {
    
    
    /// Encodes a type to a stream of bytes in either big or little endian coding.
    ///
    /// - Parameter endianness: Specifies the endianness of the bytes.
    ///
    /// - Returns: A Data structure containg the bytes that encode the basic type.
    
    func endianBytes(_ endianness: Endianness) -> Data
    
    
    /// Decode a type from the given bytes.
    ///
    /// - Parameters:
    ///   - bytePtr: A pointer to the bytes that need to be decoded.
    ///   - count: The maximum number of bytes usable for decoding.
    ///   - endianess: Specifies how the bytes are ordered.
    
    init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness)
}


/// Adds the EndianBytes protocol to Bool

extension Bool: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        if self {
            return Data(bytes: [1])
        } else {
            return Data(bytes: [0])
        }
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count > 0 else { return nil }
        if bytePtr.assumingMemoryBound(to: UInt8.self).pointee == 0 {
            self = false
            bytePtr = bytePtr.advanced(by: 1)
            count -= 1
        } else if bytePtr.assumingMemoryBound(to: UInt8.self).pointee == 1 {
            self = true
            bytePtr = bytePtr.advanced(by: 1)
            count -= 1
        } else {
            return nil
        }
    }
}


/// Adds the EndianBytes protocol to UInt8

extension UInt8: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        return Data(bytes: [self])
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count > 0 else { return nil }
        self = bytePtr.advanceUInt8()
        count -= 1
    }
}


/// Adds the EndianBytes protocol to Int8

extension Int8: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        return Data(bytes: &val, count: 1)
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count > 0 else { return nil }
        self = bytePtr.advanceInt8()
        count -= 1
    }
}


/// Adds the EndianBytes protocol to UInt16

extension UInt16: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 2)
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count >= 2 else { return nil }
        self = bytePtr.advanceUInt16(endianness: endianness)
        count -= 2
    }
}


/// Adds the EndianBytes protocol to Int16

extension Int16: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 2)
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count >= 2 else { return nil }
        self = bytePtr.advanceInt16(endianness: endianness)
        count -= 2
    }
}


/// Adds the EndianBytes protocol to UInt32

extension UInt32: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 4)
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count >= 4 else { return nil }
        self = bytePtr.advanceUInt32(endianness: endianness)
        count -= 4
    }
}


/// Adds the EndianBytes protocol to Int32

extension Int32: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 4)
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count >= 4 else { return nil }
        self = bytePtr.advanceInt32(endianness: endianness)
        count -= 4
    }
}


/// Adds the EndianBytes protocol to UInt64

extension UInt64: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 8)
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count >= 8 else { return nil }
        self = bytePtr.advanceUInt64(endianness: endianness)
        count -= 8
    }
}


/// Adds the EndianBytes protocol to Int64

extension Int64: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 8)
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count >= 8 else { return nil }
        self = bytePtr.advanceInt64(endianness: endianness)
        count -= 8
    }
}


/// Adds the EndianBytes protocol to Float32

extension Float32: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self.bitPattern
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 4)
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count >= 4 else { return nil }
        let val = bytePtr.advanceUInt32(endianness: endianness)
        self = Float32.init(bitPattern: val)
        count -= 4
    }
}


/// Adds the EndianBytes protocol to Float64

extension Float64: EndianBytes {
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self.bitPattern
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 8)
    }
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count >= 8 else { return nil }
        let val = bytePtr.advanceUInt64(endianness: endianness)
        self = Float64.init(bitPattern: val)
        count -= 8
    }
}
