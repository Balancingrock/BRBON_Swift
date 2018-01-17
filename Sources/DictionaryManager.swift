//
//  Manager.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 26/12/17.
//
//

import Foundation
import BRUtils


// ******************************************************************
// **                                                              **
// ** INTERNAL OPERATIONS ARE NOT PROTECTED AGAINST ILLEGAL VALUES **
// **                                                              **
// ******************************************************************


/// The manager of a BRBON data area

public class DictionaryManager: Item {
    
    
    /// The number of bytes not yet used in the current buffer
    
    public var availableBytes: UInt32 { return UInt32(buffer.count - buffer.baseAddress!.distance(to: entryPtr)) }
    
    
    /// The endianness of the root item and all child items
    
    public let endianness: Endianness
    
    
    /// The number of bytes with which to increment the buffer size if there is insufficient free space available.
    
    public let bufferIncrements: UInt32
    
    
    /// Returns the buffer as a Data object. The buffer will not be copied, but wrapped in a data object.
    
    public var asData: Data {
        return Data(bytesNoCopy: ptr, count: ptr.distance(to: entryPtr), deallocator: Data.Deallocator.none)
    }
    
    /// Create a new DictionaryManager.
    ///
    /// - Parameters:
    ///   - initialBufferSize: The size of the buffer area used for the initial allocation.
    ///   - bufferIncrements: The number of bytes with which to increment the buffer if it is too small.
    ///   - endianness: The endianness to be used in this dictionary manager.
    
