//
//  ElementAccess.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 14/02/18.
//
//

import Foundation
import  BRUtils


/// This protocol allows access to fields associated with an element. It is defined as class-only since otherwise the setters will not be reachable.

internal protocol ElementAccess: class, ValueAccess {
    
    
    /// The type must provide this base pointer. It must point to the first byte of an element.
    
    var basePtr: UnsafeMutableRawPointer { get }
    
    
    /// The type must provide this parent pointer. It must point to the first byte of the parent item of the element.
    
    var parentPtr: UnsafeMutableRawPointer { get }
    
    
    /// The type must provide this variable. It must contain the endianness of the element and the parent item.
    
    var endianness: Endianness { get }
    
    
    // The following pointer have a default implementation
    
    var typePtr: UnsafeMutableRawPointer { get }
    
    var byteCountPtr: UnsafeMutableRawPointer { get }
    
    
    // The following variables have a default implementation
    
    var type: ItemType? { get }
    
    var byteCount: Int { get }
}

extension ElementAccess {
    
    var typePtr: UnsafeMutableRawPointer {
        return basePtr
    }
    
    var byteCountPtr: UnsafeMutableRawPointer {
        return basePtr.advanced(by: itemByteCountOffset)
    }
}

extension ElementAccess {
    
    var type: ItemType? {
        get {
            let parentNameFieldByteCount = parentPtr.advanced(by: itemNameFieldByteCountOffset).assumingMemoryBound(to: UInt8.self).pointee
            let parentValueFieldPtr = parentPtr.advanced(by: itemNvrFieldOffset + Int(parentNameFieldByteCount))
            return ItemType.readValue(atPtr: parentValueFieldPtr)
        }
    }
    
    var byteCount: Int {
        get {
            let parentNameFieldByteCount = parentPtr.advanced(by: itemNameFieldByteCountOffset).assumingMemoryBound(to: UInt8.self).pointee
            return Int(parentPtr.advanced(by: itemNvrFieldOffset + Int(parentNameFieldByteCount) + 4).assumingMemoryBound(to: UInt32.self).pointee)
        }
    }
}

extension ElementAccess {
    
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

    
    var null: Bool? {
        get { return false }
        set {}
    }
    
    var bool: Bool? {
        get {
            guard isBool else { return nil }
            return Bool(itemPtr: basePtr, endianness)
        }
        set {
            guard isBool else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var uint8: UInt8? {
        get {
            guard isUInt8 else { return nil }
            return UInt8(itemPtr: basePtr, endianness)
        }
        set {
            guard isUInt8 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var uint16: UInt16? {
        get {
            guard isUInt16 else { return nil }
            return UInt16(itemPtr: basePtr, endianness)
        }
        set {
            guard isUInt16 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var uint32: UInt32? {
        get {
            guard isUInt32 else { return nil }
            return UInt32(itemPtr: basePtr, endianness)
        }
        set {
            guard isUInt32 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var uint64: UInt64? {
        get {
            guard isUInt64 else { return nil }
            return UInt64(itemPtr: basePtr, endianness)
        }
        set {
            guard isUInt64 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var int8: Int8? {
        get {
            guard isInt8 else { return nil }
            return Int8(itemPtr: basePtr, endianness)
        }
        set {
            guard isInt8 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var int16: Int16? {
        get {
            guard isInt16 else { return nil }
            return Int16(itemPtr: basePtr, endianness)
        }
        set {
            guard isInt16 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var int32: Int32? {
        get {
            guard isInt32 else { return nil }
            return Int32(itemPtr: basePtr, endianness)
        }
        set {
            guard isInt32 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var int64: Int64? {
        get {
            guard isInt64 else { return nil }
            return Int64(itemPtr: basePtr, endianness)
        }
        set {
            guard isInt64 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var float32: Float32? {
        get {
            guard isFloat32 else { return nil }
            return Float32(itemPtr: basePtr, endianness)
        }
        set {
            guard isFloat32 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var float64: Float64? {
        get {
            guard isFloat64 else { return nil }
            return Float64(itemPtr: basePtr, endianness)
        }
        set {
            guard isFloat64 else { return }
            newValue?.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var string: String? {
        get {
            guard isString else { return nil }
            return String(itemPtr: basePtr, endianness)
        }
        set {
            guard isString else { return }
            guard let newValue = newValue else { return }
            guard byteCount >= newValue.valueByteCount else { return }
            newValue.storeAsElement(atPtr: basePtr, endianness)
        }
    }
    
    var binary: Data? {
        get {
            guard isBinary else { return nil }
            return Data(itemPtr: basePtr, endianness)
        }
        set {
            guard isBinary else { return }
            guard let newValue = newValue else { return }
            guard byteCount >= newValue.valueByteCount else { return }
            newValue.storeAsElement(atPtr: basePtr, endianness)
        }
    }
}
