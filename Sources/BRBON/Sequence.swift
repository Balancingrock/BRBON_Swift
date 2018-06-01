// =====================================================================================================================
//
//  File:       Sequence.swift
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


// Type offsets

internal let sequenceReservedOffset = 0
internal let sequenceItemCountOffset = sequenceReservedOffset + 4
internal let sequenceItemBaseOffset = sequenceItemCountOffset + 4


fileprivate extension UnsafeMutableRawPointer {
    
    fileprivate var sequenceItemCountPtr: UnsafeMutableRawPointer { return self.advanced(by: sequenceItemCountOffset) }
    
    fileprivate var sequenceItemBasePtr: UnsafeMutableRawPointer { return self.advanced(by: sequenceItemBaseOffset) }

    fileprivate func sequenceItemCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return sequenceItemCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return sequenceItemCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    fileprivate func setSequenceItemCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            sequenceItemCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            sequenceItemCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
}


// Item access

extension Portal {
    
    
    /// The number of items in the dictionary this portal refers to.
    
    internal var _sequenceItemCount: Int {
        get { return Int(_valuePtr.sequenceItemCount(endianness)) }
        set { _valuePtr.setSequenceItemCount(to: UInt32(newValue), endianness) }
    }
    
    
    /// The total area used in the value field.
    
    internal var _sequenceValueFieldUsedByteCount: Int {
        var seqItemPtr = itemPtr.itemValueFieldPtr.sequenceItemBasePtr
        for _ in 0 ..< _sequenceItemCount {
            seqItemPtr = seqItemPtr.nextItemPtr(endianness)
        }
        return _itemValueFieldPtr.distance(to: seqItemPtr)
    }
    
    
    /// Points to the first byte after the items in the referenced sequence item.
    ///
    /// This operation avoids the use of active portals. It is implemented by pointer manipulations.
    ///
    /// - Returns: A pointer to the first unused byte in the value field.
    
    internal var _sequenceAfterLastItemPtr: UnsafeMutableRawPointer {
        var ptr = itemPtr.itemValueFieldPtr.sequenceItemBasePtr
        var itterations = _sequenceItemCount
        while itterations > 0 {
            ptr = ptr.nextItemPtr(endianness)
            itterations -= 1
        }
        return ptr
    }
    
    
    /// Returns an active portal for the item at the specified index.
    ///
    /// - Note: The index must be valid (Range: 0 ..< count).
    ///
    /// - Parameter at: The index of the requested item.
    ///
    /// - Returns an active portal that refers to the requested item.
    
    internal func _sequencePortalForItem(at index: Int) -> Portal {
        
        var ptr = itemPtr.itemValueFieldPtr.sequenceItemBasePtr
        var c = 0
        while c < index {
            ptr = ptr.nextItemPtr(endianness)
            c += 1
        }
        return manager.getActivePortal(for: ptr)
    }
    
    
    /// Removes an item from a sequence.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.
    
