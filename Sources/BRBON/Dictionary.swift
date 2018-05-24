// =====================================================================================================================
//
//  File:       Dictionary.swift
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
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


internal let dictionaryReservedOffset = 0
internal let dictionaryItemCountOffset = dictionaryReservedOffset + 4
internal let dictionaryItemBaseOffset = dictionaryItemCountOffset + 4


extension Portal {
    
    
    internal var _dictionaryItemCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: dictionaryItemCountOffset) }
    
    internal var _dictionaryItemBasePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: dictionaryItemBaseOffset) }

    
    /// The number of items in the dictionary this portal refers to.
    
    internal var _dictionaryItemCount: Int {
        get { return Int(UInt32(fromPtr: _dictionaryItemCountPtr, endianness)) }
        set { UInt32(newValue).copyBytes(to: _dictionaryItemCountPtr, endianness) }
    }
    
    
    /// The total area used in the value field.
    
    internal var _dictionaryValueFieldUsedByteCount: Int {
        var dictItemPtr = _dictionaryItemBasePtr
        for _ in 0 ..< _dictionaryItemCount {
            dictItemPtr = dictItemPtr.advanced(by: Int(UInt32(fromPtr: dictItemPtr.advanced(by: itemByteCountOffset), endianness)))
        }
        return itemValueFieldPtr.distance(to: dictItemPtr)
    }
    
    
    /// Points to the first byte after the items in the referenced dictionary item
    
    internal var _dictionaryAfterLastItemPtr: UnsafeMutableRawPointer {
        var ptr = _dictionaryItemBasePtr
        var remainingItemsToSkip = _dictionaryItemCount
        while remainingItemsToSkip > 0 {
            ptr = ptr.advanced(by: Int(UInt32(fromPtr: ptr.advanced(by: itemByteCountOffset), endianness)))
            remainingItemsToSkip -= 1
        }
        return ptr
    }
    
    
    /// Removes an item with the given name from the dictionary.
    ///
    /// - Parameter forName: The name of the item to remove.
    ///
    /// - Returns: 'success' or an error indicator (including 'itemNotFound').
    
    internal func _dictionaryRemoveItem(withNameField nameField: NameField?) -> Result {
        
        let item = dictionaryFindItem(nameField)
        
        guard item.isValid else { return .error(.itemNotFound) }
        
        let itemStartPtr = item.itemPtr
        let ibc = item._itemByteCount
        let nextItemPtr = item.itemPtr.advanced(by: ibc)
        let afterLastItemPtr = _dictionaryAfterLastItemPtr

        assert(nextItemPtr <= afterLastItemPtr)
        
        // Last item does not need a block move
        
        if afterLastItemPtr == nextItemPtr {
                
            // Update the active portals list (remove deleted item)
            
            manager.removeActivePortals(atAndAbove: itemStartPtr, below: afterLastItemPtr)
            
            
            // Zero the 'removed' bytes
            
            if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(itemStartPtr, 0, ibc) }

        } else {
                
            // Move the items after the found item over the found item
                
            let len = nextItemPtr.distance(to: afterLastItemPtr)
                
            manager.moveBlock(to: itemStartPtr, from: nextItemPtr, moveCount: len, removeCount: ibc, updateMovedPortals: true, updateRemovedPortals: true)
            
            
            // Zero the freed bytes
            
            if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(itemStartPtr.advanced(by: len), 0, ibc) }
        }
        
        _dictionaryItemCount -= 1
        
        return .success
    }

    
    internal func _dictionaryAddItem(_ value: Coder, withNameField nameField: NameField?) -> Result {
        
        guard let nameField = nameField else { return .error(.missingName) }
        
        let neededValueFieldByteCount = itemMinimumByteCount + nameField.byteCount + (value.itemType.usesSmallValue ? 0 : value.valueByteCount.roundUpToNearestMultipleOf8())
        
        let result = ensureValueFieldByteCount(of: usedValueFieldByteCount + neededValueFieldByteCount)
        guard result == .success else { return result }
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
        
        let p = buildItem(withValue: value, withNameField: nameField, atPtr: _dictionaryAfterLastItemPtr, endianness)
        p._itemParentOffset = pOffset

        _dictionaryItemCount += 1
        
        return .success
    }
    
    
    /// Add a new item to the dictionary.
    ///
    /// - Note: This operation does not check for name duplication!.
    
    internal func _dictionaryAddItem(_ value: ItemManager, withNameField nameField: NameField?) -> Result {
        

        // Make sure the new item has the appropriate name

        if let nameField = nameField {
            let result = value.root.updateItemName(to: nameField)
            guard result == .success else { return result }
        }
        
        guard value.root.hasName else { return .error(.missingName) }

        
        // The new value field byte count for the dictionary
        
        let neededValueFieldByteCount = usedValueFieldByteCount.roundUpToNearestMultipleOf8() + value.root._itemByteCount
        
        
        // Increase the value field of the dictionary if necessary
        
        let result2 = ensureValueFieldByteCount(of: neededValueFieldByteCount)
        guard result2 == .success else { return result2 }
        
        
        // Copy the new item into place
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
        let dstPtr = _dictionaryAfterLastItemPtr
        
        _ = Darwin.memmove(_dictionaryAfterLastItemPtr, value.bufferPtr, value.root._itemByteCount)

        UInt32(pOffset).copyBytes(to: dstPtr.advanced(by: itemParentOffsetOffset), endianness)
        
        
        // Increase the item count
        
        _dictionaryItemCount += 1
        
        return .success
    }
    
    
    /// Returns a portal for the item with the specified name field.
    ///
    /// Returns the nullPortal if the item cannot be found.
    ///
    /// - Parameter nameField: The name field to look for.
    ///
    /// - Returns: The requested portal or the null portal.
    
    internal func dictionaryFindItem(_ nameField: NameField?) -> Portal {
        guard isDictionary else { return Portal.nullPortal }
        guard let nameField = nameField else { return Portal.nullPortal }
        var remainder = _dictionaryItemCount
        var ptr = _dictionaryItemBasePtr
        while remainder > 0 {
            if UInt16(fromPtr: ptr.advanced(by: itemNameCrcOffset), endianness) == nameField.crc {
                if ptr.advanced(by: itemNameUtf8ByteCountOffset).assumingMemoryBound(to: UInt8.self).pointee == UInt8(nameField.data.count) {
                    var dataIsEqual = true
                    for i in 0 ..< nameField.data.count {
                        if ptr.advanced(by: itemNameUtf8CodeOffset + i).assumingMemoryBound(to: UInt8.self).pointee != nameField.data[i] {
                            dataIsEqual = false
                            break
                        }
                    }
                    if dataIsEqual {
                        return manager.getActivePortal(for: ptr)
                    }
                }
            }
            remainder -= 1
            ptr += Int(UInt32.init(fromPtr: ptr.advanced(by: itemByteCountOffset), endianness))
        }
        return Portal.nullPortal
    }
}


