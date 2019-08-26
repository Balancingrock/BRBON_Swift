// =====================================================================================================================
//
//  File:       Float64.swift
//  Project:    BRBON
//
//  Version:    1.0.1
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2019 Marinus van der Lugt, All rights reserved.
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
//  Like you, I need to make a living:
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
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


fileprivate let float64ValueByteCount = 8


// Extensions that allow a portal to test and access a Float64

extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is a Float64.
    
    public var isFloat64: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.float64 }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.float64.rawValue }
        return itemPtr.itemType == ItemType.float64.rawValue
    }
    

    /// Access the value through the portal as a Float64
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to a float64, writing will be ineffective and reading will always return nil.
    ///
    /// __On read:__ Returns the value at the associated memory location interpreted as a float64.
    ///
    /// __On write:__ Stores the float64 value at the associated memory location. If a nil is written the data at the location will be set to 0.0.

    public var float64: Float64? {
        get {
            guard isFloat64 else { return nil }
            if endianness == machineEndianness {
                return Float64(bitPattern: _valuePtr.assumingMemoryBound(to: UInt64.self).pointee)
            } else {
                return Float64(bitPattern: _valuePtr.assumingMemoryBound(to: UInt64.self).pointee.byteSwapped)
            }
        }
        set {
            guard isFloat64 else { return }
            (newValue ?? 0.0).copyBytes(to: _valuePtr, endianness)
        }
    }
}


/// Adds the Coder protocol to a Float64

extension Float64: Coder {

    
    /// Implementation of the `Coder` protocol

    public var itemType: ItemType { return ItemType.float64 }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return float64ValueByteCount }

    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            ptr.storeBytes(of: self.bitPattern, as: UInt64.self)
        } else {
            ptr.storeBytes(of: self.bitPattern.byteSwapped, as: UInt64.self)
        }
    }
}

