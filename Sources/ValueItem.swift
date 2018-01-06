//
//  ItemPtr.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 28/12/17.
//
//

import Foundation
import BRUtils


// ******************************************************************
// **                                                              **
// ** INTERNAL OPERATIONS ARE NOT PROTECTED AGAINST ILLEGAL VALUES **
// **                                                              **
// ******************************************************************



/// Create the data neccesary for a name field.
///
/// - Parameters:
///   - for: The optional string to be used as the name.
///   - fixedLength: A fixed length for the name area. Range 0...245. The actual length may be set to a rounded up value to the nearest multiple of 8. The actual length will include an additional 3 overhead bytes.
///
/// - Returns: A tuple with the name data, the hash and the field length. Nil on failure.

internal func nameFieldDescriptor(for name: String?, fixedLength: UInt8?) -> (data: Data?, crc: UInt16, length: UInt8)? {
    
    var data: Data?
    var length: UInt8 = 0

    
    // Create a data object from the name with maximal 245 bytes
    
    if let name = name {
        guard let (nameData, charRemoved) = name.utf8CodeMaxBytes(245) else { return nil }
        guard !charRemoved else { return nil }
        data = nameData
    }
    
    
    // If a fixed length is specified, determine if it can be used
    
    if let fixedLength = fixedLength {
        guard fixedLength <= 245 else { return nil }
        if Int(fixedLength) < (data?.count ?? 0) { return nil }
        length = fixedLength
    } else {
        let tmp = data?.count ?? 0
        length = UInt8(tmp)
    }
    
    
    // If there is a field, then add 3 btytes for the hash and length indicator
    
    length = length == 0 ? 0 : length + 3
    
    
    // Ensure 8 byte boundary
    
    length = length.roundUpToNearestMultipleOf8()
    
    
    // Note: At this point the length is max 248.

    
    return (data, data?.crc16() ?? 0, length)
}


/// Extends the manager with pointer manipulation operations.

internal struct ValueItem {
    
    
    /// Returns the necessary length for the nvr field.
    
    internal static func nvrLength(for value: BrbonBytes, nameFieldLength: UInt8, fixedItemValueLength: UInt32?) -> UInt32? {
        
        
        // Size needed for the value
        
        var length: UInt32 = value.brbonType().useValueField ? 0 : value.brbonCount()

        
        // If the fixed length is larger, use that.
        
        if let fixedItemValueLength = fixedItemValueLength {
            guard fixedItemValueLength < UInt32(Int32.max) else { return nil }
            if fixedItemValueLength < length { return nil }
            length = fixedItemValueLength
        }

        
        // Add the necessary name field length
        
        length += UInt32(nameFieldLength)

        
        // Round the value to the nearest 8 byte boundary
        
        return length.roundUpToNearestMultipleOf8()
    }

    
    /// Create a new byte representation for a non-null, non-container ItemType.
    ///
    /// - Parameters:
    ///   - value: The value to be converted into a byte representation.
    ///   - name: The name to use as the item name.
    ///   - fixedNameFieldLength: The bytes to be allocated for the name bytes.
    ///   - fixedItemValueLength: The number of bytes to allocate for the value of the item.
    ///   - endianness: The endianness to be used.
    ///
    /// - Returns: A buffer with the byte representation or nil when the conversion could not be made. The callee must deallocate the buffer when done.
    
