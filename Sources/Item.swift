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

internal let nameFieldOffset = itemNvrFieldOffset
internal let nameHashOffset = nameFieldOffset + 0
internal let nameCountOffset = nameFieldOffset + 2
internal let nameDataOffset = nameFieldOffset + 3


// Offsets in the value field of an array item

internal let elementTypeOffset = 0
internal let elementOptionsOffset = 1
internal let elementFlagsOffset = 2
internal let elementNameFieldByteCountOffset = 3
internal let elementByteCountOffset = 4


// The smallest possible item size

internal let minimumItemByteCount: Int = 16


/// If this variable is set to 'true', some imposible-to-reach code parts will raise the fatal error instead of returning nil.
///
/// Use this during development and testing. Possibly even for production?

public var brbonAllowFatalError: Bool = true


/// The buffer manager protocol

internal protocol BufferManagerProtocol {
    var unusedByteCount: Int { get }
    func increaseBufferSize(by bytes: Int) -> Bool
    func moveBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer, _ length: Int)
    func moveEndBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer)
}


// This class controls the access to a memory area that contains a BRBON compatible data structure

public class Item {
    
    
    /// The pointer to the memory area where the bytes containing the value are stored. For array elements it points to the element.
    
    internal var basePtr: UnsafeMutableRawPointer
    
    
    /// A pointer to the parent of this item/element
    
    internal var parentPtr: UnsafeMutableRawPointer?
    
    
    /// The endianness with which to read/write the memory structure and item values.
    
    let endianness: Endianness
    
    
    /// Reads as true if the item is an element (i.e. an item inside an array)
    
    let isElement: Bool

    
    /// A reference back to a buffer manager
    
    internal var manager: BufferManagerProtocol?
    
    
    /// Create a new item accessor.
    
    internal init(basePtr: UnsafeMutableRawPointer, parentPtr: UnsafeMutableRawPointer?, manager: BufferManagerProtocol? = nil, endianness: Endianness = machineEndianness) {
        self.basePtr = basePtr
        self.parentPtr = parentPtr
        self.manager = manager
        self.endianness = endianness
        self.isElement = (parentPtr != nil) ? (parentPtr!.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue) : false
    }
    
    
    /// This null type is used when a requested item does not exists but an item must be returned.
    
    internal static let nullItem: NullItem = {
        let nullItemBuffer = UnsafeMutableRawBufferPointer.allocate(count: Int(minimumItemByteCount))
        Item.createNull(
            atPtr: nullItemBuffer.baseAddress!,
            nameFieldDescriptor: NameFieldDescriptor(nil)!,
            parentOffset: 0)
        return NullItem(basePtr: nullItemBuffer.baseAddress!, parentPtr: nil)
    }()

    
    /// These accessors must be in the main class because they are overriden in the NullItem class.
    
