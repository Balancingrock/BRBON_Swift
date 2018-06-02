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
// 0.7.0 - Code restructuring & simplification
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================
//
// Definition: An array is an item that contains a number of elements. All elements are of the same type and occupy the
// same number of bytes in memory.
//
// Purpose: An array is used to store values as compact as possible will still offering high speeds access across a
// large number of elements.
//
// Portals: Portals for non-container element values (i.e. confirm to the Coder protocol) are index based, not item
// based. I.e. once created will keep referring to the same index, regardless of the insertion or removal of elements.
// It is invalidated if the index position itself no longer exists. (Or the array item itself is invalidated)
// Portals for element values that are Items are item-based, i.e. they will change when elements are removed or
// inserted. They are invalidated when the element itself is removed.
//
// =====================================================================================================================


import Foundation
import BRUtils


internal let arrayReservedOffset = 0
internal let arrayElementTypeOffset = arrayReservedOffset + 4
internal let arrayElementCountOffset = arrayElementTypeOffset + 4
internal let arrayElementByteCountOffset = arrayElementCountOffset + 4
internal let arrayElementBaseOffset = arrayElementByteCountOffset + 4


// Pointer manipulations

internal extension UnsafeMutableRawPointer {
    
    
    /// A pointer to the element type assuming self points to the first byte of the value field.
    
    fileprivate var arrayElementTypePtr: UnsafeMutableRawPointer { return self.advanced(by: arrayElementTypeOffset) }
    

    /// A pointer to the element count assuming self points to the first byte of the value field.

    fileprivate var arrayElementCountPtr: UnsafeMutableRawPointer { return self.advanced(by: arrayElementCountOffset) }
    
    
    /// A pointer to the element byte count assuming self points to the first byte of the value field.

    fileprivate var arrayElementByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: arrayElementByteCountOffset) }
    
    
    /// A pointer to the first element assuming self points to the first byte of the value field.

    fileprivate var arrayElementBasePtr: UnsafeMutableRawPointer { return self.advanced(by: arrayElementBaseOffset) }
    
    
    /// The raw value of the element type assuming self points to the first byte of the value field.
    
    internal var arrayElementType: UInt8 {
        get { return arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { arrayElementTypePtr.storeBytes(of: newValue, as: UInt8.self) }
    }
    
    
    /// Returns the number of elements assuming self points to the first byte of the value field.
    
    fileprivate func arrayElementCount(_ endianness: Endianness) -> UInt32 {
        return UInt32(fromPtr: arrayElementCountPtr, endianness)
    }

    
    /// Set the number of elements assuming self points to the first byte of the value field.

    fileprivate func setArrayElementCount(to value: UInt32, _ endianness: Endianness) {
        value.copyBytes(to: arrayElementCountPtr, endianness)
    }
    
    
    /// Returns the element byte count assuming self points to the first byte of the value field.

    fileprivate func arrayElementByteCount(_ endianness: Endianness) -> UInt32 {
        return UInt32(fromPtr: arrayElementByteCountPtr, endianness)
    }

    
    /// Sets the element byte count assuming self points to the first byte of the value field.

    fileprivate func setArrayElementByteCount(to value: UInt32, _ endianness: Endianness) {
        value.copyBytes(to: arrayElementByteCountPtr, endianness)
    }
    
    
    /// Return the pointer to an array element
    
    internal func arrayElementPtr(for value: Int, _ endianness: Endianness) -> UnsafeMutableRawPointer {
        let bc = Int(arrayElementByteCount(endianness))
        return arrayElementBasePtr.advanced(by: value * bc)
    }
}


// Item access

extension Portal {

    
    /// The type of the element stored in the array this portal refers to.
    
    internal var _arrayElementType: ItemType? {
        get { return ItemType(rawValue: itemPtr.itemValueFieldPtr.arrayElementType) }
        set {
            var ptr = itemPtr.itemValueFieldPtr
            ptr.arrayElementType = newValue?.rawValue ?? 0 }
    }
    