    internal static func createInBuffer(
        _ value: BrbonBytes,
        name: String? = nil,
        fixedNameFieldLength: UInt8? = nil,
        fixedItemValueLength: UInt32? = nil,
        endianness: Endianness
        ) -> UnsafeRawBufferPointer? {

        
        // Determine the name field info
        
        guard let nameFieldDescriptor = nameFieldDescriptor(for: name, fixedLength: fixedNameFieldLength) else { return nil }
        
        
        // Determine size of the value field
        
        guard let nvrLength = ValueItem.nvrLength(for: value, nameFieldLength: nameFieldDescriptor.length, fixedItemValueLength: fixedItemValueLength) else { return nil }
        
        
        // Size of the item
        
        let itemLength = nvrLength + lengthOfFixedItemPart
        
        
        // Allocate the buffer
        
        let tmpBuffer = UnsafeMutableRawBufferPointer.allocate(count: Int(itemLength))
        var ptr = tmpBuffer.baseAddress!

        
        // Serialize the item
        
        value.brbonType().rawValue.brbonBytes(endianness, toPointer: &ptr)          // Item-Header - type
        UInt8(0).brbonBytes(endianness, toPointer: &ptr)                            // Item-Header - options
        UInt8(0).brbonBytes(endianness, toPointer: &ptr)                            // Item-Header - flags
        UInt8(nameFieldDescriptor.length).brbonBytes(endianness, toPointer: &ptr)   // Item-Header - name length
        
        itemLength.brbonBytes(endianness, toPointer: &ptr)                          // Item-Length
        UInt32(0).brbonBytes(endianness, toPointer: &ptr)                           // Parent-Offset
        
        switch value.brbonType() {                                                  // Value of value/count field
        
        case .bool, .int8, .uint8:
            value.brbonBytes(endianness, toPointer: &ptr)
            UInt8(0).brbonBytes(endianness, toPointer: &ptr)
            UInt16(0).brbonBytes(endianness, toPointer: &ptr)

        case .int16, .uint16:
            value.brbonBytes(endianness, toPointer: &ptr)
            UInt16(0).brbonBytes(endianness, toPointer: &ptr)
            
        case .int32, .uint32, .float32:
            value.brbonBytes(endianness, toPointer: &ptr)

        default:
            if value.brbonType().useCountField {
                value.brbonCount().brbonBytes(endianness, toPointer: &ptr)
            } else {
                UInt32(0).brbonBytes(endianness, toPointer: &ptr)
            }
        }
        
        if nameFieldDescriptor.length > 0 {
            nameFieldDescriptor.crc.brbonBytes(endianness, toPointer: &ptr)                         // Name area hash
            UInt8(nameFieldDescriptor.data!.count).brbonBytes(endianness, toPointer: &ptr)          // Name area string length
            nameFieldDescriptor.data!.brbonBytes(endianness, toPointer: &ptr)                       // Name area string bytes
            let filler = Data(count: Int(nameFieldDescriptor.length) - nameFieldDescriptor.data!.count - 3)
            if filler.count > 0 { filler.brbonBytes(endianness, toPointer: &ptr) }                  // Name area filler bytes
        }
        
        switch value.brbonType() {                                                                  // Value
        case .uint64, .int64, .float64, .string, .binary:
            value.brbonBytes(endianness, toPointer: &ptr)
        default: break
        }
        
        let fillerSize = Int(itemLength) - tmpBuffer.baseAddress!.distance(to: ptr)
        if fillerSize > 0 { Data(count: fillerSize).brbonBytes(endianness, toPointer: &ptr) }       // Filler/Reserved
        
        return UnsafeRawBufferPointer(tmpBuffer)
    }
    
    
    /// Pointer to a ValueItem (is contained in a dictionary or sequence)
    
    internal let ptr: UnsafeMutableRawPointer

    
    /// The endianness of the ValueItem bytes
    
    internal let endianness: Endianness
    
    
    /// Creates a new ValueItem
    ///
    /// - Parameters:
    ///   - ptr: The pointer to the first byte of ValueItem.
    ///   - endianness: The endianness of the ValueItem bytes.
    
    internal init(_ ptr: UnsafeMutableRawPointer, endianness: Endianness) {
        self.ptr = ptr
        self.endianness = endianness
    }
    
    var type: ItemType? {
        get {
            return ItemType(ptr.advanced(by: itemTypeOffset))
        }
        set {
            var tptr = ptr.advanced(by: itemTypeOffset)
            newValue?.rawValue.brbonBytes(endianness, toPointer: &tptr)
        }
    }
    
