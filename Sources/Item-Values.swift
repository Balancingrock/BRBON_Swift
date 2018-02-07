//
//  Item-Values.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/01/18.
//
//

import Foundation
import BRUtils


// MARK: - Value related derviates

public extension Item {

    
    // *********************
    // MARK: - Internal
    // *********************
    
    /// Returns the necessary length for the nvr field.
    /*
    internal static func nvrLength(for value: BrbonCoder, nameFieldLength: UInt8, fixedItemValueByteCount: UInt32?) -> UInt32? {
        
        
        // Size needed for the value
        
        var length: UInt32 = value.brbonType.useValueCountFieldAsValue ? 0 : value.itemByteCount
        
        
        // If the fixed length is larger, use that.
        
        if let fixedItemValueByteCount = fixedItemValueByteCount {
            guard fixedItemValueByteCount < UInt32(Int32.max) else { return nil }
            if fixedItemValueByteCount < length { return nil }
            length = fixedItemValueByteCount
        }
        
        
        // Add the necessary name field length
        
        length += UInt32(nameFieldLength)
        
        
        // Round the value to the nearest 8 byte boundary
        
        return length.roundUpToNearestMultipleOf8()
    }

    
    internal static func createValue(
        atPtr: UnsafeMutableRawPointer,
        value: BrbonCoder,
        nameFieldDescriptor: NameFieldDescriptor,
        fixedItemValueByteCount: UInt32? = nil,
        endianness: Endianness = machineEndianness) -> Bool {

            
        // Determine size of the value field
        
        guard let nvrLength = nvrLength(for: value, nameFieldLength: nameFieldDescriptor.byteCount, fixedItemValueByteCount: fixedItemValueByteCount) else { return false }
        
        
        // Size of the item
        
        let itemLength = nvrLength + minimumItemByteCount
        
        
        // Serialize the item
        
        var ptr = atPtr
        
        value.brbonType.rawValue.storeValue(atPtr: ptr, endianness)        // Item-Header - type
        ptr = ptr.advanced(by: 1)
        
        UInt8(0).storeValue(atPtr: ptr, endianness)                        // Item-Header - options
        ptr = ptr.advanced(by: 1)
        
        UInt8(0).storeValue(atPtr: ptr, endianness)                        // Item-Header - flags
        ptr = ptr.advanced(by: 1)
        
        nameFieldDescriptor.byteCount.storeValue(atPtr: ptr, endianness)   // Item-Header - name length
        ptr = ptr.advanced(by: 1)
        
        itemLength.storeValue(atPtr: ptr, endianness)                      // Item-Length
        ptr = ptr.advanced(by: 4)
        
        UInt32(0).storeValue(atPtr: ptr, endianness)                       // Parent-Offset
        ptr = ptr.advanced(by: 4)
        
        switch value.brbonType {                                           // Value of value/count field
            
        case .bool, .int8, .uint8:
            
            value.storeValue(atPtr: ptr, endianness)
            ptr = ptr.advanced(by: 1)
            
            UInt8(0).storeValue(atPtr: ptr, endianness)
            ptr = ptr.advanced(by: 1)
            
            UInt16(0).storeValue(atPtr: ptr, endianness)
            ptr = ptr.advanced(by: 2)
            
        case .int16, .uint16:
            
            value.storeValue(atPtr: ptr, endianness)
            ptr = ptr.advanced(by: 2)
            
            UInt16(0).storeValue(atPtr: ptr, endianness)
            ptr = ptr.advanced(by: 2)

        case .int32, .uint32, .float32:
            value.storeValue(atPtr: ptr, endianness)
            ptr = ptr.advanced(by: 4)

        default:
            if value.brbonType.useValueCountFieldAsCount {
                value.itemByteCount.storeValue(atPtr: ptr, endianness)
            } else {
                UInt32(0).storeValue(atPtr: ptr, endianness)
            }
            ptr = ptr.advanced(by: 4)
        }
        
        if nameFieldDescriptor.byteCount > 0 {
            nameFieldDescriptor.storeValue(atPtr: ptr, endianness)         // Name field
            ptr = ptr.advanced(by: Int(nameFieldDescriptor.byteCount))
        }
        
        switch value.brbonType {                                           // Value
        case .uint64, .int64, .float64, .string, .binary:
            value.storeValue(atPtr: ptr, endianness)
            ptr = ptr.advanced(by: Int(value.itemByteCount))
        default: break
        }
        
        let fillerSize = Int(itemLength) - atPtr.distance(to: ptr)
        if fillerSize > 0 { Data(count: fillerSize).storeValue(atPtr: ptr, endianness) }       // Filler/Reserved

        
        // Success
        
        return true
    }*/
    
