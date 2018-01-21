//
//  Item.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 20/01/18.
//
//

import Foundation
import BRUtils


// Offsets in the item data structure

internal let itemTypeOffset = 0
internal let itemOptionsOffset = 1
internal let itemFlagsOffset = 2
internal let itemNameFieldByteCountOffset = 3
internal let itemByteCountOffset = 4
internal let itemParentOffsetOffset = 8
internal let itemValueCountOffset = 12
internal let itemNvrFieldOffset = 16


// Offsets in the NVR field data structure

internal let itemNameFieldOffset = itemNvrFieldOffset
internal let nameHashOffset = itemNameFieldOffset + 0
internal let nameCountOffset = itemNameFieldOffset + 2
internal let nameDataOffset = itemNameFieldOffset + 3


// The smallest possible item size

internal let minimumItemByteCount: UInt32 = 16


// This structure controls the access to a memory area that contains a BRBON compatible data structure

struct Item: ItemProtocol {
    
    
    /// The pointer to the memory area where the bytes containing the value are stored. For array elements it points to the element.
    
    let ptr: UnsafeMutableRawPointer
    
    
    /// A pointer to the parent of this item/element
    
    let parentPtr: UnsafeMutableRawPointer?
    
    
    /// The endianness with which to read/write the memory structure and item values.
    
    let endianness: Endianness
    
    
    /// Create a new item accessor.
    
    init(ptr: UnsafeMutableRawPointer, parentPtr: UnsafeMutableRawPointer?, endianness: Endianness = machineEndianness) {
        self.ptr = ptr
        self.parentPtr = parentPtr
        self.endianness = endianness
    }
}


extension Item {
    
    var typePtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return ptr }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: itemNameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount))
        } else {
            return ptr
        }
    }

    var optionsPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return ptr.advanced(by: itemOptionsOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: itemNameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemOptionsOffset)
        } else {
            return ptr.advanced(by: itemOptionsOffset)
        }
    }
    
    var flagsPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return ptr.advanced(by: itemFlagsOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: itemNameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemFlagsOffset)
        } else {
            return ptr.advanced(by: itemFlagsOffset)
        }
    }
    
    var nameFieldByteCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return ptr.advanced(by: itemNameFieldByteCountOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: itemNameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemNameFieldByteCountOffset)
        } else {
            return ptr.advanced(by: itemNameFieldByteCountOffset)
        }
    }

    var itemByteCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return ptr.advanced(by: itemByteCountOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: itemNameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemByteCountOffset)
        } else {
            return ptr.advanced(by: itemByteCountOffset)
        }
    }
    
    var parentOffsetPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return ptr.advanced(by: itemParentOffsetOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: itemNameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemParentOffsetOffset)
        } else {
            return ptr.advanced(by: itemParentOffsetOffset)
        }
    }

    var childCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return ptr.advanced(by: itemValueCountOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            return ptr
        } else {
            return ptr.advanced(by: itemValueCountOffset)
        }
    }
    
    var nameHashPtr: UnsafeMutableRawPointer {
        return ptr.advanced(by: nameHashOffset)
    }
    
    var nameCountPtr: UnsafeMutableRawPointer {
        return ptr.advanced(by: nameCountOffset)
    }
    
    var nameDataPtr: UnsafeMutableRawPointer {
        return ptr.advanced(by: nameDataOffset)
    }

}

// MARK: - Accessors to fields in the item.

extension Item {
    
    var type: ItemType? {
        get { return ItemType(typePtr, endianness) }
        set { newValue?.rawValue.brbonBytes(toPtr: typePtr, endianness) }
    }
    
    var options: ItemOptions? {
        get { return ItemOptions(optionsPtr, endianness) }
        set { newValue?.rawValue.brbonBytes(toPtr: optionsPtr, endianness) }
    }
    
    var flags: ItemFlags? {
        get { return ItemFlags(flagsPtr, endianness) }
        set { newValue?.rawValue.brbonBytes(toPtr: flagsPtr, endianness) }
    }

    var nameFieldByteCount: UInt8 {
        get { return UInt8(nameFieldByteCountPtr, endianness) }
        set { newValue.brbonBytes(toPtr: nameFieldByteCountPtr, endianness) }
    }
    
    var itemByteCount: UInt32 {
        get { return UInt32(itemByteCountPtr, endianness) }
        set { newValue.brbonBytes(toPtr: itemByteCountPtr, endianness) }
    }
    
