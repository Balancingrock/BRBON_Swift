// =====================================================================================================================
//
//  File:       Item.swift
//  Project:    BRBON
//
//  Version:    0.7.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2018 Marinus van der Lugt, All rights reserved.
//
//  License:    Use or redistribute this code any way you like with the following two provision:
//
//  1) You ACCEPT this source code AS IS without any guarantees that it will work as intended. Any liability from its
//  use is YOURS.
//
//  2) You WILL NOT seek damages from the author or balancingrock.nl.
//
//  I also ask you to please leave this header with the source code.
//
//  I strongly believe that voluntarism is the way for societies to function optimally. Thus I have choosen to leave it
//  up to you to determine the price for this code. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  wishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to check the website http://www.balancingrock.nl before payment)
//
//  For private and non-profit use the suggested price is the price of 1 good cup of coffee, say $4.
//  For commercial use the suggested price is the price of 1 good meal, say $20.
//
//  You are however encouraged to pay more ;-)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// History
//
// 0.7.0 - Moved some code around, file renamed.
// 0.5.0 - Migration to Swift 4
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

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

    
    /// The options for the item this portal refers to.
    ///
    /// - Note: Assumes the portal is valid, if unsure, use 'options' instead.
    
    internal var _itemsOptions: ItemOptions? {
        get { return ItemOptions.readValue(atPtr: itemOptionsPtr) }
        set { newValue?.copyBytes(to: itemOptionsPtr) }
    }
    

    /// The flags for the item this portal refers to.
    ///
    /// - Note: Assumes the portal is valid, if unsure, use 'flags' instead.
    
    internal var _itemFlags: ItemFlags? {
        get { return ItemFlags.readValue(atPtr: itemFlagsPtr) }
        set { newValue?.copyBytes(to: itemFlagsPtr) }
    }

    
    /// The small value field accessor
    
    internal var _itemSmallValue: UInt32 {
        get { return UInt32(fromPtr: itemSmallValuePtr, endianness) }
        set { UInt32(newValue).copyBytes(to: itemSmallValuePtr, endianness) }
    }
    
    
    /// The byte count of the name field in the item this portal refers to.
    
    internal var _itemNameFieldByteCount: Int {
        get { return Int(UInt8(fromPtr: itemNameFieldByteCountPtr, endianness)) }
        set { UInt8(newValue).copyBytes(to: itemNameFieldByteCountPtr, endianness) }
    }
    
    
    /// The byte count of the item this portal refers to.
    
    internal var _itemByteCount: Int {
        get { return Int(UInt32(fromPtr: itemByteCountPtr, endianness)) }
        set { UInt32(newValue).copyBytes(to: itemByteCountPtr, endianness) }
    }

    
    /// The parent offset for the item this portal refers to.
    
    internal var _itemParentOffset: Int {
        get { return Int(UInt32(fromPtr: itemParentOffsetPtr, endianness)) }
        set { UInt32(newValue).copyBytes(to: itemParentOffsetPtr, endianness) }
    }
    
    
    /// The crc16 of name of the item this portal refers to.
    
    internal var _itemNameCrc: UInt16 {
        get { return UInt16(fromPtr: _itemNameCrcPtr, endianness) }
        set { newValue.copyBytes(to: _itemNameCrcPtr, endianness) }
    }
    
    
    /// The number of used bytes in the data area of the name field of the item this portal refers to.
    
    internal var _itemNameUtf8CodeByteCount: Int {
        get { return Int(UInt8(fromPtr: _itemNameUtf8ByteCountPtr, endianness)) }
        set { UInt8(newValue).copyBytes(to: _itemNameUtf8ByteCountPtr, endianness) }
    }
    
    
    /// A data struc with the bytes of the UTF8 code sequence used in the name field of the item this portal refers to.
    
    internal var _itemNameUtf8Code: Data {
        get { return Data(bytes: _itemNameUtf8CodePtr, count: _itemNameUtf8CodeByteCount) }
        set { newValue.withUnsafeBytes({ _itemNameUtf8CodePtr.copyMemory(from: $0, byteCount: newValue.count)}) }
    }
    
    
    /// Ensures that the item can accomodate a value of the given length.
    ///
    /// - Parameter for: The number of bytes needed.
    ///
    /// - Returns: True if the item or element has sufficient bytes available.
    /*
    internal func itemEnsureValueFieldByteCount(of bytes: Int) -> Result {
        
        
        // If the current value field byte count is sufficient, return immediately
        
        if availableValueFieldByteCount >= bytes { return .success }
        
        
        // The byte count should be increased
        
        let necessaryItemByteCount = itemMinimumByteCount + _itemNameFieldByteCount + bytes.roundUpToNearestMultipleOf8()
        
        return increaseItemByteCount(to: necessaryItemByteCount)
    }*/
}


