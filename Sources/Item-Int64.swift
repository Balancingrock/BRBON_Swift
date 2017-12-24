// =====================================================================================================================
//
//  File:       Item-Int64.swift
//  Project:    BRBON
//
//  Version:    0.2.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2017 Marinus van der Lugt, All rights reserved.
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
// 0.2.0  - Changed init parameter fixedByteCount to fixedItemByteCount
// 0.1.0  - Initial version
// =====================================================================================================================

import Foundation


public extension Item {
    
    
    /// Create a new Int64 Item
    
    public static func int64(_ val: Int64) -> Item {
        return Item(val, name: nil, fixedItemByteCount: nil)!
    }
    
    
    /// Create a new Int64 Item
    ///
    /// Initializer fails when the string cannot be converted into UTF8 or the fixedItemByteCount > Int32.max.
    
    public static func int64(_ val: Int64, name: String? = nil, fixedItemByteCount: UInt32? = nil) -> Item? {
        return Item(val, name: name, fixedItemByteCount: fixedItemByteCount)
    }
    
    
    /// Create a new Int64 Item
    
    public convenience init(_ val: Int64) {
        self.init(val, name: nil, fixedItemByteCount: nil)!
    }
    
    
    /// Create a new Int64 Item
    ///
    /// Initializer only fails when the string cannot be converted into UTF8
    
    public convenience init?(_ val: Int64, name: String) {
        self.init(val, name: name, fixedItemByteCount: nil)
    }
    
    
    /// Create a new Int64 Item
    ///
    /// Initializer only fails when the string cannot be converted into UTF8 or the fixedItemByteCount > Int32.max.
    
    public convenience init?(_ val: Int64, name: String? = nil, fixedItemByteCount: UInt32?) {
        
        
        // Make sure the fixedItemByteCount is within limits
        
        if let fixedItemByteCount = fixedItemByteCount, fixedItemByteCount > UInt32(Int32.max) { return nil }
        
        
        // Create value wrapper
        
        let itemValue = ItemValue(val)
        
        
        // Create the item name (if nay)
        
        var itemName: ItemName?
        
        if let name = name {
            guard let n = ItemName(name) else { return nil }
            itemName = n
        }
        
        
        // Create new Item referencing the created item value
        
        self.init(itemValue, name: itemName, fixedItemByteCount: fixedItemByteCount)
    }
    
    
    /// Returns true if the Item is a int64 type
    
    public var isInt64: Bool { return type == .int64 }
    
    
    /// Returns the Int64 value of this Item if the item is a Int64 and the isNil option is not set.
    
    public var int64: Int64? {
        set {
            guard type == .int64 else { return }
            if let newValue = newValue {
                _value.any = newValue
                header.options.isNil = false
            } else {
                header.options.isNil = true
            }
        }
        get {
            guard type == .int64 else { return nil }
            if header.options.isNil { return nil }
            return (_value.any as! Int64)
        }
    }
}
