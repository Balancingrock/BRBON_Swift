//
//  DictionaryManager.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 29/01/18.
//
//

import Foundation
import BRUtils


public class DictionaryManager {
    
    
    /// The buffer containing the dictionary structure.
    ///
    /// Note that this buffer may change several times during runtime when the original space allocated to it was not big enough. Unless the bufferIncrements is zero.
    
    internal var buffer: UnsafeMutableRawBufferPointer
    
    
    /// The minimum buffer increments by which the buffer is grown to accomodate more items as the current buffer grows too small.
    
    public var bufferIncrements: UInt32
    
    
    /// The endianness of the dictionary structure and its data contents. This cannot change after the creation of the manager.
    
    public let endianness: Endianness
    
    
    /// A permanent shortcut for the root dictionary. The basePtr will be changed when the buffer grows.
    
    internal let rootItem: Item!
    
    
    /// Create a new directory manager. The directory manager will allocate a buffer in memory and in that buffer create a BRBON directory item. This item will become the root item for subsequent additions.
    ///
    /// All public directory access operation are bridged to the dictionary manager such that the manager itself can serve as the root for dictionary operations.
    ///
    /// - Parameters:
    ///   - name: The name that should be assigned to the root item. Note that this name is not used in subsequent access operations including subscripts operations. The UTF8 representation of the name should be less than 246 bytes.
    ///   - nameFielByteCount: The byte count for the name field in the item. If non-nil the name field will have exactly this size. If the given name does not fit, the creation of the manager will fail.
    ///   - initialByteCount: The initial byte count for the root item (dictionaty). Setting this value to non-nil will ensure a dictionary size of at least this many bytes. However the dictionary will expand to accomodate additional data if the buffer size is larger than this value or when the buffer size can be increased.
    ///   - initialBufferSize: The initial size of the buffer in which the rot dictionary is created.
    ///   - bufferIncrements: This value has to meanings: When it is zero, the buffer cannot be grown beyond the initialBufferSize. When it is non-zero it is the minimum size by which the buffer will grow when the dictionary must expand for new items.
    ///   - endianness: The endianness for the directory structure and the data stored in it.
    
    init?(
        name: String? = nil,
        nameFieldByteCount: UInt8? = nil,
        initialByteCount: UInt32? = nil,
        initialBufferSize: UInt32 = 1024,
        bufferIncrements: UInt32 = 1024,
        endianness: Endianness = machineEndianness) {

        
        self.endianness = endianness
        
        
        // Create local variables because the input parameters cannot be changed and the self members are let members.
        
        var bufferSize = initialBufferSize
        var increments = bufferIncrements


        // Create the name field info
        
        guard let nameFieldDescriptor = NameFieldDescriptor(name, nameFieldByteCount) else { return nil }
        
        
        // Determine size of the value field
        // =================================
        
        var itemLength: UInt32 = minimumItemByteCount + UInt32(nameFieldDescriptor.byteCount)
        
        
        if let initialByteCount = initialByteCount {
            
            
            // Range limit
            
            guard initialByteCount <= UInt32(Int32.max) else { return nil }
            
            
            // If specified, the fixed item length must at least be large enough for the name field
            
            guard initialByteCount >= itemLength else { return nil }
            
            
            // Make the itemLength the fixed item length, but ensure that it is a multiple of 8 bytes.
            
            itemLength = initialByteCount.roundUpToNearestMultipleOf8()
            
            
            // If the item length is bigger than the buffersize and the increments are zero, then the item cannot be constructed
            
            if itemLength > bufferSize {
                
                guard increments > 0 else { return nil }
                
                increments = 0// Set to zero to prevent further increases in size
            }
            
            bufferSize = itemLength
        }
        
        
        // Assign the increments that must be used
        
        self.bufferIncrements = increments
        
        
        // Allocate the buffer
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: Int(bufferSize))
        
        
        // Create the dictionary structure
        
        guard Item.createDictionary(atPtr: buffer.baseAddress!, nameFieldDescriptor: nameFieldDescriptor, parentOffset: 0) else {
            buffer.deallocate()
            return nil
        }
        
        
        // The root item
        
        self.rootItem = Item(basePtr: buffer.baseAddress!, parentPtr: nil, endianness: endianness)
        self.rootItem.manager = self
        
        
        // Zero the remainder of the buffer
        
