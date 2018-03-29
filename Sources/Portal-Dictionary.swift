//
//  Portal-Dictionary.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 24/03/18.
//
//

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
        set { UInt32(newValue).storeValue(atPtr: _dictionaryItemCountPtr, endianness) }
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
    
    internal func _dictionaryRemoveValue(forName name: String) -> Result {
        
        guard let item = findPortalForItem(withName: name) else { return .itemNotFound }
        
        let afterLastItemPtr = _dictionaryAfterLastItemPtr
            
        // Last item does not need a block move
        if afterLastItemPtr == item.itemPtr.advanced(by: item._itemByteCount) {
                
            // Update the active portals list (remove deleted item)
            manager.removeActivePortal(item)
                
        } else {
                
            // Move the items after the found item over the found item
                
            let srcPtr = item.itemPtr.advanced(by: item._itemByteCount)
            let dstPtr = item.itemPtr
            let len = srcPtr.distance(to: afterLastItemPtr)
                
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: item._itemByteCount, updateMovedPortals: true, updateRemovedPortals: true)
        }
            
        _dictionaryItemCount -= 1
        
        return .success
    }

    
    /// Updating an item with a given name.
    ///
    /// - Parameters:
    ///   - value: The new value.
    ///   - name: The name of the item to update.
    ///
    /// - Returns: Either .success or an error indicator.
    
    internal func _dictionaryUpdateValue(_ value: Coder, forName name: String) -> Result {
        
        guard let nfd = NameField(name) else { return .illegalNameField }
        
        guard let item = findPortalForItem(with: nfd.crc, utf8ByteCode: nfd.data) else {
            return _dictionaryAddValue(value, name: nfd)
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
    
    internal func _dictionaryAddValue(_ value: Coder, name: NameField) -> Result {
        
        let neededItemByteCount = itemMinimumByteCount + _itemNameFieldByteCount + usedValueFieldByteCount + value.itemByteCount(name)
        
        if _itemByteCount < neededItemByteCount {
            let result = increaseItemByteCount(to: neededItemByteCount)
            guard result == .success else { return result }
        }
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
        value.storeAsItem(atPtr: _dictionaryAfterLastItemPtr, name: name, parentOffset: pOffset, endianness)
        
        _dictionaryItemCount += 1
        
        return .success
    }
}
