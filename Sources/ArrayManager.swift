//
//  ArrayManager.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 17/01/18.
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

public class ArrayManager: _Item {
    
    
    /// The number of bytes not yet used in the current buffer
    
    public var availableBufferBytes: UInt32 {
        return UInt32(buffer.count) - itemLength
    }
    
    
    /// The number of bytes not yet used in the array item
    
    public var availableItemBytes: UInt32 {
        return itemLength - UInt32(count) * elementLength - minimumItemLength - 8
    }
    
    
    /// The endianness of the root item and all child items
    
    public let endianness: Endianness
    
    
    /// The number of bytes with which to increment the buffer size if there is insufficient free space available.
    
    public let bufferIncrements: UInt32
    
    
    /// The number of elements in the array
    
    public var count: Int {
        return Int(valueCount)
    }
    
    
    /// The type of element in the array.
    ///
    /// May be unknown until the first element is added.
    
    public private(set) var elementType: ItemType

    
    /// The length of each element.
    ///
    /// May be unknown (i.e. zero) until the first element is added.
    
    public var elementLength: UInt32 {
        return UInt32(ptr.advanced(by: itemNvrFieldOffset + 4), endianness: endianness)
    }
    
    
    /// Returns the buffer as a Data object. The buffer will not be copied, but wrapped in a data object.
    
    public var asData: Data {
        return Data(bytesNoCopy: ptr, count: Int(itemLength), deallocator: Data.Deallocator.none)
    }
    
    
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
    
    public init?(
        elementType: ItemType,
        initialCount: UInt32 = 0,
        elementValueLength: UInt32? = nil,
        name: String? = nil,
        nameFieldLength: UInt8? = nil,
        fixedItemLength: UInt32? = nil,
        initialBufferSize: UInt32 = 1024,
        bufferIncrements: UInt32 = 1024,
        endianness: Endianness = machineEndianness) {

        
        guard elementType != .null else { return nil }
        
        
        self.endianness = endianness
        self.elementType = elementType
        
        
        // Create local variables because the input parameters cannot be changed and the self members are let members.
        
        var bufferSize = initialBufferSize
        var increments = bufferIncrements
        
        
        // Create the name field info
        
        guard let nameFieldDescriptor = nameFieldDescriptor(for: name, fixedLength: nameFieldLength) else { return nil }
        
        
        // Determine size of the value field
        // =================================
        
        var itemLength: UInt32 = minimumItemLength + UInt32(nameFieldDescriptor.length) + 8
        

        // Add the initial allocation for the elements
        
        if let elementLength = elementValueLength, initialCount > 0 {
            itemLength += elementLength * initialCount
            bufferSize = max(itemLength, bufferSize) // Up the buffer size if the initial elements don't fit.
        }

        
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
        
        
        // Create the array structure
        
        var dptr = buffer.baseAddress!
        
        ItemType.array.rawValue.brbonBytes(endianness, toPointer: &dptr)                    // Type
        UInt8(0).brbonBytes(endianness, toPointer: &dptr)                                   // Options
        UInt8(0).brbonBytes(endianness, toPointer: &dptr)                                   // Flags
        nameFieldDescriptor.length.brbonBytes(endianness, toPointer: &dptr)                 // Name field length
        
        itemLength.brbonBytes(endianness, toPointer: &dptr)                                 // Item length
        
        UInt32(0).brbonBytes(endianness, toPointer: &dptr)                                  // Parent offset
        
        UInt32(0).brbonBytes(endianness, toPointer: &dptr)                                  // Count
        
        if nameFieldDescriptor.length > 0 {
            nameFieldDescriptor.crc.brbonBytes(endianness, toPointer: &dptr)                // Name hash
            UInt8(nameFieldDescriptor.data!.count).brbonBytes(endianness, toPointer: &dptr) // Name length
            nameFieldDescriptor.data!.brbonBytes(endianness, toPointer: &dptr)              // Name bytes
        }
        
        elementType.rawValue.brbonBytes(endianness, toPointer: &dptr)                       // Element type
        UInt8(0).brbonBytes(endianness, toPointer: &dptr)                                   // Element Options -> always 0
        UInt8(0).brbonBytes(endianness, toPointer: &dptr)                                   // Element Flags -> always 0
        UInt8(0).brbonBytes(endianness, toPointer: &dptr)                                   // Element namelength -> always 0
            
        let evLength = elementValueLength ?? elementType.defaultByteSize
        evLength.brbonBytes(endianness, toPointer: &dptr)                                   // Element length


        // Zero the remainder of the buffer
        
        let zeroingLength = (Int(bufferSize) - ptr.distance(to: dptr))/4
        
        _ = Darwin.memset(dptr, 0, zeroingLength)
        
        
        // The pointer to the first element
        
        self.element0Ptr = ptr.advanced(by: itemNvrFieldOffset + Int(nameFieldDescriptor.length) + 8)
    }
    
    
    /// Adds a new value to the array.
    
