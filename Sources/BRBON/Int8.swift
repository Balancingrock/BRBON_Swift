// =====================================================================================================================
//
//  File:       Int8.swift
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


// Extensions that allow a portal to test and access an Int8

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is an Int8.

    var isInt8: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int8 }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.int8.rawValue }
        return itemPtr.itemType == ItemType.int8.rawValue
    }
    

    /// Access the value through the portal as an Int8.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to an int8, writing will be ineffective and reading will always return nil.
    ///
    /// __On read:__ Returns the value at the associated memory location interpreted as an int8.
    ///
    /// __On write:__ Stores the int8 value at the associated memory location. If a nil is written the data at the location will be set to 0.

    var int8: Int8? {
        get {
            guard isInt8 else { return nil }
            return _valuePtr.assumingMemoryBound(to: Int8.self).pointee
        }
        set {
            guard isInt8 else { return }
            (newValue ?? 0).copyBytes(to: _valuePtr, endianness)
        }
    }
}


/// Adds the Coder protocol to an Int8

extension Int8: Coder {
    
    
    /// Implementation of the `Coder` protocol

    public var itemType: ItemType { return ItemType.int8 }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return 1 }

    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        ptr.storeBytes(of: self, as: Int8.self)
    }
}



