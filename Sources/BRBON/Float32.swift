// =====================================================================================================================
//
//  File:       Float32.swift
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
// 0.7.9 - Changed the way a nil is written (now written as 0.0)
// 0.7.0 - Code restructuring & simplification
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


// Public item access

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is a float32.

    public var isFloat32: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.float32 }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.float32.rawValue }
        return itemPtr.itemType == ItemType.float32.rawValue
    }

    
    /// Access the value through the portal as a Float32
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to a float32, writing will be ineffective and reading will always return nil.
    ///
    /// __On read:__ Returns the value at the associated memory location interpreted as a float32.
    ///
    /// __On write:__ Stores the float32 value at the associated memory location. If a nil is written the data at the location will be set to 0.0.

    public var float32: Float32? {
        get {
            guard isFloat32 else { return nil }
            if endianness == machineEndianness {
                return Float32(bitPattern: _valuePtr.assumingMemoryBound(to: UInt32.self).pointee)
            } else {
                return Float32(bitPattern: _valuePtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped)
            }
        }
        set {
            guard isFloat32 else { return }
            (newValue ?? 0.0).copyBytes(to: _valuePtr, endianness)
        }
    }
}


/// Adds the Coder protocol

extension Float32: Coder {
    
    public var itemType: ItemType { return ItemType.float32 }

    public var valueByteCount: Int { return 4 }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            ptr.storeBytes(of: self.bitPattern, as: UInt32.self)
        } else {
            ptr.storeBytes(of: self.bitPattern.byteSwapped, as: UInt32.self)
        }
    }
}

