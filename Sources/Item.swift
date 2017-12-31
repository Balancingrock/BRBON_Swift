//
//  Item.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 31/12/17.
//
//

import Foundation
import BRUtils


/// In a DIP the first pointer points to the first byte of the item header and the second pointer to the first byte of the NVR area.

public struct DesignatedItemPointers {
    
    internal let itemPtr: UnsafeMutableRawPointer
    internal let nvrPtr: UnsafeMutableRawPointer
    internal let endianness: Endianness
    
    internal init(_ cip: CurrentItemPointer, endianness: Endianness) {
        self.itemPtr = cip
        self.nvrPtr = cip.advanced(by: nvrOffset)
        self.endianness = endianness
    }
    
    internal init(itemPtr: UnsafeMutableRawPointer, nvrPtr: UnsafeMutableRawPointer, endianness: Endianness) {
        self.itemPtr = itemPtr
        self.nvrPtr = nvrPtr
        self.endianness = endianness
    }
    
    
    internal var valuePtr: UnsafeMutableRawPointer {
        return nvrPtr.advanced(by: Int(nameAreaLength(itemPtr)))
    }

    
    /// Returns the boolean value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The bool value of the designated item or nil if it does not contain a boolean.
    
    var bool: Bool? {
        guard isType(itemPtr, .bool) else { return nil }
        return Bool(valuePtr, endianness: endianness)
    }
    
    
    /// Can be used to determine if the designated item is a null or a nil for a typed value.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: True if the item is a null, False if the item is a nil of another type, nil if the type is not null or nil.
    
    var null: Bool? {
        guard isType(itemPtr, .null) else { return nil }
        guard isType(valuePtr, .null) else { return false }
        return true
    }
    
    
    /// Returns the UInt8 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The UInt8 value of the designated item or nil if it does not contain an UInt8.
    
    var uint8: UInt8? {
        guard isType(itemPtr, .uint8) else { return nil }
        return valuePtr.assumingMemoryBound(to: UInt8.self).pointee
    }
    
    
    /// Returns the Int8 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The Int8 value of the designated item or nil if it does not contain an Int8.
    
    var int8: Int8? {
        guard isType(itemPtr, .int8) else { return nil }
        return valuePtr.assumingMemoryBound(to: Int8.self).pointee
    }
    
    
    /// Returns the UInt16 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The UInt16 value of the designated item or nil if it does not contain an UInt16.
    
    var uint16: UInt16? {
        guard isType(itemPtr, .uint16) else { return nil }
        return UInt16(valuePtr, endianness: endianness)
    }
    
    
    /// Returns the Int16 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The Int16 value of the designated item or nil if it does not contain an Int16.
    
    var int16: Int16? {
        guard isType(itemPtr, .int16) else { return nil }
        return Int16(valuePtr, endianness: endianness)
    }
    
    
    /// Returns the UInt32 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The UInt32 value of the designated item or nil if it does not contain an UInt32.
    
    var uint32: UInt32? {
        guard isType(itemPtr, .uint32) else { return nil }
        return UInt32(valuePtr, endianness: endianness)
    }
    
    
    /// Returns the Int32 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The Int32 value of the designated item or nil if it does not contain an Int32.
    
    var int32: Int32? {
        guard isType(itemPtr, .int32) else { return nil }
        return Int32(valuePtr, endianness: endianness)
    }
    
    
    /// Returns the UInt64 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The UInt64 value of the designated item or nil if it does not contain an UInt64.
    
    var uint64: UInt64? {
        guard isType(itemPtr, .uint64) else { return nil }
        return UInt64(valuePtr, endianness: endianness)
    }
    
    
    /// Returns the Int64 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The Int64 value of the designated item or nil if it does not contain an Int64.
    
    var int64: Int64? {
        guard isType(itemPtr, .int64) else { return nil }
        return Int64(valuePtr, endianness: endianness)
    }
    
    
    /// Returns the Float32 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The Float32 value of the designated item or nil if it does not contain a Float32.
    
    var float32: Float32? {
        guard isType(itemPtr, .float32) else { return nil }
        return Float32(valuePtr, endianness: endianness)
    }
    
    
    /// Returns the Float64 value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The Float64 value of the designated item or nil if it does not contain a Float64.
    
    var float64: Float64? {
        guard isType(itemPtr, .float64) else { return nil }
        return Float64(valuePtr, endianness: endianness)
    }
    
    
    /// Returns the binary value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The binary value of the designated item or nil if it does not contain a binary.
    
    var binary: Data? {
        guard isType(itemPtr, .binary) else { return nil }
        let valueStartPtr = valuePtr
        let length = UInt32(valueStartPtr, endianness: endianness)
        return Data(valueStartPtr.advanced(by: 4), endianness: endianness, count: length)
    }
    
    
    /// Returns the String value of the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The String value of the designated item or nil if it does not contain a String.
    
    var string: String? {
        guard isType(itemPtr, .string) else { return nil }
        let valueStartPtr = valuePtr
        let length = UInt32(valueStartPtr, endianness: endianness)
        return String(valueStartPtr.advanced(by: 4), endianness: endianness, count: length)
    }
}