    @discardableResult
    public func append(element: BrbonBytes) -> Result {
        
        
        // Check type conformance
        
        guard element.brbonType() == elementType else { return .typeConflict }
        
        
        // Convert the value into its brbon representation
        
        var elementData = element.brbonBytes(endianness)
        guard elementData.count > 0 else { return .brbonBytesToDataFailed }
        
        
        // Check the size of the element
        
        switch elementType {
        case .binary, .string:
            guard (elementData.count + 4) <= Int(elementLength) else { return .elementToLarge }
        default:
            guard elementData.count <= Int(elementLength) else { return .elementToLarge }
        }

        
        // Check for storage area
        
        guard ensureNewItemSpace() else { return .outOfStorageSpace }
        
        
        // Check offset for new element
        
        guard (UInt32(count) * elementLength) < brbonUInt32Max else { return .indexOutOfHighLimit }
        
        
        // Add the element value
        
        var eptr = elementPtr(for: count)
        switch elementType {
        case .binary, .string:
            UInt32(elementData.count).brbonBytes(endianness, toPointer: &eptr)
            fallthrough
        default:
            elementData.brbonBytes(endianness, toPointer: &eptr)
        }
        
        return .success
    }
    
    
    /// Create a new entry at the given index.
    
    @discardableResult
    public func insert(at index: Int, element: BrbonBytes) -> Result {


        // Check type conformance
        
        guard element.brbonType() == elementType else { return .typeConflict }
        
        
        // Check the index
        
        guard index < count else { return .indexOutOfHighLimit }
        guard index >= 0 else { return .indexLessThanZero }
        
        
        // Convert the value into its brbon representation
        
        var elementData = element.brbonBytes(endianness)
        guard elementData.count > 0 else { return .brbonBytesToDataFailed }
        
        
        // Check the size of the element
        
        switch elementType {
        case .binary, .string:
            guard (elementData.count + 4) <= Int(elementLength) else { return .elementToLarge }
        default:
            guard elementData.count <= Int(elementLength) else { return .elementToLarge }
        }
        
        
        // Check for storage area
        
        guard ensureNewItemSpace() else { return .outOfStorageSpace }

        
        // Shift data to make place for the new element
        
        let dstPtr = elementPtr(for: index + 1)
        let srcPtr = elementPtr(for: index)
        let len = (count - index) * Int(elementLength)
        
        _ = Darwin.memmove(dstPtr, srcPtr, len)
        
        
        // Add the new element
        
        var tptr = srcPtr
        switch elementType {
        case .binary, .string: UInt32(elementData.count).brbonBytes(endianness, toPointer: &tptr)
        default: break
        }
        elementData.brbonBytes(endianness, toPointer: &tptr)
        
        
        // Increase the item length (if mutable)
        
        if mutableItemLength { itemLength += elementLength }
        
        
        // Increase the element counter
        
        elementCount += 1
        
        
        return .success
    }
    
    
    /// Removes a value from the array.
    
