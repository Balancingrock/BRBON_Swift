// =====================================================================================================================
//
//  File:       Item-Dictionary.swift
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
    
    
    /// Creates a new Item of the type dictionary.
    
    public static func dictionary(_ name: String? = nil, fixedItemByteCount: UInt32? = nil) -> Item? {
        
        
        // Make sure the fixedItemByteCount is within limits
        
        if let fixedItemByteCount = fixedItemByteCount, fixedItemByteCount > UInt32(Int32.max) { return nil }

        
        // Create value wrapper
        
        let itemValue = ItemValue(dictionary: [])
        
        
        // Create the item name (if nay)
        
        var itemName: ItemName?
        
        if let name = name {
            guard let n = ItemName(name) else { return nil }
            itemName = n
        }
        
        
        // Create new Item referencing the created item value
        
        return self.init(itemValue, name: itemName, fixedItemByteCount: fixedItemByteCount)
    }
    
    
    /// Returns true if the Item is a dictionary type
    
    public var isDictionary: Bool { return type == .dictionary }
    
    
    /// Adds an Item to a dictionary or a sequence. To add to a dictionary the item must have a name or a name must be specified. If a name is specified it will take precedence and that name will be written to the added Item.
    ///
    /// - Note: Only works on dictionaries and sequences.
    ///
    /// - Returns: True if the operation was succesful, false when no name was specified and the item did not have a name.
    
    @discardableResult
    public func add(_ item: Item?, for name: String? = nil) -> Bool {
        
        guard type == .dictionary || type == .sequence else { return false }
        guard let item = item else { return false }
        
        if let name = name { item.name = name }
        
        if type == .dictionary {
            guard item.name != nil else { return false }
            remove(with: item.name!)
        }
        
        guard canAccomodateIncreaseInByteCount(for: item) else { return false }
        
        // Append the new item
        item.parent = self
        _value.array.append(item)
        
        return true
    }
    
    
    /// Finds the item for a given name, if any.
    
    public func item(for name: String) -> Item? {
        
        guard type == .dictionary || type == .sequence else { return nil }
        
        for item in _value.array {
            if name == item.name {
                return item
            }
        }
        
        return nil
    }
    
    
    /// Remove the item with the given name from a dictionary or sequence. Only the first item for the name will be removed.
    ///
    /// - Returns: Nil if nothing was removed, otherwise the item that was removed.
    
    @discardableResult
    public func remove(with name: String) -> Item? {
        
        guard type == .dictionary || type == .sequence else { return nil }

        for item in _value.array {
            if name == item.name {
                if let removed = _value.array.removeObject(object: item) {
                    removed.parent = nil
                    return removed
                } else {
                    assertionFailure()
                    return nil
                }
            }
        }
        
        return nil
    }
    
    
    /// Remove the given item from self.
    ///
    /// - Note: Self must be an array, dictionary or sequences.
    ///
    /// - Returns: Nil when nothing was removed, otherwise the removed item.
    
    @discardableResult
    public func remove(_ item: Item) -> Item? {
        
        guard (type == .dictionary) || (type == .array)  || (type == .sequence) else { return nil }

        if let removed = _value.array.removeObject(object: item) {
            removed.parent = nil
            return removed
        } else {
            return nil
        }
    }
    
    
    /// Subscript operations.
    
    public subscript(key: String) -> Item? {
        set {
            guard type == .dictionary || type == .sequence else { return }
            add(newValue, for: key)
        }
        get {
            guard type == .dictionary || type == .sequence  else { return nil }
            guard let _ = ItemName(key) else { return nil }
            return item(for: key)
        }
    }    
}