    internal func _sequenceRemoveItem(atIndex index: Int) -> Result {
        
        let itm = _sequencePortalForItem(at: index)
        let aliPtr = _sequenceAfterLastItemPtr
        
        let srcPtr = itm.itemPtr.nextItemPtr(endianness)
        let dstPtr = itm.itemPtr
        let len = srcPtr.distance(to: aliPtr)
        
        manager.removeActivePortal(itm)
        
        if len > 0 {
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        _sequenceItemCount -= 1
        
        return .success
    }
    
    
    /// Adds a new value to the end of the sequence.
    ///
    /// - Parameters:
    ///   - value: The value to be added to the sequence.
    ///   - withNameField: The name field for the new value.
    ///
    /// - Returns: 'success' or an error indicator.
    /*
    internal func _sequenceAppendItem(_ value: Coder, withNameField nameField: NameField?) -> Result {
        
        let neededItemByteCount = _sequenceValueFieldUsedByteCount + itemMinimumByteCount + (nameField?.byteCount ?? 0) + value.minimumValueFieldByteCount
        let result = ensureValueFieldByteCount(of: neededItemByteCount)
        guard result == .success else { return result }
        
        let p = buildItem(withValue: value, withNameField: nameField, atPtr: _sequenceAfterLastItemPtr, endianness)
        p._itemParentOffset = manager.bufferPtr.distance(to: itemPtr)
        
        _sequenceItemCount += 1
        
        return .success
    }*/
    
    
    /// Inserts a new element.
    ///
    /// - Parameters:
    ///   - value: The value to be inserted.
    ///   - atIndex: The index at which to insert the value.
    ///   - withNameField: The name field for the value.
    ///
    /// - Returns: 'success' or an error indicator.
    
    internal func _sequenceInsertItem(_ value: Coder, atIndex index: Int, withNameField nameField: NameField? = nil) -> Result {
        
        
        // Ensure that there is enough space available
        
        let newItemByteCount =  itemHeaderByteCount + (nameField?.byteCount ?? 0) + value.minimumValueFieldByteCount
        
        if currentValueFieldByteCount - usedValueFieldByteCount < newItemByteCount {
            let result = increaseItemByteCount(to: itemHeaderByteCount + usedValueFieldByteCount + newItemByteCount)
            guard result == .success else { return result }
        }
        
        
        // Copy the existing items upward
        
        let itm = _sequencePortalForItem(at: index)
        
        let dstPtr = itm.itemPtr.advanced(by: newItemByteCount)
        let srcPtr = itm.itemPtr
        let length = itm.itemPtr.distance(to: _sequenceAfterLastItemPtr)
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: length, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        
        // Zero the new space
        
        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(srcPtr, 0, newItemByteCount) }
        
        
        // Insert the new element
        
        buildItem(withValue: value, withNameField: nameField, atPtr: srcPtr, endianness)
        srcPtr.setItemParentOffset(to: UInt32(manager.bufferPtr.distance(to: itemPtr)), endianness)
        
        
        _sequenceItemCount += 1
        
        return .success
    }
    
    
    /// Inserts a new element.
    ///
    /// - Parameters:
    ///   - value: The value to be inserted.
    ///   - atIndex: The index at which to insert the value.
    ///   - withNameField: The name field for the value.
    ///
    /// - Returns: 'success' or an error indicator.
    
    internal func _sequenceInsertItem(_ value: ItemManager, atIndex index: Int, withNameField nameField: NameField? = nil) -> Result {
        
        
        // Ensure that there is enough space available
        
        let newItemByteCount = value.root._itemByteCount
        
        if currentValueFieldByteCount - usedValueFieldByteCount < newItemByteCount {
            let result = increaseItemByteCount(to: itemHeaderByteCount + usedValueFieldByteCount + newItemByteCount)
            guard result == .success else { return result }
        }
        
        
        // Copy the existing items upward
        
        let itm = _sequencePortalForItem(at: index)
        
        let dstPtr = itm.itemPtr.advanced(by: newItemByteCount)
        let srcPtr = itm.itemPtr
        let length = itm.itemPtr.distance(to: _sequenceAfterLastItemPtr)
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: length, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        
        // Zero the new space
        
        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(srcPtr, 0, newItemByteCount) }
        
        
        // Insert the new element
        
        manager.moveBlock(to: srcPtr, from: value.bufferPtr, moveCount: value.root._itemByteCount, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)

        UInt32(manager.bufferPtr.distance(to: itemPtr)).copyBytes(to: srcPtr.advanced(by: itemParentOffsetOffset), endianness)
        
        
        _sequenceItemCount += 1
        
