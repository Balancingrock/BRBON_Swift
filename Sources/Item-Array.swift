//
//  Item-Subscript.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/01/18.
//
//

import Foundation
import BRUtils


/// Array subscript operator.
/// Note that array elements cannot change their type to/from null (unlike sequence or dictionary).

public extension Item {
    
    
    public subscript(index: Int) -> Item {
        get { return element(at: index) ?? Item.nullItem }
    }
    
    public subscript(index: Int) -> Bool? {
        get { return self[index].bool }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> UInt8? {
        get { return self[index].uint8 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> UInt16? {
        get { return self[index].uint16 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }

    public subscript(index: Int) -> UInt32? {
        get { return self[index].uint32 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> UInt64? {
        get { return self[index].uint64 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> Int8? {
        get { return self[index].int8 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> Int16? {
        get { return self[index].int16 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> Int32? {
        get { return self[index].int32 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> Int64? {
        get { return self[index].int64 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> Float32? {
        get { return self[index].float32 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> Float64? {
        get { return self[index].float64 }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> String? {
        get { return self[index].string }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    public subscript(index: Int) -> Data? {
        get { return self[index].binary }
        set {
            guard index >= 0, index < count else { return }
            let ptr = elementPtr(for: index)
            newValue?.storeAsElement(atPtr: ptr, endianness)
        }
    }
    
    
    /// Adds a new bool value to the end of the array.
    ///
    /// - Parameter value: The value to be added to the array.
    ///
    /// - Returns: success or an error indicator.
    
    @discardableResult
    private func _append<T>(_ value: T) -> Result where T:Coder {
        
        
        // Prevent errors
        
        guard isArray else { return .onlySupportedOnArray }
        guard elementType == ItemType.bool else { return .typeConflict }
        
        
        // Store element
        
        guard ensureValueStorage(for: value.elementByteCount) == .success else { return .outOfStorage }
        value.storeAsElement(atPtr: elementPtr(for: count), endianness)
        
        
        // Increase child counter
        
        count += 1
        
        
        return .success
    }
    
    @discardableResult
    public func append(_ value: Bool) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: UInt8) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: UInt16) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: UInt32) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: UInt64) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Int8) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Int16) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Int32) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Int64) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Float32) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Float64) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: String) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Data) -> Result { return _append(value) }

    
    /// Removes an item from the array.
    ///
    /// The array will decrease by item as a result. If the index is out of bounds the operation will fail. Notice that the bytecount of the array will not decrease. To remove unnecessary bytes use the "minimizeByteCount" operation.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.
    
    @discardableResult
    public func remove(at index: Int) -> Result {
        guard isArray else { return .onlySupportedOnArray }
        guard index >= 0 else { return .indexBelowLowerBound }
        guard index < count else { return .indexAboveHigherBound }
        let srcPtr = elementPtr(for: index + 1)
        let dstPtr = elementPtr(for: index)
        let len = (count - 1 - index) * elementByteCount
        moveBlock(dstPtr, srcPtr, len)
        count -= 1
        return .success
    }

    
    /// Creates 1 or a number of new elements at the end of the array. If a default value is given, it will be used. If no default value is specified the content bytes will be set to zero.
    ///
    /// - Parameters:
    ///   - amount: The number of elements to create, default = 1.
    ///   - value: The default value for the new elements, default = nil.
    ///
    /// - Returns: .success or an error indicator.
    
    @discardableResult
    private func _createNewElements<T>(_ value: T, _ amount: Int) -> Result where T:Coder {
        
        guard isArray else { return .onlySupportedOnArray }
        
        guard amount > 0 else { return .success }
        
        
        // Not implemented yet
        
        guard !elementType!.isContainer else { fatalOrNil("Not implemented"); return .typeConflict }


        // Ensure storage area
        
        let bytesNeeded = amount * value.elementByteCount
        guard ensureValueStorage(for: bytesNeeded) == .success else { return .outOfStorage }
        
        
        // Use default value
            
        var loopCount = amount
        repeat {
            value.storeValue(atPtr: elementPtr(for: count + loopCount - 1), endianness)
            loopCount -= 1
        } while loopCount > 0
        
        
        // Increment the number of elements

        count += amount
        
        
        return .success
    }
    
    @discardableResult
    public func createNewElements(_ value: Bool, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: UInt8, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: UInt16, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: UInt32, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: UInt64, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Int8, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Int16, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Int32, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Int64, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Float32, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Float64, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: String, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Data, amount: Int = 1) -> Result { return _createNewElements(value, amount) }

    
    /// Inserts a new element at the given position.
    
    @discardableResult
    private func _insert<T>(_ value: T, _ index: Int) -> Result where T:Coder {

        
        // Prevent errors
        
        guard isArray else { return .onlySupportedOnArray }
        guard value.brbonType == elementType else { return .typeConflict }
        guard index >= 0 else { return .indexBelowLowerBound }
        guard index < count else { return .indexAboveHigherBound }
        
        
        // Not implemented yet
        
        guard !value.brbonType.isContainer else { fatalOrNil("Not implemented"); return .typeConflict }
        
        
        // Store element
        
        guard ensureValueStorage(for: value.elementByteCount) == .success else { return .outOfStorage }
        
        
        // Copy the existing elements upward
        
        let dstPtr = elementPtr(for: index + 1)
        let srcPtr = elementPtr(for: index)
        let length = (count - index) * elementByteCount
        moveBlock(dstPtr, srcPtr, length)
        
        
        // Insert the new element
        
        value.storeValue(atPtr: elementPtr(for: index), endianness)
        
        
        // Increase the number of elements
        
        count += 1
        
        
        return .success
    }

    @discardableResult
    public func insert(_ value: Bool, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: UInt8, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: UInt16, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: UInt32, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: UInt64, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Int8, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Int16, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Int32, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Int64, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Float32, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Float64, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: String, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Data, at index: Int) -> Result { return _insert(value, index) }

    
    // *********************************
    // MARK: - Internal
    // *********************************

    
    /// Create the memory structure of an array item.
    ///
    /// - Parameters:
    ///   - elementType: The ItemType of the elements in the array. An array cannot contain null items.
    ///   - initialCount: The number of elements initially allocated.
    ///   - elementValueLength: The length of the value field of the elements in bytes. If not specified the default element size for the type will be used. Note that this may casue problems for types that may have a variable length (string, binary, array, dictionary, sequence).
    ///   - name: The name for the array itself.
    ///   - nameFieldLength: The length of the name field. The actual length used will always be a multiple of 8.
    ///   - fixedItemLength: The length of the array, if this is set, the array length cannot be changed. The actual length of the array will always be a mulitple of 8.
    ///   - initialBufferSize: The size of the buffer area used for the initial allocation. When an initialCount/elementValueLength is
    ///   - bufferIncrements: The number of bytes with which to increment the buffer if it is too small.
    ///   - endianness: The endianness to be used in this dictionary manager.
    
    internal static func createArray<T>(
        atPtr: UnsafeMutableRawPointer,
        elementType: ItemType,
        initialCount: Int = 0,
        initialValue: T? = nil,
        nameFieldDescriptor: NameFieldDescriptor,
        parentOffset: Int,
        elementValueLength: Int? = nil,
        fixedItemLength: Int? = nil,
        endianness: Endianness = machineEndianness) -> Bool where T:Coder {
    
        
        guard elementType != .null else { return false }
        if let initialValue = initialValue {
            guard initialValue.brbonType == elementType else { return false }
        }
        
        
        // Determine size of the value field
        // =================================
        
        var itemSize: Int = minimumItemByteCount + nameFieldDescriptor.byteCount + 8
        
        
        // Add the initial allocation for the elements
        
        let elementSize = elementValueLength ?? elementType.assumedValueByteCount
        if initialCount > 0 {
            itemSize += (elementSize * initialCount).roundUpToNearestMultipleOf8()
        }
        
        
        if let fixedItemLength = fixedItemLength {
            
            
            // Range limit
            
            guard fixedItemLength <= Int(Int32.max) else { return false }
            
            
            // If specified, the fixed item length must at least be large enough for the name field
            
            guard fixedItemLength >= itemSize else { return false }
            
            
            // Make the itemLength the fixed item length, but ensure that it is a multiple of 8 bytes.
            
            itemSize = fixedItemLength.roundUpToNearestMultipleOf8()
        }

        
        // Create the array structure
        
        var p = atPtr
        
        ItemType.array.storeValue(atPtr: p)
        p = p.advanced(by: 1)
        
        ItemOptions.none.storeValue(atPtr: p)
        p = p.advanced(by: 1)
        
        ItemFlags.none.storeValue(atPtr: p)
        p = p.advanced(by: 1)
        
        UInt8(nameFieldDescriptor.byteCount).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 1)
        
        UInt32(itemSize).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 4)
        
        UInt32(parentOffset).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 4)
        
        UInt32(initialCount).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 4)
        
        
        if nameFieldDescriptor.byteCount > 0 {
            nameFieldDescriptor.storeValue(atPtr: p, endianness)
            p = p.advanced(by: Int(nameFieldDescriptor.byteCount))
        }
        
        elementType.storeValue(atPtr: p)
        p = p.advanced(by: 1)
        
        UInt8(0).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 1)
        
        UInt8(0).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 1)
        
        UInt8(0).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 1)
        
        let evLength = elementValueLength ?? elementType.assumedValueByteCount
        UInt32(evLength).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 4)
        
        let startOfElementsPtr = p
        
        var ecount = 0
        while ecount < initialCount {
            
            if let initialValue = initialValue {
                
                initialValue.storeAsElement(atPtr: startOfElementsPtr.advanced(by: evLength * ecount), endianness)
                
                let remainder = evLength - initialValue.elementByteCount
                if remainder > 0 {
                    Data(count: remainder).storeValue(atPtr: startOfElementsPtr.advanced(by: evLength * ecount).advanced(by: initialValue.elementByteCount), endianness)
                }
                
                
            } else {
                
                Data(count: evLength).storeValue(atPtr: startOfElementsPtr.advanced(by: evLength * ecount), endianness)
            }
            
            ecount += 1
        }
        
        
        let remainder = itemSize - atPtr.distance(to: startOfElementsPtr.advanced(by: evLength * ecount))
        if remainder > 0 {
            Data(count: remainder).storeValue(atPtr: startOfElementsPtr.advanced(by: evLength * ecount), endianness)
        }

        
        // Success
        
        return true
    }

    
    /// The offset from the first byte of the first element to the indexed element.
    ///
    /// - Note: This operation does not check for validity of the index.
    ///
    /// - Parameter for: the index of the element for which to determine the offset.
    ///
    /// - Returns: The offset.
    
    internal func elementOffset(for index: Int) -> Int {
        return index * elementByteCount
    }
    
    
    /// A pointer to the first byte of the indexed element.
    ///
    /// - Note: This operation does not check for validity of the index.
    ///
    /// - Parameter for: the index of the element for which to return the pointer.
    ///
    /// - Returns: The pointer.

    internal func elementPtr(for index: Int) -> UnsafeMutableRawPointer {
        return valuePtr.advanced(by: 8 + elementOffset(for: index))
    }
    
    private func element(at index: Int) -> Item? {
        guard isArray else { return fatalOrNil("Subscript with Int on non-array") }
        guard index >= 0 && index < count else {
            let range = Range(uncheckedBounds: (lower: 0, upper: count))
            return fatalOrNil("Index (\(index)) out of range \(range)")
        }
        return Item.init(basePtr: elementPtr(for: index), parentPtr: basePtr, endianness: endianness)
    }
}
