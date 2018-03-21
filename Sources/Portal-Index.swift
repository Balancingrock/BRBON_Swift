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
            guard index < countValue else { return fatalOrNull("Index (\(index)) out of high bound (\(countValue))") }
            if isArray { return _arrayPortalForElement(at: index)
            } else if isSequence { return _sequencePortalForItem(at: index)
            } else { return fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }

    public subscript(index: Int) -> Bool? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).bool
            } else if isSequence { return _sequencePortalForItem(at: index).bool
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).bool = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Int8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).int8
            } else if isSequence { return _sequencePortalForItem(at: index).int8
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).int8 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Int16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).int16
            } else if isSequence { return _sequencePortalForItem(at: index).int16
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).int16 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Int32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).int32
            } else if isSequence { return _sequencePortalForItem(at: index).int32
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).int32 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Int64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).int64
            } else if isSequence { return _sequencePortalForItem(at: index).int64
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).int64 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> UInt8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).uint8
            } else if isSequence { return _sequencePortalForItem(at: index).uint8
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).uint8 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> UInt16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).uint16
            } else if isSequence { return _sequencePortalForItem(at: index).uint16
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).uint16 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> UInt32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).uint32
            } else if isSequence { return _sequencePortalForItem(at: index).uint32
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).uint32 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> UInt64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).uint64
            } else if isSequence { return _sequencePortalForItem(at: index).uint64
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).uint64 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Float32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).float32
            } else if isSequence { return _sequencePortalForItem(at: index).float32
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).float32 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Float64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).float64
            } else if isSequence { return _sequencePortalForItem(at: index).float64
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).float64 = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> String? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).string
            } else if isSequence { return _sequencePortalForItem(at: index).string
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).string = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Data? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray { return _arrayPortalForElement(at: index).binary
            } else if isSequence { return _sequencePortalForItem(at: index).binary
            } else { fatalOrNull("Integer index subscript not supported on \(itemType)"); return nil }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { _arrayPortalForElement(at: index).binary = newValue }
            else if isSequence { _ = _sequencePortalForItem(at: index)._sequenceReplaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    
    /// Returns the type of the element stored in the array this portal refers to.
    
    internal var _arrayElementType: ItemType? {
        get {
            return ItemType.readValue(atPtr: itemPtr.brbonArrayElementTypePtr)
        }
    }
    
    
    /// The byte count of the elements contained in the array this portal refers to.
    
    internal var _arrayElementByteCount: Int {
        get { return Int(UInt32(valuePtr: itemPtr.brbonArrayElementByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemPtr.brbonArrayElementByteCountPtr, endianness) }
    }

    
    /// Returns the element pointer for a given index.
    
    internal func _arrayElementPtr(for index: Int) -> UnsafeMutableRawPointer {
        let elementBasePtr = itemPtr.brbonItemValuePtr.advanced(by: 8)
        let elementOffset = index * _arrayElementByteCount
        return elementBasePtr.advanced(by: elementOffset)
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
        
        var ptr = itemPtr.brbonItemValuePtr
        var c = 0
        while c < index {
            let bc = ptr.brbonItemByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee
            ptr = ptr.advanced(by: Int(bc))
            c += 1
        }
        return Portal(itemPtr: ptr, manager: manager, endianness: endianness)
    }

    
    /// Increases the byte count of the array element.
    
    internal func _arrayIncreaseElementByteCount(to newByteCount: Int) {
        
        let elementBasePtr = itemPtr.brbonArrayElementsBasePtr
        let oldByteCount = _arrayElementByteCount
        
        for index in (0 ..< countValue).reversed() {
            let dstPtr = elementBasePtr.advanced(by: index * newByteCount)
            let srcPtr = elementBasePtr.advanced(by: index * oldByteCount)
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: oldByteCount, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        _arrayElementByteCount = newByteCount
    }

    
    /// Replaces the item at self.
    ///
    /// The item at self is replaced by the new value. The byte count will be preserved as is, or enlarged as necessary. If there is an existing name it will be preserved. If the new value is nil, the item will be converted into a null.
    
    internal func _sequenceReplaceWith(_ value: Coder?) -> Result {
        
        if let value = value {
            
            
            // Make sure the item byte count is big enough
            
            let necessaryItemByteCount = value.itemByteCount(nameFieldDescriptor)
            
            if itemByteCount < necessaryItemByteCount {
                let result = increaseItemByteCount(to: necessaryItemByteCount)
                guard result == .success else { return result }
            }
            
            
            // Create the new item, but remember the old size as it must be re-used
            
            let oldByteCount = itemByteCount
            
            
            // Write the new value as an item
            
            value.storeAsItem(atPtr: itemPtr, bufferPtr: manager.bufferPtr, parentPtr: parentPtr, nameField: nameFieldDescriptor, valueByteCount: nil, endianness)
            
            
            // Restore the old byte count
            
            itemByteCount = oldByteCount
            
            
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
        
        if value.elementByteCount > _arrayElementByteCount {
            
            
            // The value byte count is bigger than the existing element byte count.
            // Enlarge the item to accomodate extra bytes.
            
            let necessaryElementByteCount: Int
            if value.brbonType.isContainer {
                necessaryElementByteCount = value.elementByteCount.roundUpToNearestMultipleOf8()
            } else {
                necessaryElementByteCount = value.elementByteCount
            }
            
            
            // This is the byte count that self has to become in order to accomodate the new value
            
            let necessaryItemByteCount = itemByteCount - valueFieldByteCount + 8 + ((countValue + 1) * necessaryElementByteCount)
            
            
            if necessaryItemByteCount > itemByteCount {
                // It is necessary to increase the bytecount for the array item itself
                let result = increaseItemByteCount(to: necessaryItemByteCount.roundUpToNearestMultipleOf8())
                guard result == .success else { return result }
            }
            
            
            // Increase the byte count of the elements by shifting them up inside the enlarged array.
            
            _arrayIncreaseElementByteCount(to: necessaryElementByteCount)
            
            
        } /*else {
            
            
            // The element byte count of the array is big enough to hold the new value.
            
            // Make sure a new value can be added to the array
            
            let necessaryItemByteCount = itemByteCount - valueFieldByteCount + 8 + ((countValue + 1) * _arrayElementByteCount)
            
            if necessaryItemByteCount > itemByteCount {
                let result = increaseItemByteCount(to: necessaryItemByteCount.roundUpToNearestMultipleOf8())
                guard result == .success else { return result }
            }
        }*/
        
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
        
        if valueFieldByteCount - usedValueByteCount < value.elementByteCount {
            let result = increaseItemByteCount(to: itemByteCount + value.elementByteCount)
            guard result == .success else { return result }
        }
        
        
        // The new value can be added
        
        if value.brbonType.isContainer {
            value.storeAsItem(atPtr: _arrayElementPtr(for: countValue), bufferPtr: manager.bufferPtr, parentPtr: itemPtr, nameField: nil, valueByteCount: nil, endianness)
        } else {
            value.storeAsElement(atPtr: _arrayElementPtr(for: countValue), endianness)
        }
        
        
        // Increase child counter
        
        countValue += 1
        
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
        
        let nfd: NameFieldDescriptor? = {
            guard let name = name else { return nil }
            return NameFieldDescriptor(name)
        }()

        
        // Ensure that there is enough space available
        
        let newItemByteCount = value.itemByteCount(nfd)
        
        if valueFieldByteCount - usedValueByteCount < newItemByteCount {
            let result = increaseItemByteCount(to: minimumItemByteCount + usedValueByteCount + newItemByteCount)
            guard result == .success else { return result }
        }
        
        value.storeAsItem(atPtr: _afterLastItemPtr, bufferPtr: manager.bufferPtr, parentPtr: itemPtr, nameField: nfd, valueByteCount: nil, endianness)
        
        countValue += 1
        
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
            guard _arrayElementType == value.brbonType else { return .typeConflict }
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
        let len = (countValue - 1 - index) * _arrayElementByteCount
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        
        // The last index portal (if present) must be removed
        
        let lptr = _arrayElementPtr(for: countValue - 1)
        manager.removeActivePortals(atAndAbove: lptr, below: lptr.advanced(by: 1))
        
        
        // Decrease the number of elements
        
        countValue -= 1
        
        
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
        let aliPtr = _afterLastItemPtr
        
        let srcPtr = itm.itemPtr.advanced(by: itm.itemByteCount)
        let dstPtr = itm.itemPtr
        let len = srcPtr.distance(to: aliPtr)
        
        manager.removeActivePortal(itm)
        
        if len > 0 {
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        countValue -= 1
        
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
        guard index < countValue else { fatalOrNull("Index (\(index)) above high bound (\(countValue))"); return .indexAboveHigherBound }

        if isArray { return _arrayRemove(at: index) }
        
        if isSequence { return _sequenceRemove(at: index) }
        
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
        guard amount > 0 else { fatalOrNull("createNewElements must have amount > 0, found \(amount)"); return .illegalAmount }
        guard let value = value as? Coder else { return .missingCoder }

        guard isArray else {
            fatalOrNull("_createNewElements not supported for \(itemType)")
            return .operationNotSupported
        }
        
        // Ensure that the element byte count is sufficient
        
        var result = _arrayEnsureElementByteCount(for: value)
        guard result == .success else { return result }
        
        
        // Ensure that the item storage capacity is sufficient
        
        let newCount = countValue + amount
        let neccesaryValueByteCount = 8 + _arrayElementByteCount * newCount
        result = ensureValueFieldByteCount(of: neccesaryValueByteCount)
        guard result == .success else { return result }
        
        
        // Use default value to populate the new items
        
        var loopCount = amount
        repeat {
            value.storeValue(atPtr: _arrayElementPtr(for: countValue + loopCount - 1), endianness)
            loopCount -= 1
        } while loopCount > 0
        
        
        // Increment the number of elements
        
        countValue += amount
        
        
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
        
        let newCount = countValue + 1
        let neccesaryValueByteCount = 8 + _arrayElementByteCount * newCount
        result = ensureValueFieldByteCount(of: neccesaryValueByteCount)
        guard result == .success else { return result }
        
        
        // Copy the existing elements upward
        
        let dstPtr = _arrayElementPtr(for: index + 1)
        let srcPtr = _arrayElementPtr(for: index)
        let length = (countValue - index) * _arrayElementByteCount
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: length, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)
        
        
        // Insert the new element
        
        value.storeValue(atPtr: _arrayElementPtr(for: index), endianness)
        
        
        // Increase the number of elements
        
        countValue += 1
        
        
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
        
        let nfd: NameFieldDescriptor? = {
            guard let name = name else { return nil }
            return NameFieldDescriptor(name)
        }()
        
        let newItemByteCount = value.itemByteCount(nfd)
        
        if valueFieldByteCount - usedValueByteCount < newItemByteCount {
            let result = increaseItemByteCount(to: minimumItemByteCount + usedValueByteCount + newItemByteCount)
            guard result == .success else { return result }
        }
        
        
        // Copy the existing items upward
        
        let itm = _sequencePortalForItem(at: index)
        
        let dstPtr = itm.itemPtr.advanced(by: newItemByteCount)
        let srcPtr = itm.itemPtr
        let length = newItemByteCount
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: length, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        
        // Insert the new element
        
        value.storeAsItem(atPtr: srcPtr, bufferPtr: manager.bufferPtr, parentPtr: itemPtr, nameField: nfd, valueByteCount: nil, endianness)
        
        
        countValue += 1
        
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
        guard index < countValue else { fatalOrNull("Index (\(index)) above high bound (\(countValue))"); return .indexAboveHigherBound }

        guard let value = value as? Coder else { return .missingCoder }

        if isArray {
            guard value.brbonType == _arrayElementType else { return .typeConflict }
            return _arrayInsert(value, atIndex: index)
        }
        
        if isSequence {
            return _sequenceInsert(value, atIndex: index, withName: name)
        }
        
        fatalOrNull("insert(Coder, int) not supported on \(itemPtr)")
        return .operationNotSupported
    }
}
