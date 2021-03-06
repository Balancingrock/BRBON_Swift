// =====================================================================================================================
//
//  File:       String.swift
//  Project:    BRBON
//
//  Version:    1.3.2
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2020 Marinus van der Lugt, All rights reserved.
//
//  License:    MIT, see LICENSE file
//
//  And because I need to make a living:
//
//   - You can send payment (you choose the amount) via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
// PLEASE let me know about bugs, improvements and feature requests. (rien@balancingrock.nl)
// =====================================================================================================================
//
// History
//
// 1.3.2 - Updated LICENSE
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================
//
// This is a wrapper for a swift String.
//
// When storing strings in a BRBON structure repeated conversions to a Data struct are made. Using a BRString wrapper
// limits the number of conversions to just one, thereby improving performance.
//
// =====================================================================================================================

import Foundation
import BRUtils


// Offset definitions

internal let stringUtf8ByteCountOffset = 0
internal let stringUtf8CodeOffset = stringUtf8ByteCountOffset + 4


// Pointer manipulations

internal extension UnsafeMutableRawPointer {
    
    
    /// The pointer to the UTF8 byte count assuming self points to the first byte of the value.
    
    fileprivate var stringUtf8ByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: stringUtf8ByteCountOffset) }

    
    /// The pointer to the UTF8 code area assuming self points to the first byte of the value.

    fileprivate var stringUtf8CodePtr: UnsafeMutableRawPointer { return self.advanced(by: stringUtf8CodeOffset) }
    
    
    /// Returns the UTF8 byte count assuming self points to the first byte of the value.

    fileprivate func stringUtf8ByteCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return stringUtf8ByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return stringUtf8ByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the UTF8 byte count assuming self points to the first byte of the value.

    func setStringUtf8ByteCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            stringUtf8ByteCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            stringUtf8ByteCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Returns the UTF8 code assuming self points to the first byte of the value.
    ///
    /// Note: Also reads 'stringUtf8ByteCount'

    func stringUtf8Code(_ endianness: Endianness) -> Data {
        return Data(bytes: stringUtf8CodePtr, count: Int(stringUtf8ByteCount(endianness)))
    }
    
    
    /// Set the UTF8 code assuming self points to the first byte of the value.
    ///
    /// Note: Also writes 'stringUtf8ByteCount'
    
    func setStringUtf8Code(to value: Data, _ endianness: Endianness) {
        setStringUtf8ByteCount(to: UInt32(value.count), endianness)
        value.copyBytes(to: stringUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: value.count)
    }
    
    
    func string(_ endianness: Endianness) -> String? {
        return String(data: self.stringUtf8Code(endianness), encoding: .utf8)
    }
}


// Item access

internal extension Portal {
    
    
    /// - Returns: The UTF8 code of the value this portal refers to.
    
    var _stringUtf8Code: Data {
        get {
            return _valuePtr.stringUtf8Code(endianness)
        }
        set {
            //let result = ensureValueFieldByteCount(of: stringUtf8CodeOffset + newValue.count)
            let result = ensureStorageAtValuePtr(of: stringUtf8CodeOffset + newValue.count)
            guard result == .success else { return }
            
            _valuePtr.setStringUtf8Code(to: newValue, endianness)
        }
    }
    
    
    /// - Returns: The number of bytes actually used to store the referred value.
    
    var _stringValueFieldUsedByteCount: Int { return stringUtf8CodeOffset + Int(_valuePtr.stringUtf8ByteCount(endianness)) }
}


// Public item access

extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is a string.

    public var isString: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.string }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.string.rawValue }
        return itemPtr.itemType == ItemType.string.rawValue
    }
    
    
    /// Convenience accessor for the String type. Will use either BRString or BRCrcString depending on the type of portal.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to a BRString or a BRCrcString, writing will be ineffective and reading will always return nil.
    ///
    /// __On Read:__ The data at the associated memory location will be interpreted as a BRString or BRCrcString and returned. Note that if the specification is invalid the result is unpredictable. If the portal refers to a BRCrcString and the CRC is wrong, a nil will be returned.
    ///
    /// __On Write:__ Writes the specification of a BRString or BRCrcString to the associated memory area. Writing a nil will result in erasure of existing string data (by setting the size of the string to zero).
    
    public var string: String? {
        get {
            if isString { return brString?.string }
            if isCrcString { return crcString?.string }
            return nil
        }
        set {
            if isString { brString = BRString(newValue) }
            if isCrcString { crcString = BRCrcString(newValue) }
        }
    }
}


/// Adds the Coder protocol

extension String: Coder {
    
    
    /// Implementation of the `Coder` protocol

    public var itemType: ItemType { return ItemType.string }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return stringUtf8CodeOffset + (self.data(using: .utf8)?.count ?? 0) }

    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let code = self.data(using: .utf8) ?? Data()
        ptr.setStringUtf8Code(to: code, endianness)
    }
}
