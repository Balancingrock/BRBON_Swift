// =====================================================================================================================
//
//  File:       UUID.swift
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


internal let uuidValueByteCount = 16


internal extension UnsafeMutableRawPointer {

    
    /// Returns the UUID pointed at by self.
    
    var uuid: UUID {
        return UUID(uuid: self.bindMemory(to: uuid_t.self, capacity: 1).pointee)
    }
}


// Extensions that allow a portal to test and access an UUID

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is an UUID.

    var isUuid: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uuid }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.uuid.rawValue }
        return itemPtr.itemType == ItemType.uuid.rawValue
    }

    
    /// Access the value through the portal as an UUID.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to an UUID, writing will be ineffective and reading will always return nil.
    ///
    /// __On read:__ Returns the value at the associated memory location interpreted as an UUID.
    ///
    /// __On write:__ Stores the UUID value at the associated memory location. If a nil is written the data at the location will be set to all 0.

    var uuid: UUID? {
        get {
            guard isValid else { return nil }
            guard isUuid else { return nil }
            return _valuePtr.uuid
        }
        set {
            guard isValid else { return }
            guard isUuid else { return }
            (newValue ?? UUID(uuid: uuid_t(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))).copyBytes(to: _valuePtr, endianness)
        }
    }
}


// Adds the Coder protocol to an UUID

extension UUID: Coder {
    
    
    /// Implementation of the `Coder` protocol

    public var itemType: ItemType { return ItemType.uuid }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return uuidValueByteCount }
    
    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        ptr.storeBytes(of: self.uuid, as: uuid_t.self)
    }
}



