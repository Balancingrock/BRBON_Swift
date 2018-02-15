//
//  ItemAccess.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 14/02/18.
//
//

import Foundation
import  BRUtils




/// This protocol allows access to fields within an Item. It is defined as class-only since otherwise the setters will not be reachable.

internal protocol ItemAccess: class, ValueAccess {
    
    
    /// The type must provide this base pointer. It must point to the first byte of an item.
    
    var basePtr: UnsafeMutableRawPointer { get }
    
    
    /// The type must provide this variable. It must contain the endianness of the item.
    
    var endianness: Endianness { get }
    
    
    // The following pointer have a default implementation
    
    var typePtr: UnsafeMutableRawPointer { get }
    
    var optionsPtr: UnsafeMutableRawPointer { get }
    
    var flagsPtr: UnsafeMutableRawPointer { get }
    
    var nameFieldByteCountPtr: UnsafeMutableRawPointer { get }
    
    var byteCountPtr: UnsafeMutableRawPointer { get }
    
    var parentOffsetPtr: UnsafeMutableRawPointer { get }
    
    var countValuePtr: UnsafeMutableRawPointer { get }
    
    var nameFieldPtr: UnsafeMutableRawPointer { get }
    
    var nameHashPtr: UnsafeMutableRawPointer { get }
    
    var nameCountPtr: UnsafeMutableRawPointer { get }
    
    var nameDataPtr: UnsafeMutableRawPointer { get }
    
    var valuePtr: UnsafeMutableRawPointer { get }
    
    
    // The following variables have a default implementation
    
    var type: ItemType? { get set }
    
    var options: ItemOptions? { get set }
    
    var flags: ItemFlags? { get set }
    
    var nameFieldByteCount: Int { get set }
    
    var byteCount: Int { get set }
    
    var parentOffset: Int { get set }
    
    var countValue: Int { get set }
    
    var nameHash: UInt16 { get set }
    
    var nameCount: Int { get set }
    
    var nameData: Data { get set }
    
    var name: String { get set }
}

extension ItemAccess {
    
    var typePtr: UnsafeMutableRawPointer {
        return basePtr
    }
    
    var optionsPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: itemOptionsOffset)
    }
    
    var flagsPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: itemFlagsOffset)
    }
    
    var nameFieldByteCountPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: itemNameFieldByteCountOffset)
    }
    
    var byteCountPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: itemByteCountOffset)
    }
    
    var parentOffsetPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: itemParentOffsetOffset)
    }
    
    var countValuePtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: itemCountValueOffset)
    }
    
    var nameFieldPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: nameFieldOffset)
    }

    var nameHashPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: nameHashOffset)
    }
    
    var nameCountPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: nameCountOffset)
    }
    
    var nameDataPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: nameDataOffset)
    }
        
    var valuePtr: UnsafeMutableRawPointer {
        let t = typePtr.assumingMemoryBound(to: UInt8.self).pointee
        if (t & useCountValueAsValueMask) != 0 {
            return basePtr.advanced(by: itemCountValueOffset)
        } else {
            return basePtr.advanced(by: itemNvrFieldOffset + nameFieldByteCount)
        }
    }
}

extension ItemAccess {
    
    var type: ItemType? {
        get { return ItemType.readValue(atPtr: typePtr) }
        set { newValue?.storeValue(atPtr: typePtr) }
    }
    
    var options: ItemOptions? {
        get { return ItemOptions.readValue(atPtr: optionsPtr) }
        set { newValue?.storeValue(atPtr: optionsPtr) }
    }
    
    var flags: ItemFlags? {
        get { return ItemFlags.readValue(atPtr: flagsPtr) }
        set { newValue?.storeValue(atPtr: flagsPtr) }
    }
    