        return .success
    }

    internal func _sequenceEnsureDataStorage(of bytes: Int) -> Result {
        let necessaryValueFieldByteCount = sequenceItemBaseOffset + bytes
        return _sequenceEnsureValueFieldByteCount(of: necessaryValueFieldByteCount)
    }
    
    internal func _sequenceEnsureValueFieldByteCount(of bytes: Int) -> Result {
        if bytes > currentValueFieldByteCount {
            let necessaryItemByteCount = itemHeaderByteCount + _itemNameFieldByteCount + bytes
            return increaseItemByteCount(to: necessaryItemByteCount)
        } else {
            return .success
        }
    }
    
    /// Updates an item in a sequence.
    ///
    /// - Parameters:
    ///   - value: The new value.
    ///   - name: The name of the item to update.
    ///
    /// - Returns: Either .success or an error indicator.
    
    internal func _sequenceUpdateItem(_ value: Coder, atIndex index: Int) -> Result {
        
        let item = _sequencePortalForItem(at: index)
        
        guard let it = item.itemType else { return .error(.illegalTypeFieldValue) }
        guard it == value.itemType else { return .error(.typeConflict) }
        
        return item._updateItemValue(value)
    }
    
    
    /// Updates an item in a sequence.
    ///
    /// - Parameters:
    ///   - value: The new value.
    ///   - name: The name of the item to update.
    ///
    /// - Returns: Either .success or an error indicator.
    
    internal func _sequenceUpdateItem(_ value: ItemManager, atIndex index: Int) -> Result {
        
        let item = _sequencePortalForItem(at: index)
        
        guard item.itemType! == value.root.itemType else { return .error(.typeConflict) }
        
        
        // Save important data for later
        
        let ptr = item.itemPtr
        let bc = item._itemByteCount
        let po = item._itemParentOffset
        
        
        // Ensure storage requirement is met
        
        if item._itemByteCount < value.root._itemByteCount {
            let result = item.increaseItemByteCount(to: value.root._itemByteCount)
            guard result == .success else { return result }
        }

        
        // Remove the portal
        
        manager.removeActivePortal(self)

        
        // Zero bytes - if necessary
        
        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(ptr, 0, bc) }
        
        
        // Move bytes into place
        
        manager.moveBlock(to: ptr, from: value.bufferPtr, moveCount: value.root._itemByteCount, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)
        
        
        // Restore original content
        
        UInt32(po).copyBytes(to: ptr.advanced(by: itemParentOffsetOffset), endianness)
        
        
        return .success
    }

    
    /// Replaces an item in a sequence.
    ///
    /// The item referenced by this portal is replaced by the new value. The byte count will be preserved as is, or enlarged as necessary. If there is an existing name it will be preserved.
    /*
    internal func _sequenceReplaceItem(_ value: Coder, atIndex index: Int) -> Result {
        
        let oldItem = _sequencePortalForItem(at: index)
        let oldNameField = oldItem.itemNameField
        
        
        // Make sure the item byte count is big enough
            
        let newItemByteCount = itemMinimumByteCount + (oldNameField?.byteCount ?? 0) + value.minimumValueFieldByteCount
        let oldItemByteCount = oldItem._itemByteCount
        
        if newItemByteCount > oldItemByteCount {
            let result = oldItem.increaseItemByteCount(to: newItemByteCount)
            guard result == .success else { return result }
        }

        
        // Clear the old item
        
        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(oldItem.itemPtr, 0, oldItemByteCount) }
        
        
        // Write the new value as an item
            
        let newItem = buildItem(withValue: value, withNameField: oldNameField, atPtr: oldItem.itemPtr, endianness)
        newItem._itemParentOffset = manager.bufferPtr.distance(to: itemPtr)
        newItem._itemByteCount = max(newItemByteCount, oldItemByteCount)
        
        
        // Remove the portal(s) related to the old content
        
        manager.removeActivePortals(atAndAbove: oldItem.itemPtr, below: oldItem.itemPtr.advanced(by: oldItemByteCount))
        
        return .success
    }*/
}


// Public Sequence operations

