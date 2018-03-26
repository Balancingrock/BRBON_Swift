//
//  Portal-Item.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 24/03/18.
//
//

import Foundation
import BRUtils


internal let itemTypeOffset = 0
internal let itemOptionsOffset = 1
internal let itemFlagsOffset = 2
internal let itemNameFieldByteCountOffset = 3
internal let itemByteCountOffset = 4
internal let itemParentOffsetOffset = 8
internal let itemSmallValueOffset = 12

internal let itemValueFieldOffset = 16

internal let itemNameFieldOffset = itemValueFieldOffset
internal let itemNameCrcOffset = itemNameFieldOffset + 0
internal let itemNameUtf8ByteCountOffset = itemNameFieldOffset + 2
internal let itemNameUtf8CodeOffset = itemNameFieldOffset + 3

internal let itemMinimumByteCount = 16


// Item fields access

extension Portal {
    
    internal var itemTypePtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemTypeOffset) }
    
    internal var itemOptionsPtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemOptionsOffset) }
    
    internal var itemFlagsPtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemFlagsOffset) }
    
    internal var itemNameFieldByteCountPtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemNameFieldByteCountOffset) }

    internal var itemByteCountPtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemByteCountOffset) }
    
    internal var itemParentOffsetPtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemParentOffsetOffset) }
    
    internal var itemSmallValuePtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemSmallValueOffset) }
    
    internal var _itemNameFieldPtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemNameFieldOffset) }
    
    internal var _itemNameCrcPtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemNameCrcOffset) }

    internal var _itemNameUtf8ByteCountPtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemNameUtf8ByteCountOffset) }
    
    internal var _itemNameUtf8CodePtr: UnsafeMutableRawPointer { return itemPtr.advanced(by: itemNameUtf8CodeOffset) }
    
    
    /// Returns a pointer to the first byte of the value of the item.
    ///
    /// - Note: Self must point to the first byte of an item.
    
    internal var itemValueFieldPtr: UnsafeMutableRawPointer {
        if itemType!.usesSmallValue {
            return itemSmallValuePtr
        } else {
            if _itemNameFieldByteCount > 0 {
                return itemPtr.advanced(by: itemValueFieldOffset + _itemNameFieldByteCount)
            } else {
                return itemPtr.advanced(by: itemValueFieldOffset)
            }
        }
    }

    
    /// The type of item this portal refers to.
    ///
    /// - Note: The type of the value and the type of the item may differ when the item is a container type.
    
    public internal(set) var itemType: ItemType? {
        get {
            guard isValid else { return nil }
            return ItemType.readValue(atPtr: itemTypePtr)
        }
        set { newValue?.storeValue(atPtr: itemTypePtr) }
    }
    
    
    /// The type of value this portal refers to.
    ///
    /// - Note: The type of the value and the type of the item may differ when the item is a container type.
    
    public var valueType: ItemType? {
        get {
            guard isValid else { return nil }
            if let column = column {
                return _tableGetColumnType(for: column)
            } else if index != nil {
                return _arrayElementType
            } else {
                return itemType
            }
        }
    }
    
    
    /// The options for the item this portal refers to.
    ///
    /// - Note: Assumes the portal is valid, if unsure, use 'options' instead.
    
    internal var _itemsOptions: ItemOptions? {
        get { return ItemOptions.readValue(atPtr: itemOptionsPtr) }
        set { newValue?.storeValue(atPtr: itemOptionsPtr) }
    }
    

    /// The options for the item this portal refers to.

    public var itemOptions: ItemOptions? {
        get { guard isValid else { return nil }; return _itemsOptions }
        set { guard isValid else { return }; _itemsOptions = newValue }
    }
    
    
    /// The flags for the item this portal refers to.
    ///
    /// - Note: Assumes the portal is valid, if unsure, use 'flags' instead.
    
    internal var _itemFlags: ItemFlags? {
        get { return ItemFlags.readValue(atPtr: itemFlagsPtr) }
        set { newValue?.storeValue(atPtr: itemFlagsPtr) }
    }

    
    /// The flags for the item this portal refers to.
    
    public var itemFlags: ItemFlags? {
        get { guard isValid else { return nil }; return _itemFlags }
        set { guard isValid else { return }; _itemFlags = newValue }
    }
    
    
    /// The byte count of the name field in the item this portal refers to.
    
    internal var _itemNameFieldByteCount: Int {
        get { return Int(UInt8(fromPtr: itemNameFieldByteCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: itemNameFieldByteCountPtr, endianness) }
    }
    
    
    /// The byte count of the item this portal refers to.
    
    internal var _itemByteCount: Int {
        get { return Int(UInt32(fromPtr: itemByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemByteCountPtr, endianness) }
    }

    
    /// The parent offset for the item this portal refers to.
    
    internal var _itemParentOffset: Int {
        get { return Int(UInt32(fromPtr: itemParentOffsetPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemParentOffsetPtr, endianness) }
    }
    
    
    /// The crc16 of name of the item this portal refers to.
    
    internal var _itemNameCrc: UInt16 {
        get { return UInt16(fromPtr: _itemNameCrcPtr, endianness) }
        set { newValue.storeValue(atPtr: _itemNameCrcPtr, endianness) }
    }
    
    
    /// The number of used bytes in the data area of the name field of the item this portal refers to.
    
    internal var _itemNameUtf8CodeByteCount: Int {
        get { return Int(UInt8(fromPtr: _itemNameUtf8ByteCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: _itemNameUtf8ByteCountPtr, endianness) }
    }
    
    
    /// A data struc with the bytes of the UTF8 code sequence used in the name field of the item this portal refers to.
    
    internal var _itemNameUtf8Code: Data {
        get { return Data(bytes: _itemNameUtf8CodePtr, count: _itemNameUtf8CodeByteCount) }
        set { newValue.withUnsafeBytes({ _itemNameUtf8CodePtr.copyBytes(from: $0, count: newValue.count)}) }
    }
    
    
    /// A string with the name for the item this portal refers to.
    ///
    /// Nil if the item does not have a name. Empty if the conversion of UTF8 code to a string failed.
    
    public var itemName: String? {
        get {
            guard isValid else { return nil }
            if _itemNameFieldByteCount == 0 { return nil }
            return String(data: _itemNameUtf8Code, encoding: .utf8)
        }
    }
}