    @discardableResult
    internal static func createNull(
        atPtr: UnsafeMutableRawPointer,
        nameFieldDescriptor: NameFieldDescriptor,
        parentOffset: Int,
        valueByteCount: Int? = nil,
        endianness: Endianness = machineEndianness) -> Bool {


        // The size of the item
        
        let itemByteCount = minimumItemByteCount + nameFieldDescriptor.byteCount + (valueByteCount ?? 0)

        
        // Add the null starting at the pointer
        
        var ptr = atPtr
        
        
        // Add the null
        
        ItemType.null.storeValue(atPtr: ptr)
        ptr = ptr.advanced(by: 1)
        
        ItemOptions.none.storeValue(atPtr: ptr)
        ptr = ptr.advanced(by: 1)
        
        ItemFlags.none.storeValue(atPtr: ptr)
        ptr = ptr.advanced(by: 1)
        
        UInt8(nameFieldDescriptor.byteCount).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 1)
        
        UInt32(itemByteCount).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        UInt32(parentOffset).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        UInt32(0).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        nameFieldDescriptor.storeValue(atPtr: ptr, endianness)

        
        // Success
        
        return true
    }

    
    /// Ensures that an item can accomodate a value of the given length. If necessary it will try to increase the size of the item. Note that increasing the size is only possible for contiguous items and for variable length elements.
    ///
    /// - Parameter for: The number of bytes needed.
    ///
    /// - Returns: True if the item or element has sufficient bytes available.
    
    internal func ensureValueStorage(for bytes: Int) -> Result {
        if availableValueByteCount >= bytes { return .success }
        if !isElement || type!.hasVariableLength {
            var recursiveItems: Array<Item> = [self]
            return increaseItemByteCount(by: (bytes - availableValueByteCount), recursiveItems: &recursiveItems)
        }
        return .outOfStorage
    }
    
    
    /// Increases the byte count of the item if possible.
    ///
    /// This operation is recursive back to the top level and the buffer manager. Also, if the operation affects an item that is contained in an array or sequence the change will be applied to all elements of that array. Hence a minimum increase of 8 bytes can (worst case) result in a multi megabyte increase in total.
    ///
    /// - Parameters:
    ///   - by: The number by which to increase the size of an item. Note that the actual size increase will happen in multiples of 8 bytes.
    ///   - recursiveItems: A list of items that may need their pointers to be updated. This list is in the order of the recursivity of calls. I.e. initially this list is empty and then a new item is added at the end for each recursive call.
    ///
    /// - Returns: .noManager or .increaseFailed if the increase failed, .success if it was successful.
    
    internal func increaseItemByteCount(by bytes: Int, recursiveItems: inout Array<Item>) -> Result {

        
        if parentPtr == nil {
            
            
            // If there is no buffer manager, the size cannot be changed.
            
            guard let manager = manager else { return .noManager }
            
            
            // If the buffer manager cannot accomodate the increase of the item, then increase the buffer size.
            
            if manager.unusedByteCount < bytes {

            
                // Continue only when the buffer manager has increased its size.
            
                let oldPtr = basePtr
                guard manager.increaseBufferSize(by: bytes.roundUpToNearestMultipleOf8()) else { return .increaseFailed }
            

                // All pointers must be updated
                
                let offset = basePtr.distance(to: oldPtr)
                for item in recursiveItems {
                    item.basePtr = item.basePtr.advanced(by: offset)
                    if item.parentPtr != nil {
                        item.parentPtr = item.parentPtr?.advanced(by: offset)
                    }
                }
            }
            
            
            // No matter what this item is, its value area can be increased. Update the byte count
            
            byteCount += bytes.roundUpToNearestMultipleOf8()
            
            
            return .success
            
            
        } else {
            
            
            // There is a parent item, get it.
            
            let parent = parentItem!

            
            // Ensure the multiple-of-8 boundaries for non-elements
            
            let increase: Int
            if parent.isArray {
                increase = bytes
            } else {
                increase = bytes.roundUpToNearestMultipleOf8()
            }
            
            
            // The number of bytes the parent item has available for child byte count increases
            
            let freeByteCount = parent.availableValueByteCount - parent.usedValueByteCount
            
            
            // The number of bytes needed for the increase in the parent item
            
            let needed: Int
            
            if isArray {
                needed = (count * increase).roundUpToNearestMultipleOf8()
            } else {
                needed = increase
            }
            
            
            // If more is needed than available, then ask the parent to increase the available byte count
            
            if needed > freeByteCount {
                recursiveItems.append(self)
                let result = parent.increaseItemByteCount(by: needed, recursiveItems: &recursiveItems)
                guard result == .success else { return .increaseFailed }
                _ = recursiveItems.popLast()
            }

 
            // The parent is big enough.
                
            if parent.isArray {
                
                // Increase the size of all elements by the same amount
                
                var index = parent.count
                while index > 0 {
                    
                    let srcPtr = parent.valuePtr.advanced(by: 8 + (index - 1) * parent.elementByteCount)
                    let dstPtr = parent.valuePtr.advanced(by: 8 + (index - 1) * parent.elementByteCount + increase)
                    let length = parent.elementByteCount
                    
                    moveBlock(dstPtr, srcPtr, length)
                    
                    
                    // Check if the point to self has to be updated
                    
                    if basePtr == srcPtr {
                        
                        
                        // Yes, self must be updated.
                        
                        basePtr = dstPtr
                        
                        
                        // Also update the pointer values in the recursiveItems by the same offset
                        
                        let offset = srcPtr.distance(to: dstPtr)
                        for item in recursiveItems {
                            if item.basePtr > srcPtr { item.basePtr = item.basePtr.advanced(by: offset) }
                            if item.parentPtr! > srcPtr { item.parentPtr = item.parentPtr!.advanced(by: offset) }
                        }
                    }
                    
                    index -= 1
                }
                
                // Update the size of the elements in the parent
                
                parent.elementByteCount += increase
                
                return .success
            }
            
            
            if parent.isDictionary || parent.isSequence {
                
                // Shift all the items after self by the amount of increase of self.
                
                var srcPtr: UnsafeMutableRawPointer?
                var length: Int = 0
                
                var itemPtr = parent.valuePtr
                var childCount = parent.count
                while childCount > 0 {
                    
                    if (srcPtr == nil) && (itemPtr > basePtr) {
                        srcPtr = itemPtr
                    }
                    if srcPtr != nil {
                        length += Int(UInt32.readValue(atPtr: itemPtr.advanced(by: itemByteCountOffset), endianness))
                    }
                    itemPtr = itemPtr.advanced(by: Int(UInt32.readValue(atPtr: itemPtr.advanced(by: itemByteCountOffset), endianness)))
                    childCount -= 1
                }
                if srcPtr == nil { srcPtr = itemPtr }
                
                if byteCount > 0 {
                    let dstPtr = srcPtr!.advanced(by: Int(increase))
                    moveBlock(dstPtr, srcPtr!, length)
                }
                
                
                // Update the item size of self
                
                byteCount += increase
                
                
                return .success
            }
            
            fatalError("No other parent possible")
        }
    }    
}
