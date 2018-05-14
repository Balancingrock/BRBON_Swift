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
    
    internal func _dictionaryRemoveItem(withName name: NameField?) -> Result {
        
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
    
    internal func _dictionaryUpdateItem(_ value: Coder, withName name: NameField?) -> Result {
        
        guard let item = findPortalForItem(withName: name) else {
            return _dictionaryAddItem(value, withName: name)
        }

        
        // Update
        
        if value.itemType.usesSmallValue {
            value.copyBytes(to: item.itemSmallValuePtr, endianness)
        } else {
            let result = item.ensureValueFieldByteCount(of: value.valueByteCount.roundUpToNearestMultipleOf8())
            guard result == .success else { return result }
            value.copyBytes(to: item.valueFieldPtr, endianness)
            item._itemByteCount = itemMinimumByteCount + (name?.byteCount ?? 0) + value.valueByteCount.roundUpToNearestMultipleOf8()
        }
                
        return .success
    }
    
    internal func _dictionaryAddItem(_ value: Coder, withName name: NameField?) -> Result {
        
        guard let name = name else { return .missingName }
        
        let neededValueFieldByteCount = itemMinimumByteCount + name.byteCount + (value.itemType.usesSmallValue ? 0 : value.valueByteCount.roundUpToNearestMultipleOf8())
        
        let result = ensureValueFieldByteCount(of: usedValueFieldByteCount + neededValueFieldByteCount)
        guard result == .success else { return result }
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
        
        let p = buildItem(withValue: value, atPtr: _dictionaryAfterLastItemPtr, endianness)
        p._itemParentOffset = pOffset

        _dictionaryItemCount += 1
        
        return .success
    }
}


/// Build an item with a Dictionary in it.
///
/// - Parameters:
///   - withName: The namefield for the item. Optional.
///   - endianness: The endianness to be used while creating the item.
///
/// - Returns: An ephemeral portal. Do not retain this portal.

internal func buildDictionaryItem(withName name: NameField?, valueByteCount: Int, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Portal {
    let p = buildItem(ofType: .dictionary, withName: name, atPtr: ptr, endianness)
    p._itemByteCount += dictionaryItemBaseOffset + valueByteCount.roundUpToNearestMultipleOf8()
    p._dictionaryItemCount = 0
    return p
}