    var nameFieldByteCount: Int {
        get { return Int(UInt8(valuePtr: nameFieldByteCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: nameFieldByteCountPtr, endianness) }
    }
    
    var byteCount: Int {
        get { return Int(UInt32(valuePtr: byteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: byteCountPtr, endianness) }
    }
    
    var parentOffset: Int {
        get { return Int(UInt32(valuePtr: parentOffsetPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: parentOffsetPtr, endianness) }
    }
    
    var countValue: Int {
        get { return Int(UInt32(valuePtr: countValuePtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: countValuePtr, endianness) }
    }
    
    var nameHash: UInt16 {
        get { return UInt16(valuePtr: nameHashPtr, endianness) }
        set { newValue.storeValue(atPtr: nameHashPtr, endianness) }
    }
    
    var nameCount: Int {
        get { return Int(UInt8(valuePtr: nameCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: nameCountPtr, endianness) }
    }
    
    var nameData: Data {
        get {
            if nameFieldByteCount == 0 { return Data() }
            return Data(bytes: nameDataPtr, count: nameCount)
        }
        set {
            guard newValue.count <= (nameFieldByteCount - 3) else { return }
            newValue.withUnsafeBytes({ nameDataPtr.copyBytes(from: $0, count: newValue.count)})
        }
    }
    
    var name: String {
        get {
            if nameFieldByteCount == 0 { return "" }
            return String.init(data: nameData, encoding: .utf8) ?? ""
        }
        set {
            guard let nfd = NameFieldDescriptor(name) else { return }
            nfd.storeValue(atPtr: nameFieldPtr, endianness)
        }
    }
}

extension ItemAccess {
    
    public var isNull: Bool { return type == .null }
    
    public var isBool: Bool { return type == .bool }
    
    public var isUInt8: Bool { return type == .uint8 }
    
    public var isUInt16: Bool { return type == .uint16 }
    
    public var isUInt32: Bool { return type == .uint32 }
    
    public var isUInt64: Bool { return type == .uint64 }
    
    public var isInt8: Bool { return type == .int8 }
    
    public var isInt16: Bool { return type == .int16 }
    
    public var isInt32: Bool { return type == .int32 }
    
    public var isInt64: Bool { return type == .int64 }
    
    public var isFloat32: Bool { return type == .float32 }
    
    public var isFloat64: Bool { return type == .float64 }
    
    public var isString: Bool { return type == .string }
    
    public var isBinary: Bool { return type == .binary }
    
    public var isArray: Bool { return type == .array }
    
    public var isDictionary: Bool { return type == .dictionary }
    
    public var isSequence: Bool { return type == .sequence }
}

extension ItemAccess {
    
    public var null: Bool? {
        get { return type == .null ? true : nil }
        set { return }
    }
    
    public var bool: Bool? {
        get {
            guard isBool else { return nil }
            return Bool(itemPtr: basePtr, endianness)
        }
        set {
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

    public var uint8: UInt8? {
        get {
            guard isUInt8 else { return nil }
            return UInt8(itemPtr: basePtr, endianness)
        }
        set {
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
    
    public var uint16: UInt16? {
        get {
            guard isUInt16 else { return nil }
            return UInt16(itemPtr: basePtr, endianness)
        }
        set {
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
    
    public var uint32: UInt32? {
        get {
            guard isUInt32 else { return nil }
            return UInt32(itemPtr: basePtr, endianness)
        }
        set {
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
    
    public var uint64: UInt64? {
        get {
            guard isUInt64 else { return nil }
            return UInt64(itemPtr: basePtr, endianness)
        }
        set {
            if let newValue = newValue {
                if isNull {
                    guard byteCount >= minimumItemByteCount + nameFieldByteCount + 8 else { return }
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
    
    public var int8: Int8? {
        get {
            guard isInt8 else { return nil }
            return Int8(itemPtr: basePtr, endianness)
        }
        set {
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
    
    public var int16: Int16? {
        get {
            guard isInt16 else { return nil }
            return Int16(itemPtr: basePtr, endianness)
        }
        set {
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
    
    public var int32: Int32? {
        get {
            guard isInt32 else { return nil }
            return Int32(itemPtr: basePtr, endianness)
        }
        set {
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
    
    public var int64: Int64? {
        get {
            guard isInt64 else { return nil }
            return Int64(itemPtr: basePtr, endianness)
        }
        set {
            if let newValue = newValue {
                if isNull {
                    guard byteCount >= minimumItemByteCount + nameFieldByteCount + 8 else { return }
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
    
    public var float32: Float32? {
        get {
            guard isFloat32 else { return nil }
            return Float32(itemPtr: basePtr, endianness)
        }
        set {
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
    
    public var float64: Float64? {
        get {
            guard isFloat64 else { return nil }
            return Float64(itemPtr: basePtr, endianness)
        }
        set {
            if let newValue = newValue {
                if isNull {
                    guard byteCount >= minimumItemByteCount + nameFieldByteCount + 8 else { return }
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
    
    public var string: String? {
        get {
            guard isString else { return nil }
            return String(itemPtr: basePtr, endianness)
        }
        set {
            if let newValue = newValue {
                if isNull || isString {
                    guard byteCount >= minimumItemByteCount + nameFieldByteCount + newValue.valueByteCount else { return }
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
    
    public var binary: Data? {
        get {
            guard isBinary else { return nil }
            return Data(itemPtr: basePtr, endianness)
        }
        set {
            if let newValue = newValue {
                if isNull || isBinary {
                    guard byteCount >= minimumItemByteCount + nameFieldByteCount + newValue.valueByteCount else { return }
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
