// =====================================================================================================================
//
//  File:       UUID.swift
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
// 0.7.0 - Code restructuring & simplification
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


internal let uuidValueByteCount = 16


// Extensions that allow a portal to test and access an UUID

public extension Portal {
    
    
    /// Assess if the portal is valid and refers to an UUID.
    ///
    /// - Returns: True if the value accessable through this portal is an UUID. False if the portal is invalid or the value is not an UUID.

    public var isUuid: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uuid }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.uuid.rawValue }
        return itemPtr.itemType == ItemType.uuid.rawValue
    }

    
    /// Access the value through the portal as an UUID.
    ///
    /// - Note: Assigning a nil has no effect.
    ///
    /// - Returns: The value of the UUID if this portal is valid and refers to an UUID.

    public var uuid: UUID? {
        get {
            guard isValid else { return nil }
            guard isUuid else { return nil }
            return UUID(fromPtr: _valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            guard isUuid else { return }
            newValue?.copyBytes(to: _valuePtr, endianness)
        }
    }
}


// Adds the Coder protocol to an UUID

extension UUID: Coder {
    
    public var itemType: ItemType { return ItemType.uuid }

    public var valueByteCount: Int { return uuidValueByteCount }
        
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        ptr.storeBytes(of: self.uuid, as: uuid_t.self)
    }
}


// Add decoder

extension UUID {
    
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let ptr = fromPtr.bindMemory(to: uuid_t.self, capacity: 1)
        self.init(uuid: ptr.pointee)
    }
}



