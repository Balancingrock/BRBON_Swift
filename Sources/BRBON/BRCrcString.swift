// =====================================================================================================================
//
//  File:       BRCrcString.swift
//  Project:    BRBON
//
//  Version:    0.7.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
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
// 0.7.0 - Reorganization & Simplification.
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


fileprivate let crcStringCrcOffset = 0
fileprivate let crcStringUtf8ByteCountOffset = crcStringCrcOffset + 4
internal let crcStringUtf8CodeOffset = crcStringUtf8ByteCountOffset + 4


// Pointer manipulations

fileprivate extension UnsafeMutableRawPointer {
    
    
    /// Returns a pointer to the CRC value of a crcString item assuming self points at the first byte of the value.

    fileprivate var crcStringCrcPtr: UnsafeMutableRawPointer { return self.advanced(by: crcStringCrcOffset) }


    /// Returns a pointer to the UTF8 Byte Count value of a crcString item assuming self points at the first byte of the value.

    fileprivate var crcStringUtf8ByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: crcStringUtf8ByteCountOffset) }


    /// Returns a pointer to the UTF8 Code area of a crcString item assuming self points at the first byte of the value.

    fileprivate var crcStringUtf8CodePtr: UnsafeMutableRawPointer { return self.advanced(by: crcStringUtf8CodeOffset) }
    
    
    /// Returns the CRC value of a crcString item assuming self points at the first byte of the value.
    
    fileprivate func crcStringCrc(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return crcStringCrcPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return crcStringCrcPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the CRC value of a crcString item assuming self points at the first byte of the value.
    
    fileprivate func setCrcStringCrc(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            crcStringCrcPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            crcStringCrcPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Returns the UTF8 Byte Count of a crcString item assuming self points at the first byte of the value.
    
    fileprivate func crcStringUtf8ByteCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return crcStringUtf8ByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return crcStringUtf8ByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the UTF8 Byte Count of a crcString item assuming self points at the first byte of the value.
    
    fileprivate func setCrcStringUtf8ByteCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            crcStringUtf8ByteCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            crcStringUtf8ByteCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Returns the UTF8 data of a crcString item assuming self points to the first byte of the value.
    ///
    /// Note that this will also read the crcStringUtf8ByteCount.
    
    fileprivate func crcStringUtf8Code(_ endianness: Endianness) -> Data {
        return Data(bytes: crcStringUtf8CodePtr, count: Int(self.crcStringUtf8ByteCount(endianness)))
    }
    
    
    /// Sets the UTF8 data of a crcString item assuming self points to the first byte of the value.
    ///
    /// Note that this will also write the crcStringUtf8ByteCount.
    
    fileprivate func setCrcStringUtf8Code(to value: Data, _ endianness: Endianness) {
        value.copyBytes(to: crcStringUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: value.count)
        setCrcStringUtf8ByteCount(to: UInt32(value.count), endianness)
    }
}


// Utility additions for the crcString

internal extension Portal {
    
//    internal var _crcStringUtf8Code: Data {
        
//    }
    
    internal var _crcStringValueFieldUsedByteCount: Int {
        return crcStringUtf8CodeOffset + Int(itemPtr.crcStringUtf8ByteCount(endianness))
    }
}


// Public access for crcString

public extension Portal {
    
    
    /// Returns true if the value accessable through this portal is a CrcString.
    
    public var isCrcString: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.crcString }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.crcString.rawValue }
        return itemPtr.itemType == ItemType.crcString.rawValue
    }
    
    
    /// Evaluates the validity of the CRC
    ///
    /// - Returns: True if the stored CRC value and the calculated CRC value of the string byte code are the same. False if not. Nil if the portal is invalid or does not refer to a CrcString.
    
    public var crcIsValid: Bool? {
        guard isCrcString else { return nil }
        return _valuePtr.crcStringUtf8Code(endianness).crc32() == itemPtr.crcStringCrc(endianness)
    }
    
    
    /// Access the value through the portal as a BRCrcString.
    ///
    /// - Note: Assigning a null has no effect.
    ///
    /// - Note: Returns nil if the CRC value was wrong.
    
    public var crcString: BRCrcString? {
        get {
            guard isCrcString else { return nil }
            
            let utf8Code = _valuePtr.crcStringUtf8Code(endianness)
            let crc = _valuePtr.crcStringCrc(endianness)
            
            guard utf8Code.crc32() == crc else { return nil }
            
            return BRCrcString(utf8Code: utf8Code, crc: crc)
        }
        set {
            guard isCrcString else { return }
            guard let newValue = newValue else { return }
            
            let result = ensureValueFieldByteCount(of: crcStringUtf8CodeOffset + newValue.utf8Code.count)
            guard result == .success else { return }

            _valuePtr.setCrcStringUtf8Code(to: newValue.utf8Code, endianness)
        }
    }

    // Accessing as a String is covered in BRString.swift    
}


/// Defines the BRCrcString.

public struct BRCrcString {
    
    public let utf8Code: Data
    public let crc: UInt32
    
    public var crcIsValid: Bool { return utf8Code.crc32() == crc }
    
    public var string: String? { return crcIsValid ? String(data: utf8Code, encoding: .utf8) : nil }
    
    public init?(_ value: String?) {
        guard let data = value?.data(using: .utf8) else { return nil }
        utf8Code = data
        crc = utf8Code.crc32()
    }

    public init(_ value: BRString) {
        utf8Code = value.utf8Code
        crc = utf8Code.crc32()
    }
    
    public init(utf8Code: Data, crc: UInt32) {
        self.utf8Code = utf8Code
        self.crc = crc
    }
}


/// Add the equatable protocol

extension BRCrcString: Equatable {
    
    public static func == (lhs: BRCrcString, rhs: BRCrcString) -> Bool {
        if lhs.crc != rhs.crc { return false }
        return lhs.utf8Code == rhs.utf8Code
    }
}


/// Add Coder protocol

extension BRCrcString: Coder {
    
    public var itemType: ItemType { return ItemType.crcString }

    public var valueByteCount: Int { return utf8Code.count + crcStringUtf8CodeOffset }

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc.copyBytes(to: ptr, endianness)
        UInt32(utf8Code.count).copyBytes(to: ptr.advanced(by: crcStringUtf8ByteCountOffset), endianness)
        utf8Code.copyBytes(to: ptr.advanced(by: crcStringUtf8CodeOffset).assumingMemoryBound(to: UInt8.self), count: utf8Code.count)
    }
}


/// Add decoder

extension BRCrcString {
    
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc = UInt32(fromPtr: fromPtr.advanced(by: crcStringCrcOffset), endianness)
        let c = Int(UInt32(fromPtr: fromPtr.advanced(by: crcStringUtf8ByteCountOffset), endianness))
        utf8Code = Data(bytes: fromPtr.advanced(by: crcStringUtf8CodeOffset), count: c)
    }
}