    public init?(
        name: String? = nil,
        fixedNameFieldLength: UInt8? = nil,
        fixedItemLength: UInt32? = nil,
        initialBufferSize: UInt32 = 1024,
        bufferIncrements: UInt32 = 1024,
        endianness: Endianness = machineEndianness) {
        
        
        self.endianness = endianness

        
        // Create local variables because the input parameters cannot be changed and the self members are let members.
        
        var bufferSize = initialBufferSize
        var increments = bufferIncrements

        
        // Create the name field info
        
        guard let nameFieldDescriptor = nameFieldDescriptor(for: name, fixedLength: fixedNameFieldLength) else { return nil }

        
        // Determine size of the value field
        // =================================
        
        var itemLength: UInt32 = minimumItemLength + UInt32(nameFieldDescriptor.length)

        
        if let fixedItemLength = fixedItemLength {
            
            
            // Range limit
            
            guard fixedItemLength <= UInt32(Int32.max) else { return nil }

            
            // If specified, the fixed item length must at least be large enough for the name field

            guard fixedItemLength >= itemLength else { return nil }
            
            
            // Make the itemLength the fixed item length, but ensure that it is a multiple of 8 bytes.
            
            itemLength = fixedItemLength.roundUpToNearestMultipleOf8()
            
            
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
        self.ptr = buffer.baseAddress!
        
        
        // Set item length mutability
        
        self.mutableItemLength = (fixedItemLength == nil)


        // Create the dictionary structure
        
        var dptr = ptr
        
        ItemType.dictionary.rawValue.brbonBytes(endianness, toPointer: &dptr)                // Type
        UInt8(0).brbonBytes(endianness, toPointer: &dptr)                                    // Options
        UInt8(0).brbonBytes(endianness, toPointer: &dptr)                                    // Flags
        nameFieldDescriptor.length.brbonBytes(endianness, toPointer: &dptr)                  // Name field length
        
        itemLength.brbonBytes(endianness, toPointer: &dptr)                                  // Item length
        
        UInt32(0).brbonBytes(endianness, toPointer: &dptr)                                   // Parent offset
        
        UInt32(0).brbonBytes(endianness, toPointer: &dptr)                                   // Count
        
        if nameFieldDescriptor.length > 0 {
            nameFieldDescriptor.crc.brbonBytes(endianness, toPointer: &dptr)                 // Name hash
            UInt8(nameFieldDescriptor.data!.count).brbonBytes(endianness, toPointer: &dptr)  // Name length
            nameFieldDescriptor.data!.brbonBytes(endianness, toPointer: &dptr)               // Name bytes
        }
        

        // Setup the entry point for the child items

        self.entryPtr = dptr
    }
    
    
    /// Creates a new Dictionary Manager with the data in the given filepath.
    ///
    /// - Parameters:
    ///   - file: A URL pointing at the file to read.
    ///   - initialBufferSize: The size of the buffer to be allocated. Note that when the file size is bigger than this value, the file size will take precedence.
    ///   - bufferIncrements: The size of buffer increments. If zero, the data structure will be unable to grow beyond the buffer size.
    ///   - endianness: The endianness of the data.
    
    public init?(
        file url: URL,
        initialBufferSize: UInt32 = 1024,
        bufferIncrements: UInt32 = 1024,
        endianness: Endianness = machineEndianness) {
        
        
        // Read the data from file
        
        guard let data = try? Data.init(contentsOf: url) else { return nil }
        
        
        // Allocate a buffer for the data and copy the data into it
        
        let allocationCount = max(data.count + 1, Int(initialBufferSize))

        buffer = UnsafeMutableRawBufferPointer.allocate(count: allocationCount)
        
        let ptr = buffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
        
        data.copyBytes(to: ptr, count: data.count)
        
        
        // Setup members
        
        self.bufferIncrements = bufferIncrements
        self.ptr = buffer.baseAddress!
        self.entryPtr = self.ptr.advanced(by: data.count)
        self.mutableItemLength = (bufferIncrements == 0)
        self.endianness = endianness
    }
    
    
    /// Returns the count of the number of children in the dictionary.
    
    public var count: UInt32 {
        get {
            return valueCount
        }
        set {
            var cptr = ptr.advanced(by: itemValueCountOffset)
            newValue.brbonBytes(endianness, toPointer: &cptr)
        }
    }
  
    
    /// Save the dictionary structure to file
    
    public func write(to file: URL) -> Bool {
        guard ((try? asData.write(to: file)) != nil) else { return false }
        return true
    }

    
    /// Check that the data area is consistent with respect to the BRBON structure that wraps the information.
    ///
    /// - Returns: Nil if there no errors were found. Otherwise an error message.
    
    public func structureCheck() -> String? {
        
        if let type = ItemType(ptr), type == .dictionary {} else { return "Not a dictionary" }
        
        var zero = UInt8(ptr.advanced(by: 1), endianness: endianness)
        if zero != 0 { return "Expected zero in options of dictionary" }
        
        zero = UInt8(ptr.advanced(by: 2), endianness: endianness)
        if zero != 0 { return "Expected zero in flags of dictionary" }
        
        var len8 = UInt8(ptr.advanced(by: 3), endianness: endianness)
        if (len8 & 0x07) != 0 { return "Name length not a multiple of 8" }
        
        var len32 = UInt32(ptr.advanced(by: itemLengthOffset), endianness: endianness)
        if (len32 & 0x07) != 0 { return "Dictionary length not a multiple of 8" }
        if len32 > UInt32(Int32.max) { return "Dictionary length too long (> Int32.max)" }
        
        var par = UInt32(ptr.advanced(by: itemParentOffsetOffset), endianness: endianness)
        if par != 0 { return "Parent of dictionary should be zero" }
        
        let cnt32 = UInt32(ptr.advanced(by: itemValueCountOffset), endianness: endianness)
        if cnt32 > UInt32(Int32.max) { return "Dictionary count too high (> Int32.max)" }
        
        if nameFieldLength > 0 {
            let crc = UInt16(ptr.advanced(by: itemNvrFieldOffset), endianness: endianness)
            let dcnt = UInt8(ptr.advanced(by: nameCountOffset), endianness: endianness)
            let nameData = Data(ptr.advanced(by: nameDataOffset), endianness: endianness, count: UInt32(dcnt))
            let str = String(ptr.advanced(by: nameDataOffset), endianness: endianness, count: UInt32(dcnt))
            if str.isEmpty { return "Could not convert dictionary name into a string" }
            if nameData.crc16() != crc { return "Crc of dictionary name does not match the calculated crc" }
        }
        
        // Now the directory structure is intact, we can use other internal operations to check for consistency of the inernal structure
        
        var error: String?
        var childCount: UInt32 = 0
        
        forEachAbortOnTrue() {
            
            if $0.ptr > entryPtr { error = "Illegal pointer for child item \($0.ptr)" ; return true }
            
            if ItemType($0.ptr) != nil {} else { error = "Not a valid type \($0.ptr)" ; return true }

            zero = UInt8($0.ptr.advanced(by: 1), endianness: endianness)
            if zero != 0 { error = "Expected zero in options of item \($0.ptr)" ; return true }

            zero = UInt8($0.ptr.advanced(by: 2), endianness: endianness)
            if zero != 0 { error = "Expected zero in flags of item \($0.ptr)" ; return true }

            len8 = UInt8($0.ptr.advanced(by: 3), endianness: endianness)
            if (len8 & 0x07) != 0 { error = "Name length not a multiple of 8 in item \($0.ptr)" ; return true }

            len32 = UInt32($0.ptr.advanced(by: itemLengthOffset), endianness: endianness)
            if (len32 & 0x07) != 0 { error = "Item length not a multiple of 8 in item \($0.ptr)" ; return true }
            if len32 > UInt32(Int32.max) { error = "Item length too long (> Int32.max) in item \($0.ptr)" ; return true }

            par = UInt32($0.ptr.advanced(by: itemParentOffsetOffset), endianness: endianness)
            if par != 0 { error = "Parent of dictionary should be zero in item \($0.ptr)" ; return true }

            if $0.nameFieldLength > 0 {
                let crc = UInt16($0.ptr.advanced(by: itemNvrFieldOffset), endianness: endianness)
                let dcnt = UInt8($0.ptr.advanced(by: nameCountOffset), endianness: endianness)
                let nameData = Data($0.ptr.advanced(by: nameDataOffset), endianness: endianness, count: UInt32(dcnt))
                let str = String($0.ptr.advanced(by: nameDataOffset), endianness: endianness, count: UInt32(dcnt))
                if str.isEmpty { error = "Could not convert item name into a string for item \($0.ptr)"; return true }
                if nameData.crc16() != crc { error = "Crc of item name does not match the calculated crc for item \($0.ptr)"; return true }
            }

            childCount += 1
            
            return false
        }
        
        if error == nil {
            if childCount < cnt32 { return "Missing child items" }
        }
        
        return error
    }
    
    
    /// Returns the item for a given name.
    ///
    /// The returned value item will remain valid until the dictionary is updated in a way that changes the data structure. This will happen when changing the length of any item or the removal of any item.
    ///
    /// - Note: In the current version of the API it is not possible to know when the returned ValueItem is invalidated. Hence it is strongly recommended NOT to store them.
    
    public func findItem(for name: String) -> ValueItem? {
        
        guard let nameData = name.data(using: .utf8) else { return nil }
        
        let crc = nameData.crc16()
        
        return findItem(with: crc, stringData: nameData)
    }
    
    

    /// Adds a new value to the dictionary using the given name.
    ///
    /// - Parameters:
    ///   - value: The value to be added to the dictionary. When nil, a null will be created.
    ///   - name: The name for the value item.
    ///   - fixedNameLength: The length (in bytes) to be used for the name field in the item. Note that the actual length will be rounded up to a multiple of 8. Specify nil if the default length should be used.
    ///   - fixedItemValueLength: The length of the value part of the item. The length of the item will always be a multiple of 8, thus the value length field may be a little larger that specified here. Specify nil if the default length should be used.
    ///
    /// - Returns: True on success, nil on failure.
    
    @discardableResult
    public func add(_ value: BrbonBytes?, name: String, fixedNameLength: UInt8? = nil, fixedItemValueLength: UInt32? = nil) -> Bool {

        
        guard let value = value else {
            return addNull(name: name, fixedNameLength: fixedNameLength, fixedItemValueLength: fixedItemValueLength)
        }
        
        
        // Create a new ValueItem
        
        guard let valueItem = ValueItem(value, name: name, fixedNameFieldLength: fixedNameLength, fixedItemValueLength: fixedItemValueLength, endianness: endianness) else { return false }
        
        
        // Remove an existing item with this name
        
        removeItem(name: name)

        
        // Add the item
        
        return add(valueItem)
    }
    
    
    /// Adds a null value to the dictionary using the given name.
    ///
    /// Null values can be considered placeholders for future values. A null value may be changed into any other kind of value later.
    ///
    /// An alternative way to create a null value is to create any other kind of value and assign a nil to that variable. This will change that value into a null value while maintaining the original size and name parameters.
    ///
    /// - Parameters:
    ///   - name: The name for the null item.
    ///   - fixedNameLength: The length (in bytes) to be used for the name field in the item. Note that the actual length will be rounded up to a multiple of 8. Specify nil if the default length should be used.
    ///   - fixedItemValueLength: The length of the value part of the null item. Though the null item itself does not have a value, it is recommended to set a value for the item value field if the null will be changed into a value later. The length of the item will always be a multiple of 8, thus the value length field may be increased to fit. Specify nil if the default length should be used.
    ///
    /// - Returns: True on success, nil on failure.
    
    @discardableResult
    public func addNull(name: String, fixedNameLength: UInt8? = nil, fixedItemValueLength: UInt32? = nil) -> Bool {
        
        guard let null = ValueItem.createNull(name: name, fixedNameFieldLength: fixedNameLength, fixedItemValueLength: fixedItemValueLength, endianness: endianness) else { return false }
        
        defer { null.deallocate() }
        
        
        // Remove an existing item with this name
        
        removeItem(name: name)
        
        
        // Create & Add the item
        
        return add(ValueItem(null.baseAddress!, endianness, self))
    }
    
    
    /// Removes the named item form the dictionary.
    ///
    /// - Parameters name: The name of the item to be removed.
    ///
    /// - Returns: True if the item was found and removed. False otherwise.
    
    @discardableResult
    public func removeItem(name: String) -> Bool {
        
        guard let nameData = name.data(using: .utf8) else { return false }
        
        let crc = nameData.crc16()
        
        if let exists = findItem(with: crc, stringData: nameData) {
            removeChild(item: exists)
            return true
        } else {
            return false
        }
    }
    
    
    /// Remove all items from the dictionary.
    
    public func removeAll() {
        
        count = 0
        if mutableItemLength { itemLength = minimumItemLength }
        entryPtr = ptr.advanced(by: itemNvrFieldOffset)
    }
    
    
    /// Subscript access
    
    public subscript(name: String) -> ValueItem? {
        get {
            if let found = findItem(for: name) { return found }
            return addNull(name: name, fixedItemValueLength: 8) ? findItem(for: name) : nil
        }
    }
    
    public subscript(name: String) -> Bool? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            // Note: The (nvr) value length is zero because the value is stored in the value/count field.
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 0, assignment: { $0.bool = newValue })
        }
    }
    
    public subscript(name: String) -> UInt8? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 0, assignment: { $0.uint8 = newValue })
        }
    }
    
    public subscript(name: String) -> Int8? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 0, assignment: { $0.int8 = newValue })
        }
    }
    
    public subscript(name: String) -> UInt16? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 0, assignment: { $0.uint16 = newValue })
        }
    }
    
    public subscript(name: String) -> Int16? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 0, assignment: { $0.int16 = newValue })
        }
    }
    
    public subscript(name: String) -> UInt32? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 0, assignment: { $0.uint32 = newValue })
        }
    }
    
    public subscript(name: String) -> Int32? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 0, assignment: { $0.int32 = newValue })
        }
    }
    
    public subscript(name: String) -> UInt64? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 8, assignment: { $0.uint64 = newValue })
        }
    }
    
    public subscript(name: String) -> Int64? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 8, assignment: { $0.int64 = newValue })
        }
    }
    
    public subscript(name: String) -> Float32? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 0, assignment: { $0.float32 = newValue })
        }
    }
    
    public subscript(name: String) -> Float64? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            fixedValueLengthSubscriptAssignment(for: name, valueLength: 8, assignment: { $0.float64 = newValue })
        }
    }
    
    public subscript(name: String) -> String? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            guard let strLen = newValue.data(using: .utf8)?.count, strLen < Int(Int32.max) else { return }
            variableLengthSubscriptAssignment(for: name, value: newValue, assignment: { $0.string = newValue })
        }
    }
    
    public subscript(name: String) -> Data? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            guard newValue.brbonCount() < UInt32(Int32.max) else { return }
            variableLengthSubscriptAssignment(for: name, value: newValue, assignment: { $0.binary = newValue })
        }
    }
    
    
    // =========================
    // MARK: - INTERNAL
    // =========================
    
    /// The buffer containing the root item with all child items.
    
    internal var buffer: UnsafeMutableRawBufferPointer
    
    
    /// Points to the first byte in the buffer
    
    internal var ptr: UnsafeMutableRawPointer
    
    
    /// True if the size of the dictionary can be changed, false if not.
    
    internal var mutableItemLength: Bool = true
    
    
    /// The entry point for new items.
    
    internal var entryPtr: UnsafeMutableRawPointer
    
    
    /// Accessor for the item length (Overrides protocol extension implementation)
    
    internal var itemLength: UInt32 {
        get {
            return UInt32(ptr.advanced(by: itemLengthOffset), endianness: endianness)
        }
        set {
            var iptr = ptr.advanced(by: itemLengthOffset)
            newValue.brbonBytes(endianness, toPointer: &iptr)
        }
    }
    
    
    /// Helper for subscript assignment
    
    internal func fixedValueLengthSubscriptAssignment(for name: String, valueLength: UInt32, assignment: (ValueItem) -> ()) {
        if let found = findItem(for: name) {
            assignment(found)
        } else {
            _ = addNull(name: name, fixedItemValueLength: valueLength)
            if let found = findItem(for: name) {
                assignment(found)
            }
        }
    }

    
    /// Helper for subscript assignment
    
    internal func variableLengthSubscriptAssignment(for name: String, value: BrbonBytes, assignment: (ValueItem)->() ) {
        if let found = findItem(for: name) {
            let newValueLength = value.brbonCount()
            if found.maxValueLength < newValueLength {
                let newItemLength = (found.itemLength + (newValueLength - found.maxValueLength)).roundUpToNearestMultipleOf8()
                let itemLengthIncrease = newItemLength - found.itemLength
                if availableBytes < itemLengthIncrease {
                    guard mutableItemLength && (bufferIncrements > 0) else { return }
                    increaseBufferSize(by: Int(itemLengthIncrease))
                }
                resize(found, by: Int(itemLengthIncrease))
            }
            assignment(found)
        } else {
            _ = addNull(name: name, fixedItemValueLength: UInt32(value.brbonCount()))
            if let found = findItem(for: name) {
                assignment(found)
            }
        }
    }

    
    /// The array with all active value items.
    
    fileprivate var activeValueItems = ActiveValueItems()
    
        
    // Cleanup.
    
    deinit {
        
        
        // The active value items are no longer valid
        
        activeValueItems.forEach() { _ = $0.updateFromDictionaryManager(isValid: false, oldPtr: $0.ptr, newPtr: $0.ptr) }
        
        
        // Buffer area must be deallocated
        
        self.buffer.deallocate()
    }
    
    
    internal func unsubscribe(item: ValueItem) {
        activeValueItems.decrementRefcountAndRemoveOnZero(for: item)
    }
    
    internal func updateSubscribers(isValid: Bool, oldPtr: UnsafeMutableRawPointer, newPtr: UnsafeMutableRawPointer) {
        activeValueItems.forEach() {
            $0.updateFromDictionaryManager(isValid: isValid, oldPtr: oldPtr, newPtr: newPtr)
        }
    }
    
    /// Increases the number of children counter by 1
    
    internal func incrementCounter() {
        let c = count
        if c < UInt32(Int32.max) {
            var cptr = ptr.advanced(by: itemValueCountOffset)
            (c + 1).brbonBytes(endianness, toPointer: &cptr)
        }
    }
    
    
    /// Decreases the number of children counter by 1 (cannot go negative)
    
    internal func decrementCounter() {
        let c = count
        if c > 0 {
            var cptr = ptr.advanced(by: itemValueCountOffset)
            (c - 1).brbonBytes(endianness, toPointer: &cptr)
        }
    }
    
    
    /// Returns the pointer to the first byte after the item the input pointer points at.
    ///
    /// - Parameters ptrToFirstByteOfItem: A pointer to the first byte of an item.
    ///
    /// - Returns: A pointer to the first byte after the item.
    
    internal func firstByteAfterItem(_ ptrToFirstByteOfItem: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        let length = Int(UInt32(ptrToFirstByteOfItem.advanced(by: 4), endianness: endianness))
        return ptrToFirstByteOfItem.advanced(by: length)
    }
    
    
    /// Increases the size of the buffer by the given amount.
    ///
    /// - Parameters: by: The amount of bytes to add to the buffer.
    
    internal func increaseBufferSize(by amount: Int) {
        
        let usedSize = ptr.distance(to: entryPtr)
        
        let increase = amount > Int(bufferIncrements) ? amount : Int(bufferIncrements)
        
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(count: increase + buffer.count)
        
        _ = Darwin.memmove(newBuffer.baseAddress!, buffer.baseAddress!, buffer.count)
        
        buffer = newBuffer
        
        ptr = newBuffer.baseAddress!
        
        entryPtr = ptr.advanced(by: usedSize)
    }
    
    
    /// Resizes an item.
    ///
    /// The data after the item will be shifted according to the new size of the item. Both the item and dictionary internals will be updated to reflect the new size. Subscribers will be notified.
    ///
    /// - Parameters:
    ///   - item: The descriptor for the item to be resized.
    ///   - by: The number of bytes to either add or substract from the item. Must be a multiple of 8. (This is not checked)

    internal func resize(_ item: Item, by amount: Int) {
        
        
        // Prepare for subscriber updates
        
        var preItems: Array<UnsafeMutableRawPointer> = []
        forEachAbortOnTrue({ preItems.append($0.ptr) ; return false })

        
        // Shift the data
        
        let srcPtr = item.ptr.advanced(by: Int(item.itemLength))
        let bytesToShift = srcPtr.distance(to: entryPtr)
        let dstPtr = srcPtr.advanced(by: amount)
        
        _ = Darwin.memmove(dstPtr, srcPtr, bytesToShift)
        
        
        // Update size of the item
        
        let newLength = UInt32(Int(item.itemLength) + amount)
        var lptr = item.ptr.advanced(by: itemLengthOffset)
        newLength.brbonBytes(endianness, toPointer: &lptr)
        
        
        // Update the entry pointer
        
        entryPtr = entryPtr.advanced(by: amount)
        
        
        // Update subscribers
        
        processSubscribers(preItems, changed: item.ptr)
    }
    
    
    /// Replace an item. No checks are made, assumes that the buffer is large enough.
    ///
    /// - Note: updates the internal members: itemSize and entryPtr.
    /*
     internal func replaceItem(_ item: Item, with newItem: Item) {
     
        let oldSize = item.itemLength
        let newSize = newItem.itemLength
        let delta = Int(oldSize) - Int(newSize)
     
        resize(item, by: delta)
     
        _ = Darwin.memmove(item.ptr, newItem.ptr, Int(newSize))
     
        itemLength = UInt32(Int(itemLength) + delta)
        entryPtr = entryPtr.advanced(by: delta)
     }*/
    
    
    /// The closure is called for each item in the dictionary or until the closure returns true.
    ///
    /// - Parameter closure: The closure that is called for each item in the dictionary. If the closure returns false then the processing of further items is aborted.
    
    internal func forEachAbortOnTrue(_ closure: (UniversalItem) -> Bool) {
        var itemPtr = ptr.advanced(by: itemNvrFieldOffset)
        while itemPtr < entryPtr {
            if closure(UniversalItem(ptr: itemPtr, endianness: endianness)) { return }
            itemPtr = firstByteAfterItem(itemPtr)
        }
    }
    
    
    /// Searches for an item with the same hash and string data as the search paremeters.
    ///
    /// - Parameters:
    ///   - with: A CRC16 over the stringData.
    ///   - stringData: The bytes that make up a name string.
    ///
    /// - Returns: A pointer to the first byte
    
    internal func findItem(with hash: UInt16, stringData: Data) -> ValueItem? {
        
        var ptrFound: UnsafeMutableRawPointer?
        
        forEachAbortOnTrue() {
            if $0.nameHash != hash { return false }
            if $0.nameCount != UInt8(stringData.count) { return false }
            if $0.nameData != stringData { return false }
            ptrFound = $0.ptr
            return true
        }
        
        if let ptr = ptrFound {
            return activeValueItems.getValueItemFor(ptr: ptr, dm: self)
        } else {
            return nil
        }
    }
    
    
    /// Removes the item at the given location from the dictionary.
    ///
    /// - Parameter item: The item to remove.
    
    internal func removeChild(item: Item) {
        
        
        // Prepare for subscriber updates
        
        var preItems: Array<UnsafeMutableRawPointer> = []
        forEachAbortOnTrue({ preItems.append($0.ptr) ; return false })
        
        
        // Get the source address (i.e. the first byte after the item)
        
        let srcPtr = firstByteAfterItem(item.ptr)
        
        
        // Get the size of this item
        
        let bytesRemoved = item.itemLength
        
        
        // Determine how many bytes must be moved
        
        let bytesToMove = srcPtr.distance(to: entryPtr)
        
        
        // Move the bytes
        
        _ = Darwin.memmove(item.ptr, srcPtr, bytesToMove)
        
        
        // Adjust the entry pointer
        
        entryPtr = entryPtr.advanced(by: -Int(bytesRemoved))
        
        
        // Decrement the counter index in the parent
        
        decrementCounter()
        
        
        // If the length is not fixed, then decrement the size of the dictionary
        
        if mutableItemLength { itemLength -= bytesRemoved }
        
        
        // Update the subscribers
        
        processSubscribers(preItems, changed: item.ptr)
    }
    
    
    /// Sends a signal to the subscribers to update their pointer or validity status.
    ///
    /// - Parameters:
    ///   - preItems: An array with the pointer values of the items in the dictionary before the update was made.
    ///   - changed: The pointer value of the first item that was changed in the dictionary (possibly now deleted).
    
    internal func processSubscribers(_ preItems: Array<UnsafeMutableRawPointer>, changed: UnsafeMutableRawPointer) {
        
        // This work by comparing two lists of item pointers with ech other. One from before the change, another from after the change. If the pre-list and post-list have the same number of entries, then there was a size update. If the post-list is smaller than the pre-list, then an item was removed.
        // Note: the 'changed' pointer is used as an optimization, only the items starting at and after this ptr need to be updated.
        
        
        // Create the post-list of all pointer values
        
        var postItems: Array<UnsafeMutableRawPointer> = []
        forEachAbortOnTrue({ postItems.append($0.ptr) ; return false })
        
        
        // Check for deletion or change
        
        if preItems.count > postItems.count {
            
            // An item was deleted
            
            var postIndex: Int = 0 // Used to find the new pointer value for an item
            var after: Bool = false // Used to prevent updating the items before 'changed'
            for aptr in preItems {
                
                if after {
                    
                    // ptr was updated (item was moved)
                    
                    updateSubscribers(isValid: true, oldPtr: aptr, newPtr: postItems[postIndex])
                    
                } else {
                    
                    if aptr == changed {
                        
                        // aptr is now the deleted item
                        
                        updateSubscribers(isValid: false, oldPtr: aptr, newPtr: aptr)
                        after = true // From here on, start updating pointer values
                        postIndex -= 1 // prevent an update of the postIndex for this ptr
                    }
                }
                postIndex += 1
            }
            
        } else {
            
            // The size of an item changed
            
            var after: Bool = false
            for (index, aptr) in preItems.enumerated() {
                
                if aptr == changed {
                    
                    // this is the first changed item
                    
                    updateSubscribers(isValid: true, oldPtr: aptr, newPtr: aptr)
                    after = true
                }
                
                if after {
                
                    // ptr was updated (item was moved)
                    
                    updateSubscribers(isValid: true, oldPtr: aptr, newPtr: postItems[index])
                }
            }
        }
    }
    
    
    /// Adds the new item value at the end of the child items. May increase the size of the buffer - if allowed. Does not check for duplicate names.
    ///
    /// - Parameter itemValue: The item to be added.
    ///
    /// - Returns: True on success, flase on failure.
    
    internal func add(_ item: Item) -> Bool {
        
        
        // Check if there is enough space
        
        if availableBytes < item.itemLength {
            
            guard bufferIncrements != 0 else { return false }
            
            increaseBufferSize(by: Int(item.itemLength - availableBytes))
        }
        
        
        // Copy the bytes of the item into the dictionary
        
        _ = Darwin.memmove(entryPtr, item.ptr, Int(item.itemLength))
        
        
        // Increase the number of child items in this dictionary
        
        incrementCounter()
        
        
        // If the length is not fixed, then increment the length
        
        if mutableItemLength { itemLength += item.itemLength }
        
        
        // Shift the entry pointer
        
        entryPtr = entryPtr.advanced(by: Int(item.itemLength))
        
        
        return true
    }
    
}

