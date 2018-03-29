//
//  Portal-Subscript.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/01/18.
//
//

import Foundation
import BRUtils


/// Extension that implement indexed lookup and other array/sequence related operations.

public extension Portal {

    
    public subscript(index: Int) -> Portal {
        get {
            guard isValid else { return fatalOrNull("Portal is no longer valid") }
            guard index >= 0 else { return fatalOrNull("Index (\(index)) is negative") }
            if isArray {
                guard index < _arrayElementCount else { return fatalOrNull("Index (\(index)) out of high bound (\(_arrayElementCount))") }
                return _arrayPortalForElement(at: index)
            } else if isSequence {
                guard index < _sequenceItemCount else { return fatalOrNull("Index (\(index)) out of high bound (\(_sequenceItemCount))") }
                return _sequencePortalForItem(at: index)
            } else { return fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }

    public subscript(index: Int) -> Bool? {
        get { return self[index].bool }
        set { self[index].bool = newValue }
    }
    
    public subscript(index: Int) -> Int8? {
        get { return self[index].int8 }
        set { self[index].int8 = newValue }
    }
    
    public subscript(index: Int) -> Int16? {
        get { return self[index].int16 }
        set { self[index].int16 = newValue }
    }
    
    public subscript(index: Int) -> Int32? {
        get { return self[index].int32 }
        set { self[index].int32 = newValue }
    }
    
    public subscript(index: Int) -> Int64? {
        get { return self[index].int64 }
        set { self[index].int64 = newValue }
    }
    
    public subscript(index: Int) -> UInt8? {
        get { return self[index].uint8 }
        set { self[index].uint8 = newValue }
    }
    
    public subscript(index: Int) -> UInt16? {
        get { return self[index].uint16 }
        set { self[index].uint16 = newValue }
    }
    
    public subscript(index: Int) -> UInt32? {
        get { return self[index].uint32 }
        set { self[index].uint32 = newValue }
    }
    
    public subscript(index: Int) -> UInt64? {
        get { return self[index].uint64 }
        set { self[index].uint64 = newValue }
    }
    
    public subscript(index: Int) -> Float32? {
        get { return self[index].float32 }
        set { self[index].float32 = newValue }
    }
    
    public subscript(index: Int) -> Float64? {
        get { return self[index].float64 }
        set { self[index].float64 = newValue }
    }
    
    public subscript(index: Int) -> String? {
        get { return self[index].string }
        set { self[index].string = newValue }
    }
    
    public subscript(index: Int) -> Data? {
        get { return self[index].binary }
        set { self[index].binary = newValue }
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

    
    /// Returns the portal for the item at the specified index.
    
    internal func _sequencePortalForItem(at index: Int) -> Portal {
        
        var ptr = itemValueFieldPtr
        var c = 0
        while c < index {
            let bc = ptr.advanced(by: itemByteCountOffset).assumingMemoryBound(to: UInt32.self).pointee
            ptr = ptr.advanced(by: Int(bc))
            c += 1
        }
        return Portal(itemPtr: ptr, manager: manager, endianness: endianness)
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

    
    /// Replaces the referenced item.
    ///
    /// The item referenced byt his portal is replaced by the new value. The byte count will be preserved as is, or enlarged as necessary. If there is an existing name it will be preserved. If the new value is nil, the item will be converted into a null.
    
    internal func _sequenceReplaceWith(_ value: Coder?) -> Result {
        
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

    
    /// Makes sure the element byte count is sufficient.
    ///
    /// - Parameter for: The Coder value that must be accomodated.
    ///
    /// - Returns: Success if the value can be allocated, an error identifier when not.
    
    internal func _arrayEnsureElementByteCount(for value: Coder) -> Result {
        
        
        // Check to see if the element byte count of the array must be increased.
        
        let necessaryElementByteCount: Int = value.itemType.isContainer ? value.itemByteCount(nil) : value.valueByteCount
        
        if necessaryElementByteCount > _arrayElementByteCount {
            

            // This is the byte count that self has to become in order to accomodate the new value
            
            let necessaryItemByteCount = _itemByteCount - actualValueFieldByteCount + arrayElementBaseOffset + ((_arrayElementCount + 1) * necessaryElementByteCount)
            
            
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
    
    
    /// Adds a new bool value to the end of the array.
    ///
    /// - Parameter value: The value to be added to the array.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    private func _arrayAppend(_ value: Coder) -> Result {
        

        // Ensure that the element byte count is sufficient
        
        let result = _arrayEnsureElementByteCount(for: value)
        guard result == .success else { return result }
        
        
        // Ensure that the new value can be added
        
        if actualValueFieldByteCount - usedValueFieldByteCount < value.valueByteCount {
            let result = increaseItemByteCount(to: _itemByteCount + value.valueByteCount.roundUpToNearestMultipleOf8())
            guard result == .success else { return result }
        }
        
        
        // The new value can be added
        
        if value.itemType.isContainer {
            let pOffset = manager.bufferPtr.distance(to: itemPtr)
            value.storeAsItem(atPtr: _arrayElementPtr(for: _arrayElementCount), parentOffset: pOffset, endianness)
        } else {
            value.storeValue(atPtr: _arrayElementPtr(for: _arrayElementCount), endianness)
        }
        
        
        // Increase child counter
        
        _arrayElementCount += 1
        
        return .success
    }
    
    
    /// Adds a new bool value to the end of the sequence.
    ///
    /// - Parameters:
    ///   - value: The value to be added to the sequence.
    ///   - forName: The name for the new value.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    private func _sequenceAppend(_ value: Coder, forName name: String? = nil) -> Result {
        
        
        // Create the name field descriptor (if used)
        
        let nfd: NameField? = {
            guard let name = name else { return nil }
            return NameField(name)
        }()

        
        // Ensure that there is enough space available
        
        let newItemByteCount = value.itemByteCount(nfd)
        
        if actualValueFieldByteCount - usedValueFieldByteCount < newItemByteCount {
            let result = increaseItemByteCount(to: itemMinimumByteCount + usedValueFieldByteCount + newItemByteCount)
            guard result == .success else { return result }
        }
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
        value.storeAsItem(atPtr: _sequenceAfterLastItemPtr, name: nfd, parentOffset: pOffset, endianness)
        
        _arrayElementCount += 1
        
        return .success
    }

    
    /// Appends a new value to an array or sequence.
    ///
    /// - Parameters:
    ///   - value: A Coder compatible value.
    ///   - forName: An optional name, only used when the target is a sequence. Ignored for array's.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func append(_ value: IsBrbon, forName name: String? = nil) -> Result {
        
        guard isValid else { return .portalInvalid }
        
        guard let value = value as? Coder else { return .missingCoder }
        
        
        if isArray {
            guard _arrayElementType == value.itemType else { return .typeConflict }
            return _arrayAppend(value)
        }
        
        
        if isSequence {
            return _sequenceAppend(value, forName: name)
        }
        
        
        fatalOrNull("Append operation not valid on \(itemType)")
        
        return .operationNotSupported
    }

    
    /// Removes an item from an array.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.
    
    @discardableResult
    private func _arrayRemove(at index: Int) -> Result {
        

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
    
    
    /// Removes an item from a sequence.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.

    @discardableResult
    private func _sequenceRemove(at index: Int) -> Result {
        
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

    
    /// Removes an item from an array or sequence.
    ///
    /// If the index is out of bounds the operation will fail. Notice that the itemByteCount of the array will not decrease.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.

    @discardableResult
    public func remove(at index: Int) -> Result {
        
        guard isValid else { fatalOrNull("Portal is invalid"); return .portalInvalid }
        
        guard index >= 0 else { fatalOrNull("Index (\(index)) below zero"); return .indexBelowLowerBound }

        if isArray {
            guard index < _arrayElementCount else { fatalOrNull("Index (\(index)) above high bound (\(_arrayElementCount))"); return .indexAboveHigherBound }
            return _arrayRemove(at: index)
        }
        
        if isSequence {
            guard index < _sequenceItemCount else { fatalOrNull("Index (\(index)) above high bound (\(_sequenceItemCount))"); return .indexAboveHigherBound }
            return _sequenceRemove(at: index)
        }
        
        fatalOrNull("remove(int) not supported on \(itemPtr)")
        return .operationNotSupported
    }
    
    
    /// Appends one or a number of new elements to the end of an array. The elf must be an array.
    ///
    /// If a default value is given, it will be used. If no default value is specified the content bytes will be set to zero.
    ///
    /// - Parameters:
    ///   - amount: The number of elements to create, default = 1.
    ///   - value: The default value for the new elements, default = nil.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func createNewElements(_ value: IsBrbon, amount: Int = 1) -> Result {
        
        guard isValid else { fatalOrNull("Portal is invalid"); return .portalInvalid }
        guard isArray else {
            fatalOrNull("_createNewElements not supported for \(itemType)")
            return .operationNotSupported
        }
        guard amount > 0 else { fatalOrNull("createNewElements must have amount > 0, found \(amount)"); return .illegalAmount }
        guard let value = value as? Coder else { return .missingCoder }

        
        // Ensure that the element byte count is sufficient
        
        var result = _arrayEnsureElementByteCount(for: value)
        guard result == .success else { return result }
        
        
        // Ensure that the item storage capacity is sufficient
        
        let newCount = _arrayElementCount + amount
        let neccesaryValueByteCount = 8 + _arrayElementByteCount * newCount
        result = ensureValueFieldByteCount(of: neccesaryValueByteCount)
        guard result == .success else { return result }
        
        
        // Use default value to populate the new items
        
        var loopCount = amount
        repeat {
            value.storeValue(atPtr: _arrayElementPtr(for: _arrayElementCount + loopCount - 1), endianness)
            loopCount -= 1
        } while loopCount > 0
        
        
        // Increment the number of elements
        
        _arrayElementCount += amount
        
        
        return .success
    }

    
    /// Inserts a new element.
    ///
    /// - Parameters:
    ///   - value: The value to be inserted.
    ///   - atIndex: The index at which to insert the value.
    ///
    /// - Returns: 'success' or an error indicator.

    @discardableResult
    private func _arrayInsert(_ value: Coder, atIndex index: Int) -> Result {

        
        // Ensure that the element byte count is sufficient
        
        var result = _arrayEnsureElementByteCount(for: value)
        guard result == .success else { return result }
        
        
        // Ensure that the item storage capacity is sufficient
        
        let newCount = _arrayElementCount + 1
        let neccesaryValueByteCount = 8 + _arrayElementByteCount * newCount
        result = ensureValueFieldByteCount(of: neccesaryValueByteCount)
        guard result == .success else { return result }
        
        
        // Copy the existing elements upward
        
        let dstPtr = _arrayElementPtr(for: index + 1)
        let srcPtr = _arrayElementPtr(for: index)
        let length = (_arrayElementCount - index) * _arrayElementByteCount
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: length, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)
        
        
        // Insert the new element
        
        value.storeValue(atPtr: _arrayElementPtr(for: index), endianness)
        
        
        // Increase the number of elements
        
        _arrayElementCount += 1
        
        
        return .success
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
    private func _sequenceInsert(_ value: Coder, atIndex index: Int, withName name: String? = nil) -> Result {
        
        
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

    
    /// Inserts a new element.
    ///
    /// - Parameters:
    ///   - value: The value to be inserted.
    ///   - atIndex: The index at which to insert the value.
    ///   - withName: A name for the value, only used if the target is a sequence. Ignorded for arrays.
    ///
    /// - Returns: 'success' or an error indicator.

    @discardableResult
    public func insert(_ value: IsBrbon, atIndex index: Int, withName name: String? = nil) -> Result {
        
        guard isValid else { fatalOrNull("Portal is invalid"); return .portalInvalid }
        
        guard index >= 0 else { fatalOrNull("Index (\(index)) below zero"); return .indexBelowLowerBound }

        guard let value = value as? Coder else { return .missingCoder }

        if isArray {
            guard index < _arrayElementCount else { fatalOrNull("Index (\(index)) above high bound (\(_arrayElementCount))"); return .indexAboveHigherBound }
            guard value.itemType == _arrayElementType else { return .typeConflict }
            return _arrayInsert(value, atIndex: index)
        }
        
        if isSequence {
            guard index < _sequenceItemCount else { fatalOrNull("Index (\(index)) above high bound (\(_sequenceItemCount))"); return .indexAboveHigherBound }
            return _sequenceInsert(value, atIndex: index, withName: name)
        }
        
        fatalOrNull("insert(Coder, int) not supported on \(itemPtr)")
        return .operationNotSupported
    }
}