    /// The number of elements in the array this portal refers to.
    
    internal var _arrayElementCount: Int {
        get { return Int(itemPtr.itemValueFieldPtr.arrayElementCount(endianness)) }
        set { itemPtr.itemValueFieldPtr.setArrayElementCount(to: UInt32(newValue), endianness) }
    }
    
    
    /// The byte count of the elements in the array this portal refers to.
    
    internal var _arrayElementByteCount: Int {
        get { return Int(itemPtr.itemValueFieldPtr.arrayElementByteCount(endianness)) }
        set { itemPtr.itemValueFieldPtr.setArrayElementByteCount(to: UInt32(newValue), endianness) }
    }

    
    /// The total area used in the value field.
    
    internal var _arrayValueFieldUsedByteCount: Int {
        return arrayElementBaseOffset + _arrayElementCount * _arrayElementByteCount
    }
}


// Helper functions

extension Portal {
    
    /// Makes sure the element byte count is sufficient.
    ///
    /// - Parameter for: The Coder value that must be accomodated.
    ///
    /// - Returns: Success if the value can be allocated, an error identifier when not.
    
    internal func _arrayEnsureElementByteCount(for value: Coder) -> Result {
        
        
        // Check to see if the element byte count of the array must be increased.

        let necessaryElementByteCount: Int
        if value.itemType.isContainer {
            necessaryElementByteCount = itemHeaderByteCount + value.minimumValueFieldByteCount
        } else if value.itemType.hasFlexibleLength {
            necessaryElementByteCount = value.valueByteCount.roundUpToNearestMultipleOf8()
        } else {
            necessaryElementByteCount = value.valueByteCount
        }
        
        return _arrayEnsureElementByteCount(of: necessaryElementByteCount)
    }
    
    internal func _arrayEnsureElementByteCount(of bytes: Int) -> Result {
        
        
        // Check to see if the element byte count of the array must be increased.
        
        if bytes > _arrayElementByteCount {
            
            
            // This is the byte count that self has to become in order to accomodate the new element bytecount
            
            let necessaryItemByteCount = _itemByteCount - currentValueFieldByteCount + arrayElementBaseOffset + (_arrayElementCount * bytes)
            
            
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
        
        let necessaryElementByteCount: Int = _arrayElementType!.isContainer ? itemHeaderByteCount + bytes : bytes
        
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
        
        let elementBasePtr = _itemValueFieldPtr.arrayElementBasePtr
        let oldByteCount = _arrayElementByteCount
        
        for index in (0 ..< _arrayElementCount).reversed() {
            
            let dstPtr = elementBasePtr.advanced(by: index * newByteCount)
            let srcPtr = elementBasePtr.advanced(by: index * oldByteCount)
            
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: oldByteCount, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
            
            if ItemManager.startWithZeroedBuffers {
                let startPtr = dstPtr.advanced(by: oldByteCount)
                let len = newByteCount - oldByteCount
                Darwin.memset(startPtr, 0, len)
            }
        }
        
        _arrayElementByteCount = newByteCount
    }
    

    /// Get an element from an array or an item from a sequence as a portal.
    ///
    /// - Parameter index: The index of the element to retrieve.
    /// - Returns: A portal for the requested element, or the null-portal if the element does not exist
    
    internal func _arrayPortalForElement(at index: Int) -> Portal {
        
        if _arrayElementType!.isContainer {
            return manager.getActivePortal(for: itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness), index: nil, column: nil)
        } else {
            return manager.getActivePortal(for: itemPtr, index: index, column: nil)
        }
    }

    
    /// Removes an item from an array.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.
    
    internal func _arrayRemove(at index: Int) -> Result {
        
        
        // Remove the active portals for the items inside the element to be removed.
        
        if _arrayElementType!.isContainer {
            let eptr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness)
            manager.removeActivePortals(atAndAbove: eptr, below: eptr.advanced(by: _arrayElementByteCount))
        }
        
        
        // Shift the remaining elements into their new place
        
