// =====================================================================================================================
//
//  File:       Int8.swift
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
// 0.7.9 - Changed the way a nil is written (now written as 0)
// 0.7.0 - Code restructuring & simplification
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


// Extensions that allow a portal to test and access an Int8

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is an Int8.

    public var isInt8: Bool {
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

    public var int8: Int8? {
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
    
    public var itemType: ItemType { return ItemType.int8 }

    public var valueByteCount: Int { return 1 }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        ptr.storeBytes(of: self, as: Int8.self)
    }
}