    var bool: Bool? {
        get {
            guard isBool else { return nil }
            return Bool.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isBool else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { type = .bool }
                    guard isBool else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var uint8: UInt8? {
        get {
            guard isUInt8 else { return nil }
            return UInt8.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isUInt8 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { type = .uint8 }
                    guard isUInt8 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var uint16: UInt16? {
        get {
            guard isUInt16 else { return nil }
            return UInt16.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isUInt16 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { type = .uint16 }
                    guard isUInt16 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var uint32: UInt32? {
        get {
            guard isUInt32 else { return nil }
            return UInt32.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isUInt32 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { type = .uint32 }
                    guard isUInt32 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var uint64: UInt64? {
        get {
            guard isUInt64 else { return nil }
            return UInt64.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isUInt64 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        type = .uint64
                    }
                    guard isUInt64 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var int8: Int8? {
        get {
            guard isInt8 else { return nil }
            return Int8.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isInt8 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { type = .int8 }
                    guard isInt8 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var int16: Int16? {
        get {
            guard isInt16 else { return nil }
            return Int16.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isInt16 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { type = .int16 }
                    guard isInt16 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var int32: Int32? {
        get {
            guard isInt32 else { return nil }
            return Int32.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isInt32 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { type = .int32 }
                    guard isInt32 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var int64: Int64? {
        get {
            guard isInt64 else { return nil }
            return Int64.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isInt64 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        type = .int64
                    }
                    guard isInt64 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var float32: Float32? {
        get {
            guard isFloat32 else { return nil }
            return Float32.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isFloat32 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { type = .float32 }
                    guard isFloat32 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var float64: Float64? {
        get {
            guard isFloat64 else { return nil }
            return Float64.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isFloat64 else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        type = .float64
                    }
                    guard isFloat64 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var string: String? {
        get {
            guard isString else { return nil }
            return String.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isString else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        type = .string
                    }
                    guard isString else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
    
    var binary: Data? {
        get {
            guard isBinary else { return nil }
            return Data.readValue(atPtr: valuePtr, endianness)
        }
        set {
            if isElement {
                guard isBinary else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        type = .binary
                    }
                    guard isBinary else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    type = .null
                }
            }
        }
    }
}


internal extension Item {
    
    internal var typePtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr }
        if UInt8.readValue(atPtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8.readValue(atPtr: parentPtr.advanced(by: itemNameFieldByteCountOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount))
        } else {
            return basePtr
        }
    }

    internal var optionsPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemOptionsOffset) }
        if UInt8.readValue(atPtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8.readValue(atPtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemOptionsOffset)
        } else {
            return basePtr.advanced(by: itemOptionsOffset)
        }
    }
    
    internal var flagsPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemFlagsOffset) }
        if UInt8.readValue(atPtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8.readValue(atPtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemFlagsOffset)
        } else {
            return basePtr.advanced(by: itemFlagsOffset)
        }
    }
    
    internal var nameFieldByteCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemNameFieldByteCountOffset) }
        if UInt8.readValue(atPtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8.readValue(atPtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemNameFieldByteCountOffset)
        } else {
            return basePtr.advanced(by: itemNameFieldByteCountOffset)
        }
    }

    internal var itemByteCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemByteCountOffset) }
        if UInt8.readValue(atPtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8.readValue(atPtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemByteCountOffset)
        } else {
            return basePtr.advanced(by: itemByteCountOffset)
        }
    }
    
    internal var parentOffsetPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemParentOffsetOffset) }
        if UInt8.readValue(atPtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8.readValue(atPtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemParentOffsetOffset)
        } else {
            return basePtr.advanced(by: itemParentOffsetOffset)
        }
    }

    internal var childCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemValueCountOffset) }
        if UInt8.readValue(atPtr: parentPtr, endianness) == ItemType.array.rawValue {
            return basePtr
        } else {
            return basePtr.advanced(by: itemValueCountOffset)
        }
    }
    
    internal var nameHashPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: nameHashOffset)
    }
    
    internal var nameCountPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: nameCountOffset)
    }
    
    internal var nameDataPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: nameDataOffset)
    }
    
    
    /// Return a pointer to the first value byte of this item.
    
    internal var valuePtr: UnsafeMutableRawPointer {
        
        if isElement {
            
            return basePtr
            
        } else {
            
            switch type! {
                
            case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32:
                return basePtr.advanced(by: itemValueCountOffset)
                
            case .int64, .uint64, .float64, .string, .binary, .array, .dictionary, .sequence:
                return basePtr.advanced(by: itemNvrFieldOffset + nameFieldByteCount)
            }
        }
    }
}


// MARK: - Accessors to item properties.

public extension Item {
    
    internal(set) var type: ItemType? {
        get {
            if isElement {
                return ItemType.readValue(atPtr: parentItem!.valuePtr)
            } else {
                return ItemType.readValue(atPtr: typePtr)
            }
        }
        set {
            if isElement { return } // Not for array's
            newValue?.rawValue.storeValue(atPtr: typePtr, endianness)
        }
    }
    
    internal(set) var options: ItemOptions? {
        get {
            if isElement {
                return ItemOptions.readValue(atPtr: parentItem!.valuePtr.advanced(by: itemOptionsOffset))
            } else {
                return ItemOptions.readValue(atPtr: optionsPtr)
            }
        }
        set {
            if isElement { return } // Not for array's
            newValue?.rawValue.storeValue(atPtr: optionsPtr, endianness)
        }
    }
    