        let srcPtr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: index + 1, endianness)
        let dstPtr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness)
        let len = (_arrayElementCount - 1 - index) * _arrayElementByteCount
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        if ItemManager.startWithZeroedBuffers {
            let ptr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: _arrayElementCount - 1, endianness)
            Darwin.memset(ptr, 0, _arrayElementByteCount)
        }
        
        
        // The last index portal (if present) must be removed
        
        let lastPortal = manager.getActivePortal(for: itemPtr, index: (_arrayElementCount - 1), column: nil)
        manager.removeActivePortal(lastPortal)
        
        
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
        
        let dstPtr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: index + 1, endianness)
        let srcPtr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness)
        let length = (_arrayElementCount - index) * _arrayElementByteCount
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: length, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        
        // Zero bytes - if necessary
        
        if ItemManager.startWithZeroedBuffers { Darwin.memset(srcPtr, 0, _arrayElementByteCount) }
        
        
        // Insert the new element
        
        value.copyBytes(to: itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness), endianness)
        
        
        // Increase the number of elements
        
        _arrayElementCount += 1
        
        
        return .success
    }
    
    internal func appendClosure(for type: ItemType, with bytes: Int, assignment: () -> Void) -> Result {
        
        guard isArray else { return .error(.operationNotSupported) }
        guard _arrayElementType == type else { return .error(.typeConflict) }
        
        
        // Determine number of bytes per element
        
        let byteCountPerElement: Int = type.hasFlexibleLength ? bytes.roundUpToNearestMultipleOf8() : bytes
        
        
        // Ensure that the element byte count is sufficient
        
        let result = _arrayEnsureElementByteCount(of: byteCountPerElement)
        guard result == .success else { return result }
        
        
        // Ensure that the new value can be added
        
        let neccesaryValueByteCount = arrayElementBaseOffset + _arrayElementByteCount * (_arrayElementCount + 1)
        let result1 = ensureValueFieldByteCount(of: neccesaryValueByteCount)
        guard result1 == .success else { return result }
        
        
        // The new value can be added
        
        assignment()
        
        
        // Increase child counter
        
        _arrayElementCount += 1
        
        return .success
    }
}


/// Build an item with a Array in it.
///
/// - Parameters:
///   - withNameField: The namefield for the item. Optional.
///   - elementType: The type of elements in the array.
///   - elementByteCount: The number of bytes used for each element in the array. It must be ensured that the byte count is large enough for the element type!
///   - elementCount:
///   - endianness: The endianness to be used while creating the item.

internal func buildArrayItem(withNameField nameField: NameField?, elementType: ItemType, elementByteCount: Int, elementCount: Int, atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
    
    let ptr = atPtr
    
    buildItem(ofType: .array, withNameField: nameField, atPtr: ptr, endianness)
    
    var bc: Int = itemHeaderByteCount + (nameField?.byteCount ?? 0) + arrayElementBaseOffset
    bc += (elementCount * elementByteCount).roundUpToNearestMultipleOf8()
    
    ptr.setItemByteCount(to: UInt32(bc), endianness)
    
    var arrayPtr = ptr.itemValueFieldPtr
    arrayPtr.arrayElementType = elementType.rawValue
    arrayPtr.setArrayElementCount(to: 0, endianness)
    arrayPtr.setArrayElementByteCount(to: UInt32(elementByteCount), endianness)
}


// The public interface

extension Portal {
    
    
    /// Appends a value to the end of an Array item.
    ///
    /// Portals: Appending an element does not invalidate portals.
    ///
    /// - Parameter value: The value to be appended.
    ///
    /// - Returns:
    ///   success: When the value was appended
    ///
    ///   noAction: If the value was nil or a Null
    ///
    ///   error(code): If an error prevented the completion, de code details the kind of error.
    
