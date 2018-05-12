// =====================================================================================================================
//
//  File:       BRString.swift
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


// Offset definitions

fileprivate let stringByteCountOffset = 0
internal let stringUtf8CodeOffset = stringByteCountOffset + 4


// Internal portal helpers for BRString items

internal extension Portal {
    
    internal var _stringByteCountPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: stringByteCountOffset) }
    internal var _stringUtf8CodePtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: stringUtf8CodeOffset) }
    
    
    internal var _stringByteCount: Int {
        get { return Int(UInt32(fromPtr: _stringByteCountPtr, endianness)) }
        set { UInt32(newValue).copyBytes(to: _stringByteCountPtr, endianness) }
    }
    
    internal var _stringUtf8Code: Data {
        get {
            return Data(bytes: _stringUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: _stringByteCount)
        }
        set {
            let result = ensureValueFieldByteCount(of: stringUtf8CodeOffset + newValue.count)
            guard result == .success else { return }
            _stringByteCount = newValue.count
            newValue.copyBytes(to: _stringUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: newValue.count)
        }
    }
    
    internal var _stringValueFieldUsedByteCount: Int { return stringUtf8CodeOffset + _stringByteCount }
}


// Public portal access

extension Portal {
    
    
    /// - Returns: True if the value accessable through this portal is a string.
    
    public var isString: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.string }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue
    }
    
    
    /// Access the value through the portal as a BRString
    ///
    /// - Note: Assigning a nil has no effect. If an error occurs when assigning, the setter will fail silently.

    public var brString: BRString? {
        get {
            guard isString else { return nil }
            return BRString.init(fromPtr: valueFieldPtr, endianness)
        }
        set {
            guard isString else { return }
            guard let newValue = newValue else { return }
            _stringUtf8Code = newValue.utf8Code
        }
    }
    
    
    /// Convenience accessor using String type. Note that a nil is returned if the portal is invalid, the portal does not refer to a String or a CrcString, or if the UTF8 data cannot be converted into a string, or if the CrcString CRC is wrong.
    ///
    /// - Note: Assigning a nil has no effect.
    
    public var string: String? {
        get {
            if isString { return brString?.string }
            if isCrcString { return brCrcString?.string }
            return nil
        }
        set {
            if isString { brString = BRString(newValue) }
            if isCrcString { brCrcString = BRCrcString(newValue) }
        }
    }
    

    /// Add a String to an Array of either String or CrcString.
    ///
    /// - Returns: .success or one of .portalInvalid, .operationNotSupported, .typeConflict
    
    @discardableResult
    public func append(_ value: BRString) -> Result {
        if _arrayElementType == .string {
            return appendClosure(for: value.itemType, with: value.valueByteCount) {
                value.copyBytes(to: _arrayElementPtr(for: _arrayElementCount), endianness)
            }
        } else if _arrayElementType == .crcString {
            let crcString = BRCrcString(value)
            return appendClosure(for: crcString.itemType, with: crcString.valueByteCount) {
                crcString.copyBytes(to: _arrayElementPtr(for: _arrayElementCount), endianness)
            }
        } else {
            return .typeConflict
        }
    }
}


/// The BRString structure

public struct BRString {
    
    public let utf8Code: Data
    
    public var string: String? { return String(data: utf8Code, encoding: .utf8) }
    
    public init?(_ str: String?) {
        guard let code = str?.data(using: .utf8) else { return nil }
        utf8Code = code
    }
}


/// Add the equatable protocol

extension BRString: Equatable {
    
    public static func == (lhs: BRString, rhs: BRString) -> Bool {
        return lhs.utf8Code == rhs.utf8Code
    }
}


/// Adds the Coder protocol

extension BRString: Coder {
    
    public var itemType: ItemType { return ItemType.string }

    public var valueByteCount: Int { return stringUtf8CodeOffset + utf8Code.count }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        UInt32(utf8Code.count).copyBytes(to: ptr.advanced(by: stringByteCountOffset), endianness)
        utf8Code.copyBytes(to: ptr.advanced(by: stringUtf8CodeOffset).assumingMemoryBound(to: UInt8.self), count: utf8Code.count)
    }
}


/// Adds decoder

extension BRString {
    internal init?(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let c = Int(UInt32(fromPtr: fromPtr.advanced(by: stringByteCountOffset), endianness))
        utf8Code = Data(bytes: fromPtr.advanced(by: stringUtf8CodeOffset), count: c)
    }
}

