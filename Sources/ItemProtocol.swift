//
//  ItemProtocol.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 20/01/18.
//
//

import Foundation
import BRUtils


/// The maximum value for just about UInt32 values in BRBON.

internal let UInt32Max = UInt32(Int32.max)


/// This protocol allows resizing of a memory area.

protocol ResizeProtocol {
    func resize(byteCount: Int) -> Bool
}


/// This protocol is used to inform the manager of an item that an action must be performed.

protocol ManagerProtocol {
    
}


/// Each BRBON Item has to implement the folowing protocol. Dummys must be provided for those operations that make no sense for specific item type.

protocol ItemProtocol: ResizeProtocol {
    
    
    // MARK: - These members are mapped to real variables
    
    /// The pointer to the memory area where the bytes containing the value are stored. For array elements it points to the element.
    
    var ptr: UnsafeMutableRawPointer { get }
    
    
    /// A pointer to the parent of this item/element
    
    var parentPtr: UnsafeMutableRawPointer? { get }
    
    
    /// The endianness with which to read/write the memory structure and item values.
    
    var endianness: Endianness { get }
    
    
    // MARK: - Accessors to fields in the item.
    
    var type: ItemType? { get set }
    
    var options: ItemOptions? { get set }
    
    var flags: ItemFlags? { get set }
    
    var nameFieldByteCount: UInt8 { get }
    
    var itemByteCount: UInt32 { get set }
    
    var parentOffset: Int32 { get set }
    
    var childCount: UInt32 { get set }
    
    var nameHash: UInt16 { get set }
    
    var nameCount: UInt8 { get set }
    
    var name: String { get set }

    
    // MARK: - Derived values from field values
    
    var parentItem: Item? { get }
    
    var isItem: Bool { get }
    
    var isElement: Bool { get }
    
    var valuePtr: UnsafeMutableRawPointer? { get }
    
    var hasName: Bool { get }

    var unusedValueByteCount: UInt32 { get }
    
    var maximumValueByteCount: UInt32 { get }
    
    
    // MARK: - Value related derviates
    
    var isBool: Bool { get }
    var isUInt8: Bool { get }
    var isUInt16: Bool { get }
    var isUInt32: Bool { get }
    var isUInt64: Bool { get }
    var isInt8: Bool { get }
    var isInt16: Bool { get }
    var isInt32: Bool { get }
    var isInt64: Bool { get }
    var isFloat32: Bool { get }
    var isFloat64: Bool { get }
    var isString: Bool { get }
    var isBinary: Bool { get }
    var isArray: Bool { get }
    var isDictionary: Bool { get }
    var isSequence: Bool { get }

    var bool: Bool? { get set }
    var uint8: UInt8? { get set }
    var uint16: UInt16? { get set }
    var uint32: UInt32? { get set }
    var uint64: UInt64? { get set }
    var int8: Int8? { get set }
    var int16: Int16? { get set }
    var int32: Int32? { get set }
    var int64: Int64? { get set }
    var float32: Float32? { get set }
    var float64: Float64? { get set }
    var string: String? { get set }
    var binary: Data? { get set }
    var array: ItemProtocol? { get set }
    var dictionary: ItemProtocol? { get set }
    var sequence: ItemProtocol? { get set }
    
    subscript(index: Int) -> ItemProtocol? { get }
    
    subscript(index: Int) -> Bool { get set }
    subscript(index: Int) -> UInt8 { get set }
    subscript(index: Int) -> UInt16 { get set }
    subscript(index: Int) -> UInt32 { get set }
    subscript(index: Int) -> UInt64 { get set }
    subscript(index: Int) -> Int8 { get set }
    subscript(index: Int) -> Int16 { get set }
    subscript(index: Int) -> Int32 { get set }
    subscript(index: Int) -> Int64 { get set }
    subscript(index: Int) -> Float32 { get set }
    subscript(index: Int) -> Float64 { get set }
    subscript(index: Int) -> String { get set }
    subscript(index: Int) -> Data { get set }

    subscript(name: String) -> ItemProtocol? { get }
    
    subscript(name: String) -> Bool { get set }
    subscript(name: String) -> UInt8 { get set }
    subscript(name: String) -> UInt16 { get set }
    subscript(name: String) -> UInt32 { get set }
    subscript(name: String) -> UInt64 { get set }
    subscript(name: String) -> Int8 { get set }
    subscript(name: String) -> Int16 { get set }
    subscript(name: String) -> Int32 { get set }
    subscript(name: String) -> Int64 { get set }
    subscript(name: String) -> Float32 { get set }
    subscript(name: String) -> Float64 { get set }
    subscript(name: String) -> String { get set }
    subscript(name: String) -> Data { get set }
}
