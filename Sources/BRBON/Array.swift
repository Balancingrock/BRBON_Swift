// =====================================================================================================================
//
//  File:       Array.swift
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
// 0.7.0 - Code reorganization and API simplification
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


internal let arrayReservedOffset = 0
internal let arrayElementTypeOffset = arrayReservedOffset + 4
internal let arrayElementCountOffset = arrayElementTypeOffset + 4
internal let arrayElementByteCountOffset = arrayElementCountOffset + 4
internal let arrayElementBaseOffset = arrayElementByteCountOffset + 4

//internal let arrayMinimumItemByteCount = itemMinimumByteCount + arrayElementBaseOffset


extension Portal {
    

    internal var _arrayElementTypePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: arrayElementTypeOffset) }

    internal var _arrayElementCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: arrayElementCountOffset) }
    
    internal var _arrayElementByteCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: arrayElementByteCountOffset) }
    
    internal var _arrayElementBasePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: arrayElementBaseOffset) }
    
    
    /// The type of the element stored in the array this portal refers to.
    
    internal var _arrayElementType: ItemType? {
        get { return ItemType.readValue(atPtr: _arrayElementTypePtr) }
        set { newValue?.copyBytes(to: _arrayElementTypePtr) }
    }
    

    /// The number of elements in the array this portal refers to.
    
    internal var _arrayElementCount: Int {
        get { return Int(UInt32(fromPtr: _arrayElementCountPtr, endianness)) }
        set { UInt32(newValue).copyBytes(to: _arrayElementCountPtr, endianness) }
    }
    
    
    /// The byte count of the elements in the array this portal refers to.
    
    internal var _arrayElementByteCount: Int {
        get { return Int(UInt32(fromPtr: _arrayElementByteCountPtr, endianness)) }
        set { UInt32(newValue).copyBytes(to: _arrayElementByteCountPtr, endianness) }
    }
    
    
    /// The element pointer for a given index.
    ///
    /// - Note: No range check performed.
    
    internal func _arrayElementPtr(for index: Int) -> UnsafeMutableRawPointer {
        let elementOffset = index * _arrayElementByteCount
        return _arrayElementBasePtr.advanced(by: elementOffset)
    }

    
    /// The total area used in the value field.
    
    internal var _arrayValueFieldUsedByteCount: Int {
        return arrayElementBaseOffset + _arrayElementCount * _arrayElementByteCount
    }
    
    
    /// Makes sure the element byte count is sufficient.
    ///
    /// - Parameter for: The Coder value that must be accomodated.
    ///
    /// - Returns: Success if the value can be allocated, an error identifier when not.
    
    internal func _arrayEnsureElementByteCount(for value: Coder) -> Result {
        
        
        // Check to see if the element byte count of the array must be increased.
        
        let necessaryElementByteCount: Int = value.itemType.isContainer ? (itemMinimumByteCount + value.valueByteCount) : value.valueByteCount
        
        if necessaryElementByteCount > _arrayElementByteCount {
            
            
            // This is the byte count that self has to become in order to accomodate the new value
            
            let necessaryItemByteCount = _itemByteCount - currentValueFieldByteCount + arrayElementBaseOffset + ((_arrayElementCount + 1) * necessaryElementByteCount)
            
            
            if necessaryItemByteCount > _itemByteCount {
                // It is necessary to increase the bytecount for the array item itself
                let result = increaseItemByteCount(to: necessaryItemByteCount.roundUpToNearestMultipleOf8())
                guard result == .success else { return result }
            }
            
            
            // Increase the byte count of the elements by shifting them up inside the enlarged array.
            
            _arrayIncreaseElementByteCount(to: necessaryElementByteCount)
        }
        
        return .success
    }
    
    internal func _arrayEnsureElementByteCount(of bytes: Int) -> Result {
        
        
        // Check to see if the element byte count of the array must be increased.
        
        if bytes > _arrayElementByteCount {
            
            
            // This is the byte count that self has to become in order to accomodate the new value
            
            let necessaryItemByteCount = _itemByteCount - currentValueFieldByteCount + arrayElementBaseOffset + ((_arrayElementCount + 1) * bytes)
            
            
            if necessaryItemByteCount > _itemByteCount {
                // It is necessary to increase the bytecount for the array item itself
                let result = increaseItemByteCount(to: necessaryItemByteCount.roundUpToNearestMultipleOf8())
                guard result == .success else { return result }
            }
            
            
            // Increase the byte count of the elements by shifting them up inside the enlarged array.
            
            _arrayIncreaseElementByteCount(to: bytes)
        }
        
        return .success
    }

    
    internal func _arrayEnsureValueFieldByteCount(of bytes: Int) -> Result {
        
        
        // Check to see if the element byte count of the array must be increased.
        
        let necessaryElementByteCount: Int = _arrayElementType!.isContainer ? itemMinimumByteCount + bytes : bytes
        
        if necessaryElementByteCount > _arrayElementByteCount {
            
            
            // This is the byte count that self has to become in order to accomodate the new value
            
            let necessaryItemByteCount = _itemByteCount - currentValueFieldByteCount + arrayElementBaseOffset + ((_arrayElementCount + 1) * necessaryElementByteCount)
            
            
            if necessaryItemByteCount > _itemByteCount {
                // It is necessary to increase the bytecount for the array item itself
                let result = increaseItemByteCount(to: necessaryItemByteCount.roundUpToNearestMultipleOf8())
                guard result == .success else { return result }
            }
            
            
            // Increase the byte count of the elements by shifting them up inside the enlarged array.
            
            _arrayIncreaseElementByteCount(to: necessaryElementByteCount)
        }
        
        return .success
    }

    
    /// Increases the byte count of the array element.
    
    internal func _arrayIncreaseElementByteCount(to newByteCount: Int) {
        
        let elementBasePtr = _arrayElementBasePtr
        let oldByteCount = _arrayElementByteCount
        
        for index in (0 ..< _arrayElementCount).reversed() {
            let dstPtr = elementBasePtr.advanced(by: index * newByteCount)
            let srcPtr = elementBasePtr.advanced(by: index * oldByteCount)
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: oldByteCount, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        _arrayElementByteCount = newByteCount
    }
    

    /// Get an element from an array or an item from a sequence as a portal.
    ///
    /// - Parameter index: The index of the element to retrieve.
    /// - Returns: A portal for the requested element, or the null-portal if the element does not exist
    
    internal func _arrayPortalForElement(at index: Int) -> Portal {
        
        if _arrayElementType!.isContainer {
            return Portal(itemPtr: _arrayElementPtr(for: index), index: nil, manager: manager, endianness: endianness)
        } else {
            return Portal(itemPtr: itemPtr, index: index, manager: manager, endianness: endianness)
        }
    }

    
    /// Removes an item from an array.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.
    
    internal func _arrayRemove(at index: Int) -> Result {
        
        
        // Remove the active portals for the items inside the element to be removed, but not the element itself.
        
        let eptr = _arrayElementPtr(for: index)
        manager.removeActivePortals(atAndAbove: eptr.advanced(by: 1), below: eptr.advanced(by: _arrayElementByteCount))
        
        
        // Shift the remaining elements into their new place
        
        let srcPtr = _arrayElementPtr(for: index + 1)
        let dstPtr = _arrayElementPtr(for: index)
        let len = (_arrayElementCount - 1 - index) * _arrayElementByteCount
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        
        // The last index portal (if present) must be removed
        
        let lptr = _arrayElementPtr(for: _arrayElementCount - 1)
        manager.removeActivePortals(atAndAbove: lptr, below: lptr.advanced(by: 1))
        
        
        // Decrease the number of elements
        
        _arrayElementCount -= 1
        
        
        return .success
    }

    
    /// Inserts a new element.
    ///
    /// - Parameters:
    ///   - value: The value to be inserted.
    ///   - atIndex: The index at which to insert the value.
    ///
    /// - Returns: 'success' or an error indicator.
    
    internal func _arrayInsert(_ value: Coder, atIndex index: Int) -> Result {
        
        
        // Ensure that the element byte count is sufficient
        
        var result = _arrayEnsureElementByteCount(for: value)
        guard result == .success else { return result }
        
        
        // Ensure that the item storage capacity is sufficient
        
        let newCount = _arrayElementCount + 1
        let neccesaryValueByteCount = arrayElementBaseOffset + _arrayElementByteCount * newCount
        result = ensureValueFieldByteCount(of: neccesaryValueByteCount)
        guard result == .success else { return result }
        
        
        // Copy the existing elements upward
        
        let dstPtr = _arrayElementPtr(for: index + 1)
        let srcPtr = _arrayElementPtr(for: index)
        let length = (_arrayElementCount - index) * _arrayElementByteCount
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: length, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)
        
        
        // Insert the new element
        
        value.copyBytes(to: _arrayElementPtr(for: index), endianness)
        
        
        // Increase the number of elements
        
        _arrayElementCount += 1
        
        
        return .success
    }
}


