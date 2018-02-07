//
//  Item-Subscript-Dictionary.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/01/18.
//
//

import Foundation
import BRUtils


extension Item {
    
    
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
    public func addNull(name: String, nameFieldByteCount: Int? = nil, valueByteCount: Int? = nil) -> Result {
        
        guard isDictionary else { return .onlySupportedOnDictionary }
        
        
        // Remove an existing item with this name
        
        remove(name)
        
        
        // Make sure there is enough free space available
        
        guard let nfd = NameFieldDescriptor(name, nameFieldByteCount) else { return .illegalNameField }
        
        let bytes = minimumItemByteCount + nfd.byteCount + (valueByteCount ?? 0)

        guard ensureValueStorage(for: bytes) == .success else { return .outOfStorage }
        
        
        // Add the null at the end
        
        Item.createNull(atPtr: newItemPtr, nameFieldDescriptor: nfd, parentOffset: offsetInBuffer(for: basePtr), valueByteCount: valueByteCount, endianness: endianness)
        
        
        // Increment the number of children
        
        count += 1
        
        return .success
    }

    
    public subscript(name: String) -> Item {
        get {
            if let found = findItem(for: name) { return found }
            return (addNull(name: name, valueByteCount: 8) == .success) ? (findItem(for: name) ?? Item.nullItem) : Item.nullItem
        }
    }
    
    subscript(name: String) -> Bool? {
        get { return self[name].bool }
        set {
            guard let newValue = newValue else { return }
            // Note: The (nvr) value length is zero because the value is stored in the value/count field.
            subscriptAssignment(for: name, valueByteCount: 0, assignment: { $0.bool = newValue })
        }
    }
    
