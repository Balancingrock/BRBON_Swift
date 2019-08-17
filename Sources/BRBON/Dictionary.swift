// =====================================================================================================================
//
//  File:       Dictionary.swift
//  Project:    BRBON
//
//  Version:    1.0.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
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
//  Like you, I need to make a living:
//
//   - You can send payment (you choose the amount) via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
// PLEASE let me know about bugs, improvements and feature requests. (rien@balancingrock.nl)
// =====================================================================================================================
//
// History
//
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


internal let dictionaryReservedOffset = 0
internal let dictionaryItemCountOffset = dictionaryReservedOffset + 4
internal let dictionaryItemBaseOffset = dictionaryItemCountOffset + 4


extension UnsafeMutableRawPointer {
    
    internal var dictionaryItemCountPtr: UnsafeMutableRawPointer { return self.advanced(by: dictionaryItemCountOffset) }
    
    internal var dictionaryItemBasePtr: UnsafeMutableRawPointer { return self.advanced(by: dictionaryItemBaseOffset) }
    
    internal func dictionaryItemCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return dictionaryItemCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return dictionaryItemCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    internal func setDictionaryItemCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            dictionaryItemCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            dictionaryItemCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    internal func dictionaryItemCountIncrement(_ endianness: Endianness) {
        if endianness == machineEndianness {
            let value = dictionaryItemCountPtr.assumingMemoryBound(to: UInt32.self).pointee + 1
            dictionaryItemCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            let value = dictionaryItemCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped + 1
            dictionaryItemCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    internal func dictionaryItemCountDecrement(_ endianness: Endianness) {
        if endianness == machineEndianness {
            let value = dictionaryItemCountPtr.assumingMemoryBound(to: UInt32.self).pointee - 1
            dictionaryItemCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            let value = dictionaryItemCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped - 1
            dictionaryItemCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
}


extension Portal {
    
    
    /// The number of items in the dictionary this portal refers to.
    
    internal var _dictionaryItemCount: Int {
        get { return Int(itemPtr.itemValueFieldPtr.dictionaryItemCount(endianness)) }
        set { itemPtr.itemValueFieldPtr.setDictionaryItemCount(to: UInt32(newValue), endianness) }
    }
    
    
    /// Points to the first byte after the items in the referenced dictionary item
    
    internal var _dictionaryAfterLastItemPtr: UnsafeMutableRawPointer {
        var ptr = itemPtr.itemValueFieldPtr.dictionaryItemBasePtr
        var itterations = _dictionaryItemCount
        while itterations > 0  {
            ptr = ptr.nextItemPtr(endianness)
            itterations -= 1
        }
        return ptr
    }
    
    
    /// The total area used in the value field.
    
    internal var _dictionaryValueFieldUsedByteCount: Int {
        return itemPtr.itemValueFieldPtr.distance(to: _dictionaryAfterLastItemPtr)
    }
    
    
    /// Returns a portal for the item with the specified name field.
    ///
    /// Returns the nullPortal if the item cannot be found.
    ///
    /// - Parameter nameField: The name field to look for.
    ///
    /// - Returns: The requested portal or the null portal.
    
    internal func dictionaryFindItem(_ nameField: NameField?) -> Portal? {
        guard isDictionary else { return nil }
        guard let nameField = nameField else { return nil }
        var remainder = _dictionaryItemCount
        var ptr = itemPtr.itemValueFieldPtr.dictionaryItemBasePtr
        while remainder > 0 {
            if ptr.itemNameCrc(endianness) == nameField.crc {
                if ptr.itemNameUtf8ByteCount == UInt8(nameField.data.count) {
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
            ptr = ptr.nextItemPtr(endianness)
        }
        return nil
    }
}


// Public operations on the dictionary type

public extension Portal {
    
    
    /// Updates the referenced item or adds a new item to a dictionary.
    ///
    /// The type of the value and of the referenced item must be the same. Use 'replaceItem' to change the type of the referenced item.
    ///
    /// - Note: This portal will not be affected, portals referring to items in the content field will be invalidated.
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
    func updateItem(_ value: Coder?, withNameField nameField: NameField?) -> Result {
        
        guard let nameField = nameField else { return .noAction }
        guard let value = value else { return .success }

        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }
        
        
        // Update an exiting item
        
        if let item = dictionaryFindItem(nameField), item.isValid {
        
            guard item.itemType! == value.itemType else { return .error(.typeConflict) }

            return item._updateItemValue(value)

        } else {
        
            // Add a new item
            
            let newItemByteCount = itemHeaderByteCount + nameField.byteCount + value.minimumValueFieldByteCount
            let necessaryValueFieldByteCount = usedValueFieldByteCount + newItemByteCount
            let necessaryItemByteCount = itemPtr.itemHeaderAndNameByteCount + necessaryValueFieldByteCount
            
            if necessaryItemByteCount > _itemByteCount {
                let result = increaseItemByteCount(to: necessaryItemByteCount)
                guard result == .success else { return result }
            }
                        
            let pOffset = UInt32(manager.bufferPtr.distance(to: itemPtr))
            let ptr = _dictionaryAfterLastItemPtr

            buildItem(withValue: value, withNameField: nameField, atPtr: ptr, endianness)
            ptr.setItemParentOffset(to: pOffset, endianness)
            
            itemPtr.itemValueFieldPtr.dictionaryItemCountIncrement(endianness)
            
            return .success
        }
    }

    
    /// Updates the referenced item or adds a new item to a dictionary.
    ///
    /// The type of the value and of the referenced item must be the same. Use 'replaceItem' to change the type of the referenced item.
    ///
    /// - Note: This portal will not be affected, portals referring to items in the content field will be invalidated.
    ///
    /// - Parameters:
    ///   - value: The new value.
    ///   - withName: The name of the item to update/add.
    ///
    /// - Returns:
    ///   success: if the update was made.
    ///
    ///   noAction: if the value is nil.
    ///
    ///   error(code): if the update could not be made because of an error, the code details the kind of error.
    
    @discardableResult
    func updateItem(_ value: Coder?, withName name: String) -> Result {
        guard let nameField = NameField(name) else { return .error(.nameFieldError) }
        return updateItem(value, withNameField: nameField)
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
    func updateItem(_ value: ItemManager?, withNameField nameField: NameField?) -> Result {
        
        guard let value = value else { return .noAction }
        guard (nameField != nil) || value.root.hasName else { return .noAction }

        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }

        if let item = dictionaryFindItem(nameField), item.isValid {
        
            guard item.itemType! == value.root.itemType else { return .error(.typeConflict) }

            return item._updateItemValue(value)

        } else {
            
            // Add a new item
            
            
            // Make sure there is enough space
            
            let newItemByteCount = value.root._itemByteCount
            let necessaryValueFieldByteCount = usedValueFieldByteCount + newItemByteCount
            let necessaryItemByteCount = itemPtr.itemHeaderAndNameByteCount + necessaryValueFieldByteCount
            
            if necessaryItemByteCount > _itemByteCount {
                let result = increaseItemByteCount(to: necessaryItemByteCount)
                guard result == .success else { return result }
            }
            
            
            // Copy the new item into place
            
            let pOffset = manager.bufferPtr.distance(to: itemPtr)
            let dstPtr = _dictionaryAfterLastItemPtr
            
            _ = Darwin.memmove(dstPtr, value.bufferPtr, value.root._itemByteCount)
            
            let p = manager.getActivePortal(for: dstPtr)
            p._itemParentOffset = pOffset
            if let nameField = nameField {
                _ = p.updateItemName(to: nameField)
            }

            
            // Increase the item count
            
            itemPtr.itemValueFieldPtr.dictionaryItemCountIncrement(endianness)

            return .success
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
    ///   - withName: The name of the item to update/add.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    func updateItem(_ value: ItemManager?, withName name: String) -> Result {
        guard let nameField = NameField(name) else { return .error(.nameFieldError) }
        return updateItem(value, withNameField: nameField)
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
    func replaceItem(_ value: Coder?, withNameField nameField: NameField?) -> Result {
        
        guard let nameField = nameField else { return .noAction }
        guard let value = value else { return .noAction }
        
        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }
        
        guard let item = dictionaryFindItem(nameField) else { return .error(.itemNotFound) }
        
        // Ensure sufficient storage
        let newItemByteCount = itemHeaderByteCount + nameField.byteCount + value.minimumValueFieldByteCount
        if newItemByteCount > item._itemByteCount {
            let result = item.increaseItemByteCount(to: newItemByteCount)
            guard result == .success else { return result }
        }

        // Save the parameters that must be restored
        let pOffset = item.itemPtr.itemParentOffset(endianness)
        let oldByteCount = item.itemPtr.itemByteCount(endianness)
            
        // Invalidate contained portals
        let ptr = item.itemPtr
        manager.removeActivePortals(atAndAbove: ptr, below: ptr.advanced(by: Int(oldByteCount)))
            
        // Zero the bytes if necessary
        if ItemManager.startWithZeroedBuffers { Darwin.memset(ptr, 0, Int(oldByteCount)) }
            
        // Create the new item
        buildItem(withValue: value, withNameField: nameField, atPtr: ptr, endianness)
            
        // Restore the saved parameters
        ptr.setItemParentOffset(to: pOffset, endianness)
        ptr.setItemByteCount(to: oldByteCount, endianness)
        
        return .success
    }
    
    
    /// Replaces an item with a new item. If the item is not yet present, the new value will be rejected.
    ///
    /// - Note: The portal of the replaced item will be invalidated, as will the portals to any item in the content area of the replaced item.
    ///
    /// - Parameters:
    ///   - value: The new content for the item.
    ///   - withName: The name for the item to be replaced (and the new item).
    ///
    /// - Returns:
    ///   success: If the old item was replaced.
    ///
    ///   noAction: If the value is nil.
    ///
    ///   error(code): If an error prevented completion of the request, the code will detail the kind of error.
    
    @discardableResult
    func replaceItem(_ value: Coder?, withName name: String) -> Result {
        guard let nameField = NameField(name) else { return .error(.nameFieldError) }
        return replaceItem(value, withNameField: nameField)
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
    func replaceItem(_ value: ItemManager?, withNameField nameField: NameField?) -> Result {
        
        guard let nameField = nameField else { return .noAction }
        guard let value = value else { return .noAction }
        
        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }
        
        guard let item = dictionaryFindItem(nameField), item.isValid else { return .error(.itemNotFound) }
        
        // Ensure sufficient storage
        let newItemByteCount = value.root._itemByteCount - value.root._itemNameFieldByteCount + nameField.byteCount
        if newItemByteCount > item._itemByteCount {
            let result = item.increaseItemByteCount(to: newItemByteCount)
            guard result == .success else { return result }
        }
        
        // Save the parameters that must be restored
        let pOffset = item._itemParentOffset
        let oldByteCount = item._itemByteCount
        let ipooPtr = item.itemPtr.itemParentOffsetPtr
        let ibcPtr = item.itemPtr.itemByteCountPtr
            
        // Copy the new item
        let newByteCount = value.root._itemByteCount
        let ptr = item.itemPtr
        manager.moveBlock(to: ptr, from: value.bufferPtr, moveCount: newByteCount, removeCount: oldByteCount, updateMovedPortals: false, updateRemovedPortals: true)
            
        // Zero unused bytes in the old item area (after the new item)
        if ItemManager.startWithZeroedBuffers && (newByteCount < oldByteCount) {
            Darwin.memset(ptr.advanced(by: newByteCount), 0, (oldByteCount - newByteCount))
        }
            
        // Restore the saved parameters
        UInt32(pOffset).copyBytes(to: ipooPtr, endianness)
        UInt32(oldByteCount).copyBytes(to: ibcPtr, endianness)
            
        return .success
    }

    
    /// Replaces an item with the contents from an item manager. If the item is not present, the new content will be rejected.
    ///
    /// - Note: The portal of the replaced item will be invalidated, as will the portals to any item in the content area of the replaced item.
    ///
    /// - Parameters:
    ///   - value: The new content for the item.
    ///   - withName: The name for the item to be replaced (and the new item).
    ///
    /// - Returns:
    ///   success: If the old item was replaced.
    ///
    ///   noAction: If either parameter was nil.
    ///
    ///   error(code): If an error prevented completion of the request, the code will detail the kind of error.
    
    @discardableResult
    func replaceItem(_ value: ItemManager?, withName name: String) -> Result {
        guard let nameField = NameField(name) else { return .error(.nameFieldError) }
        return replaceItem(value, withNameField: nameField)
    }

    
    /// Removes an item with the given name from the dictionary or all the items with the given name from a sequence.
    ///
    /// Works only on dictionaries and sequences.
    ///
    /// - Parameter withNameField: The name of the item to remove.
    ///
    /// - Returns: 'success' or an error indicator (including 'itemNotFound').
    
    @discardableResult
    func removeItem(withNameField nameField: NameField?) -> Result {
        
        guard let nameField = nameField else { return .error(.missingName) }
        
        guard isValid else { return .error(.portalInvalid) }
        guard isDictionary else { return .error(.operationNotSupported) }
        
        guard let item = dictionaryFindItem(nameField) else { return .error(.itemNotFound) }
        
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
        
        itemPtr.itemValueFieldPtr.dictionaryItemCountDecrement(endianness)

        return .success
    }
    
    
    /// Removes an item with the given name from the dictionary or all the items with the given name from a sequence.
    ///
    /// Works only on dictionaries and sequences.
    ///
    /// - Parameter withName: The name of the item to remove.
    ///
    /// - Returns: 'success' or an error indicator (including 'itemNotFound').
    
    @discardableResult
    func removeItem(withName name: String) -> Result {
        guard let nameField = NameField(name) else { return .error(.nameFieldError) }
        return removeItem(withNameField: nameField)
    }
}

public extension Portal {
    
    subscript(name: String) -> Portal { get { return dictionaryFindItem(NameField(name)) ?? Portal.nullPortal } }

    subscript(nameField: NameField) -> Portal { get { return dictionaryFindItem(nameField) ?? Portal.nullPortal } }

    subscript(name: String) -> Bool? {
        get { return dictionaryFindItem(NameField(name))?.bool }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }

    subscript(nameField: NameField) -> Bool? {
        get { return dictionaryFindItem(nameField)?.bool }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> Int8? {
        get { return dictionaryFindItem(NameField(name))?.int8 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> Int8? {
        get { return dictionaryFindItem(nameField)?.int8 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> Int16? {
        get { return dictionaryFindItem(NameField(name))?.int16 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> Int16? {
        get { return dictionaryFindItem(nameField)?.int16 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> Int32? {
        get { return dictionaryFindItem(NameField(name))?.int32 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> Int32? {
        get { return dictionaryFindItem(nameField)?.int32 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> Int64? {
        get { return dictionaryFindItem(NameField(name))?.int64 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> Int64? {
        get { return dictionaryFindItem(nameField)?.int64 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> UInt8? {
        get { return dictionaryFindItem(NameField(name))?.uint8 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> UInt8? {
        get { return dictionaryFindItem(nameField)?.uint8 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> UInt16? {
        get { return dictionaryFindItem(NameField(name))?.uint16 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> UInt16? {
        get { return dictionaryFindItem(nameField)?.uint16 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> UInt32? {
        get { return dictionaryFindItem(NameField(name))?.uint32 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> UInt32? {
        get { return dictionaryFindItem(nameField)?.uint32 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> UInt64? {
        get { return dictionaryFindItem(NameField(name))?.uint64 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> UInt64? {
        get { return dictionaryFindItem(nameField)?.uint64 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> Float32? {
        get { return dictionaryFindItem(NameField(name))?.float32 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> Float32? {
        get { return dictionaryFindItem(nameField)?.float32 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> Float64? {
        get { return dictionaryFindItem(NameField(name))?.float64 }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> Float64? {
        get { return dictionaryFindItem(nameField)?.float64 }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> String? {
        get { return dictionaryFindItem(NameField(name))?.string }
        set { updateItem(BRString(newValue), withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> String? {
        get { return dictionaryFindItem(nameField)?.string }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> BRString? {
        get { return dictionaryFindItem(NameField(name))?.brString }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> BRString? {
        get { return dictionaryFindItem(nameField)?.brString }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> BRCrcString? {
        get { return dictionaryFindItem(NameField(name))?.crcString }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> BRCrcString? {
        get { return dictionaryFindItem(nameField)?.crcString }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> Data? {
        get { return dictionaryFindItem(NameField(name))?.binary }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> Data? {
        get { return dictionaryFindItem(nameField)?.binary }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> BRCrcBinary? {
        get { return dictionaryFindItem(NameField(name))?.crcBinary }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> BRCrcBinary? {
        get { return dictionaryFindItem(nameField)?.crcBinary }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> UUID? {
        get { return dictionaryFindItem(NameField(name))?.uuid }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> UUID? {
        get { return dictionaryFindItem(nameField)?.uuid }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> BRColor? {
        get { return dictionaryFindItem(NameField(name))?.color }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> BRColor? {
        get { return dictionaryFindItem(nameField)?.color }
        set { updateItem(newValue, withNameField: nameField) }
    }

    subscript(name: String) -> BRFont? {
        get { return dictionaryFindItem(NameField(name))?.font }
        set { updateItem(newValue, withNameField: NameField(name)) }
    }
    
    subscript(nameField: NameField) -> BRFont? {
        get { return dictionaryFindItem(nameField)?.font }
        set { updateItem(newValue, withNameField: nameField) }
    }
}

/// Build an item with a Dictionary in it.
///
/// - Parameters:
///   - withNameField: The namefield for the item. Optional.
///   - endianness: The endianness to be used while creating the item.
///
/// - Returns: An ephemeral portal. Do not retain this portal.

internal func buildDictionaryItem(withNameField nameField: NameField?, valueByteCount: Int, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
    buildItem(ofType: .dictionary, withNameField: nameField, atPtr: ptr, endianness)
    ptr.setItemByteCount(to: UInt32(itemHeaderByteCount + (nameField?.byteCount ?? 0) + dictionaryItemBaseOffset + valueByteCount.roundUpToNearestMultipleOf8()), endianness)
    UInt32(0).copyBytes(to: ptr.itemValueFieldPtr.dictionaryItemCountPtr, endianness)
}

