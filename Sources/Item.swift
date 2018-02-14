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
internal let itemCountValueOffset = 12
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
        Null().storeAsItem(
            atPtr: nullItemBuffer.baseAddress!,
            bufferPtr: nullItemBuffer.baseAddress!,
            parentPtr: nullItemBuffer.baseAddress!,
            machineEndianness)
        return NullItem(basePtr: nullItemBuffer.baseAddress!, parentPtr: nil)
    }()

    
    /// These accessors must be in the main class because they are overriden in the NullItem class.
    
    var bool: Bool? {
        get {
            guard isBool else { return nil }
            if isElement {
                return Bool(elementPtr: basePtr, endianness)
            } else {
                return Bool(itemPtr: basePtr, endianness)
            }
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
                    if isBool {
                        type = .null
                    }
                }
            }
        }
    }
    
    var uint8: UInt8? {
        get {
            guard isUInt8 else { return nil }
            if isElement {
                return UInt8(elementPtr: basePtr, endianness)
            } else {
                return UInt8(itemPtr: basePtr, endianness)
            }
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
                    if isUInt8 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var uint16: UInt16? {
        get {
            guard isUInt16 else { return nil }
            if isElement {
                return UInt16(elementPtr: basePtr, endianness)
            } else {
                return UInt16(itemPtr: basePtr, endianness)
            }
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
                    if isUInt16 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var uint32: UInt32? {
        get {
            guard isUInt32 else { return nil }
            if isElement {
                return UInt32(elementPtr: basePtr, endianness)
            } else {
                return UInt32(itemPtr: basePtr, endianness)
            }
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
                    if isUInt32 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var uint64: UInt64? {
        get {
            guard isUInt64 else { return nil }
            if isElement {
                return UInt64(elementPtr: basePtr, endianness)
            } else {
                return UInt64(itemPtr: basePtr, endianness)
            }
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
                    if isUInt64 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var int8: Int8? {
        get {
            guard isInt8 else { return nil }
            if isElement {
                return Int8(elementPtr: basePtr, endianness)
            } else {
                return Int8(itemPtr: basePtr, endianness)
            }
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
                    if isInt8 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var int16: Int16? {
        get {
            guard isInt16 else { return nil }
            if isElement {
                return Int16(elementPtr: basePtr, endianness)
            } else {
                return Int16(itemPtr: basePtr, endianness)
            }
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
                    if isInt16 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var int32: Int32? {
        get {
            guard isInt32 else { return nil }
            if isElement {
                return Int32(elementPtr: basePtr, endianness)
            } else {
                return Int32(itemPtr: basePtr, endianness)
            }
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
                    if isInt32 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var int64: Int64? {
        get {
            guard isInt64 else { return nil }
            if isElement {
                return Int64(elementPtr: basePtr, endianness)
            } else {
                return Int64(itemPtr: basePtr, endianness)
            }
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
                    if isInt64 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var float32: Float32? {
        get {
            guard isFloat32 else { return nil }
            if isElement {
                return Float32(elementPtr: basePtr, endianness)
            } else {
                return Float32(itemPtr: basePtr, endianness)
            }
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
                    if isFloat32 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var float64: Float64? {
        get {
            guard isFloat64 else { return nil }
            if isElement {
                return Float64(elementPtr: basePtr, endianness)
            } else {
                return Float64(itemPtr: basePtr, endianness)
            }
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
                    if isFloat64 {
                        type = .null
                    }
                }
            }
        }
    }
    
    var string: String? {
        get {
            guard isString else { return nil }
            if isElement {
                return String(elementPtr: basePtr, endianness)
            } else {
                return String(itemPtr: basePtr, endianness)
            }
        }
        set {
            if isElement {
                guard isString else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull || isString {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        type = .string
                    }
                    UInt32(newValue.valueByteCount).storeValue(atPtr: countValuePtr, endianness)
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isString {
                        type = .null
                    }
                }
            }
        }
    }
    
    var binary: Data? {
        get {
            guard isBinary else { return nil }
            if isElement {
                return Data(elementPtr: basePtr, endianness)
            } else {
                return Data(itemPtr: basePtr, endianness)
            }
        }
        set {
            if isElement {
                guard isBinary else { return }
                newValue?.storeAsElement(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull || isBinary {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        type = .binary
                    }
                    UInt32(newValue.count).storeValue(atPtr: countValuePtr, endianness)
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isBinary {
                        type = .null
                    }
                }
            }
        }
    }    
}


internal extension Item {
    
    internal var typePtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr }
        if UInt8(valuePtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(valuePtr: parentPtr.advanced(by: itemNameFieldByteCountOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount))
        } else {
            return basePtr
        }
    }

    internal var optionsPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemOptionsOffset) }
        if UInt8(valuePtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(valuePtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemOptionsOffset)
        } else {
            return basePtr.advanced(by: itemOptionsOffset)
        }
    }
    
    internal var flagsPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemFlagsOffset) }
        if UInt8(valuePtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(valuePtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemFlagsOffset)
        } else {
            return basePtr.advanced(by: itemFlagsOffset)
        }
    }
    
    internal var nameFieldByteCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemNameFieldByteCountOffset) }
        if UInt8(valuePtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(valuePtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemNameFieldByteCountOffset)
        } else {
            return basePtr.advanced(by: itemNameFieldByteCountOffset)
        }
    }

    internal var itemByteCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemByteCountOffset) }
        if UInt8(valuePtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(valuePtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemByteCountOffset)
        } else {
            return basePtr.advanced(by: itemByteCountOffset)
        }
    }
    
    internal var parentOffsetPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemParentOffsetOffset) }
        if UInt8(valuePtr: parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(valuePtr: parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemParentOffsetOffset)
        } else {
            return basePtr.advanced(by: itemParentOffsetOffset)
        }
    }

    internal var countValuePtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemCountValueOffset) }
        if UInt8(valuePtr: parentPtr, endianness) == ItemType.array.rawValue {
            return basePtr
        } else {
            return basePtr.advanced(by: itemCountValueOffset)
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
                return basePtr.advanced(by: itemCountValueOffset)
                
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
            return Int(UInt8(valuePtr: nameFieldByteCountPtr, endianness))
        }
        set {
            if isElement { return } // Not for array's
            UInt8(newValue).storeValue(atPtr: nameFieldByteCountPtr, endianness)
        }
    }

    internal var byteCount: Int {
        get {
            if isElement {
                return Int(UInt32(valuePtr: parentItem!.valuePtr.advanced(by: 4), endianness))
            } else {
                return Int(UInt32(valuePtr: itemByteCountPtr, endianness))
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
            return Int(UInt32(valuePtr: parentOffsetPtr, endianness))
        }
        set {
            if isElement { return }
            UInt32(newValue).storeValue(atPtr: parentOffsetPtr, endianness)
        }
    }

    public var count: Int {
        get {
            if isElement { return 0 }
            return Int(UInt32(valuePtr: countValuePtr, endianness))
        }
        set {
            if isElement { return }
            UInt32(newValue).storeValue(atPtr: countValuePtr, endianness)
        }
    }
    
    internal(set) var nameHash: UInt16 {
        get {
            if nameFieldByteCount == 0 { return 0 }
            return UInt16(valuePtr: nameHashPtr, endianness)
        }
        set {
            if isElement { return }
            newValue.storeValue(atPtr: nameHashPtr, endianness)
        }
    }
    
    internal(set) var nameCount: Int {
        get {
            if nameFieldByteCount == 0 { return 0 }
            return Int(UInt8(valuePtr: nameCountPtr, endianness))
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
        let parentParentOffset = Int(UInt32(valuePtr: parentParentOffsetPtr, endianness))
        if parentParentOffset == 0 {
            return Item.init(basePtr: parentPtr, parentPtr: nil, endianness: endianness)
        } else {
            return Item.init(basePtr: parentPtr, parentPtr: parentPtr.advanced(by: parentParentOffset), endianness: endianness)
        }
    }
    
    
    /// Returns the length of a child item in an array
    
    internal var elementByteCount: Int {
        get {
            return Int(UInt32(valuePtr: parentItem!.valuePtr.advanced(by: 4), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: parentItem!.valuePtr.advanced(by: 4), endianness)
        }
    }
    
    
    /// Returns the type of this item if the item is an element
    
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
            return Int(UInt32(valuePtr: parentItem!.valuePtr.advanced(by: 4), endianness))
        } else {
            return byteCount - minimumItemByteCount - nameFieldByteCount
        }
    }

    
    /// Returns the number of bytes that are currently needed to represent the value in an item.

    internal var usedValueByteCount: Int {
        switch type! {
        case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32: return 0
        case .int64, .uint64, .float64: return 8
        case .string, .binary: return count
        case .array: return 8 + count * Int(UInt32(valuePtr: valuePtr.advanced(by: 4), endianness))
        case .dictionary, .sequence:
            var usedByteCount: Int = 0
            forEachAbortOnTrue({ usedByteCount += Int($0.byteCount) ; return false })
            return usedByteCount
        }
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
                        length += Int(UInt32(valuePtr: itemPtr.advanced(by: itemByteCountOffset), endianness))
                    }
                    itemPtr = itemPtr.advanced(by: Int(UInt32(valuePtr: itemPtr.advanced(by: itemByteCountOffset), endianness)))
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
    
    
    internal var bufferPtr: UnsafeMutableRawPointer {
        var pit = parentItem
        var ptr = basePtr
        while pit != nil {
            ptr = pit!.basePtr      // The base pointer of the first item is the buffer base address
            pit = pit!.parentItem   // Go up the parent/child chain
        }
        return ptr
    }
    
    
    /// Reduces the byte count of this item to the minimal possible
    
    public func minimizeByteCount() {
        print("Not implemented yet")
    }
    
    
    /// The closure is called for each child item or until the closure returns true.
    ///
    /// - Parameter closure: The closure that is called for each item in the dictionary. If the closure returns true then the processing of further items is aborted.
    
    internal func forEachAbortOnTrue(_ closure: (Item) -> Bool) {
        if isArray {
            let elementPtr = valuePtr.advanced(by: 8)
            let nofChildren = count
            var index = 0
            let ebc = elementByteCount
            while index < nofChildren {
                let item = Item(basePtr: elementPtr.advanced(by: index * ebc), parentPtr: basePtr, endianness: endianness)
                if closure(item) { return }
                index += 1
            }
            return
        }
        if isDictionary {
            var itemPtr = valuePtr
            var remainder = count
            while remainder > 0 {
                let item = Item(basePtr: itemPtr, parentPtr: basePtr, endianness: endianness)
                if closure(item) { return }
                itemPtr = itemPtr.advanced(by: item.byteCount)
                remainder -= 1
            }
        }
    }
}

