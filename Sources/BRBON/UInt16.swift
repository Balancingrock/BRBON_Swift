// =====================================================================================================================
//
//  File:       UInt16.swift
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
// 0.8.0 - Migration to Swift 5
// 0.7.9 - Changed the way a nil is written (now written as 0)
// 0.7.0 - Code restructuring & simplification
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


// Extensions that allow a portal to test and access an UInt16

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is an UInt16.

    var isUInt16: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint16 }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.uint16.rawValue }
        return itemPtr.itemType == ItemType.uint16.rawValue
    }

    
    /// Access the value through the portal as an UInt16.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to an uint16, writing will be ineffective and reading will always return nil.
    ///
    /// __On read:__ Returns the value at the associated memory location interpreted as an uint16.
    ///
    /// __On write:__ Stores the uint16 value at the associated memory location. If a nil is written the data at the location will be set to 0.

    var uint16: UInt16? {
        get {
            guard isValid else { return nil }
            guard isUInt16 else { return nil }
            if endianness == machineEndianness {
                return _valuePtr.assumingMemoryBound(to: UInt16.self).pointee
            } else {
                return _valuePtr.assumingMemoryBound(to: UInt16.self).pointee.byteSwapped
            }
        }
        set {
            guard isValid else { return }
            guard isUInt16 else { return }
            (newValue ?? 0).copyBytes(to: _valuePtr, endianness)
        }
    }
}


// Adds the Coder protocol to an UInt16

extension UInt16: Coder {

    public var itemType: ItemType { return ItemType.uint16 }

    public var valueByteCount: Int { return 2 }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            ptr.storeBytes(of: self, as: UInt16.self)
        } else {
            ptr.storeBytes(of: self.byteSwapped, as: UInt16.self)
        }
    }
}


