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

    var isNull: Bool { return type == .null }
    var isBool: Bool { return type == .bool }
    var isUInt8: Bool { return type == .uint8 }
    var isUInt16: Bool { return type == .uint16 }
    var isUInt32: Bool { return type == .uint32 }
    var isUInt64: Bool { return type == .uint64 }
    var isInt8: Bool { return type == .int8 }
    var isInt16: Bool { return type == .int16 }
    var isInt32: Bool { return type == .int32 }
    var isInt64: Bool { return type == .int64 }
    var isFloat32: Bool { return type == .float32 }
    var isFloat64: Bool { return type == .float64 }
    var isString: Bool { return type == .string }
    var isBinary: Bool { return type == .binary }
    var isArray: Bool { return type == .array }
    var isDictionary: Bool { return type == .dictionary }
    var isSequence: Bool { return type == .sequence }
    
    
    // *********************
    // MARK: - Internal
    // *********************
    
    /// Returns the necessary length for the nvr field.
    
    internal static func nvrLength(for value: BrbonBytes, nameFieldLength: UInt8, fixedItemValueByteCount: UInt32?) -> UInt32? {
        
        
        // Size needed for the value
        
        var length: UInt32 = value.brbonType.useValueCountFieldAsValue ? 0 : value.brbonCount
        
        
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
        value: BrbonBytes,
        nameFieldDescriptor: NameFieldDescriptor,
        fixedItemValueByteCount: UInt32? = nil,
        endianness: Endianness = machineEndianness) -> Bool {

            
        // Determine size of the value field
        
        guard let nvrLength = nvrLength(for: value, nameFieldLength: nameFieldDescriptor.byteCount, fixedItemValueByteCount: fixedItemValueByteCount) else { return false }
        
        
        // Size of the item
        
        let itemLength = nvrLength + minimumItemByteCount
        
        
        // Serialize the item
        
        var ptr = atPtr
        
        value.brbonType.rawValue.brbonBytes(toPtr: ptr, endianness)        // Item-Header - type
        ptr = ptr.advanced(by: 1)
        
        UInt8(0).brbonBytes(toPtr: ptr, endianness)                        // Item-Header - options
        ptr = ptr.advanced(by: 1)
        
        UInt8(0).brbonBytes(toPtr: ptr, endianness)                        // Item-Header - flags
        ptr = ptr.advanced(by: 1)
        
        nameFieldDescriptor.byteCount.brbonBytes(toPtr: ptr, endianness)   // Item-Header - name length
        ptr = ptr.advanced(by: 1)
        
        itemLength.brbonBytes(toPtr: ptr, endianness)                      // Item-Length
        ptr = ptr.advanced(by: 4)
        
        UInt32(0).brbonBytes(toPtr: ptr, endianness)                       // Parent-Offset
        ptr = ptr.advanced(by: 4)
        
        switch value.brbonType {                                           // Value of value/count field
            
        case .bool, .int8, .uint8:
            
            value.brbonBytes(toPtr: ptr, endianness)
            ptr = ptr.advanced(by: 1)
            
            UInt8(0).brbonBytes(toPtr: ptr, endianness)
            ptr = ptr.advanced(by: 1)
            
            UInt16(0).brbonBytes(toPtr: ptr, endianness)
            ptr = ptr.advanced(by: 2)
            
        case .int16, .uint16:
            
            value.brbonBytes(toPtr: ptr, endianness)
            ptr = ptr.advanced(by: 2)
            
            UInt16(0).brbonBytes(toPtr: ptr, endianness)
            ptr = ptr.advanced(by: 2)

        case .int32, .uint32, .float32:
            value.brbonBytes(toPtr: ptr, endianness)
            ptr = ptr.advanced(by: 4)

        default:
            if value.brbonType.useValueCountFieldAsCount {
                value.brbonCount.brbonBytes(toPtr: ptr, endianness)
            } else {
                UInt32(0).brbonBytes(toPtr: ptr, endianness)
            }
            ptr = ptr.advanced(by: 4)
        }
        
        if nameFieldDescriptor.byteCount > 0 {
            nameFieldDescriptor.brbonBytes(toPtr: ptr, endianness)         // Name field
            ptr = ptr.advanced(by: Int(nameFieldDescriptor.byteCount))
        }
        
        switch value.brbonType {                                           // Value
        case .uint64, .int64, .float64, .string, .binary:
            value.brbonBytes(toPtr: ptr, endianness)
            ptr = ptr.advanced(by: Int(value.brbonCount))
        default: break
        }
        
        let fillerSize = Int(itemLength) - atPtr.distance(to: ptr)
        if fillerSize > 0 { Data(count: fillerSize).brbonBytes(toPtr: ptr, endianness) }       // Filler/Reserved

        
        // Success
        
        return true
    }
    
    @discardableResult
    internal static func createNull(
        atPtr: UnsafeMutableRawPointer,
        nameFieldDescriptor: NameFieldDescriptor,
        parentOffset: UInt32,
        valueByteCount: UInt32? = nil,
        endianness: Endianness = machineEndianness) -> Bool {


        // The size of the item
        
        let itemByteCount = minimumItemByteCount + UInt32(nameFieldDescriptor.byteCount) + (valueByteCount ?? 0)

        
        // Add the null starting at the pointer
        
        var ptr = atPtr
        
        
        // Add the null
        
        ItemType.null.brbonBytes(toPtr: ptr, endianness)
        ptr = ptr.advanced(by: 1)
        
        UInt8(0).brbonBytes(toPtr: ptr, endianness)
        ptr = ptr.advanced(by: 1)
        
        UInt8(0).brbonBytes(toPtr: ptr, endianness)
        ptr = ptr.advanced(by: 1)
        
        nameFieldDescriptor.byteCount.brbonBytes(toPtr: ptr, endianness)
        ptr = ptr.advanced(by: 1)
        
        itemByteCount.brbonBytes(toPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        parentOffset.brbonBytes(toPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        UInt32(0).brbonBytes(toPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        nameFieldDescriptor.brbonBytes(toPtr: ptr, endianness)

        
        // Success
        
        return true
    }

    
    /// Ensures that an item can accomodate a value of the given length. If necessary it will try to increase the size of the item. Note that increasing the size is only possible for contiguous items and for variable length elements.
    ///
    /// - Parameter for: The number of bytes needed.
    ///
    /// - Returns: True if the item or element has sufficient bytes available.
    
    internal func ensureValueStorage(for bytes: UInt32) -> Result {
        let availableByteCount = maximumValueByteCount - minimumValueByteCount
        if availableByteCount >= bytes { return .success }
        if isContiguous || type!.isVariableLength {
            var recursiveItems: Array<Item> = [self]
            return increaseItemByteCount(by: (bytes - availableByteCount), recursiveItems: &recursiveItems)
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
    
    internal func increaseItemByteCount(by bytes: UInt32, recursiveItems: inout Array<Item>) -> Result {

        
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
            
            let increase: UInt32
            if parent.isArray {
                increase = bytes
            } else {
                increase = bytes.roundUpToNearestMultipleOf8()
            }
            
            
            // The number of bytes the parent item has available for child byte count increases
            
            let available = parent.maximumValueByteCount - parent.minimumValueByteCount
            
            
            // The number of bytes needed for the increase in the parent item
            
            let needed: UInt32
            
            if isArray {
                needed = (count32 * increase).roundUpToNearestMultipleOf8()
            } else {
                needed = increase
            }
            
            
            // If more is needed than available, then ask the parent to increase the available byte count
            
            if needed > available {
                recursiveItems.append(self)
                let result = parent.increaseItemByteCount(by: needed, recursiveItems: &recursiveItems)
                guard result == .success else { return .increaseFailed }
                _ = recursiveItems.popLast()
            }

 
            // The parent is big enough.
                
            if parent.isArray {
                
                // Increase the size of all elements by the same amount
                
                var index = parent.count32
                while index > 0 {
                    
                    let srcPtr = parent.valuePtr.advanced(by: 8 + Int((index - 1) * parent.elementByteCount))
                    let dstPtr = parent.valuePtr.advanced(by: 8 + Int((index - 1) * parent.elementByteCount + increase))
                    let length = Int(parent.elementByteCount)
                    
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
                        length += Int(UInt32(itemPtr.advanced(by: itemByteCountOffset), endianness))
                    }
                    itemPtr = itemPtr.advanced(by: Int(UInt32(itemPtr.advanced(by: itemByteCountOffset), endianness)))
                    childCount -= 1
                }
                
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
