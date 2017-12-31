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
    
    
    /// Encodes a type to a stream of bytes in either big or little endian coding and returns an unowned buffer with these bytes in it.
    ///
    /// - Parameters:
    ///   - endianness: Specifies the endianness of the bytes.
    ///   - toPointer: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    
    func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer)

    
    /// - Returns: The number of bytes needed to encode self into an endianBytes stream
    
    func endianCount() -> UInt32
    
    
    /// Decode a type from the given bytes.
    ///
    /// - Parameters:
    ///   - bytePtr: A pointer to the bytes that need to be decoded.
    ///   - endianess: Specifies how the bytes are ordered.
    ///   - count: The number of bytes to be used for decoding, only used for tpyes with a variable length. Disregarded for fixed-length types.
    
    init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32)
}



/// Adds the EndianBytes protocol to Bool

extension Bool: EndianBytes {
    
    public func endianCount() -> UInt32 { return 1 }
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        if self {
            return Data(bytes: [1])
        } else {
            return Data(bytes: [0])
        }
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if self {
            toPointer.storeBytes(of: 1, as: UInt8.self)
        } else {
            toPointer.storeBytes(of: 1, as: UInt8.self)
        }
        toPointer = toPointer.advanced(by: 1)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        if bytePtr.assumingMemoryBound(to: UInt8.self).pointee == 0 {
            self = false
        } else if bytePtr.assumingMemoryBound(to: UInt8.self).pointee == 1 {
            self = true
        } else {
            self = false
        }
    }
}


/// Adds the EndianBytes protocol to UInt8

extension UInt8: EndianBytes {
    
    public func endianCount() -> UInt32 { return 1 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        return Data(bytes: [self])
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        toPointer.storeBytes(of: self, as: UInt8.self)
        toPointer = toPointer.advanced(by: 1)
    }
    
    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        self = bytePtr.assumingMemoryBound(to: UInt8.self).pointee
    }
}


/// Adds the EndianBytes protocol to Int8

extension Int8: EndianBytes {
    
    public func endianCount() -> UInt32 { return 1 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        return Data(bytes: &val, count: 1)
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        toPointer.storeBytes(of: self, as: Int8.self)
        toPointer = toPointer.advanced(by: 1)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        self = bytePtr.assumingMemoryBound(to: Int8.self).pointee
    }
}


/// Adds the EndianBytes protocol to UInt16

extension UInt16: EndianBytes {
    
    public func endianCount() -> UInt32 { return 2 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 2)
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if endianness == machineEndianness {
            toPointer.storeBytes(of: self, as: UInt16.self)
        } else {
            toPointer.storeBytes(of: self.byteSwapped, as: UInt16.self)
        }
        toPointer = toPointer.advanced(by: 2)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        let i = bytePtr.assumingMemoryBound(to: UInt16.self).pointee
        if endianness == machineEndianness {
            self = i
        } else {
            self = i.byteSwapped
        }
    }
}


/// Adds the EndianBytes protocol to Int16

extension Int16: EndianBytes {
    
    public func endianCount() -> UInt32 { return 2 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 2)
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if endianness == machineEndianness {
            toPointer.storeBytes(of: self, as: Int16.self)
        } else {
            toPointer.storeBytes(of: self.byteSwapped, as: Int16.self)
        }
        toPointer = toPointer.advanced(by: 2)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        let i = bytePtr.assumingMemoryBound(to: Int16.self).pointee
        if endianness == machineEndianness {
            self = i
        } else {
            self = i.byteSwapped
        }
    }
}


/// Adds the EndianBytes protocol to UInt32

extension UInt32: EndianBytes {
    
    public func endianCount() -> UInt32 { return 4 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 4)
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if endianness == machineEndianness {
            toPointer.storeBytes(of: self, as: UInt32.self)
        } else {
            toPointer.storeBytes(of: self.byteSwapped, as: UInt32.self)
        }
        toPointer = toPointer.advanced(by: 4)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        let i = bytePtr.assumingMemoryBound(to: UInt32.self).pointee
        if endianness == machineEndianness {
            self = i
        } else {
            self = i.byteSwapped
        }
    }
}


/// Adds the EndianBytes protocol to Int32

extension Int32: EndianBytes {
    
