// =====================================================================================================================
//
//  File:       Null.swift
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
// 0.7.0 - Code reorganization
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


// Extensions that allow a portal to test and access a Null

public extension Portal {
    
    
    /// Assess if the portal is valid and refers to a Null.
    ///
    /// - Returns: True if the value accessable through this portal is a Null. False if the portal is invalid or the value is not a Null.

    public var isNull: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.null }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue
    }

    
    /// Access the value through the portal as a Null. This operation is for orthogonality only, it is in effect the same operation as the isNull member.
    ///
    /// - Note: Assigning has no effect.
    ///
    /// - Returns: True if the value accessable through this portal is a Null. False if the portal is invalid or the value is not a Null.

    public var null: Bool? {
        get { return isNull }
        set {}
    }
    
    
    // Note: A Null cannot be appended to an Array.
}


/// Defines the BRBON Null class and adds the Coder protocol

internal final class Null: Coder {
    
    var itemType: ItemType { return ItemType.null }
    
    var valueByteCount: Int { return 0 }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) { }
}


/// Build an item with a null in it.
///
/// - Parameters:
///   - withName: The namefield for the item. Optional.
///   - atPtr: The pointer at which to build the item structure.
///   - endianness: The endianness to be used while creating the item.
///
/// - Returns: An ephemeral portal. Do not retain this portal.

internal func buildNullItem(withName name: NameField?, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Portal {
    return buildItem(ofType: .null, withName: name, atPtr: ptr, endianness)
}
