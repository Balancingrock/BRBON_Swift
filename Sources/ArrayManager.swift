//
//  ArrayManager.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 25/01/18.
//
//

import Foundation
import BRUtils


public class ArrayManager {
    
    internal var buffer: UnsafeMutableRawBufferPointer
    
    internal(set) var endianness: Endianness
    
    public var bufferIncrements: Int
    
    internal var basePtr: UnsafeMutableRawPointer
    internal var rootItem: Item!
    internal var elementType: ItemType // Cached
    
    internal(set) var mutableItemLength: Bool

    
    /// Create a new ArrayManager.
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
    
    public init?<T>(
        elementType: ItemType,
        initialCount: UInt32 = 0,
        initialValue: T? = nil,
        elementValueLength: UInt32? = nil,
        name: String? = nil,
        nameFieldLength: UInt8? = nil,
        fixedItemLength: UInt32? = nil,
        initialBufferSize: Int = 1024,
        bufferIncrements: Int = 1024,
        endianness: Endianness = machineEndianness) where T: BrbonCoder {
    
        
        guard elementType != .null else { return nil }
        
        self.elementType = elementType
        self.endianness = endianness
        
        
        // Create local variables because the input parameters cannot be changed and the self members are let members.
        
        var bufferSize = initialBufferSize
        var increments = bufferIncrements
        
        
        // Create the name field info
        
        guard let nameFieldDescriptor = NameFieldDescriptor(name, nameFieldLength) else { return nil }
        
        
        // Determine size of the value field
        // =================================
        
        var itemSize: UInt32 = minimumItemByteCount + UInt32(nameFieldDescriptor.byteCount) + 8
        
        
        // Add the initial allocation for the elements
        
        let elementSize = elementValueLength ?? elementType.assumedValueByteCount
        if initialCount > 0 {
            itemSize += (elementSize * initialCount).roundUpToNearestMultipleOf8()
            bufferSize = max(itemSize, bufferSize) // Up the buffer size if the initial elements don't fit.
        }
        
        
        if let fixedItemLength = fixedItemLength {
            
            
            // Range limit
            
            guard fixedItemLength <= UInt32(Int32.max) else { return nil }
            
            
            // If specified, the fixed item length must at least be large enough for the name field
            
            guard fixedItemLength >= itemSize else { return nil }
            
            
            // Make the itemLength the fixed item length, but ensure that it is a multiple of 8 bytes.
            
            itemSize = fixedItemLength.roundUpToNearestMultipleOf8()
            
            
            // If the item length is bigger than the buffersize and the increments are zero, then the item cannot be constructed
            
            if itemSize > bufferSize {
                
                guard increments > 0 else { return nil }
                
                increments = 0// Set to zero to prevent further increases in size
            }
            
            bufferSize = itemSize
        }
        
        
        // Assign the increments that must be used
        
        self.bufferIncrements = increments
        
        
        // Allocate the buffer
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: bufferSize)
        self.basePtr = buffer.baseAddress!
        
        
        // Set item length mutability
        
        self.mutableItemLength = (fixedItemLength == nil)
        
        
        // Create the array structure
        
        guard Item.createArray(
            atPtr: basePtr,
            elementType: elementType,
            initialCount: initialCount,
            nameFieldDescriptor: nameFieldDescriptor,
            parentOffset: 0,
            elementValueLength: elementValueLength,
            fixedItemLength: fixedItemLength,
            endianness: endianness) else { self.buffer.deallocate(); return nil }
        
        
        // The root item
        
        self.rootItem = Item(basePtr: self.basePtr, parentPtr: nil, manager: self, endianness: endianness)

        
        // Zero the remainder of the buffer
        
