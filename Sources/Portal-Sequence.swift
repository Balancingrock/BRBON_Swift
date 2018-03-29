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
            return _sequenceAddValue(value, name: nfd)
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
    
    internal func _sequenceAddValue(_ value: Coder, name: NameField) -> Result {
        
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
}
