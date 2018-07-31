// =====================================================================================================================
//
//  File:       Bool.swift
//  Project:    BRBON
//
//  Version:    0.7.9
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
// 0.7.9 - Changed handling of writing a nil (will now set the bool value to false)
// 0.7.0 - Code restructuring & simplification
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


// Extensions that allow a portal to test and access a Bool

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is a bool.
    
    public var isBool: Bool {
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
    
    public var bool: Bool? {
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
    
    public var itemType: ItemType { return ItemType.bool }
    
    public var valueByteCount: Int { return 1 }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if self {
            ptr.storeBytes(of: 1, as: UInt8.self)
        } else {
            ptr.storeBytes(of: 0, as: UInt8.self)
        }
    }
}