public extension Portal {
    
    
    /// Inserts an item into a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the location where to insert the new value.
    ///   - withValue: The value to insert.
    ///   - withNameField: An optional namefield specifying the name of the new item.
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func insertItem(atIndex index: Int, withValue value: Coder) -> Result {
        return insertItem(atIndex: index, withValue: value, withNameField: nil)
    }

    
    /// Inserts an item into a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the location where to insert the new value.
    ///   - withValue: The value to insert.
    ///   - withNameField: An optional namefield specifying the name of the new item.
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func insertItem(atIndex index: Int, withValue value: Coder, withName name: String) -> Result {
        guard let nameField = NameField(name) else { return .error(.nameFieldError) }
        return insertItem(atIndex: index, withValue: value, withNameField: nameField)
    }

    
    /// Inserts an item into a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the location where to insert the new value.
    ///   - withValue: The value to insert.
    ///   - withNameField: An optional namefield specifying the name of the new item.
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func insertItem(atIndex index: Int, withValue value: Coder, withNameField nameField: NameField?) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isSequence else { return .error(.operationNotSupported) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < count else { return .error(.indexAboveHigherBound) }

        return _sequenceInsertItem(value, atIndex: index, withNameField: nameField)
    }

    
    /// Inserts an item into a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the location where to insert the new value.
    ///   - withValue: The value to insert.
    ///   - withNameField: An optional namefield specifying the name of the new item.
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func insertItem(atIndex index: Int, withValue value: ItemManager) -> Result {
        return insertItem(atIndex: index, withValue: value, withNameField: nil)
    }
    
    
    /// Inserts an item into a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the location where to insert the new value.
    ///   - withValue: The value to insert.
    ///   - withNameField: An optional namefield specifying the name of the new item.
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func insertItem(atIndex index: Int, withValue value: ItemManager, withName name: String) -> Result {
        guard let nameField = NameField(name) else { return .error(.nameFieldError) }
        return insertItem(atIndex: index, withValue: value, withNameField: nameField)
    }
    
    
    /// Inserts an item into a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the location where to insert the new value.
    ///   - withValue: The value to insert.
    ///   - withNameField: An optional namefield specifying the name of the new item.
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func insertItem(atIndex index: Int, withValue value: ItemManager, withNameField nameField: NameField?) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isSequence else { return .error(.operationNotSupported) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < count else { return .error(.indexAboveHigherBound) }
        
        return _sequenceInsertItem(value, atIndex: index, withNameField: nameField)
    }

    
    /// Updates an item in a sequence.
    ///
    /// The type of the item cannot be changed, use 'replaceItem' to change the type as well as the item.
    ///
    /// - Note: Does not invalidate the portal of the item.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the item to update.
    ///   - withValue: The new value for the item. The type of the value and item must be the same. Use 'replaceItem' if the type of the item must be changed.
    ///
    /// - Returns: Either .success or an error indicator.

    @discardableResult
    public func updateItem(atIndex index: Int, withValue value: Coder) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isSequence else { return .error(.operationNotSupported) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < count else { return .error(.indexAboveHigherBound) }
        
        return _sequenceUpdateItem(value, atIndex: index)
    }
    
    
    /// Updates an item in a sequence with the contents of the ItemManager.
    ///
    /// - Note: Does not invalidate the portal of the item but will invalidate portals to any child items.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the item to update.
    ///   - withValue: The new value for the item. The type of the value and item must be the same. Use 'replaceItem' if the type of the item must be changed.
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func updateItem(atIndex index: Int, withValue value: ItemManager) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isSequence else { return .error(.operationNotSupported) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < count else { return .error(.indexAboveHigherBound) }
        
        return _sequenceUpdateItem(value, atIndex: index)
    }

    
    /// Replaces an item in a sequence. The entire item will be replaced, including name and options.
    ///
    /// - Note: Invalidates the portal of the replaced item and all child items.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the item to update.
    ///   - withValue: The new value for the item. The type of the value and item may be different.
    ///   - withNameField: The name field for the new item. (optional)
    ///
    /// - Returns: Either .success or an error indicator.