// Public operations on the dictionary type

public extension Portal {
    
    
    /// Updates the referenced item or adds a new item to a dictionary.
    ///
    /// The type of the value and of the referenced item must be the same. Use 'replaceItem' to change the type of the referenced item.
    ///
    /// - Note: The portal 'self' will not be affected, portals referring to items in the content field will be invalidated.
    ///
    /// - Parameters:
    ///   - value: The new value.
    ///   - withNameField: The name field of the item to update/add.
    ///
    /// - Returns:
    ///   success: if the update was made.
    ///
    ///   noAction: if either value or withNameField is nil.
    ///
    ///   error(code): if the update could not be made because of an error, the code details the kind of error.
    
    @discardableResult
    public func updateItem(_ value: Coder?, withNameField nameField: NameField?) -> Result {
        
        guard let nameField = nameField else { return .noAction }
        guard let value = value else { return .success }

        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }
        
        let item = dictionaryFindItem(nameField)
        
        if item.isValid {
            guard item.itemType! == value.itemType else { return .error(.typeConflict) }
            return item._updateItemValue(value)
        } else {
            return _dictionaryAddItem(value, withNameField: nameField)
        }
    }

    
    /// Updates the referenced item or adds a new item to a dictionary.
    ///
    /// If the referenced item has an active portal, that portal is unaffected. However any active portal to the content of the items will be invalidated.
    ///
    /// - Note: The type in value.root and in the referenced item must be the same. Use 'replaceItem' to change the type of the referenced item.
    ///
    /// - Note: If the name is nil, but the value.root has a name, then that name will be used.
    ///
    /// - Parameters:
    ///   - value: The new value.
    ///   - withNameField: The name of the item to update/add.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func updateItem(_ value: ItemManager?, withNameField nameField: NameField?) -> Result {
        
        guard let value = value else { return .noAction }
        guard (nameField != nil) || value.root.hasName else { return .noAction }

        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }

        let item = dictionaryFindItem(nameField)
        
        if item.isValid {
            guard item.itemType! == value.root.itemType else { return .error(.typeConflict) }
            return item._updateItemValue(value)
        } else {
            return _dictionaryAddItem(value, withNameField: nameField)
        }
    }

    
    /// Replaces an item with a new item. If the item is not yet present, the new value will be rejected.
    ///
    /// - Note: The portal of the replaced item will be invalidated, as will the portals to any item in the content area of the replaced item.
    ///
    /// - Parameters:
    ///   - value: The new content for the item.
    ///   - withNameField: The name field for the item to be replaced (and the new item).
    ///
    /// - Returns:
    ///   success: If the old item was replaced.
    ///
    ///   noAction: If either parameter was nil.
    ///
    ///   error(code): If an error prevented completion of the request, the code will detail the kind of error.
    
    @discardableResult
    public func replaceItem(_ value: Coder?, withNameField nameField: NameField?) -> Result {
        
        guard let nameField = nameField else { return .noAction }
        guard let value = value else { return .noAction }
        
        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }
        
        let item = dictionaryFindItem(nameField)
        
        if item.isValid {

            // Ensure sufficient storage
            let result = item.ensureValueFieldByteCount(of: value.minimumValueFieldByteCount)
            guard result == .success else { return result }

            // Save the parameters that must be restored
            let pOffset = item._itemParentOffset
            let oldByteCount = item._itemByteCount
            
            // Invalidate contained portals
            manager.removeActivePortals(atAndAbove: item.itemPtr, below: item.itemPtr.advanced(by: item._itemByteCount))
            
            // Create the new item
            let p = buildItem(withValue: value, withNameField: nameField, atPtr: itemPtr, endianness)
            
            // Restore the saved parameters
            p._itemParentOffset = pOffset
            p._itemByteCount = oldByteCount
            
            return .success

        } else {
            return .error(.itemNotFound)
        }
    }
    
    
    /// Replaces an item with the contents from an item manager. If the item is not present, the new content will be rejected.
    ///
    /// - Note: The portal of the replaced item will be invalidated, as will the portals to any item in the content area of the replaced item.
    ///
    /// - Parameters:
    ///   - value: The new content for the item.
    ///   - withNameField: The name field for the item to be replaced (and the new item).
    ///
    /// - Returns:
    ///   success: If the old item was replaced.
    ///
    ///   noAction: If either parameter was nil.
    ///
    ///   error(code): If an error prevented completion of the request, the code will detail the kind of error.

    @discardableResult
    public func replaceItem(_ value: ItemManager?, withNameField nameField: NameField?) -> Result {
        
        guard let nameField = nameField else { return .noAction }
        guard let value = value else { return .noAction }
        
        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }
        
        let item = dictionaryFindItem(nameField)
        
        if item.isValid {
            
            // Ensure sufficient storage
            let result = item.ensureValueFieldByteCount(of: value.root._itemByteCount)
            guard result == .success else { return result }
            
            // Save the parameters that must be restored
            let pOffset = item._itemParentOffset
            let oldByteCount = item._itemByteCount
            let ipooPtr = item.itemParentOffsetPtr
            let ibcPtr = item.itemByteCountPtr
            
            // Copy the new item
            manager.moveBlock(to: item.itemPtr, from: value.bufferPtr, moveCount: value.root._itemByteCount, removeCount: item._itemByteCount, updateMovedPortals: false, updateRemovedPortals: true)
            
            // Restore the saved parameters
            UInt32(pOffset).copyBytes(to: ipooPtr, endianness)
            UInt32(oldByteCount).copyBytes(to: ibcPtr, endianness)
            
            return .success
            
        } else {
            return .error(.itemNotFound)
        }
    }

    
    /// Removes an item with the given name from the dictionary or all the items with the given name from a sequence.
    ///
    /// Works only on dictionaries and sequences.
    ///
    /// - Parameter withNameField: The name of the item to remove.
    ///
    /// - Returns: 'success' or an error indicator (including 'itemNotFound').
    
    @discardableResult
    public func removeItem(withNameField nameField: NameField?) -> Result {
        
        guard let nameField = nameField else { return .error(.missingName) }
        
        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }

        return _dictionaryRemoveItem(withNameField: nameField)
    }
}

