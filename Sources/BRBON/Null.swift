// =====================================================================================================================
//
//  File:       Null.swift
//  Project:    BRBON
//
//  Version:    0.8.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
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
//  I strongly believe that voluntarism is the way for societies to function optimally. So you can pay whatever you
//  think our code is worth to you.
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
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// History
//
// 0.8.0 - Migrated to Swift 5
// 0.7.9 - Minor comment updates.
// 0.7.0 - Code restructuring & simplification
// 0.4.2 - Added header & general review of access levels
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

