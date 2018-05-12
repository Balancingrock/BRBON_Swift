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


// Internal helpers

extension Portal {
    
    
    internal var _sequenceItemCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: sequenceItemCountOffset) }
    
    internal var _sequenceItemBasePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: sequenceItemBaseOffset) }
    
    
    /// The number of items in the dictionary this portal refers to.
    
    internal var _sequenceItemCount: Int {
        get { return Int(UInt32(fromPtr: _sequenceItemCountPtr, endianness)) }
        set { UInt32(newValue).copyBytes(to: _sequenceItemCountPtr, endianness) }
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
    
    
    /// Execute the given closure for each element in the sequence or until false is returned.
    ///
    /// The closure is executed for the successive items in the sequence as long as 'false' is returned. The pointer into the closure is a pointer to the first byte of the itterated item. As soon as true is returned the itteration stops and the most recent itterated item pointer is returned as a portal.
    /*
    internal func _sequenceForEach(_ closure: (UnsafeMutableRawPointer) -> (Bool)) -> Portal? {
        
        guard _sequenceItemCount > 0 else { return nil }
        
        var ptr = _sequenceItemBasePtr
        
        for _ in 0 ... _sequenceItemCount {
            if closure(ptr) { return Portal(itemPtr: ptr, endianness: endianness) }
            ptr = ptr.advanced(by: Int(UInt32(fromPtr: ptr.advanced(by: itemByteCountOffset))))
        }
        
        return nil
    }*/
    
    
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
    
    internal func _sequenceRemoveItem(withName name: NameField?) -> Result {
        
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
    
    
    /// Removes an item from a sequence.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.
    
    internal func _sequenceRemoveItem(atIndex index: Int) -> Result {
        
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
    
    
    /// Adds a new value to the end of the sequence.
    ///
    /// - Parameters:
    ///   - value: The value to be added to the sequence.
    ///   - name: The name for the new value.
    ///
    /// - Returns: 'success' or an error indicator.
    
    internal func _sequenceAppendItem(_ value: Coder, withName name: NameField?) -> Result {
        
        let neededItemByteCount = (currentValueFieldByteCount - usedValueFieldByteCount) + itemMinimumByteCount + (name?.byteCount ?? 0) + value.minimumValueFieldByteCount
        let result = ensureValueFieldByteCount(of: neededItemByteCount)
        guard result == .success else { return result }
        
        let p = buildItem(withValue: value, atPtr: _sequenceAfterLastItemPtr, endianness)
        p._itemParentOffset = manager.bufferPtr.distance(to: itemPtr)
        
        _sequenceItemCount += 1
        
        return .success
    }

    
    /// Removes all items with the given name and appends a new item from the given value with the given name.
    ///
    /// - Parameters:
    ///   - value: The new value.
    ///   - name: The name of the item to update.
    ///
    /// - Returns: Either .success or an error indicator.
    
    internal func _sequenceUpdateItem(_ value: Coder, withName name: NameField?) -> Result {
        
        let result = _sequenceRemoveItem(withName: name)
        guard result == .success else { return result }
        
        return _sequenceAppendItem(value, withName: name)
    }
    
    
    /// Replaces the referenced item.
    ///
    /// The item referenced by this portal is replaced by the new value. The byte count will be preserved as is, or enlarged as necessary. If there is an existing name it will be preserved. If the new value is nil, the item will be converted into a null.
    
    internal func _sequenceReplaceItemValue(with value: Coder?) -> Result {
        
        if let value = value {
            
            
            // Make sure the item byte count is big enough
            
            let newItemByteCount = itemMinimumByteCount + value.minimumValueFieldByteCount
            
            if _itemByteCount < newItemByteCount {
                let result = increaseItemByteCount(to: newItemByteCount)
                guard result == .success else { return result }
            }
            
            
            // Create the new item, but remember the old size as it must be re-used
            
            let oldByteCount = _itemByteCount
            
            
            // Write the new value as an item
            
            let p = buildItem(withValue: value, atPtr: itemPtr, endianness)
            p._itemParentOffset = manager.bufferPtr.distance(to: itemPtr)
            p._itemByteCount = newItemByteCount
            
            
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
    
    internal func _sequenceInsertItem(_ value: Coder, atIndex index: Int, withName name: NameField? = nil) -> Result {
        
        
        // Ensure that there is enough space available
        
        let newItemByteCount = itemMinimumByteCount + (name?.byteCount ?? 0) + value.minimumValueFieldByteCount
        
        if currentValueFieldByteCount - usedValueFieldByteCount < newItemByteCount {
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
        
        let p = buildItem(withValue: value, withName: name, atPtr: srcPtr, endianness)
        p._itemParentOffset = manager.bufferPtr.distance(to: itemPtr)
        
        
        _sequenceItemCount += 1
        
        return .success
    }
}


// Public Sequence operations

extension Portal {
    
    public func update(_ value: Coder, forName name: String) -> Result {
        
        guard isValid else { return .portalInvalid }
        
        if isSequence { return _sequenceUpdateItem(value, withName: NameField(name)) }
        
        if isDictionary { return _dictionaryUpdateItem(value, withName: NameField(name)) }
        
        return .operationNotSupported
    }
    
    public func add(_ value: Coder, forName name: String? = nil) -> Result {
        
        guard isValid else { return .portalInvalid }
        
        if isSequence { return _sequenceAppendItem(value, withName: NameField(name)) }
        
        if isDictionary {
            guard let name = name else { return .missingName }
            return _dictionaryAddItem(value, withName: NameField(name))
        }
        
        return .operationNotSupported
    }
    
    
    /// Appends a new value to an array or sequence.
    ///
    /// - Note: Only for array and sequence items.
    ///
    /// - Parameters:
    ///   - value: The value to be added.
    ///   - forName: An optional name, only used when the target is a sequence. Ignored for array's.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func append(_ value: Coder, forName name: String? = nil) -> Result {
        
        
        // Portal must be valid
        
        guard isValid else { return .portalInvalid }
        
        
        // Implement for array's
        
        if isArray {
            guard _arrayElementType == value.itemType else { return .typeConflict }
            return append(value)
        }
        
        
        // Implement for sequence's
        
        if isSequence {
            return _sequenceAppendItem(value, withName: NameField(name))
        }
        
        
        // Not supported for other item types.
        
        return .operationNotSupported
    }
}


/// Build an item with a Sequence in it.
///
/// - Parameters:
///   - withName: The namefield for the item. Optional.
///   - endianness: The endianness to be used while creating the item.
///
/// - Returns: An ephemeral portal. Do not retain this portal.

internal func buildSequenceItem(withName name: NameField?, valueByteCount: Int, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Portal {
    let p = buildItem(ofType: .sequence, withName: name, atPtr: ptr, endianness)
    p._itemByteCount += sequenceItemBaseOffset + valueByteCount.roundUpToNearestMultipleOf8()
    p._sequenceItemCount = 0
    return p
}




