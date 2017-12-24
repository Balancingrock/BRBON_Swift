// =====================================================================================================================
//
//  File:       Item-String.swift
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
// 0.2.0  - Added operations to specify a maximum storage size for the string itself.
//          Changed init parameter fixedByteCount to fixedItemByteCount
// 0.1.0  - Initial version
// =====================================================================================================================

import Foundation


public extension Item {
    
    
    /// Create a new String Item
    
    public static func string(_ val: String) -> Item {
        return Item(val, name: nil, fixedItemByteCount: nil)!
    }
    
    
    /// Create a new String Item
    ///
    /// Initializer fails when the string cannot be converted into UTF8 or the fixedItemByteCount > Int32.max.
    
    public static func string(_ val: String, name: String? = nil, fixedItemByteCount: UInt32? = nil) -> Item? {
        return Item(val, name: name, fixedItemByteCount: fixedItemByteCount)
    }
    
    
    /// Creates a new String Item in which a maximum of (UTF8 encoded) string bytes can be stored.
    ///
    /// Initializer fails when the string cannot be converted into UTF8 or the total storage would be > Int32.max.
    
    public static func string(_ val: String, name: String? = nil, fixedStorageArea: UInt32) -> Item? {
        return Item(val, name: name, fixedStorageArea: fixedStorageArea)
    }
    
    
    /// Create a new String Item
    
    public convenience init(_ val: String) {
        self.init(val, name: nil, fixedItemByteCount: nil)!
    }
    
    
    /// Create a new String Item.
    ///
    /// Initializer only fails when the string cannot be converted into UTF8
    
    public convenience init?(_ val: String, name: String) {
        self.init(val, name: name, fixedItemByteCount: nil)
    }
    
    
    /// Create a new String Item.
    ///
    /// Initializer only fails when the string cannot be converted into UTF8 or the fixedItemByteCount > Int32.max.
    
    public convenience init?(_ val: String, name: String? = nil, fixedItemByteCount: UInt32?) {
        
        
        // Make sure the fixedItemByteCount is within limits
        
        if let fixedItemByteCount = fixedItemByteCount, fixedItemByteCount > UInt32(Int32.max) { return nil }
        
        
        // Create the value wrapper
        
        let itemValue = ItemValue(val)
        
        
        // Create the item name (if any)
        
        var itemName: ItemName?
        
        if let name = name {
            guard let n = ItemName(name) else { return nil }
            itemName = n
        }
        
        
        // Create new Item referencing the created item value
        
        self.init(itemValue, name: itemName, fixedItemByteCount: fixedItemByteCount)
    }
    
    
    /// Creates a new String Item in which a maximum number of (UTF8 encoded) bytes can be stored. The size of this item will always be fixed to the storage size specified plus all overhead.
    ///
    /// Initializer fails when the string cannot be converted into UTF8 or the total storage would be > Int32.max.
    ///
    /// - Parameters:
    ///   - val: The string to be stored. Must be convertable to UTF8 code units. Operation fails if the string cannot be converted.
    //    - name: The name to be used for this item. If no name is given here, but the item is given a name later, then the name will occupy part of the storage that was allocated. The name must be convertible to UTF8. Operation fails if the name cannot be converted.
    ///   - fixedStorageArea: The number of bytes available to store the UTF8 representation of the string in. Note that the fixedItemByteCount is equal to the fixedStorageArea plus the overhead due to the name and item fields. If the name is not set now, but later, then the name will occupy part of the storage area.
    ///
    /// - Note: If this item will be stored in a dictionary, then it is recommened to assign a name now. Or make the fixedStorageArea big enough to include a name that is assigned later.
    
    public convenience init?(_ val: String, name: String? = nil, fixedStorageArea: UInt32) {
        
        if fixedStorageArea > UInt32(Int32.max) { return nil }

        let itemValue = ItemValue(val)
        var itemName: ItemName?
        
        if let name = name {
            guard let n = ItemName(name) else { return nil }
            itemName = n
        }

        self.init(itemValue, name: itemName, fixedStorageArea: fixedStorageArea)
    }
    
    
    /// Returns true if the Item is a string type
    
    public var isString: Bool { return type == .string }
    
    
    /// Returns the String value of this Item if the item is a String and the isNil option is not set.
    
    public var string: String? {
        set {
            guard type == .string else { return }
            if let newValue = newValue {
                _value.any = newValue
                header.options.isNil = false
            } else {
                header.options.isNil = true
            }
        }
        get {
            guard type == .string else { return nil }
            if header.options.isNil { return nil }
            return (_value.any as! String)
        }
    }
}