    var nameFieldLength: UInt8 {
        get {
            return UInt8(ptr.advanced(by: itemNameFieldLengthOffset), endianness: endianness)
        }
        set {
            var nptr = ptr.advanced(by: itemNameFieldLengthOffset)
            newValue.brbonBytes(endianness, toPointer: &nptr)
        }
    }
    
    var itemLength: UInt32 {
        get {
            return UInt32(ptr.advanced(by: itemLengthOffset), endianness: endianness)
        }
        set {
            var iptr = ptr.advanced(by: itemLengthOffset)
            newValue.brbonBytes(endianness, toPointer: &iptr)
        }
    }
    
    var parentOffset: UInt32 {
        get {
            return UInt32(ptr.advanced(by: itemParentOffsetOffset), endianness: endianness)
        }
        set {
            var pptr = ptr.advanced(by: itemParentOffsetOffset)
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }

    var nameHash: UInt16 {
        get {
            return UInt16(ptr.advanced(by: nameHashOffset), endianness: endianness)
        }
        set {
            var pptr = ptr.advanced(by: nameHashOffset)
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }
    
    var nameCount: UInt8 {
        get {
            return UInt8(ptr.advanced(by: nameCountOffset), endianness: endianness)
        }
        set {
            var pptr = ptr.advanced(by: nameCountOffset)
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }
    
    var nameData: Data {
        get {
            return Data(ptr.advanced(by: nameDataOffset), endianness: endianness, count: UInt32(nameCount))
        }
        set {
            var pptr = ptr.advanced(by: nameDataOffset)
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }

    
    /// Returns true if the name of the item equals the given information.
    ///
    /// - Parameters:
    ///   - hash: The CRC16 has of the name.
    ///   - name: A data struct that contains the UTF8 bytes of the name to compare against.
    ///
    /// - Returns: True if the names match, false otherwise.
    
    internal func nameEquals(hash: UInt16, name: Data) -> Bool {
        guard nameFieldLength > 0 else { return false }
        guard hash == UInt16(ptr.advanced(by: nameHashOffset), endianness: endianness) else { return false }
        guard name.count == Int(UInt8(ptr.advanced(by: nameCountOffset), endianness: endianness)) else { return false }
        return name == nameData
    }

    
    /// Increments the buffer size by bufferIncrements bytes.
    ///
    /// Note that this involves a memory allocation, copy and deallocation operations which can be costly.
    ///
    /// - Returns: True on success, false on failure.
    /*
    internal func incrementBufferSize() -> Bool {
        if bufferIncrements == 0 { return false }
        let newSize = buffer.count + Int(bufferIncrements)
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(count: newSize)
        let byteCount = buffer.baseAddress!.distance(to: entryPtr)
        _ = Darwin.memcpy(newBuffer.baseAddress!, buffer.baseAddress!, byteCount)
        buffer.deallocate()
        buffer = newBuffer
        entryPtr = buffer.baseAddress!.advanced(by: byteCount)
        rootItem = Item(buffer.baseAddress!, endianness)
        return true
    }

    
    /// Make space for a new dictionary (or sequence) item.
    ///
    /// - Parameters:
    ///   - at: The pointer to the first byte of the area that must be freed.
    ///   - for: The number of bytes that must be freed.
    
    //internal func makeSpaceForNewDictionaryItem(at srcPtr: UnsafeMutableRawPointer, for nofBytes: UInt32) {
    //    let dstPtr = srcPtr.advanced(by: Int(nofBytes))
    //    let count = srcPtr.distance(to: entryPtr)
    //    _ = Darwin.memmove(dstPtr, srcPtr, count)
    //}
    
    
    /// Insert the buffer content at the end of the given parent which should be a dictionary or sequence.
    ///
    /// - Parameters:
    ///   - rawBuffer: The buffer with the content to be inserted.
    ///   - toDictionary: The dictionary or sequence item to which to append the buffer content.
    
    internal func append(_ rawBuffer: UnsafeRawBufferPointer, toDictionary dict: Item) {
        
        let srcPtr = dict.pointerToFirstByteAfter
        let dstPtr = srcPtr.advanced(by: rawBuffer.count)
        let count = srcPtr.distance(to: entryPtr)
        
        // Free up the area for insertion
        _ = Darwin.memmove(dstPtr, srcPtr, count)
        
        // Insert
        _ = Darwin.memmove(srcPtr, rawBuffer.baseAddress!, rawBuffer.count)
    }

    
    /// Removes a block of memory from the internal data structure.
    ///
    /// - Parameters:
    ///   - fromPtr: A pointer to the first byte to be removed.
    ///   - upToPtr: A pointer to the first byte NOT to be removed.
    
    internal func removeBlock(fromPtr: UnsafeMutableRawPointer, upToPtr: UnsafeMutableRawPointer) {
        let bytes = upToPtr.distance(to: entryPtr)
        _ = Darwin.memmove(fromPtr, upToPtr, bytes)
        let newCount = buffer.baseAddress!.distance(to: entryPtr) - bytes
        entryPtr = buffer.baseAddress!.advanced(by: newCount)
    }
    

    /// Removes an item from a parent. The item count will be decremented.
    ///
    /// - Parameters:
    ///   - item: The item to be removed.
    ///   - parent: The parent from which the item is removed.

    internal func remove(_ item: Item, parent: Item) {
        
        if parent.isArray {
            remove(item, fromArray: parent)
            return
        }
        
        if parent.isDictionary || parent.isSequence {
            remove(item, fromDictionary: parent)
            return
        }
    }
    
    
    /// Removes an item from an array. The item count in the array will be decremented.
    ///
    /// - Parameters:
    ///   - item: The item to be removed.
    ///   - fromArray: The array from which the item is removed.
    
    private func remove(_ item: Item, fromArray: Item) {
        

        // Get the source address for the removal
            
        let elementSize = UInt32(fromArray.valuePtr.advanced(by: valueFieldElementTypeOffset), endianness: endianness)
        let srcPtr = item.nvrPtr.advanced(by: Int(elementSize))
        
        
        // If the item is the last item
            
        if srcPtr == entryPtr {
            
                
            // Just move the entryPtr to the first byte to be removed
                
            entryPtr = item.headerPtr

            
            // Decrement the counter index in the parent
            
            fromArray.decrementCount()

        } else {
            
            
            // Remove by shifting the data downward
            
            removeBlock(fromPtr: item.headerPtr, upToPtr: srcPtr)
            
            
            // Decrement the counter index in the parent
            
            fromArray.decrementCount()
            
            
            // Any parents in the dictionary after the removal pointer must update the parent pointers in their children
            
            fromArray.forEachDoWhileTrue() {
                if $0.headerPtr <= item.headerPtr { $0.updateParentPointers(bufferPtr: buffer.baseAddress!) }
                return true
            }
        }
    }

    
    /// Removes an item from a dictionary or sequence. The item count will be decremented.
    ///
    /// - Parameters:
    ///   - item: The item to be removed.
    ///   - fromDictionary: The dictionary or sequence from which the item is removed.
    

    private func remove(_ item: Item, fromDictionary: Item) {

        
        // Get the source address for the removal
        
        let srcPtr = item.pointerToFirstByteAfter

        
        // If the item is the last item
        
        if srcPtr == entryPtr {
            
            
            // Just move the entryPtr to the first byte to be removed
            
            entryPtr = item.headerPtr

            
            // Decrement the counter index in the parent
            
            fromDictionary.decrementCount()

        } else {
            
            
            // Remove by shifting the data downward
            
            removeBlock(fromPtr: item.headerPtr, upToPtr: srcPtr)
            
            
            // Decrement the counter index in the parent
            
            fromDictionary.decrementCount()

            
            // Any parents in the dictionary after the removal pointer must update the parent pointers in their children
            
            fromDictionary.forEachDoWhileTrue() {
                if $0.headerPtr <= item.headerPtr { $0.updateParentPointers(bufferPtr: buffer.baseAddress!) }
                return true
            }
        }
    }*/
}