extension Portal {
    
    internal func appendClosure(for type: ItemType, with bytes: Int, assignment: () -> Void) -> Result {
        
        guard isValid else { return .portalInvalid }
        guard isArray else { return .operationNotSupported }
        guard _arrayElementType == type else { return .typeConflict }
        
        
        // Ensure that the element byte count is sufficient
        
        let result = _arrayEnsureElementByteCount(of: bytes)
        guard result == .success else { return result }
        
        
        // Ensure that the new value can be added
        
        if currentValueFieldByteCount - _arrayValueFieldUsedByteCount < bytes {
            let result = increaseItemByteCount(to: _itemByteCount + arrayElementBaseOffset + ((_arrayElementCount + 1) * bytes).roundUpToNearestMultipleOf8())
            guard result == .success else { return result }
        }
        
        
        // The new value can be added
        
        assignment()
        
        
        // Increase child counter
        
        _arrayElementCount += 1
        
        return .success
    }
    
    
    /// Add a Bool to an Array.
    ///
    /// - Returns: .success or one of .portalInvalid, .operationNotSupported, .typeConflict
    
    @discardableResult
    public func append(_ value: Coder) -> Result {
        return appendClosure(for: value.itemType, with: value.valueByteCount) { value.copyBytes(to: _arrayElementPtr(for: _arrayElementCount), endianness) }
    }
}