    internal(set) var flags: ItemFlags? {
        get {
            if isElement {
                return ItemFlags.readValue(atPtr: parentItem!.valuePtr.advanced(by: itemFlagsOffset))
            } else {
                return ItemFlags.readValue(atPtr: flagsPtr)
            }
        }
        set {
            if isElement { return } // Not for array's
            newValue?.rawValue.storeValue(atPtr: flagsPtr, endianness)
        }
    }
    
    internal(set) var nameFieldByteCount: Int {
        get {
            if isElement { return 0 }
            return Int(UInt8.readValue(atPtr: nameFieldByteCountPtr, endianness))
        }
        set {
            if isElement { return } // Not for array's
            UInt8(newValue).storeValue(atPtr: nameFieldByteCountPtr, endianness)
        }
    }

    internal var byteCount: Int {
        get {
            if isElement {
                return Int(UInt32.readValue(atPtr: parentItem!.valuePtr.advanced(by: 4), endianness))
            } else {
                return Int(UInt32.readValue(atPtr: itemByteCountPtr, endianness))
            }
        }
        set {
            if isElement {
                UInt32(newValue).storeValue(atPtr: parentItem!.valuePtr.advanced(by: 4), endianness)
            } else {
                UInt32(newValue).storeValue(atPtr: itemByteCountPtr, endianness)
            }
        }
    }
    
    internal var parentOffset: Int {
        get {
            if isElement { return 0 }
            return Int(UInt32.readValue(atPtr: parentOffsetPtr, endianness))
        }
        set {
            if isElement { return }
            UInt32(newValue).storeValue(atPtr: parentOffsetPtr, endianness)
        }
    }

    public var count: Int {
        get {
            if isElement { return 0 }
            return Int(UInt32.readValue(atPtr: childCountPtr, endianness))
        }
        set {
            if isElement { return }
            UInt32(newValue).storeValue(atPtr: childCountPtr, endianness)
        }
    }
    
    internal(set) var nameHash: UInt16 {
        get {
            if nameFieldByteCount == 0 { return 0 }
            return UInt16.readValue(atPtr: nameHashPtr, endianness)
        }
        set {
            if isElement { return }
            newValue.storeValue(atPtr: nameHashPtr, endianness)
        }
    }
    
    internal(set) var nameCount: Int {
        get {
            if nameFieldByteCount == 0 { return 0 }
            return Int(UInt8.readValue(atPtr: nameCountPtr, endianness))
        }
        set {
            if isElement { return }
            UInt8(newValue).storeValue(atPtr: nameCountPtr, endianness)
        }
    }
    
    internal(set) var nameData: Data {
        get {
            if nameFieldByteCount == 0 { return Data() }
            return Data(bytes: nameDataPtr, count: nameCount)
        }
        set {
            if isElement { return }
            guard newValue.count <= (nameFieldByteCount - 3) else { return }
            newValue.withUnsafeBytes({ nameDataPtr.copyBytes(from: $0, count: newValue.count)})
        }
    }
    
    internal(set) var name: String? {
        get {
            if nameFieldByteCount == 0 { return "" }
            return String.init(data: nameData, encoding: .utf8)
        }
        set {
            if isElement { return }
            guard let (data, discarded) = newValue?.utf8CodeMaxBytes(248), !discarded else { return }
            guard data.count <= (nameFieldByteCount - 3) else { return }
            let hash = data.crc16()
            let byteCount = data.count
            hash.storeValue(atPtr: nameHashPtr, endianness)
            UInt8(byteCount).storeValue(atPtr: nameCountPtr, endianness)
            data.withUnsafeBytes({ nameDataPtr.copyBytes(from: $0, count: data.count)})
        }
    }
}


// MARK: - Derived values from field values 

internal extension Item {
    
    
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

    
    /// Returns the parent as a new Item
    