public extension Portal {
    
    
    /// The type of item this portal refers to.
    ///
    /// - Note: The type of the value and the type of the item may differ when the item is a container type.
    
    public internal(set) var itemType: ItemType? {
        get {
            guard isValid else { return nil }
            return ItemType.readValue(atPtr: itemTypePtr)
        }
        set { newValue?.copyBytes(to: itemTypePtr) }
    }
    
        
    /// The options for the item this portal refers to.
    
    public var itemOptions: ItemOptions? {
        get { guard isValid else { return nil }; return _itemsOptions }
        set { guard isValid else { return }; _itemsOptions = newValue }
    }
    
    
    /// The flags for the item this portal refers to.
    
    public var itemFlags: ItemFlags? {
        get { guard isValid else { return nil }; return _itemFlags }
        set { guard isValid else { return }; _itemFlags = newValue }
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


/// Build an item structure.
///
/// - Note: The parentOffset, smallValueField and valueField are not be initialised. The itemByteCount is set to the minimum item byte count regardless of type.
///
/// - Parameters:
///   - ofType: The type to put in the itemType field.
///   - withName: The namefield for the item. Optional.
///   - atPtr: The pointer at which to build the item structure.
///   - endianness: The endianness to be used while creating the item.
///
/// - Returns: An ephemeral portal. Do not retain this portal, use it only to complete the rest of the structure.

internal func buildItem(ofType type: ItemType, withName name: NameField? = nil, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Portal {
    
    let portal = Portal.init(itemPtr: ptr, endianness: endianness)
    
    portal.itemType = type
    portal.itemFlags = ItemFlags.none
    portal.itemOptions = ItemOptions.none
    portal._itemNameFieldByteCount = name?.byteCount ?? 0
    portal._itemByteCount = itemMinimumByteCount + (name?.byteCount ?? 0)
    portal._itemParentOffset = 0
    portal._itemSmallValue = 0
    
    name?.copyBytes(to: ptr.advanced(by: itemValueFieldOffset), endianness)
    
    return portal
}


/// Build an item structure and set the initial value.
///
/// - Note: The parentOffset is not initialized. The itemByteCount is set to the smallest value possible.
///
/// - Parameters:
///   - withValue: The value to put in the item.
///   - withName: The namefield for the item. Optional.
///   - atPtr: The pointer at which to build the item structure.
///   - endianness: The endianness to be used while creating the item.
///
/// - Returns: An ephemeral portal. Do not retain this portal, use it only to complete the rest of the structure.

internal func buildItem(withValue value: Coder, withName name: NameField? = nil, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Portal {

    let p = buildItem(ofType: value.itemType, withName: name, atPtr: ptr, endianness)

    if value.itemType.usesSmallValue {
        value.copyBytes(to: p.itemSmallValuePtr, endianness)
    } else {
        value.copyBytes(to: p.itemValueFieldPtr, endianness)
        p._itemByteCount += value.valueByteCount.roundUpToNearestMultipleOf8()
    }
    
    return p
}