    public func endianCount() -> UInt32 { return 4 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 4)
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if endianness == machineEndianness {
            toPointer.storeBytes(of: self, as: Int32.self)
        } else {
            toPointer.storeBytes(of: self.byteSwapped, as: Int32.self)
        }
        toPointer = toPointer.advanced(by: 4)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        let i = bytePtr.assumingMemoryBound(to: Int32.self).pointee
        if endianness == machineEndianness {
            self = i
        } else {
            self = i.byteSwapped
        }
    }
}


/// Adds the EndianBytes protocol to UInt64

extension UInt64: EndianBytes {
    
    public func endianCount() -> UInt32 { return 8 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 8)
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if endianness == machineEndianness {
            toPointer.storeBytes(of: self, as: UInt64.self)
        } else {
            toPointer.storeBytes(of: self.byteSwapped, as: UInt64.self)
        }
        toPointer = toPointer.advanced(by: 8)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        let i = bytePtr.assumingMemoryBound(to: UInt64.self).pointee
        if endianness == machineEndianness {
            self = i
        } else {
            self = i.byteSwapped
        }
    }
}


/// Adds the EndianBytes protocol to Int64

extension Int64: EndianBytes {
    
    public func endianCount() -> UInt32 { return 8 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 8)
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if endianness == machineEndianness {
            toPointer.storeBytes(of: self, as: Int64.self)
        } else {
            toPointer.storeBytes(of: self.byteSwapped, as: Int64.self)
        }
        toPointer = toPointer.advanced(by: 8)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        let i = bytePtr.assumingMemoryBound(to: Int64.self).pointee
        if endianness == machineEndianness {
            self = i
        } else {
            self = i.byteSwapped
        }
    }
}


/// Adds the EndianBytes protocol to Float32

extension Float32: EndianBytes {
    
    public func endianCount() -> UInt32 { return 4 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self.bitPattern
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 4)
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if endianness == machineEndianness {
            toPointer.storeBytes(of: self, as: Float32.self)
        } else {
            toPointer.storeBytes(of: self.bitPattern.byteSwapped, as: UInt32.self)
        }
        toPointer = toPointer.advanced(by: 4)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        let i = bytePtr.assumingMemoryBound(to: UInt32.self).pointee
        if endianness == machineEndianness {
            self = Float32.init(bitPattern: i)
        } else {
            self = Float32.init(bitPattern: i.byteSwapped)
        }
    }
}


/// Adds the EndianBytes protocol to Float64

extension Float64: EndianBytes {
    
    public func endianCount() -> UInt32 { return 8 }

    public func endianBytes(_ endianness: Endianness) -> Data {
        var val = self.bitPattern
        if endianness != machineEndianness { val = val.byteSwapped }
        return Data(bytes: &val, count: 8)
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if endianness == machineEndianness {
            toPointer.storeBytes(of: self, as: Float64.self)
        } else {
            toPointer.storeBytes(of: self.bitPattern.byteSwapped, as: UInt64.self)
        }
        toPointer = toPointer.advanced(by: 8)
    }

    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32 = 0) {
        let i = bytePtr.assumingMemoryBound(to: UInt64.self).pointee
        if endianness == machineEndianness {
            self = Float64.init(bitPattern: i)
        } else {
            self = Float64.init(bitPattern: i.byteSwapped)
        }
    }
}


/// Adds the EndianBytes protocol to Data

extension Data: EndianBytes {
    
    public func endianCount() -> UInt32 { return UInt32(self.count) }

    public func endianBytes(_ endianness: Endianness) -> Data {
        return self
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        self.withUnsafeBytes({ toPointer.copyBytes(from: $0, count: self.count)})
        toPointer = toPointer.advanced(by: self.count)
    }
        
    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32) {
        self.init(bytes: bytePtr, count: Int(count))
    }
}


/// Adds the EndianBytes protocol to String

extension String: EndianBytes {
    
    public func endianCount() -> UInt32 { return UInt32(self.data(using: .utf8)?.count ?? 0) }
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        return self.data(using: .utf8) ?? Data()
    }
    
    public func endianBytes(_ endianness: Endianness, toPointer: inout UnsafeMutableRawPointer) {
        if let data = self.data(using: .utf8) {
            data.endianBytes(endianness, toPointer: &toPointer)
            toPointer = toPointer.advanced(by: data.count)
        }
    }
    
    public init(_ bytePtr: UnsafeRawPointer, endianness: Endianness, count: UInt32) {
        let data = Data(bytePtr, endianness: endianness, count: count)
        self = String(bytes: data, encoding: .utf8) ?? ""
    }
}