    public func remove(at index: Int) -> Result {
        
        
        // Check index
        
        guard index < count else { return .indexOutOfHighLimit }
        guard index >= 0 else { return .indexLessThanZero }

        
        // Get the pointer to the item to be removed
            
        let dstPtr = elementPtr(for: index)
            
            
        // Get the pointer to the first item after it
            
        let srcPtr = elementPtr(for: index + 1)
            
            
        // Get the number of bytes to move
            
        let nofBytes = (count - 1 - index) * Int(elementLength)

        
        // Move the bytes after the item to be removed forward
        
        _ = Darwin.memmove(dstPtr, srcPtr, nofBytes)
        

        // Decrement the counter of the number of children.

        var vptr = ptr.advanced(by: itemValueCountOffset)
        UInt32(count - 1).brbonBytes(endianness, toPointer: &vptr)

        
        // Only decrement the item length if it is mutable
        
        if mutableItemLength {
            var iptr = ptr.advanced(by: itemLengthOffset)
            (itemLength - elementLength).brbonBytes(endianness, toPointer: &iptr)
        }
        
        return .success
    }
    
    
    /// Subscript access
    
    public subscript(index: Int) -> Element? {
        get {
            
        }
        set {
            
        }
    }
    
    public subscript(index: Int) -> Bool? {
        get {
            guard elementType == .bool else { return nil }
            guard index < count, index >= 0 else { return nil }
            return Bool(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .bool else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }
    
    public subscript(index: Int) -> Int8? {
        get {
            guard elementType == .int8 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return Int8(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .int8 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }
    
    public subscript(index: Int) -> UInt8? {
        get {
            guard elementType == .uint8 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return UInt8(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .uint8 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }

    public subscript(index: Int) -> Int16? {
        get {
            guard elementType == .int16 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return Int16(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .int16 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }
    
    public subscript(index: Int) -> UInt16? {
        get {
            guard elementType == .uint16 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return UInt16(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .uint16 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }

    public subscript(index: Int) -> Int32? {
        get {
            guard elementType == .int32 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return Int32(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .int32 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }
    
    public subscript(index: Int) -> UInt32? {
        get {
            guard elementType == .uint32 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return UInt32(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .uint32 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }

    public subscript(index: Int) -> Int64? {
        get {
            guard elementType == .int64 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return Int64(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .int64 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }
    
    public subscript(index: Int) -> UInt64? {
        get {
            guard elementType == .uint64 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return UInt64(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .uint64 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }

    public subscript(index: Int) -> Float32? {
        get {
            guard elementType == .float32 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return Float32(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .float32 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }
    
    public subscript(index: Int) -> Float64? {
        get {
            guard elementType == .float64 else { return nil }
            guard index < count, index >= 0 else { return nil }
            return Float64(elementPtr(for: index), endianness: endianness)
        }
        set {
            guard elementType == .float64 else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            newValue?.brbonBytes(endianness, toPointer: &vptr)
        }
    }

    public subscript(index: Int) -> String? {
        get {
            guard elementType == .string else { return nil }
            guard index < count, index >= 0 else { return nil }
            let sptr = elementPtr(for: index)
            let strLen = UInt32.init(sptr, endianness: endianness)
            return String(sptr.advanced(by: 4), endianness: endianness, count: strLen)
        }
        set {
            guard let newValue = newValue else { return }
            guard elementType == .string else { return }
            guard index < count, index >= 0 else { return }
            var vptr = elementPtr(for: index)
            let newCount = newValue.brbonCount()
            guard newCount + 4 <= elementLength else { return }
            newValue.brbonCount().brbonBytes(endianness, toPointer: &vptr)
            newValue.brbonBytes(endianness, toPointer: &vptr)
        }
    }
    
    public subscript(index: Int) -> Data? {
        get {
            guard elementType == .binary else { return nil }
            guard index < count, index >= 0 else { return nil }
            let bptr = elementPtr(for: index)
            let binlen = UInt32.init(bptr, endianness: endianness)
            return Data(bptr.advanced(by: 4), endianness: endianness, count: binlen)
        }
        set {
            guard let newValue = newValue else { return }
            guard elementType == .binary else { return }
            guard index < count, index >= 0 else { return }
            var bptr = elementPtr(for: index)
            let newCount = newValue.brbonCount()
            guard newCount + 4 <= elementLength else { return }
            newValue.brbonCount().brbonBytes(endianness, toPointer: &bptr)
            newValue.brbonBytes(endianness, toPointer: &bptr)
        }
    }

    
    // ****************
    // MARK: - Internal
    // ****************
    
    internal var buffer: UnsafeMutableRawBufferPointer
    internal var ptr: UnsafeMutableRawPointer
    internal var element0Ptr: UnsafeMutableRawPointer
    internal let mutableItemLength: Bool

    internal var itemLength: UInt32 {
        get {
            return UInt32.init(ptr.advanced(by: itemLengthOffset), endianness: endianness)
        }
        set {
            var lptr = ptr.advanced(by: itemLengthOffset)
            newValue.brbonBytes(endianness, toPointer: &lptr)
        }
    }
    internal var elementCount: UInt32 {
        get {
            return UInt32.init(ptr.advanced(by: itemValueCountOffset), endianness: endianness)
        }
        set {
            var cptr = ptr.advanced(by: itemValueCountOffset)
            newValue.brbonBytes(endianness, toPointer: &cptr)
        }
    }
    
    deinit {
        buffer.deallocate()
    }
    
    
    /// - Returns: A pointer to the memory area where the element for the given index is located.
    
    internal func elementPtr(for index: Int) -> UnsafeMutableRawPointer {
        return element0Ptr.advanced(by: Int(elementLength) * index)
    }
    
    
    /// Ensures that a new item can be placed in the array, or returns false.
    ///
    /// - Returns: True if the item can be placed, false otherwise.
    
    internal func ensureNewItemSpace() -> Bool {
        
        if availableItemBytes >= elementLength { return true }
        
        return increaseItemLength(by: elementLength)
    }
    
    
    /// Increase the item length of the array by at least the given amount of bytes.
    ///
    /// The item length will only be incremented if it has a mutable length (_mutableItemLength_ is true) and if -when necessary- the buffer size can be increased as well.
    ///
    /// __Side effects__: Will call _increaseBufferSize_ when necessary. The _itemLength_ field will be updated if the length increase was successful.
    ///
    /// - Parameters:
    ///   - by: The minimum number of bytes by which to increase the item length. This will be rounded up to the nearest multiple of 8 if it is not a multiple of 8.
    ///
    /// - Returns: True on success, false on failure.
    
    internal func increaseItemLength(by bytes: UInt32) -> Bool {
        guard mutableItemLength else { return false }
        let currentSize = itemLength
        if currentSize + bytes.roundUpToNearestMultipleOf8() > availableBufferBytes {
            guard bufferIncrements > 0 else { return false }
            guard increaseBufferSize(by: bytes.roundUpToNearestMultipleOf8()) else { return false }
        }
        var lptr = ptr.advanced(by: itemLengthOffset)
        (currentSize + bytes.roundUpToNearestMultipleOf8()).brbonBytes(endianness, toPointer: &lptr)
        return true
    }
    
    
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
    
    internal func increaseBufferSize(by bytes: UInt32) -> Bool {
        
        guard bufferIncrements > 0 else { return false }
        
        let increase = Int(max(bytes, bufferIncrements))
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(count: buffer.count + increase)
        
        _ = Darwin.memmove(newBuffer.baseAddress!, buffer.baseAddress!, buffer.count)
        
        buffer = newBuffer
        ptr = newBuffer.baseAddress!
        element0Ptr = ptr.advanced(by: itemNvrFieldOffset + Int(nameFieldLength) + 8)
        
        return true
    }
}