public extension Portal {
    
    public subscript(name: String) -> Portal { get { return dictionaryFindItem(NameField(name)) } }
    
    public subscript(name: String) -> Bool? {
        get { return dictionaryFindItem(NameField(name)).bool }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> Int8? {
        get { return dictionaryFindItem(NameField(name)).int8 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> Int16? {
        get { return dictionaryFindItem(NameField(name)).int16 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> Int32? {
        get { return dictionaryFindItem(NameField(name)).int32 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> Int64? {
        get { return dictionaryFindItem(NameField(name)).int64 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> UInt8? {
        get { return dictionaryFindItem(NameField(name)).uint8 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> UInt16? {
        get { return dictionaryFindItem(NameField(name)).uint16 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> UInt32? {
        get { return dictionaryFindItem(NameField(name)).uint32 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> UInt64? {
        get { return dictionaryFindItem(NameField(name)).uint64 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> Float32? {
        get { return dictionaryFindItem(NameField(name)).float32 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> Float64? {
        get { return dictionaryFindItem(NameField(name)).float64 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> String? {
        get { return dictionaryFindItem(NameField(name)).string }
        set { updateItem(BRString(newValue), withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> BRString? {
        get { return dictionaryFindItem(NameField(name)).brString }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> BRCrcString? {
        get { return dictionaryFindItem(NameField(name)).crcString }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> Data? {
        get { return dictionaryFindItem(NameField(name)).binary }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> BRCrcBinary? {
        get { return dictionaryFindItem(NameField(name)).crcBinary }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> UUID? {
        get { return dictionaryFindItem(NameField(name)).uuid }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> BRColor? {
        get { return dictionaryFindItem(NameField(name)).color }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    public subscript(name: String) -> BRFont? {
        get { return dictionaryFindItem(NameField(name)).font }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
}

/// Build an item with a Dictionary in it.
///
/// - Parameters:
///   - withNameField: The namefield for the item. Optional.
///   - endianness: The endianness to be used while creating the item.
///
/// - Returns: An ephemeral portal. Do not retain this portal.

internal func buildDictionaryItem(withNameField nameField: NameField?, valueByteCount: Int, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Portal {
    let p = buildItem(ofType: .dictionary, withNameField: nameField, atPtr: ptr, endianness)
    p._itemByteCount += dictionaryItemBaseOffset + valueByteCount.roundUpToNearestMultipleOf8()
    p._dictionaryItemCount = 0
    return p
}