    var parentOffset: UInt32 {
        get { return UInt32(parentOffsetPtr, endianness) }
        set { newValue.brbonBytes(toPtr: parentOffsetPtr, endianness) }
    }
    
    var childCount: UInt32 {
        get { return UInt32(childCountPtr, endianness) }
        set { newValue.brbonBytes(toPtr: childCountPtr, endianness) }
    }
    
    var nameHash: UInt16 {
        get { return UInt16(nameHashPtr, endianness) }
        set { newValue.brbonBytes(toPtr: nameHashPtr, endianness) }
    }
    
    var nameCount: UInt8 {
        get { return UInt8(nameCountPtr, endianness) }
        set { newValue.brbonBytes(toPtr: nameCountPtr, endianness) }
    }
    
    var name: String? {
        get {
            let data = Data(bytes: nameDataPtr, count: Int(nameCount))
            return String.init(data: data, encoding: .utf8)
        }
        set {
            guard let (data, discarded) = newValue?.utf8CodeMaxBytes(248), !discarded else { return }
            let hash = data.crc16()
            let byteCount = UInt8(data.count)
            hash.brbonBytes(toPtr: nameHashPtr, endianness)
            byteCount.brbonBytes(toPtr: nameCountPtr, endianness)
            data.withUnsafeBytes({ nameDataPtr.copyBytes(from: $0, count: data.count)})
        }
    }
}


// MARK: - Derived values from field values 

extension Item {
    
    
    /// Returns the parent as a new Item
    
    var parentItem: Item? {
        guard let parentPtr = parentPtr else { return nil }
        let parentParentOffsetPtr = parentPtr.advanced(by: Int(itemParentOffsetOffset))
        let parentParentOffset = UInt32(parentParentOffsetPtr, endianness)
        if parentParentOffset == 0 {
            return Item.init(ptr: parentPtr, parentPtr: nil, endianness: endianness)
        } else {
            return Item.init(ptr: parentPtr, parentPtr: parentPtr.advanced(by: Int(parentParentOffset)), endianness: endianness)
        }
    }
    
    
    /// Return true if the bytes of this item are stored sequentially. (I.e. if the parent is not an array)
    
    var isContiguous: Bool {
        if parentPtr == nil { return true }
        return UInt8(typePtr, endianness) != ItemType.array.rawValue
    }
    
    
    /// Return a pointer to the first value byte of this item.
    
    var valuePtr: UnsafeMutableRawPointer {
        guard let type = type else {
            // Note this error should be prevented by tests before this member is ever read. Because when this happens, the data that is beiing processed is corrupt and we cannot proceed at all.
            fatalError("Cannot construct type for BRBON.Item.valuePtr")
        }
        if isContiguous {
            switch type {
            case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32:
                return ptr.advanced(by: itemValueCountOffset)
            case .int64, .uint64, .float64, .string, .binary, .array, .dictionary, .sequence:
                return ptr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount))
            }
        } else { // self is contained in an array
            switch type {
            case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32, .int64, .uint64, .float64, .string, .binary:
                // The value starts immediately at the first byte of the value field. There is no name.
                return ptr
            case .array, .dictionary, .sequence:
                // The value starts after the count field
                return ptr.advanced(by: 4)
            }
            return ptr
        }
    }
    
    
    /// Return the number of bytes that are unused in the value field.
    
    var unusedValueByteCount: UInt32 {
        guard let type = type else {
            // Note this error should be prevented by tests before this member is ever read. Because when this happens, the data that is beiing processed is corrupt and we cannot proceed at all.
            fatalError("Cannot construct type for BRBON.Item.valuePtr")
        }
        switch type {
        case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32: return maximumValueByteCount
        case .int64, .uint64, .float64: return maximumValueByteCount - 8
        case .string, .binary: return maximumValueByteCount - 4 - UInt32(valuePtr, endianness)
        case .array: return maximumValueByteCount - childCount * UInt32(valuePtr.advanced(by: 4), endianness)
        case .dictionary, .sequence:
            let unusedByteCount = itemByteCount - minimumItemByteCount
//            forEach({ unusedByteCount -= $0.itemByteCount })
            return unusedByteCount
        }
    }
    
    var maximumValueByteCount: UInt32 {
        return itemByteCount - minimumItemByteCount - UInt32(nameFieldByteCount)
    }
    
    
    @discardableResult
    func fatalOrNil(_ message: String) -> Item? {
        if true {
            fatalError(message)
        } else {
            return nil
        }
    }
}