/// This struct is used to keep track of the number of ValueItems that have been returned to the API user.

fileprivate struct ActiveValueItems {
    
    
    /// Associate the valueItem with a reference counter
    
    class Entry {
        let item: ValueItem
        var refcount: Int = 0
        init(_ item: ValueItem) { self.item = item }
    }
    
    
    /// The dictionary that associates an item pointer with a valueItem entry
    
    var dict: Dictionary<UnsafeMutableRawPointer, Entry> = [:]
    
    
    /// Return the value item for the given parameters. A new one is created if it was not found in the dictionary.
    
    mutating func getValueItemFor(ptr: UnsafeMutableRawPointer, dm: DictionaryManager) -> ValueItem {
        if let entry = dict[ptr] {
            entry.refcount += 1
            return entry.item
        } else {
            let vi = ValueItem(ptr, dm.endianness, dm)
            let entry = Entry(vi)
            dict[ptr] = entry
            return vi
        }
    }
    
    
    /// Decrement the reference counter of a valueItem and remove the entry of the refcount reaches zero.
    
    mutating func decrementRefcountAndRemoveOnZero(for item: ValueItem) {
        if let vi = dict[item.ptr] {
            vi.refcount -= 1
            if vi.refcount == 0 {
                dict.removeValue(forKey: item.ptr)
            }
        }
    }
    
    
    /// Execute the given closure on each valueItem
    
    func forEach(_ closure: (ValueItem) -> ()) {
        dict.forEach() { closure($0.value.item) }
    }
}