        let zeroingLength = Int(bufferSize - rootItem.byteCount)/4
        let startPtr = basePtr.advanced(by: Int(rootItem.byteCount))
        _ = Darwin.memset(startPtr, 0, zeroingLength)
    }


    /// - Returns: The number of elements in the array.
    
    public var count: Int { return rootItem.count }
    
    
    /// - Returns: The number of bytes the (root) array item will occupy when written or transferred.
    
    public var byteCount: UInt32 { return rootItem.byteCount }
    
    
    /// - Returns: The name of the array (if any).
    
    public var name: String? { return rootItem.name }
    
    
    /// Subscript accessors.
    
    public subscript(index: Int) -> Item {
        get {
            let item: Item = rootItem[index]
            item.manager = self
            return item
        }
    }
    
    public subscript(index: Int) -> Bool? {
        get { return rootItem[index].bool }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> Int8? {
        get { return rootItem[index].int8 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> Int16? {
        get { return rootItem[index].int16 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> Int32? {
        get { return rootItem[index].int32 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> Int64? {
        get { return rootItem[index].int64 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> UInt8? {
        get { return rootItem[index].uint8 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> UInt16? {
        get { return rootItem[index].uint16 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> UInt32? {
        get { return rootItem[index].uint32 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> UInt64? {
        get { return rootItem[index].uint64 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> Float32? {
        get { return rootItem[index].float32 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> Float64? {
        get { return rootItem[index].float64 }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> String? {
        get { return rootItem[index].string }
        set { rootItem[index] = newValue }
    }
    
    public subscript(index: Int) -> Data? {
        get { return rootItem[index].binary }
        set { rootItem[index] = newValue }
    }

    
    /// Adds a new item to the end of the array.
    ///
    /// The array will grow by one item on success. If the array cannot grow or if the value is not of the expected type, then the operation will fail. The byte count of the array can increase as a result. Notice that any byte count increase will always be in a multiple of 8 bytes.
    ///
    /// - Note: Works only on an item of the type aray.
    ///
    /// - Parameter value: A value that can implements the BrbonBytes protocol.
    ///
    /// - Returns: An ignorable result, .success if the append worked, a failure indicator if not.
    
    @discardableResult
    public func append<T>(_ value: T) -> Result where T:BrbonCoder { return rootItem.append(value) }
    
    
    /// Removes an item from the array.
    ///
    /// The array will decrease by item as a result. If the index is out of bounds the operation will fail. Notice that the bytecount of the array will not decrease. To remove unnecessary bytes use the "minimizeByteCount" operation.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: An ignorable result, .success if the remove worked, a failure indicator if not.
    
    @discardableResult
    public func remove(at index: Int) -> Result { return rootItem.remove(at: index) }
    
    
    /// Creates 1 or a number of new elements at the end of the array. If a default value is given, it will be used. If no default value is specified the content bytes will be set to zero.
    ///
    /// - Parameters:
    ///   - amount: The number of elements to create, default = 1.
    ///   - value: The default value for the new elements, default = nil.
    ///
    /// - Returns: .success or an error indicator.
    
    @discardableResult
    public func createNewElements<T>(amount: UInt32 = 1, value: T? = nil) -> Result where T:BrbonCoder {
        return rootItem.createNewElements(amount: amount, value: value)
    }
    
    
    /// Inserts a new element at the given position.
    
    @discardableResult
    public func insert<T>(_ value: T, at index: Int) -> Result where T:BrbonCoder { return rootItem.insert(value, at: index) }
}

extension ArrayManager: BufferManagerProtocol {

    
    /// BufferManagerProtocol
    
    var unusedByteCount: Int { return buffer.count - rootItem.byteCount }
    
    
    /// Increases the size of the buffer by at least the given amount of bytes.
    ///
    /// The buffer size will only be incremented if the _bufferIncrement_ is > 0. If the requested increment is smaller than _bufferIncrement_, the value _bufferIncrement_ will be used instead.
    ///
    /// __Side effects__: The _buffer_ and _ptr_ members will be updated.
    ///
    /// - Parameters:
    ///   - by: The minimum number of bytes to increase the buffer size with.
    ///
    /// - Returns: True on success, false on failure.
    
    internal func increaseBufferSize(by bytes: Int) -> Bool {
        
        guard bufferIncrements > 0 else { return false }
        
        let increase = max(bytes, Int(bufferIncrements))
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(count: buffer.count + increase)
        
        _ = Darwin.memmove(newBuffer.baseAddress!, buffer.baseAddress!, buffer.count)
        print("TBD: Add updating of item pointers for items that have been exposed to the API user")
        
        buffer.deallocate()
        buffer = newBuffer
        basePtr = newBuffer.baseAddress!
        rootItem.basePtr = newBuffer.baseAddress!
        
        return true
    }
    
    internal func moveBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer, _ length: Int) {
        _ = Darwin.memmove(dstPtr, srcPtr, length)
        print("TBD: Add updating of item pointers for items that have been exposed to the API user")
    }

    internal func moveEndBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer) {
        let lastBytePtr = basePtr.advanced(by: Int(rootItem.byteCount))
        let length = srcPtr.distance(to: lastBytePtr)
        _ = Darwin.memmove(dstPtr, srcPtr, length)
        print("TBD: Add updating of item pointers for items that have been exposed to the API user")
    }
}
