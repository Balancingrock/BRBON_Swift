// =====================================================================================================================
//
//  File:       Item-Array.swift
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
    
    
    /// Create a new .array Item
    
    public static func array(elementType: ItemType, elementByteCount: UInt32) -> Item {
        return Item(elementType: elementType, elementByteCount: elementByteCount, name: nil, fixedItemByteCount: nil)!
    }
    
    
    /// Create a new .array Item
    ///
    /// Initializer fails when the string cannot be converted into UTF8 or the length > Int32.max.
    
    public static func array(elementType: ItemType, elementByteCount: UInt32, name: String? = nil, fixedItemByteCount: UInt32? = nil) -> Item? {
        return Item(elementType: elementType, elementByteCount: elementByteCount, name: name, fixedItemByteCount: fixedItemByteCount)
    }
    
    
    /// Create a new .array Item
    
    public convenience init(elementType: ItemType, elementByteCount: UInt32) {
        self.init(elementType: elementType, elementByteCount: elementByteCount, name: nil, fixedItemByteCount: nil)!
    }
    
    
    /// Create a new String Item.
    ///
    /// Initializer only fails when the string cannot be converted into UTF8
    
    public convenience init?(elementType: ItemType, elementByteCount: UInt32, name: String) {
        self.init(elementType: elementType, elementByteCount: elementByteCount, name: name, fixedItemByteCount: nil)!
    }
    
    
    /// Create a new String Item.
    ///
    /// Initializer only fails when the string cannot be converted into UTF8 or the fixedItemByteCount > Int32.max.
    
    public convenience init?(elementType: ItemType, elementByteCount: UInt32, name: String? = nil, fixedItemByteCount: UInt32?) {
        
        
        // Make sure the fixedItemByteCount is within limits
        
        if let fixedItemByteCount = fixedItemByteCount, fixedItemByteCount > UInt32(Int32.max) { return nil }
        
        
        // Create the value wrapper
        
        let itemValue = ItemValue(array: Array<Item>(), elementType: elementType, elementByteCount: elementByteCount)
        
        
        // Create the item name (if any)
        
        var itemName: ItemName?
        
        if let name = name {
            guard let n = ItemName(name) else { return nil }
            itemName = n
        }
        
        
        // Create new Item referencing the created item value
        
        self.init(itemValue, name: itemName, fixedItemByteCount: fixedItemByteCount)
    }
    
    
    /// Returns true if the Item is a array type
    
    public var isArray: Bool { return type == .array }
    
    
    /// Returns the number of items in the array or dictionary. For other types it returns nil.
    
    public var count: Int? { return _value?.array.count }
    
    
    /// The type of the elements in the array, if this Item is an array.
    
    public var elementType: ItemType? { return header.type == .array ? _value!.elementType : nil }
    
    
    /// The byte count for the array element, if this Item is an array
    
    public var elementByteCount: UInt32? { return header.type == .array ? _value!.elementByteCount : nil }
    

    /// Appends the given item to the end of the array if allowed by the following conditions:
    ///
    /// - Note: Only works for array and sequence.
    ///
    /// - The type of the item must match the type of the elements in the array.
    /// - The byte count of the item must fit in the byte count of the array elements.
    /// - The Item may not have a name or have a fixedNameByteCount
    /// - If the parent has a fixedByteCount, there must be enough space to add the new item. (All the way up the BRBON hierarchy)
    
    @discardableResult
    public func append(_ item: Item?) -> Bool {
        
        guard type == .array || type == .sequence else { return false }
        guard let item = item else { return false }
        
        if type == .array { guard isItemAcceptableForArray(item) else { return false } }
        
        guard canAccomodateIncreaseInByteCount(for: item) else { return false }
        
        item.parent = self
        
        _value.array.append(item)
        
        return true
    }

    
    /// Inserts the given item at the given location if allowed by the following conditions:
    ///
    /// - Note: Only works for array and sequence.
    ///
    /// - The location must be valid.
    /// - The type of the item must match the type of the elements in the array.
    /// - The byte count of the item must fit in the byte count of the array elements.
    /// - If the parent has a fixedByteCount, there must be enough space to add the new item. (All the way up the BRBON hierarchy)
    
    @discardableResult
    public func insert(_ item: Item?, at index: Int) -> Bool {
        
        guard type == .array || type == .sequence else { return false }
        guard let item = item else { return false }
        guard (index >= 0) && (index < _value.array.count) else { return false }
        
        if type == .array { guard isItemAcceptableForArray(item) else { return false } }
        
        guard canAccomodateIncreaseInByteCount(for: item) else { return false }
        
        _value.array.insert(item, at: index)
        
        return true
    }

    
    /// Replaces the item at the given location with the given item if allowed by the following conditions:
    ///
    /// - Note: Only works for array and sequence.
    ///
    /// - The location must be valid.
    /// - The type of the item must match the type of the elements in the array.
    /// - The byte count of the item must fit in the byte count of the array elements (substracting for the removed item).
    /// - If the parent has a fixedByteCount, there must be enough space to add the new item. (All the way up the BRBON hierarchy)
    
    @discardableResult
    public func replace(_ item: Item?, at index: Int) -> Item? {
        
        guard type == .array || type == .sequence else { return nil }
        guard let item = item else { return nil }
        guard (index >= 0) && (index < _value.array.count) else { return nil }
        
        if type == .array {
            guard isItemAcceptableForArray(item) else { return nil }
        }
        
        let replaced = _value.array.remove(at: index)
        replaced.parent = nil
        
        if canAccomodateIncreaseInByteCount(for: item) {
            item.parent = self
            _value.array.insert(item, at: index)
        } else {
            replaced.parent = self
            _value.array.insert(replaced, at: index)
        }
        
        return replaced
    }
    
    
    /// Removes and returns the item at the given location. The given location must be a valid location.
    ///
    /// - Note: Only works for array and sequence.
    ///
    /// - Returns: Nil if there was an error, the removed item on success.
    
    @discardableResult
    public func remove(at index: Int) -> Item? {
        
        guard type == .array || type == .sequence else { return nil }
        guard (index >= 0) && (index < _value.array.count) else { return nil }
        
        let removed = _value.array.remove(at: index)
        removed.parent = nil
        
        return removed
    }
    

    /// Removes all items from an array, sequence or dictionary.
    ///
    /// - Note: Works for array, dictionary and sequence.
    
    @discardableResult
    public func removeAll() -> Bool {
        
        guard type == .array || type == .dictionary || type == .sequence else { return false }
        
        _value.array.removeAll()
        
        return true
    }

    
    /// Either sets or gets the item at the requested index.
    
    public subscript(index: Int) -> Item? {
        set {
            guard type == .array || type == .sequence else { return }
            guard index >= 0 else { return }
            replace(newValue, at: index)
        }
        get {
            guard type == .array || type == .sequence else { return nil }
            guard index >= 0 else { return nil }
            return _value.array[index]
        }
    }
    
    
    /// This function determines if a new item is acceptable into an array:
    ///
    /// - Then the type of the item must match the array element type.
    /// - Then the new item byte count must be less or equal the array element byte count.
    /// - The item cannot have a name or fixedNameByteCount

    internal func isItemAcceptableForArray(_ item: Item?) -> Bool {
        guard let item = item else { return false }
        if item.type != _value.elementType { return false }
        if item._value.byteCount > _value.elementByteCount { return false }
        if item._name != nil { return false }
        if item.fixedNameByteCount != nil { return false }
        return true
    }
    
    /// This function determines if a new item is acceptable due to:
    ///
    /// - If self is an array, then the type of the item must match the array element type.
    /// - If self is an array, then the new item byte count must be less or equal the array element byte count.
    /// - If self is a container, then the new item must find place within a possible fixedItemByteCount.
    /// - If self is part of a container, then the container size limits may not be violated all the way to the topmost item.
    
    internal func canAccomodateIncreaseInByteCount(for item: Item?) -> Bool {
        guard let item = item else { return false }
        var neededBytes: UInt32 = 0
        if type == .array { neededBytes = item._value.byteCount }
        if type == .dictionary || type == .sequence { neededBytes = item.byteCount }
        if let unusedByteCount = unusedByteCount {
            if neededBytes > unusedByteCount { return false }
        }
        return parent?.canAccomodateIncreaseInByteCount(neededBytes) ?? true
    }
    
    
    /// Returns true if this item and all parents up the hierachy can allocate the extra bytes. False otherwise.
    
    public func canAccomodateIncreaseInByteCount(_ size: UInt32) -> Bool {
        if let fixedItemByteCount = fixedItemByteCount {
            if fixedItemByteCount < (byteCount + size) { return false }
        }
        return parent?.canAccomodateIncreaseInByteCount(size) ?? true
    }
}
