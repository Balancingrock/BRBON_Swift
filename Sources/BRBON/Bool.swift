// =====================================================================================================================
//
//  File:       Bool.swift
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
// 1.0.1 - Documentation updates
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


// Extensions that allow a portal to test and access a Bool

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is a bool.
    
    var isBool: Bool {
        guard isValid else { return false }
        if let column = column { return itemPtr.itemValueFieldPtr.tableColumnType(for: column) == ItemType.bool.rawValue }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.bool.rawValue }
        return itemPtr.itemType == ItemType.bool.rawValue
    }
    
    
    /// The value of the bool accessible through this portal.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to a bool, writing will be ineffective and reading will always return nil.
    ///
    /// __On read:__ When the value at the associated memory location is zero, false is returned. True if the value is non-nil.
    ///
    /// __On write:__ If the value is false or nil, a zero will be written to the associated memory location. For true the value 1 is written.
    
    var bool: Bool? {
        get {
            guard isBool else { return nil }
            return Bool(!(0 == _valuePtr.assumingMemoryBound(to: UInt8.self).pointee))
        }
        set {
            guard isBool else { return }
            (newValue ?? false).copyBytes(to: _valuePtr, endianness)
        }
    }
}


/// Adds the Coder protocol to a Bool

extension Bool: Coder {
    
    
    /// Implementation of the `Coder` protocol

    public var itemType: ItemType { return ItemType.bool }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return 1 }

    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if self {
            ptr.storeBytes(of: 1, as: UInt8.self)
        } else {
            ptr.storeBytes(of: 0, as: UInt8.self)
        }
    }
}
