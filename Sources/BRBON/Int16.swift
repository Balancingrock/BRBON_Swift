// =====================================================================================================================
//
//  File:       Int16.swift
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


// Extensions that allow a portal to test and access an Int16

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is an Int16.

    var isInt16: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int16 }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.int16.rawValue }
        return itemPtr.itemType == ItemType.int16.rawValue
    }

    
    /// Access the value through the portal as an Int16.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to an int16, writing will be ineffective and reading will always return nil.
    ///
    /// __On read:__ Returns the value at the associated memory location interpreted as an int16.
    ///
    /// __On write:__ Stores the int16 value at the associated memory location. If a nil is written the data at the location will be set to 0.

    var int16: Int16? {
        get {
            guard isInt16 else { return nil }
            if endianness == machineEndianness {
                return _valuePtr.assumingMemoryBound(to: Int16.self).pointee
            } else {
                return _valuePtr.assumingMemoryBound(to: Int16.self).pointee.byteSwapped
            }
        }
        set {
            guard isInt16 else { return }
            (newValue ?? 0).copyBytes(to: _valuePtr, endianness)
        }
    }
}


/// Adds the Coder protocol to an Int16

extension Int16: Coder {

    
    /// Implementation of the `Coder` protocol

    public var itemType: ItemType { return ItemType.int16 }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return 2 }

    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            ptr.storeBytes(of: self, as: Int16.self)
        } else {
            ptr.storeBytes(of: self.byteSwapped, as: Int16.self)
        }
    }
}


