//
//  Item-Subscript.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/01/18.
//
//

import Foundation
import BRUtils


/// Array subscript operator.
/// Note that array elements cannot change their type to/from null (unlike sequence or dictionary).

extension Item {
    
    private func element(at index: Int) -> Item? {
        guard isArray else { return fatalOrNil("Subscript with Int on non-array") }
        guard index >= 0 && index < Int(childCount) else { return fatalOrNil("Index out of range") }
        let elementOffset = index * Int(UInt32(valuePtr.advanced(by: 4)))
        let elementPtr = valuePtr.advanced(by: 8 + elementOffset)
        return Item.init(ptr: elementPtr, parentPtr: ptr, endianness: endianness)
    }
    
    subscript(index: Int) -> Item? {
        get { return element(at: index) }
    }
    
    subscript(index: Int) -> Bool? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.bool = newValue }
        }
    }
    
    subscript(index: Int) -> UInt8? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.uint8 = newValue }
        }
    }
    
    subscript(index: Int) -> UInt16? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.uint16 = newValue }
        }
    }

    subscript(index: Int) -> UInt32? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.uint32 = newValue }
        }
    }
    
    subscript(index: Int) -> UInt64? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.uint64 = newValue }
        }
    }
    
    subscript(index: Int) -> Int8? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.int8 = newValue }
        }
    }
    
    subscript(index: Int) -> Int16? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.int16 = newValue }
        }
    }
    
    subscript(index: Int) -> Int32? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.int32 = newValue }
        }
    }
    
    subscript(index: Int) -> Int64? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.int64 = newValue }
        }
    }
    
    subscript(index: Int) -> Float32? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.float32 = newValue }
        }
    }
    
    subscript(index: Int) -> Float64? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.float64 = newValue }
        }
    }
    
    subscript(index: Int) -> String? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.string = newValue }
        }
    }
    
    subscript(index: Int) -> Data? {
        get { return nil }
        set {
            guard var item = element(at: index) else { return }
            if let newValue = newValue { item.binary = newValue }
        }
    }
}
