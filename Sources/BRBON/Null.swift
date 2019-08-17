// =====================================================================================================================
//
//  File:       Null.swift
//  Project:    BRBON
//
//  Version:    1.0.0
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
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


// Extensions that allow a portal to test and access a Null

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is a null.

    var isNull: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.null }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.null.rawValue }
        return itemPtr.itemType == ItemType.null.rawValue
    }

    
    /// Access the value through the portal as a Null. This operation is for orthogonality only.
    ///
    /// __On Read:__ In effect the same operation as the isNull member.
    ///
    /// __On Write:__ Assigning has no effect.

    var null: Bool? {
        get { return isNull }
        set {}
    }
}


/// Defines the BRBON Null and adds the Coder protocol

public struct Null: Coder {
    
    public var itemType: ItemType { return ItemType.null }
    
    public var valueByteCount: Int { return 0 }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) { }
}

