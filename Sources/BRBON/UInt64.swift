// =====================================================================================================================
//
//  File:       UInt64.swift
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

import Foundation
import BRUtils


internal let uint64ValueByteCount = 8


// Extensions that allow a portal to test and access an UInt64

public extension Portal {
        
    
    /// Returns true if the portal is valid and the value accessable through this portal is an UInt64.

    var isUInt64: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint64 }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.uint64.rawValue }
        return itemPtr.itemType == ItemType.uint64.rawValue
    }
    
    
    /// Access the value through the portal as an UInt64.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to an uint64, writing will be ineffective and reading will always return nil.
    ///
    /// __On read:__ Returns the value at the associated memory location interpreted as an uint64.
    ///
    /// __On write:__ Stores the uint64 value at the associated memory location. If a nil is written the data at the location will be set to 0.

    var uint64: UInt64? {
        get {
            guard isValid else { return nil }
            guard isUInt64 else { return nil }
            if endianness == machineEndianness {
                return _valuePtr.assumingMemoryBound(to: UInt64.self).pointee
            } else {
                return _valuePtr.assumingMemoryBound(to: UInt64.self).pointee.byteSwapped
            }
        }
        set {
            guard isValid else { return }
            guard isUInt64 else { return }
            (newValue ?? 0).copyBytes(to: _valuePtr, endianness)
        }
    }
}


/// Adds the Coder protocol to an UInt64

extension UInt64: Coder {

    
    /// Implementation of the `Coder` protocol

    public var itemType: ItemType { return ItemType.uint64 }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return uint64ValueByteCount }

    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            ptr.storeBytes(of: self, as: UInt64.self)
        } else {
            ptr.storeBytes(of: self.byteSwapped, as: UInt64.self)
        }
    }
}