// Adding containers to an Array

extension Portal {

    @discardableResult
    public func append(_ itemManager: ItemManager) -> Result {
        
        guard isValid else { return .portalInvalid }
        guard isArray else { return .operationNotSupported }
        guard _arrayElementType?.isContainer ?? false else { return .typeConflict }
        
        
        // Ensure that the maximum element size can be accomodated
        
        let result = _arrayEnsureElementByteCount(of: itemManager.count)
        guard result == .success else { return result }
        
        
        // Ensure that all elements (including the new ones) can be accomodated
        
        let necessaryValueByteCountIncrease = _arrayElementByteCount
        if currentValueFieldByteCount - _arrayValueFieldUsedByteCount < necessaryValueByteCountIncrease {
            let result = increaseItemByteCount(to: _itemByteCount + necessaryValueByteCountIncrease)
            guard result == .success else { return result }
        }
        
        
        // Add the new item
        
        _ = Darwin.memcpy(_arrayElementPtr(for: _arrayElementCount), itemManager.bufferPtr, itemManager.count)
        let parentOffset = manager!.bufferPtr.distance(to: itemPtr)
        UInt32(parentOffset).copyBytes(to: _arrayElementPtr(for: _arrayElementCount).advanced(by: itemParentOffsetOffset), endianness)

        _arrayElementCount += 1
        
        return .success
    }

    @discardableResult
    public func append(_ arr: Array<ItemManager>) -> Result {
        
        guard isValid else { return .portalInvalid }
        guard isArray else { return .operationNotSupported }
        guard _arrayElementType?.isContainer ?? false else { return .typeConflict }

        
        // Determine the largest new byte count of the elements
        
        var maxByteCount: Int = 0
        arr.forEach({ maxByteCount = max($0.count, maxByteCount) })
        
        
        // Ensure that the maximum element size can be accomodated
        
        let result = _arrayEnsureElementByteCount(of: maxByteCount)
        guard result == .success else { return result }
        
        
        // Ensure that all elements (including the new ones) can be accomodated
        
        let necessaryValueByteCountIncrease = _arrayElementByteCount * arr.count
        if currentValueFieldByteCount - _arrayValueFieldUsedByteCount < necessaryValueByteCountIncrease {
            let result = increaseItemByteCount(to: _itemByteCount + necessaryValueByteCountIncrease)
            guard result == .success else { return result }
        }
        
        
        // Add the new items
        
        let parentOffset = manager!.bufferPtr.distance(to: itemPtr)
        arr.forEach() {
            let srcPtr = $0.bufferPtr
            let dstPtr = _arrayElementPtr(for: _arrayElementCount)
            let length = $0.count
            _ = Darwin.memcpy(dstPtr, srcPtr, length)
            UInt32(parentOffset).copyBytes(to: dstPtr.advanced(by: itemParentOffsetOffset), endianness)
            _arrayElementCount += 1
        }
        
        return .success
    }
}


/// Build an item with a Array in it.
///
/// - Parameters:
///   - withName: The namefield for the item. Optional.
///   - elementType: The type of elements in the array.
///   - elementByteCount: The number of bytes used for each element in the array. It must be ensured that the byte count is large enough for the element type!
///   - elementCount:
///   - endianness: The endianness to be used while creating the item.
///
/// - Returns: An ephemeral portal. Do not retain this portal.

internal func buildArrayItem(withName name: NameField?, elementType: ItemType, elementByteCount: Int, elementCount: Int, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Portal {
    let p = buildItem(ofType: .array, withName: name, atPtr: ptr, endianness)
    p._itemByteCount += arrayElementBaseOffset + (elementCount * elementByteCount).roundUpToNearestMultipleOf8()
    p._arrayElementType = elementType
    p._arrayElementByteCount = elementByteCount
    p._arrayElementCount = 0
    return p
}