    @discardableResult
    public func replaceItem(atIndex index: Int, withValue value: Coder, withNameField nameField: NameField? = nil) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isSequence else { return .error(.operationNotSupported) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < count else { return .error(.indexAboveHigherBound) }
        
        let oldItem = _sequencePortalForItem(at: index)
        let oldNameField = oldItem.itemNameField
        
        
        // Make sure the item byte count is big enough
        
        let newItemByteCount = itemHeaderByteCount + (oldNameField?.byteCount ?? 0) + value.minimumValueFieldByteCount
        let oldItemByteCount = oldItem._itemByteCount
        
        if newItemByteCount > oldItemByteCount {
            let result = oldItem.increaseItemByteCount(to: newItemByteCount)
            guard result == .success else { return result }
        }
        
        
        // Remove the portal(s) related to the old content
        
        manager.removeActivePortals(atAndAbove: oldItem.itemPtr, below: oldItem.itemPtr.nextItemPtr(endianness))

        
        // Clear the old item
        
        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(oldItem.itemPtr, 0, oldItemByteCount) }
        
        
        // Write the new value as an item
        
        let ptr = oldItem.itemPtr
        buildItem(withValue: value, withNameField: oldNameField, atPtr: ptr, endianness)
        ptr.setItemParentOffset(to: UInt32(manager.bufferPtr.distance(to: itemPtr)), endianness)
        ptr.setItemByteCount(to: UInt32(max(newItemByteCount, oldItemByteCount)), endianness)
        
        
        return .success
    }

    
    /// Replaces an item in a sequence. The entire item will be replaced, the new item does not need to be of the same type as the old item.
    ///
    /// - Note: Invalidates the portal of the replaced item and all child items.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the item to update. Must be in range 0 ..< count.
    ///   - withValue: The item manager from which the data will be copied. The type of the value and item may be different.
    ///   - withNameField: The name field for the new item. (optional)
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func replaceItem(atIndex index: Int, withValue value: ItemManager, withNameField nameField: NameField? = nil) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isSequence else { return .error(.operationNotSupported) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < count else { return .error(.indexAboveHigherBound) }

        
        let oldItem = _sequencePortalForItem(at: index)
        
        
        // Make sure the item byte count is big enough
        
        let newItemByteCount = value.root._itemByteCount - value.root._itemNameFieldByteCount + max(value.root._itemNameFieldByteCount, (nameField?.byteCount ?? 0))
        let oldItemByteCount = oldItem._itemByteCount
        
        if newItemByteCount > oldItemByteCount {
            let result = oldItem.increaseItemByteCount(to: newItemByteCount)
            guard result == .success else { return result }
        }
        
        
        // Write the new value as an item
        
        manager.moveBlock(to: oldItem.itemPtr, from: value.bufferPtr, moveCount: value.root._itemByteCount, removeCount: oldItem._itemByteCount, updateMovedPortals: false, updateRemovedPortals: true)


        // Clear the old item
        
        if ItemManager.startWithZeroedBuffers {
            let zeroLength = oldItemByteCount - newItemByteCount
            if zeroLength > 0 {
                _ = Darwin.memset(oldItem.itemPtr.advanced(by: newItemByteCount), 0, zeroLength)
            }
        }
        
        
        // Restore offset
        
        let newItem = manager.getActivePortal(for: oldItem.itemPtr)
        newItem._itemParentOffset = manager.bufferPtr.distance(to: itemPtr)
        
        
        // Set name
        
        if let nameField = nameField { newItem.itemNameField = nameField }
        
        
        return .success
    }

    
    /// Removes an item from a sequence.
    ///
    /// - Note: Invalidates the portal of the removed item and all child items.
    ///
    /// - Parameters:
    ///   - atIndex: The index of the item to update.
    ///
    /// - Returns: Either .success or an error indicator.

    @discardableResult
    public func removeItem(atIndex index: Int) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isSequence else { return .error(.operationNotSupported) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < count else { return .error(.indexAboveHigherBound) }

        let itm = _sequencePortalForItem(at: index)
        let aliPtr = _sequenceAfterLastItemPtr
        
        let srcPtr = itm.itemPtr.nextItemPtr(endianness)
        let dstPtr = itm.itemPtr
        let len = srcPtr.distance(to: aliPtr)
        
        manager.removeActivePortal(itm)
        
        if len > 0 {
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        _sequenceItemCount -= 1
        
        return .success
    }
    
    
    /// Appends a new value to a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - value: The value to be added.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func appendItem(_ value: Coder) -> Result {
        return appendItem(value, withNameField: nil)
    }

    
    /// Appends a new value to a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - value: The value to be added.
    ///   - withName: An optional name.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func appendItem(_ value: Coder, withName name: String) -> Result {
        
        guard let nameField = NameField(name) else { return .error(.nameFieldError) }
        return appendItem(value, withNameField: nameField)
    }
    
    
    /// Appends a new value to a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - value: The value to be added.
    ///   - withName: An optional name.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func appendItem(_ value: Coder, withNameField nameField: NameField?) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isSequence else { return .error(.operationNotSupported) }
        
        let neededItemByteCount = _sequenceValueFieldUsedByteCount + itemHeaderByteCount + (nameField?.byteCount ?? 0) + value.minimumValueFieldByteCount
        let result = ensureValueFieldByteCount(of: neededItemByteCount)
        guard result == .success else { return result }
        
        let startPtr = _sequenceAfterLastItemPtr
        
        buildItem(withValue: value, withNameField: nameField, atPtr: startPtr, endianness)
        
        startPtr.setItemParentOffset(to: UInt32(manager.bufferPtr.distance(to: itemPtr)), endianness)
        
        _sequenceItemCount += 1
        
        return .success
    }
    
    
    /// Appends the contents of an item manager to a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - value: The item manager of which the content will be added.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func appendItem(_ value: ItemManager) -> Result {
        return appendItem(value, withNameField: nil)
    }
    
    
    /// Appends the contents of an item manager to a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - value: The item manager of which the content will be added.
    ///   - withName: An optional name.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func appendItem(_ value: ItemManager, withName name: String) -> Result {
        
        guard let nameField = NameField(name) else { return .error(.nameFieldError) }
        return appendItem(value, withNameField: nameField)
    }
    
    
    /// Appends the contents of an item manager to a sequence.
    ///
    /// - Note: Does not invalidate existing portals.
    ///
    /// - Parameters:
    ///   - value: The item manager of which the content will be added.
    ///   - withNameField: An optional name field.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func appendItem(_ value: ItemManager, withNameField nameField: NameField?) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isSequence else { return .error(.operationNotSupported) }
        
        let neededItemByteCount =  _sequenceValueFieldUsedByteCount + value.root._itemByteCount
        let result = ensureValueFieldByteCount(of: neededItemByteCount)
        guard result == .success else { return result }
        
        let dstPtr = _sequenceAfterLastItemPtr
        
        manager.moveBlock(to: dstPtr, from: value.bufferPtr, moveCount: value.root._itemByteCount, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)

        UInt32(manager.bufferPtr.distance(to: itemPtr)).copyBytes(to: dstPtr.advanced(by: itemParentOffsetOffset), endianness)
        
        if let nameField = nameField {
            let p = manager.getActivePortal(for: dstPtr)
            p.itemNameField = nameField
        }
        
        _sequenceItemCount += 1
        
        return .success
    }
}


/// Build an item with a Sequence in it.
///
/// - Parameters:
///   - withName: The namefield for the item. Optional.
///   - endianness: The endianness to be used while creating the item.

internal func buildSequenceItem(withNameField nameField: NameField?, valueByteCount: Int, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
    buildItem(ofType: .sequence, withNameField: nameField, atPtr: ptr, endianness)
    ptr.setItemByteCount(to: UInt32(ptr.itemHeaderAndNameByteCount + sequenceItemBaseOffset + valueByteCount.roundUpToNearestMultipleOf8()), endianness)
    ptr.itemValueFieldPtr.setSequenceItemCount(to: 0, endianness)
}