    public subscript(name: String) -> UInt8? {
        get { return self[name].uint8 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 0, assignment: { $0.uint8 = newValue })
        }
    }
    
    public subscript(name: String) -> Int8? {
        get { return self[name].int8 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 0, assignment: { $0.int8 = newValue })
        }
    }
    
    public subscript(name: String) -> UInt16? {
        get { return self[name].uint16 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 0, assignment: { $0.uint16 = newValue })
        }
    }
    
    public subscript(name: String) -> Int16? {
        get { return self[name].int16 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 0, assignment: { $0.int16 = newValue })
        }
    }
    
    public subscript(name: String) -> UInt32? {
        get { return self[name].uint32 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 0, assignment: { $0.uint32 = newValue })
        }
    }
    
    public subscript(name: String) -> Int32? {
        get { return self[name].int32 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 0, assignment: { $0.int32 = newValue })
        }
    }
    
    public subscript(name: String) -> UInt64? {
        get { return self[name].uint64 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 8, assignment: { $0.uint64 = newValue })
        }
    }
    
    public subscript(name: String) -> Int64? {
        get { return self[name].int64 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 8, assignment: { $0.int64 = newValue })
        }
    }
    
    public subscript(name: String) -> Float32? {
        get { return self[name].float32 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 0, assignment: { $0.float32 = newValue })
        }
    }
    
    public subscript(name: String) -> Float64? {
        get { return self[name].float64 }
        set {
            guard let newValue = newValue else { return }
            subscriptAssignment(for: name, valueByteCount: 8, assignment: { $0.float64 = newValue })
        }
    }
    
    public subscript(name: String) -> String? {
        get { return self[name].string }
        set {
            guard let newValue = newValue else { return }
            guard let strLen = newValue.data(using: .utf8)?.count, strLen < Int(Int32.max) else { return }
            subscriptAssignment(for: name, valueByteCount: newValue.byteCountItem(), assignment: { $0.string = newValue })
        }
    }
    
    public subscript(name: String) -> Data? {
        get { return self[name].binary }
        set {
            guard let newValue = newValue else { return }
            guard newValue.byteCountItem() < Int(Int32.max) else { return }
            subscriptAssignment(for: name, valueByteCount: newValue.byteCountItem(), assignment: { $0.binary = newValue })
        }
    }
    
    
    /// Removes the item with the given name (if any).
    ///
    /// - Returns: One of the following: .onlySupportedOnDictionary, .itemNotFound, .success
    
    @discardableResult
    public func remove(_ name: String) -> Result {
        
        guard isDictionary else { return .onlySupportedOnDictionary }
        
        guard let item = findItem(for: name) else { return .itemNotFound }
        
        let dstPtr = item.basePtr
        let srcPtr = item.basePtr.advanced(by: item.byteCount)
        let len = srcPtr.distance(to: newItemPtr)
        
        moveBlock(dstPtr, srcPtr, len)
        
        count -= 1
        
        return .success
    }
    
    
    /// Updates the value or adds a new value for the given name
    
    @discardableResult
    public func updateValue<T>(_ value: T, forName name: String) -> Result where T:BrbonCoder {
        
        guard isDictionary else { return .onlySupportedOnDictionary }
        
        guard let nfd = NameFieldDescriptor(name, nameFieldByteCount), nfd.data != nil else { return .illegalNameField }

        if let item = findItem(with: nfd.crc, stringData: nfd.data!) {
            
            // Replace value
            
            // Ensure enough space is available
            
            let availableByteCount = byteCount
            let neededByteCount = minimumItemByteCount + nfd.byteCount + value.byteCountItem(nfd)
            
            
            
        } else {
            
            // Add new value
        }
        
        return .success
    }
    
    
    // *****************
    // MARK: - Internals
    // *****************
    
    
    /// Helper for subscript assignment
    
    fileprivate func subscriptAssignment(for name: String, valueByteCount: Int, assignment: (Item) -> ()) {
        if let found = findItem(for: name) {
            assignment(found)
        } else {
            _ = addNull(name: name, valueByteCount: valueByteCount)
            if let found = findItem(for: name) {
                assignment(found)
            }
        }
    }

    
    /// The pointer to the memory area where a new item should be added.

    fileprivate var newItemPtr: UnsafeMutableRawPointer {
        var p = valuePtr
        var remainder = count
        while remainder > 0 {
            let byteCount = Int(UInt32.readValue(atPtr: p.advanced(by: itemByteCountOffset), endianness))
            p = p.advanced(by: byteCount)
            remainder -= 1
        }
        return p
    }
    
    
    /// Create the memory structure of a dictionary item.
    ///
    /// - Parameters:
    ///   - atPtr: The pointer to where the dictionary mustb e created.
    ///   - nameFieldDescriptor: The name field descriptor.
    ///   - parentOffset: An offset from the start of the buffer to the first byte of the parent item.
    ///   - fixedItemLength: The length of the array, if this is set, the array length cannot be changed. The actual length of the array will always be a mulitple of 8.
    ///   - initialBufferSize: The size of the buffer area used for the initial allocation. When an initialCount/elementValueLength is
    ///   - bufferIncrements: The number of bytes with which to increment the buffer if it is too small.
    ///   - endianness: The endianness to be used in this dictionary manager.
    
    internal static func createDictionary(
        atPtr: UnsafeMutableRawPointer,
        nameFieldDescriptor: NameFieldDescriptor,
        parentOffset: Int,
        elementValueLength: Int? = nil,
        fixedItemLength: Int? = nil,
        endianness: Endianness = machineEndianness) -> Bool {
        
        
        // Determine size of the value field
        // =================================
        
        var itemSize: Int = minimumItemByteCount + nameFieldDescriptor.byteCount
        
        
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
        
        ItemType.dictionary.storeValue(atPtr: p)
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
        
        UInt32(0).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 4)
        
        
        if nameFieldDescriptor.byteCount > 0 {
            nameFieldDescriptor.storeValue(atPtr: p, endianness)
            p = p.advanced(by: Int(nameFieldDescriptor.byteCount))
        }
                
        
        // Success
        
        return true
    }
    
    
    /// Returns the item for a given name.
    ///
    /// The returned value item will remain valid until the dictionary is updated in a way that changes the data structure. This will happen when changing the length of any item or the removal of any item.
    ///
    /// - Note: In the current version of the API it is not possible to know when the returned ValueItem is invalidated. Hence it is strongly recommended NOT to store them.
    
    internal func findItem(for name: String) -> Item? {
        
        guard let nameData = name.data(using: .utf8) else { return nil }
        
        let crc = nameData.crc16()
        
        return findItem(with: crc, stringData: nameData)
    }
    
    
    /// Searches for an item with the same hash and string data as the search paremeters.
    ///
    /// - Parameters:
    ///   - with: A CRC16 over the stringData.
    ///   - stringData: The bytes that make up a name string.
    ///
    /// - Returns: A pointer to the first byte
    
    internal func findItem(with hash: UInt16, stringData: Data) -> Item? {
        
        var ptrFound: UnsafeMutableRawPointer?
        
        forEachAbortOnTrue() {
            if $0.nameHash != hash { return false }
            if $0.nameCount != stringData.count { return false }
            if $0.nameData != stringData { return false }
            ptrFound = $0.basePtr
            return true
        }
        
        if let aptr = ptrFound {
            return Item(basePtr: aptr, parentPtr: basePtr, endianness: endianness)
        } else {
            return nil
        }
    }
}
