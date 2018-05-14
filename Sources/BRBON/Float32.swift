// =====================================================================================================================
//
//  File:       Float32.swift
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


// Extensions that allow a portal to test and access a Float32

public extension Portal {
    
    
    /// Returns true if the value accessable through this portal is a Float32.
    
    public var isFloat32: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.float32 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue
    }

    
    /// Access the value through the portal as a Float32
    ///
    /// - Note: Assigning a nil has no effect.
    
    public var float32: Float32? {
        get {
            guard isFloat32 else { return nil }
            return Float32(fromPtr: valueFieldPtr, endianness)
        }
        set {
            guard isFloat32 else { return }
            newValue?.copyBytes(to: valueFieldPtr, endianness)
        }
    }
    
    
    /// Add an Float32 to an Array.
    ///
    /// - Returns: .success or one of .portalInvalid, .operationNotSupported, .typeConflict
    
    @discardableResult
    public func append(_ value: Float32) -> Result {
        return appendClosure(for: value.itemType, with: value.valueByteCount) { value.copyBytes(to: _arrayElementPtr(for: _arrayElementCount), endianness) }
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


/// Add decoding

extension Float32 {
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.init(bitPattern: fromPtr.assumingMemoryBound(to: UInt32.self).pointee)
        } else {
            self.init(bitPattern: fromPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped)
        }
    }
}