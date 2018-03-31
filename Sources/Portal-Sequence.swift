//
//  Portal-Sequence.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 24/03/18.
//
//

import Foundation
import BRUtils


internal let sequenceReservedOffset = 0
internal let sequenceItemCountOffset = sequenceReservedOffset + 4
internal let sequenceItemBaseOffset = sequenceItemCountOffset + 4


extension Portal {
    
    
    internal var _sequenceItemCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: sequenceItemCountOffset) }
    
    internal var _sequenceItemBasePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: sequenceItemBaseOffset) }
    
    
    /// The number of items in the dictionary this portal refers to.
    
    internal var _sequenceItemCount: Int {
        get { return Int(UInt32(fromPtr: _sequenceItemCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _sequenceItemCountPtr, endianness) }
    }
    
    
    /// The total area used in the value field.
    
    internal var _sequenceValueFieldUsedByteCount: Int {
        var seqItemPtr = _sequenceItemBasePtr
        for _ in 0 ..< _sequenceItemCount {
            seqItemPtr = seqItemPtr.advanced(by: Int(UInt32(fromPtr: seqItemPtr.advanced(by: itemByteCountOffset), endianness)))
        }
        return itemValueFieldPtr.distance(to: seqItemPtr)
    }
    
    
    /// Points to the first byte after the items in the referenced sequence item
    
    internal var _sequenceAfterLastItemPtr: UnsafeMutableRawPointer {
        var ptr = _sequenceItemBasePtr
        var remainingItemsToSkip = _sequenceItemCount
        while remainingItemsToSkip > 0 {
            ptr = ptr.advanced(by: Int(UInt32(fromPtr: ptr.advanced(by: itemByteCountOffset), endianness)))
            remainingItemsToSkip -= 1
        }
        return ptr
    }
    
    
    /// Returns the portal for the item at the specified index.
    
    internal func _sequencePortalForItem(at index: Int) -> Portal {
        
        var ptr = _sequenceItemBasePtr
        var c = 0
        while c < index {
            let bc = ptr.advanced(by: itemByteCountOffset).assumingMemoryBound(to: UInt32.self).pointee
            ptr = ptr.advanced(by: Int(bc))
            c += 1
        }
        return Portal(itemPtr: ptr, manager: manager, endianness: endianness)
    }
    
    
    /// Removes all the items with the given name from the sequence.
    ///
    /// - Parameter forName: The name of the item to remove.
    ///
    /// - Returns: 'success' or an error indicator (including 'itemNotFound').
    
    internal func _sequenceRemoveValue(forName name: String) -> Result {
        
        var item = findPortalForItem(withName: name)
        
        if item == nil { return .itemNotFound }
        
        while item != nil {
            
            let afterLastItemPtr = _sequenceAfterLastItemPtr
            
            // Last item does not need a block move
            if afterLastItemPtr == item!.itemPtr.advanced(by: item!._itemByteCount) {
                
                // Update the active portals list (remove deleted item)
                manager.removeActivePortal(item!)
                
            } else {
                
                // Move the items after the found item over the found item
                
                let srcPtr = item!.itemPtr.advanced(by: item!._itemByteCount)
                let dstPtr = item!.itemPtr
                let len = srcPtr.distance(to: afterLastItemPtr)
                
                manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: item!._itemByteCount, updateMovedPortals: true, updateRemovedPortals: true)
            }
            
            _sequenceItemCount -= 1
            
            item = findPortalForItem(withName: name)
        }
        
        return .success
    }
    
    
    /// Updating an item with a given name.
    ///
    /// - Parameters:
    ///   - value: The new value.
    ///   - name: The name of the item to update.
    ///
    /// - Returns: Either .success or an error indicator.
    
    internal func _sequenceUpdateValue(_ value: Coder, forName name: String) -> Result {
        
        guard let nfd = NameField(name) else { return .illegalNameField }
        
        guard let item = findPortalForItem(with: nfd.crc, utf8ByteCode: nfd.data) else {
            return _sequenceAppend(value, name: nfd)
        }
        
        
        // Ensure enough space is available
        
        let neededItemByteCount = value.itemByteCount(nfd)
        
        if item._itemByteCount < neededItemByteCount {
            let result = item.increaseItemByteCount(to: neededItemByteCount)
            guard result == .success else { return result }
        }
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
        value.storeAsItem(atPtr: item.itemPtr, name: nfd, parentOffset: pOffset, endianness)
        
        return .success
    }
    
    
    /// Adds a new value to the end of the sequence.
    ///
    /// - Parameters:
    ///   - value: The value to be added to the sequence.
    ///   - name: The name for the new value.
    ///
    /// - Returns: 'success' or an error indicator.

    internal func _sequenceAppend(_ value: Coder, name: NameField?) -> Result {
        
        let neededItemByteCount = itemMinimumByteCount + _itemNameFieldByteCount + usedValueFieldByteCount + value.itemByteCount(name)
        
        if _itemByteCount < neededItemByteCount {
            let result = increaseItemByteCount(to: neededItemByteCount)
            guard result == .success else { return result }
        }
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
        value.storeAsItem(atPtr: _sequenceAfterLastItemPtr, name: name, parentOffset: pOffset, endianness)
        
        _sequenceItemCount += 1
        
        return .success
    }
    

    /// Removes an item from a sequence.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.
    
    internal func _sequenceRemove(at index: Int) -> Result {
        
        let itm = _sequencePortalForItem(at: index)
        let aliPtr = _sequenceAfterLastItemPtr
        
        let srcPtr = itm.itemPtr.advanced(by: itm._itemByteCount)
        let dstPtr = itm.itemPtr
        let len = srcPtr.distance(to: aliPtr)
        
        manager.removeActivePortal(itm)
        
        if len > 0 {
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        _sequenceItemCount -= 1
        
        return .success
    }
    
    
    /// Replaces the referenced item.
    ///
    /// The item referenced byt his portal is replaced by the new value. The byte count will be preserved as is, or enlarged as necessary. If there is an existing name it will be preserved. If the new value is nil, the item will be converted into a null.
    
    internal func _sequenceReplace(with value: Coder?) -> Result {
        
        if let value = value {
            
            
            // Make sure the item byte count is big enough
            
            let necessaryItemByteCount = value.itemByteCount(nameField)
            
            if _itemByteCount < necessaryItemByteCount {
                let result = increaseItemByteCount(to: necessaryItemByteCount)
                guard result == .success else { return result }
            }
            
            
            // Create the new item, but remember the old size as it must be re-used
            
            let oldByteCount = _itemByteCount
            
            
            // Write the new value as an item
            
            let offset = manager.bufferPtr.distance(to: itemPtr)
            value.storeAsItem(atPtr: itemPtr, name: nameField, parentOffset: offset, initialValueByteCount: nil, endianness)
            
            
            // Restore the old byte count
            
            _itemByteCount = oldByteCount
            
            
            return .success
            
        } else {
            
            itemType = .null
            return .success
        }
    }
    
    
    /// Inserts a new element.
    ///
    /// - Parameters:
    ///   - value: The value to be inserted.
    ///   - atIndex: The index at which to insert the value.
    ///   - withName: A name for the value.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    internal func _sequenceInsert(_ value: Coder, atIndex index: Int, withName name: String? = nil) -> Result {
        
        
        // Ensure that there is enough space available
        
        let nfd: NameField? = {
            guard let name = name else { return nil }
            return NameField(name)
        }()
        
        let newItemByteCount = value.itemByteCount(nfd)
        
        if actualValueFieldByteCount - usedValueFieldByteCount < newItemByteCount {
            let result = increaseItemByteCount(to: itemMinimumByteCount + usedValueFieldByteCount + newItemByteCount)
            guard result == .success else { return result }
        }
        
        
        // Copy the existing items upward
        
        let itm = _sequencePortalForItem(at: index)
        
        let dstPtr = itm.itemPtr.advanced(by: newItemByteCount)
        let srcPtr = itm.itemPtr
        let length = newItemByteCount
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: length, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        
        // Insert the new element
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
        value.storeAsItem(atPtr: srcPtr, name: nfd, parentOffset: pOffset, endianness)
        
        
        _sequenceItemCount += 1
        
        return .success
    }
}