    internal var parentItem: Item? {
        guard let parentPtr = parentPtr else { return nil }
        let parentParentOffsetPtr = parentPtr.advanced(by: itemParentOffsetOffset)
        let parentParentOffset = Int(UInt32.readValue(atPtr: parentParentOffsetPtr, endianness))
        if parentParentOffset == 0 {
            return Item.init(basePtr: parentPtr, parentPtr: nil, endianness: endianness)
        } else {
            return Item.init(basePtr: parentPtr, parentPtr: parentPtr.advanced(by: parentParentOffset), endianness: endianness)
        }
    }
    
    
    /// Returns the length of a child item in an array
    
    internal var elementByteCount: Int {
        get {
            return Int(UInt32.readValue(atPtr: parentItem!.valuePtr.advanced(by: 4), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: parentItem!.valuePtr.advanced(by: 4), endianness)
        }
    }
    
    
    /// Returns the type of a child in an array
    
    internal var elementType: ItemType? {
        get {
            return ItemType.readValue(atPtr: parentItem!.valuePtr)
        }
        set {
            guard let newValue = newValue else { return }
            newValue.storeValue(atPtr: parentItem!.valuePtr)
        }
    }
    
    
    /// Returns the number of bytes that are currently available for the value in this item.

    internal var availableValueByteCount: Int {
        if isElement {
            return Int(UInt32.readValue(atPtr: parentItem!.valuePtr.advanced(by: 4), endianness))
        } else {
            return byteCount - minimumItemByteCount - nameFieldByteCount
        }
    }

    
    /// Returns the number of bytes that are currently needed to represent the value in an item.

    internal var usedValueByteCount: Int {
        switch type! {
        case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32: return 0
        case .int64, .uint64, .float64: return 8
        case .string, .binary: return Int(4 + UInt32.readValue(atPtr: valuePtr, endianness))
        case .array: return 8 + count * Int(UInt32.readValue(atPtr: valuePtr.advanced(by: 4), endianness))
        case .dictionary, .sequence:
            var usedByteCount: Int = 0
            forEachAbortOnTrue({ usedByteCount += Int($0.byteCount) ; return false })
            return usedByteCount
        }
    }
    
    
    /// Moves a block of memory from the source pointer to the destination pointer.
    ///
    /// This operation is passed on to the buffer manager to allow updating of pointer values in items that the API has made visible.
    
    internal func moveBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer, _ length: Int) {
        if let parent = parentItem {
            return parent.moveBlock(dstPtr, srcPtr, length)
        } else {
            guard let manager = manager else { return }
            manager.moveBlock(dstPtr, srcPtr, length)
        }
    }
    

    /// Moves a block of memory from the source pointer to the destination pointer. The size of the block is given by the distance from the source pointer to the last byte used in the buffer area.
    ///
    /// This operation is passed on to the buffer manager to allow updating of pointer values in items that the API has made visible.
    
    internal func moveEndBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer) {
        if let parent = parentItem {
            return parent.moveEndBlock(dstPtr, srcPtr)
        } else {
            guard let manager = manager else { return }
            manager.moveEndBlock(dstPtr, srcPtr)
        }
    }
    
    
    /// The offset for the given pointer from the start of the buffer.
    
    internal func offsetInBuffer(for aptr: UnsafeMutableRawPointer) -> Int {
        var pit = parentItem
        var ptr = basePtr
        while pit != nil {
            ptr = pit!.basePtr      // The base pointer of the first item is the buffer base address
            pit = pit!.parentItem   // Go up the parent/child chain
        }
        return ptr.distance(to: aptr)
    }

    
    /// An intermediate error handler. Raises the fatal error if triggered. But an API use may decide to have a NOP instead.
    
    @discardableResult
    internal func fatalOrNil(_ message: String) -> Item? {
        if brbonAllowFatalError {
            fatalError(message)
        } else {
            return nil
        }
    }
    
    
    /// An intermediate error handler. Raises the fatal error if triggered. But an API use may decide to have a NOP instead.
    
    @discardableResult
    internal func fatalOrNull(_ message: String) -> Item? {
        if brbonAllowFatalError {
            fatalError(message)
        } else {
            return Item.nullItem
        }
    }
}


public extension Item {
    
    
    /// Reduces the byte count of this item to the minimal possible
    
    public func minimizeByteCount() {
        print("Not implemented yet")
    }
}

