// =====================================================================================================================
//
//  File:       Int8.swift
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


// Extensions that allow a portal to test and access an Int8

public extension Portal {
    
    
    /// Assess if the portal is valid and refers to an Int8.
    ///
    /// - Returns: True if the value accessable through this portal is an Int8. False if the portal is invalid or the value is not an Int8.

    public var isInt8: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int8 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue
    }
    

    /// Access the value through the portal as an Int8.
    ///
    /// - Note: Assigning a nil has no effect.
    ///
    /// - Returns: The value of the Int8 if this portal is valid and refers to an Int8.

    public var int8: Int8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isInt8 else { fatalOrNull("Attempt to access \(String(describing: itemType)) as a Int8"); return nil }
            return Int8(fromPtr: valueFieldPtr, endianness)
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isInt8 else { fatalOrNull("Attempt to access \(String(describing: itemType)) as a Int8"); return }
            
            if index == nil {
                newValue?.storeValue(atPtr: itemSmallValuePtr, endianness)
            } else {
                newValue?.storeValue(atPtr: valueFieldPtr, endianness)
            }
        }
    }
    
    /// Add an Int8 to an Array.
    ///
    /// - Returns: .success or one of .portalInvalid, .operationNotSupported, .typeConflict
    
    @discardableResult
    public func append(_ value: Int8) -> Result {
        return appendClosure(for: value.itemType, with: value.valueByteCount) { value.storeValue(atPtr: _arrayElementPtr(for: _arrayElementCount), endianness) }
    }
}


/// Adds the Coder protocol to an Int8

extension Int8: Coder {
    
    internal var itemType: ItemType { return ItemType.int8 }

    internal var valueByteCount: Int { return 1 }
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        atPtr.storeBytes(of: self, as: Int8.self)
    }
    
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.init(fromPtr.assumingMemoryBound(to: Int8.self).pointee)
    }
}


/// Build an item with a Int8 in it.
///
/// - Parameters:
///   - withName: The namefield for the item. Optional.
///   - value: The value to store in the smallValueField.
///   - atPtr: The pointer at which to build the item structure.
///   - endianness: The endianness to be used while creating the item.
///
/// - Returns: An ephemeral portal. Do not retain this portal.

internal func buildInt8Item(withName name: NameField?, value: Int8 = 0, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Portal {
    let p = buildItem(ofType: .int8, withName: name, atPtr: ptr, endianness)
    p.itemSmallValuePtr.storeBytes(of: value, as: Int8.self)
}