        let zeroingLength = Int(bufferSize - rootItem.byteCount)/4
        let startPtr = buffer.baseAddress!.advanced(by: Int(rootItem.byteCount))
        _ = Darwin.memset(startPtr, 0, zeroingLength)
    }
    
    
    /// Free the current buffer when the manager is no longer needed.
    
    deinit {
        buffer.deallocate()
    }
    
    
    /// - Returns: The number of elements in the array.
    
    public var count: Int { return rootItem.count }
    
    
    /// - Returns: The number of bytes the (root) array item will occupy when written or transferred.
    
    public var byteCount: UInt32 { return rootItem.byteCount }
    
    
    /// - Returns: The name of the array (if any).
    
    public var name: String? { return rootItem.name }

    
    /// Subscript accessors
    
    public subscript(name: String) -> Item {
        get { return rootItem[name] }
    }
    
    subscript(name: String) -> Bool? {
        get { return rootItem[name].bool }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> UInt8? {
        get { return rootItem[name].uint8 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> Int8? {
        get { return rootItem[name].int8 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> UInt16? {
        get { return rootItem[name].uint16 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> Int16? {
        get { return rootItem[name].int16 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> UInt32? {
        get { return rootItem[name].uint32 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> Int32? {
        get { return rootItem[name].int32 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> UInt64? {
        get { return rootItem[name].uint64 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> Int64? {
        get { return rootItem[name].int64 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> Float32? {
        get { return rootItem[name].float32 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> Float64? {
        get { return rootItem[name].float64 }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> String? {
        get { return rootItem[name].string }
        set { rootItem[name] = newValue }
    }
    
    public subscript(name: String) -> Data? {
        get { return rootItem[name].binary }
        set { rootItem[name] = newValue }
    }

    
    /// Adds a null value to a dictionary using the given name.
    ///
    /// Null values can be considered placeholders for future values. A null value may be changed into any other kind of value later.
    ///
    /// An alternative way to create a null value is to create any other kind of value and assign a nil to that variable. This will change that value into a null value while maintaining the original size and name parameters.
    ///
    /// - Parameters:
    ///   - name: The name for the null item.
    ///   - nameFieldByteCount: The initial byte count for the name field in the item if used. Range 0...248. Note that the actual length will be rounded up to a multiple of 8, that 3 bytes will be allocated for the hash and the byteCount.
    ///   - valueByteCount: The byte count for the value part of the null item. Though the null item itself does not have a value, it is recommended to set a byte count for the item value field if the null will be changed into a value later. The byte count of the item will always be a multiple of 8, thus the value field may be increased to fit.
    ///
    /// - Returns: .success, or a failure code.
    
    @discardableResult
    public func addNull(name: String, nameFieldByteCount: UInt8? = nil, valueByteCount: UInt32? = nil) -> Result {
        return rootItem.addNull(name: name, nameFieldByteCount: nameFieldByteCount, valueByteCount: valueByteCount)
    }

    
    /// Remove an item with the given name. For a sequence it will remove the first item with the given name.
    ///
    /// - Parameter name: The name of the item to remove.
    ///
    /// - Returns: .success or a failure code.
    
    public func remove(_ name: String) -> Result {
        return rootItem.remove(name)
    }
    
    
    /// Update an item or add a new item.
    
    public func updateValue<T>(_ value: T, forName name: String) -> Result where T:BrbonCoder {
        return rootItem.updateValue(value, forName: name)
    }
}

extension DictionaryManager: BufferManagerProtocol {
    
    
    /// BufferManagerProtocol
    
    internal var unusedByteCount: UInt32 { return UInt32(buffer.count) - rootItem.byteCount }
    
    
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
        rootItem.basePtr = newBuffer.baseAddress!
        
        return true
    }
    
    internal func moveBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer, _ length: Int) {
        _ = Darwin.memmove(dstPtr, srcPtr, length)
        print("TBD: Add updating of item pointers for items that have been exposed to the API user")
    }
    
    internal func moveEndBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer) {
        let lastBytePtr = buffer.baseAddress!.advanced(by: Int(rootItem.byteCount))
        let byteCount = srcPtr.distance(to: lastBytePtr)
        _ = Darwin.memmove(dstPtr, srcPtr, byteCount)
        print("TBD: Add updating of item pointers for items that have been exposed to the API user")
    }
}
