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
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.bool = newValue }
        }
    }
    
    public subscript(index: Int) -> UInt8? {
        get { return self[index].uint8 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.uint8 = newValue }
        }
    }
    
    public subscript(index: Int) -> UInt16? {
        get { return self[index].uint16 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.uint16 = newValue }
        }
    }

    public subscript(index: Int) -> UInt32? {
        get { return self[index].uint32 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.uint32 = newValue }
        }
    }
    
    public subscript(index: Int) -> UInt64? {
        get { return self[index].uint64 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.uint64 = newValue }
        }
    }
    
    public subscript(index: Int) -> Int8? {
        get { return self[index].int8 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.int8 = newValue }
        }
    }
    
    public subscript(index: Int) -> Int16? {
        get { return self[index].int16 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.int16 = newValue }
        }
    }
    
    public subscript(index: Int) -> Int32? {
        get { return self[index].int32 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.int32 = newValue }
        }
    }
    
    public subscript(index: Int) -> Int64? {
        get { return self[index].int64 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.int64 = newValue }
        }
    }
    
    public subscript(index: Int) -> Float32? {
        get { return self[index].float32 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.float32 = newValue }
        }
    }
    
    public subscript(index: Int) -> Float64? {
        get { return self[index].float64 }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.float64 = newValue }
        }
    }
    
    public subscript(index: Int) -> String? {
        get { return self[index].string }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.string = newValue }
        }
    }
    
    public subscript(index: Int) -> Data? {
        get { return self[index].binary }
        set {
            guard let item = element(at: index) else { return }
            if let newValue = newValue { item.binary = newValue }
        }
    }
    
    
    /// Adds a new element with the given value, to the end of the array.
    ///
    /// - Parameter value: The value to be added to the array.
    ///
    /// - Returns: The result fo the operation, .success when the operation was succesful.
    
    @discardableResult
    public func append(_ value: BrbonBytes) -> Result {
        
        
        // Prevent errors
        
        guard isArray else { return .onlySupportedOnArray }
        guard value.brbonType == elementType else { return .typeConflict }

        
        // Not implemented yet
        
        guard !value.brbonType.isContainer else { fatalOrNil("Not implemented"); return .wrongType }
        
        
        // Store element

        guard ensureValueStorage(for: value.brbonCount) == .success else { return .outOfStorage }
        value.brbonBytes(toPtr: elementPtr(for: count32), endianness)
        count32 += 1
        
        return .success
    }
    
    
    /// Removes an item from the array.
    ///
    /// The array will decrease by item as a result. If the index is out of bounds the operation will fail. Notice that the bytecount of the array will not decrease. To remove unnecessary bytes use the "minimizeByteCount" operation.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: An ignorable result, .success if the remove worked, a failure indicator if not.
    
    @discardableResult
    public func remove(at index: Int) -> Result {
        let index = UInt32(index)
        guard isArray else { return .onlySupportedOnArray }
        guard index >= 0 else { return .indexBelowLowerBound }
        guard index < count32 else { return .indexAboveHigherBound }
        let srcPtr = elementPtr(for: index + 1)
        let dstPtr = elementPtr(for: index)
        let len = Int((count32 - 1 - index) * elementByteCount)
        moveBlock(dstPtr, srcPtr, len)
        count32 -= 1
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
    public func createNewElements(amount: UInt32 = 1, value: BrbonBytes? = nil) -> Result {
        
        guard isArray else { return .onlySupportedOnArray }
        
        guard amount > 0 else { return .success }
        
        if let value = value {
            guard value.brbonType == elementType! else { return .typeConflict }
        }

        
        // Not implemented yet
        
        guard !elementType!.isContainer else { fatalOrNil("Not implemented"); return .wrongType }


        // Ensure storage area
        
        let bytesNeeded = amount * (value?.brbonCount ?? elementType!.brbonCount)
        guard ensureValueStorage(for: bytesNeeded) == .success else { return .outOfStorage }
        
        
        // Fill it with initial values or zero
        
        if let value = value {
            
            
            // Use default value
            
            var loopCount = amount
            repeat {
                value.brbonBytes(toPtr: elementPtr(for: count32 + loopCount - 1), endianness)
                loopCount -= 1
            } while loopCount > 0
            
        } else {
            
            
            // No default value, set the whole area to zero
            
            let ptr = elementPtr(for: count32).assumingMemoryBound(to: UInt8.self)
            Data(count: Int(bytesNeeded)).copyBytes(to: ptr, count: self.count)
        }
        
        
        // Increment the number of elements

        count32 += amount
        
        
        return .success
    }
    
    
    /// Inserts a new element at the given position.
    
    @discardableResult
    public func insert(_ value: BrbonBytes, at index: Int) -> Result {

        
        // Prevent errors
        
        guard isArray else { return .onlySupportedOnArray }
        guard value.brbonType == elementType else { return .typeConflict }
        guard index >= 0 else { return .indexBelowLowerBound }
        guard index < count else { return .indexAboveHigherBound }
        
        
        // Not implemented yet
        
        guard !value.brbonType.isContainer else { fatalOrNil("Not implemented"); return .wrongType }
        
        
        // Store element
        
        guard ensureValueStorage(for: value.brbonCount) == .success else { return .outOfStorage }
        
        
        // Copy the existing elements upward
        
        let dstPtr = elementPtr(for: UInt32(index) + 1)
        let srcPtr = elementPtr(for: UInt32(index))
        let length = (count - index) * Int(elementByteCount)
        moveBlock(dstPtr, srcPtr, length)
        
        
        // Insert the new element
        
        value.brbonBytes(toPtr: elementPtr(for: UInt32(index)), endianness)
        
        
        // Increase the number of elements
        
        count32 += 1
        
        
        return .success
    }

    
    /// Returns the type of the elements in this array.
    ///
    /// - Returns: The type of the elements or nil when this is not an array or the type is invalid.
    
    public var elementType: ItemType? {
        guard isArray else { return nil }
        return ItemType(valuePtr, endianness)
    }
    
    
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
    
    internal static func createArray(
        atPtr: UnsafeMutableRawPointer,
        elementType: ItemType,
        initialCount: UInt32 = 0,
        initialValue: BrbonBytes? = nil,
        nameFieldDescriptor: NameFieldDescriptor,
        parentOffset: UInt32,
        elementValueLength: UInt32? = nil,
        fixedItemLength: UInt32? = nil,
        endianness: Endianness = machineEndianness) -> Bool {
        
        
        guard elementType != .null else { return false }
        if let initialValue = initialValue {
            guard initialValue.brbonType == elementType else { return false }
        }
        
        
        // Determine size of the value field
        // =================================
        
        var itemSize: UInt32 = minimumItemByteCount + UInt32(nameFieldDescriptor.byteCount) + 8
        
        
        // Add the initial allocation for the elements
        
        let elementSize = elementValueLength ?? elementType.defaultByteSize
        if initialCount > 0 {
            itemSize += (elementSize * initialCount).roundUpToNearestMultipleOf8()
        }
        
        
        if let fixedItemLength = fixedItemLength {
            
            
            // Range limit
            
            guard fixedItemLength <= UInt32(Int32.max) else { return false }
            
            
            // If specified, the fixed item length must at least be large enough for the name field
            
            guard fixedItemLength >= itemSize else { return false }
            
            
            // Make the itemLength the fixed item length, but ensure that it is a multiple of 8 bytes.
            
            itemSize = fixedItemLength.roundUpToNearestMultipleOf8()
        }

        
        // Create the array structure
        
        var p = atPtr
        
        ItemType.array.rawValue.brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 1)
        
        UInt8(0).brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 1)
        
        UInt8(0).brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 1)
        
        nameFieldDescriptor.byteCount.brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 1)
        
        itemSize.brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 4)
        
        parentOffset.brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 4)
        
        initialCount.brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 4)
        
        
        if nameFieldDescriptor.byteCount > 0 {
            nameFieldDescriptor.brbonBytes(toPtr: p, endianness)
            p = p.advanced(by: Int(nameFieldDescriptor.byteCount))
        }
        
        elementType.rawValue.brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 1)
        
        UInt8(0).brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 1)
        
        UInt8(0).brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 1)
        
        UInt8(0).brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 1)
        
        let evLength = elementValueLength ?? elementType.defaultByteSize
        evLength.brbonBytes(toPtr: p, endianness)
        p = p.advanced(by: 4)
        
        var ecount = initialCount
        while ecount > 0 {
            
            switch elementType {
            
            case .null, .array, .dictionary, .sequence: break
                
            case .bool:
                (initialValue ?? false).brbonBytes(toPtr: p, endianness)
                p = p.advanced(by: 1)
                
            case .uint8, .int8:
                (initialValue ?? 0).brbonBytes(toPtr: p, endianness)
                p = p.advanced(by: 1)
                
            case .uint16, .int16:
                (initialValue ?? 0).brbonBytes(toPtr: p, endianness)
                p = p.advanced(by: 2)
                
            case .uint32, .int32:
                (initialValue ?? 0).brbonBytes(toPtr: p, endianness)
                p = p.advanced(by: 4)
                
            case .float32:
                (initialValue ?? Float32(0)).brbonBytes(toPtr: p, endianness)
                p = p.advanced(by: 4)
                
            case .uint64, .int64, .float64:
                (initialValue ?? 0).brbonBytes(toPtr: p, endianness)
                p = p.advanced(by: 8)
                
            case .string:
                (initialValue ?? "").brbonBytes(toPtr: p, endianness)
                p = p.advanced(by: Int((initialValue ?? "").brbonCount))
                
            case .binary:
                (initialValue ?? Data()).brbonBytes(toPtr: p, endianness)
                p = p.advanced(by: Int((initialValue ?? Data()).brbonCount))
            }
            
            ecount -= 1
        }
        
        // Success
        
        return true
    }

    
    /// The number of bytes in an element
    
    internal var elementByteCount: UInt32 {
        get { return UInt32(valuePtr.advanced(by: 4), endianness) }
        set { newValue.brbonBytes(toPtr: valuePtr.advanced(by: 4), endianness) }
    }
    
    
    /// The offset from the first byte of the first element to the indexed element.
    ///
    /// - Note: This operation does not check for validity of the index.
    ///
    /// - Parameter for: the index of the element for which to determine the offset.
    ///
    /// - Returns: The offset.
    
    internal func elementOffset(for index: UInt32) -> UInt32 {
        return UInt32(index) * elementByteCount
    }
    
    
    /// A pointer to the first byte of the indexed element.
    ///
    /// - Note: This operation does not check for validity of the index.
    ///
    /// - Parameter for: the index of the element for which to return the pointer.
    ///
    /// - Returns: The pointer.

    internal func elementPtr(for index: UInt32) -> UnsafeMutableRawPointer {
        return valuePtr.advanced(by: 8 + Int(elementOffset(for: index)))
    }
    
    private func element(at index: Int) -> Item? {
        guard isArray else { return fatalOrNil("Subscript with Int on non-array") }
        guard index >= 0 && index < Int(count) else {
            let range = Range(uncheckedBounds: (lower: 0, upper: count))
            return fatalOrNil("Index (\(index)) out of range \(range)")
        }
        return Item.init(basePtr: elementPtr(for: UInt32(index)), parentPtr: basePtr, endianness: endianness)
    }
}
