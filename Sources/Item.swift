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

internal let minimumItemByteCount: UInt32 = 16


// The maximum accepted value for UInt32

internal let UInt32Max = UInt32(Int32.max)


/// If this variable is set to 'true', some imposible-to-reach code parts will raise the fatal error instead of returning nil.
///
/// Use this during development and testing. Possibly even for production?

public var brbonAllowFatalError: Bool = true


/// The buffer manager protocol

internal protocol BufferManagerProtocol {
    var unusedByteCount: UInt32 { get }
    func increaseBufferSize(by bytes: UInt32) -> Bool
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
    
    
    /// A reference back to a manager
    
    internal var manager: BufferManagerProtocol?
    
    
    /// Create a new item accessor.
    
    internal init(basePtr: UnsafeMutableRawPointer, parentPtr: UnsafeMutableRawPointer?, manager: BufferManagerProtocol? = nil, endianness: Endianness = machineEndianness) {
        self.basePtr = basePtr
        self.parentPtr = parentPtr
        self.manager = manager
        self.endianness = endianness
    }
    
    
    /// These accessors must be in the main class because they are overriden in the NullItem class.
    
    var bool: Bool? {
        get {
            guard isBool else { return nil }
            return Bool(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) { type = .bool }
            guard isBool else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var uint8: UInt8? {
        get {
            guard isUInt8 else { return nil }
            return UInt8(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) { type = .uint8 }
            guard isUInt8 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var uint16: UInt16? {
        get {
            guard isUInt16 else { return nil }
            return UInt16(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) { type = .uint16 }
            guard isUInt16 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var uint32: UInt32? {
        get {
            guard isUInt32 else { return nil }
            return UInt32(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) { type = .uint32 }
            guard isUInt32 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var uint64: UInt64? {
        get {
            guard isUInt64 else { return nil }
            return UInt64(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) { type = .uint64 }
            guard isUInt64 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var int8: Int8? {
        get {
            guard isInt8 else { return nil }
            return Int8(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) { type = .int8 }
            guard isInt8 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var int16: Int16? {
        get {
            guard isInt16 else { return nil }
            return Int16(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) { type = .int16 }
            guard isInt16 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var int32: Int32? {
        get {
            guard isInt32 else { return nil }
            return Int32(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) { type = .int32 }
            guard isInt32 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var int64: Int64? {
        get {
            guard isInt64 else { return nil }
            return Int64(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) {
                guard ensureValueStorage(for: 8) == .success else { return }
                type = .int64
            }
            guard isInt64 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var float32: Float32? {
        get {
            guard isFloat32 else { return nil }
            return Float32(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) { type = .float32 }
            guard isFloat32 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var float64: Float64? {
        get {
            guard isFloat64 else { return nil }
            return Float64(valuePtr, endianness)
        }
        set {
            if isNull && !(parentItem?.isArray ?? false) {
                guard ensureValueStorage(for: 8) == .success else { return }
                type = .float64
            }
            guard isFloat64 else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var string: String? {
        get {
            guard isString else { return nil }
            return String(valuePtr, endianness)
        }
        set {
            if isNull { type = .string }
            guard isString else { return }
            guard ensureValueStorage(for: newValue?.brbonCount ?? 0) == .success else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
    
    var binary: Data? {
        get {
            guard isBinary else { return nil }
            return Data(valuePtr, endianness)
        }
        set {
            if isNull { type = .binary }
            guard isBinary else { return }
            guard ensureValueStorage(for: newValue?.brbonCount ?? 0) == .success else { return }
            newValue?.brbonBytes(toPtr: valuePtr, endianness)
        }
    }
}

internal extension Item {
    
    internal static let nullItem: NullItem = {
        let nullItemBuffer = UnsafeMutableRawBufferPointer.allocate(count: Int(minimumItemByteCount))
        Item.createNull(
            atPtr: nullItemBuffer.baseAddress!,
            nameFieldDescriptor: NameFieldDescriptor(nil)!,
            parentOffset: 0)
        return NullItem(basePtr: nullItemBuffer.baseAddress!, parentPtr: nil)
    }()
}

internal extension Item {
    
    internal var typePtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: itemNameFieldByteCountOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount))
        } else {
            return basePtr
        }
    }

    internal var optionsPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemOptionsOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemOptionsOffset)
        } else {
            return basePtr.advanced(by: itemOptionsOffset)
        }
    }
    
    internal var flagsPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemFlagsOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemFlagsOffset)
        } else {
            return basePtr.advanced(by: itemFlagsOffset)
        }
    }
    
    internal var nameFieldByteCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemNameFieldByteCountOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemNameFieldByteCountOffset)
        } else {
            return basePtr.advanced(by: itemNameFieldByteCountOffset)
        }
    }

    internal var itemByteCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemByteCountOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemByteCountOffset)
        } else {
            return basePtr.advanced(by: itemByteCountOffset)
        }
    }
    
    internal var parentOffsetPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemParentOffsetOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
            let nameFieldByteCount = UInt8(parentPtr.advanced(by: nameFieldOffset), endianness)
            return parentPtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + itemParentOffsetOffset)
        } else {
            return basePtr.advanced(by: itemParentOffsetOffset)
        }
    }

    internal var childCountPtr: UnsafeMutableRawPointer {
        guard let parentPtr = parentPtr else { return basePtr.advanced(by: itemValueCountOffset) }
        if UInt8(parentPtr, endianness) == ItemType.array.rawValue {
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
}


// MARK: - Accessors to fields in the item.

public extension Item {
    
    internal(set) var type: ItemType? {
        get { return ItemType(typePtr, endianness) }
        set { newValue?.rawValue.brbonBytes(toPtr: typePtr, endianness) }
    }
    
    internal(set) var options: ItemOptions? {
        get { return ItemOptions(optionsPtr, endianness) }
        set { newValue?.rawValue.brbonBytes(toPtr: optionsPtr, endianness) }
    }
    
    internal(set) var flags: ItemFlags? {
        get { return ItemFlags(flagsPtr, endianness) }
        set { newValue?.rawValue.brbonBytes(toPtr: flagsPtr, endianness) }
    }
    
    internal(set) var nameFieldByteCount: UInt8 {
        get { return UInt8(nameFieldByteCountPtr, endianness) }
        set { newValue.brbonBytes(toPtr: nameFieldByteCountPtr, endianness) }
    }

    internal var byteCount: UInt32 {
        get { return UInt32(itemByteCountPtr, endianness) }
        set { newValue.brbonBytes(toPtr: itemByteCountPtr, endianness) }
    }
    
    internal var parentOffset: UInt32 {
        get { return UInt32(parentOffsetPtr, endianness) }
        set { newValue.brbonBytes(toPtr: parentOffsetPtr, endianness) }
    }

    public var count: Int {
        return Int(UInt32(childCountPtr, endianness))
    }

    internal var count32: UInt32 {
        get { return UInt32(childCountPtr, endianness) }
        set { newValue.brbonBytes(toPtr: childCountPtr, endianness) }
    }
    
    internal(set) var nameHash: UInt16 {
        get { return UInt16(nameHashPtr, endianness) }
        set { newValue.brbonBytes(toPtr: nameHashPtr, endianness) }
    }
    
    internal(set) var nameCount: UInt8 {
        get { return UInt8(nameCountPtr, endianness) }
        set { newValue.brbonBytes(toPtr: nameCountPtr, endianness) }
    }
    
    internal(set) var nameData: Data {
        get {
            return Data(bytes: nameDataPtr, count: Int(nameCount))
        }
        set {
            guard newValue.count <= Int(nameFieldByteCount - 3) else { return }
            newValue.withUnsafeBytes({ nameDataPtr.copyBytes(from: $0, count: newValue.count)})
        }
    }
    
    internal(set) var name: String? {
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

internal extension Item {
    
    
    /// Returns the parent as a new Item
    
    internal var parentItem: Item? {
        guard let parentPtr = parentPtr else { return nil }
        let parentParentOffsetPtr = parentPtr.advanced(by: Int(itemParentOffsetOffset))
        let parentParentOffset = UInt32(parentParentOffsetPtr, endianness)
        if parentParentOffset == 0 {
            return Item.init(basePtr: parentPtr, parentPtr: nil, endianness: endianness)
        } else {
            return Item.init(basePtr: parentPtr, parentPtr: parentPtr.advanced(by: Int(parentParentOffset)), endianness: endianness)
        }
    }
    
    
    /// Return true if the bytes of this item are stored sequentially. (I.e. if the parent is not an array)
    
    internal var isContiguous: Bool {
        guard let parentPtr = parentPtr else { return true }
        return UInt8(parentPtr, endianness) != ItemType.array.rawValue
    }
    
    
    /// Return a pointer to the first value byte of this item.
    
    internal var valuePtr: UnsafeMutableRawPointer {
        guard let type = type else {
            // Note this error should be prevented by tests before this member is ever read. Because when this happens, the data that is beiing processed is corrupt and we cannot proceed at all.
            fatalError("Cannot construct type for BRBON.Item.valuePtr")
        }
        if isContiguous {
            switch type {
            case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32:
                return basePtr.advanced(by: itemValueCountOffset)
            case .int64, .uint64, .float64, .string, .binary, .array, .dictionary, .sequence:
                return basePtr.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount))
            }
        } else { // self is contained in an array
            switch type {
            case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32, .int64, .uint64, .float64, .string, .binary:
                // The value starts immediately at the first byte of the value field. There is no name.
                return basePtr
            case .array, .dictionary, .sequence:
                // The value starts after the count field
                return basePtr.advanced(by: 4)
            }
        }
    }
    
    
    /// Returns the number of bytes that are currently unused in the item.
    ///
    /// - Note: These bytes may be unusable, for example an Int16 that has N bytes unused will never be able to use those bytes. (However by cycling the item through the null type, and then to a variable length type these bytes can become usable)

    internal var maximumValueByteCount: UInt32 {
        return byteCount - minimumItemByteCount - UInt32(nameFieldByteCount)
    }

    
    /// Returns the number of bytes that are currently needed to represent the value in an item.
    
    internal var minimumValueByteCount: UInt32 {
        switch type! {
        case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32: return 0
        case .int64, .uint64, .float64: return 8
        case .string, .binary: return 4 + UInt32(valuePtr, endianness)
        case .array: return 8 + count32 * elementByteCount
        case .dictionary, .sequence:
            var usedByteCount: UInt32 = 0
            forEachAbortOnTrue({ usedByteCount += $0.minimumValueByteCount ; return false })
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
    
    internal func offsetInBuffer(for aptr: UnsafeMutableRawPointer) -> UInt32 {
        var pit = parentItem
        var ptr = basePtr
        while pit != nil {
            ptr = pit!.basePtr      // The base pointer of the first item is the buffer base address
            pit = pit!.parentItem   // Go up the parent/child chain
        }
        return UInt32(ptr.distance(to: aptr))
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
}


public extension Item {
    
    
    /// Reduces the byte count of this item to the minimal possible
    
    public func minimizeByteCount() {
        print("Not implemented yet")
    }
}