    @discardableResult
    public func appendElement(_ value: Coder?) -> Result {
        guard let value = value else { return .success }
        return appendClosure(for: value.itemType, with: value.valueByteCount) {
            value.copyBytes(to: itemPtr.itemValueFieldPtr.arrayElementPtr(for: _arrayElementCount, endianness), endianness)
            
        }
    }
    
    
    /// Removes an item from an Array item.
    ///
    /// This operation does not decrease the byte count of the Array item.
    ///
    /// Portals: The portals for sub-items of the removed item will be invalidated. The portal for the last element in the array (if any) will be invalidated. Any portal for the sub-items in the last element will also be invalidated.
    ///
    /// - Parameter at: The index of the element to remove.
    ///
    /// - Returns:
    ///   success: If the item was removed
    ///
    ///   error(code): If an error prevented the removal, the code details the kind of error.
    
    @discardableResult
    public func removeElement(at index: Int) -> Result {
        
        guard isArray else { return .error(.portalInvalid) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < _arrayElementCount else { return .error(.indexAboveHigherBound) }
            
        return _arrayRemove(at: index)
    }

    
    /// Inserts a new element into an Array item.
    ///
    /// - Parameters:
    ///   - value: The value to be inserted.
    ///   - atIndex: The index at which to insert the value.
    ///
    /// - Returns:
    ///   success: If the insertion was successful.
    ///
    ///   noAction: If the value was nil or Null.
    ///
    ///   error(code): If an error prevented the insertion, the code details the kind of error.
    
    @discardableResult
    public func insertElement(_ value: Coder?, atIndex index: Int) -> Result {
        
        guard let value = value else { return .noAction }
        guard value.itemType != .null else { return .noAction }
        
        guard isArray else { return .error(.portalInvalid) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < _arrayElementCount else { return .error(.indexAboveHigherBound) }
        guard value.itemType == _arrayElementType else { return .error(.typeConflict) }
            
        return _arrayInsert(value, atIndex: index)
    }

    
    /// Appends one or more new elements to the end of an array.
    ///
    /// If a default value is given, it will be used. If no default value is specified the content bytes will be set to zero.
    ///
    /// - Note: Only for array item portals.
    ///
    /// - Parameters:
    ///   - amount: The number of elements to create, default = 1.
    ///   - value: The default value for the new elements, default = nil.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func createNewElements(amount: Int = 1, value: Coder? = nil) -> Result {
        
        guard isArray else { return .error(.operationNotSupported) }
        if let value = value, value.itemType != _arrayElementType { return .error(.typeConflict) }
        
        
        // The number of new elements must be positive
        
        guard amount > 0 else { return .error(.illegalAmount) }
        
        
        // A default value should fit the element byte count
        
        if let value = value {
            let result = _arrayEnsureElementByteCount(for: value)
            guard result == .success else { return result }
        }
        
        
        // Ensure that the item storage capacity is sufficient
        
        let newCount = _arrayElementCount + amount
        let neccesaryValueFieldByteCount = (arrayElementBaseOffset + _arrayElementByteCount * newCount).roundUpToNearestMultipleOf8()
        let result = ensureValueFieldByteCount(of: neccesaryValueFieldByteCount)
        guard result == .success else { return result }
        
        
        // Initialize the area of the new elements to zero
        
        _ = Darwin.memset(itemPtr.itemValueFieldPtr.arrayElementPtr(for: _arrayElementCount, endianness), 0, amount * _arrayElementByteCount)
        
        
        // Use the default value if provided
        
        if let value = value {
            var loopCount = amount
            repeat {
                value.copyBytes(to: itemPtr.itemValueFieldPtr.arrayElementPtr(for: _arrayElementCount + loopCount - 1, endianness), endianness)
                loopCount -= 1
            } while loopCount > 0
        }
        
        
        // Increment the number of elements
        
        _arrayElementCount += amount
        
        
        return .success
    }


    /// Append the contens of an item manager to the Array item.
    ///
    /// Note that the type of the item manager root item must be the same as the element type.
    ///
    /// - Parameter itemManager: The item manager with the content to append.
    ///
    /// - Returns:
    ///   success: If the content was appended.
    ///
    ///   error(code): If the append failed, the code will detail the kind of error.
    
    @discardableResult
    public func appendElement(_ itemManager: ItemManager?) -> Result {
        
        guard let itemManager = itemManager else { return .error(.missingValue) }
        guard isValid else { return .error(.portalInvalid) }
        guard isArray else { return .error(.operationNotSupported) }
        guard _arrayElementType! == itemManager.root.itemType! else { return .error(.typeConflict) }
        
        
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
        
        _ = Darwin.memcpy(itemPtr.itemValueFieldPtr.arrayElementPtr(for: _arrayElementCount, endianness), itemManager.bufferPtr, itemManager.count)
        let parentOffset = manager!.bufferPtr.distance(to: itemPtr)
        UInt32(parentOffset).copyBytes(to: itemPtr.itemValueFieldPtr.arrayElementPtr(for: _arrayElementCount, endianness).advanced(by: itemParentOffsetOffset), endianness)

        _arrayElementCount += 1
        
        return .success
    }

    
    /// Append the contens of an array of item managers to the Array item.
    ///
    /// Note that the type of the item manager root items must be the same as the element type.
    ///
    /// - Parameter arr: The item managers with the content to append.
    ///
    /// - Returns:
    ///   success: If the content was appended.
    ///
    ///   error(code): If the append failed, the code will detail the kind of error.

    @discardableResult
    public func appendElements(_ arr: Array<ItemManager>) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isArray else { return .error(.operationNotSupported) }
        for im in arr { guard im.root.itemType == _arrayElementType! else { return .error(.typeConflict) }}
        
        
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
            let dstPtr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: _arrayElementCount, endianness)
            let length = $0.count
            _ = Darwin.memcpy(dstPtr, srcPtr, length)
            UInt32(parentOffset).copyBytes(to: dstPtr.advanced(by: itemParentOffsetOffset), endianness)
            _arrayElementCount += 1
        }
        
        return .success
    }
    
    
    /// Inserts an item manager's content into an Array item.
    ///
    /// - Parameters:
    ///   - value: The item manager with the content to be inserted.
    ///   - atIndex: The index at which to insert the value.
    ///
    /// - Returns:
    ///   success: If the insertion was successful.
    ///
    ///   noAction: If the value was nil or Null.
    ///
    ///   error(code): If an error prevented the insertion, the code details the kind of error.

    @discardableResult
    public func insertElement(_ itemManager: ItemManager?, atIndex index: Int) -> Result {
        
        guard let value = itemManager?.data else { return .noAction }
        guard isArray else { return .error(.portalInvalid) }
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < _arrayElementCount else { return .error(.indexAboveHigherBound) }
        guard _arrayElementType! == itemManager!.root.itemType! else { return .error(.typeConflict) }
        
        
        // Ensure that the element byte count is sufficient
        
        var result = _arrayEnsureElementByteCount(of: value.count)
        guard result == .success else { return result }
        
        
        // Ensure that the item storage capacity is sufficient
        
        let newCount = _arrayElementCount + 1
        let neccesaryValueByteCount = arrayElementBaseOffset + _arrayElementByteCount * newCount
        result = ensureValueFieldByteCount(of: neccesaryValueByteCount)
        guard result == .success else { return result }
        
        
        // Copy the existing elements upward
        
        let dstPtr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: index + 1, endianness)
        let srcPtr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness)
        let length = (_arrayElementCount - index) * _arrayElementByteCount
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: length, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        
        // Zero bytes - if necessary
        
        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(srcPtr, 0, _arrayElementByteCount) }
        
        
        // Insert the new element
        
        value.copyBytes(to: itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness).assumingMemoryBound(to: UInt8.self), count: value.count)
        
        
        // Increase the number of elements
        
        _arrayElementCount += 1
        
        
        return .success
    }
}





