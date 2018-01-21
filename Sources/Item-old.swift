// =====================================================================================================================
//
//  File:       BrbonBytes.swift
//  Project:    Item
//
//  Version:    0.3.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2017-2018 Marinus van der Lugt, All rights reserved.
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
// 0.3.0  - Completely recoded
// 0.1.0  - Initial version
// =====================================================================================================================

import Foundation
import BRUtils


// Offsets in the item data structure

internal let itemTypeOffset = 0
internal let itemNameFieldLengthOffset = 3
internal let itemLengthOffset = 4
internal let itemParentOffsetOffset = 8
internal let itemValueCountOffset = 12
internal let itemNvrFieldOffset = 16


// Offsets in the NVR field data structure

internal let itemNameFieldOffset = itemNvrFieldOffset
internal let nameHashOffset = itemNameFieldOffset + 0
internal let nameCountOffset = itemNameFieldOffset + 2
internal let nameDataOffset = itemNameFieldOffset + 3


// The smallest possible item length

internal let minimumItemLength: UInt32 = 16


// The largest possible UInt32 value allowed in BRBON

internal let brbonUInt32Max = UInt32(Int32.max)


// Accessors for the different fields in the item.

internal protocol _Item {

    
    /// Points to the first byte of an item structure
    
    var ptr: UnsafeMutableRawPointer { get }
    
    
    /// The endianness of the data stored in the item
    
    var endianness: Endianness { get }
    
    
    /// The type of the item
    
    var type: ItemType? { get set }
    
    
    /// The length of the name field inside the NVR field. When there is no name, this length is zero.
    
    var nameFieldLength: UInt8 { get set }
    
    
    /// The total length of the item in bytes.
    
    var itemLength: UInt32 { get set }
    
    
    /// The offset of the parent in which this item is contained. Zero is there is no parent.
    
    var parentOffset: UInt32 { get set }
    
    
    /// The UInt32 value of the value/count field.
    
    var valueCount: UInt32 { get set }
    
    
    /// The hash of the name, only if a name field is present
    
    var nameHash: UInt16 { get set }
    
    
    /// The number of bytes in the data area of the name.
    
    var nameCount: UInt8 { get set }
    
    
    /// The utf8 coded bytes of the name.
    
    var nameData: Data { get set }
    
    
    /// The maximum possible length of the value bytes.
    
    var maxValueLength: UInt32 { get }
}


/// Default implementations for the accessors.

internal extension _Item {
    
    var type: ItemType? {
        get {
            return ItemType(ptr.advanced(by: itemTypeOffset))
        }
        set {
            var tptr = ptr.advanced(by: itemTypeOffset)
            newValue?.rawValue.brbonBytes(endianness, toPointer: &tptr)
        }
    }
    
    var nameFieldLength: UInt8 {
        get {
            return UInt8(ptr.advanced(by: itemNameFieldLengthOffset), endianness: endianness)
        }
        set {
            var nptr = ptr.advanced(by: itemNameFieldLengthOffset)
            newValue.brbonBytes(endianness, toPointer: &nptr)
        }
    }
    
    var itemLength: UInt32 {
        get {
            return UInt32(ptr.advanced(by: itemLengthOffset), endianness: endianness)
        }
        set {
            var iptr = ptr.advanced(by: itemLengthOffset)
            newValue.brbonBytes(endianness, toPointer: &iptr)
        }
    }
    
    var parentOffset: UInt32 {
        get {
            return UInt32(ptr.advanced(by: itemParentOffsetOffset), endianness: endianness)
        }
        set {
            var pptr = ptr.advanced(by: itemParentOffsetOffset)
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }
    
    var valueCount: UInt32 {
        get {
            return UInt32(ptr.advanced(by: itemValueCountOffset), endianness: endianness)
        }
        set {
            var pptr = ptr.advanced(by: itemValueCountOffset)
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }
    
    var nameHash: UInt16 {
        get {
            return UInt16(ptr.advanced(by: nameHashOffset), endianness: endianness)
        }
        set {
            var pptr = ptr.advanced(by: nameHashOffset)
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }
    
    var nameCount: UInt8 {
        get {
            return UInt8(ptr.advanced(by: nameCountOffset), endianness: endianness)
        }
        set {
            var pptr = ptr.advanced(by: nameCountOffset)
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }
    
    var nameData: Data {
        get {
            return Data(ptr.advanced(by: nameDataOffset), endianness: endianness, count: UInt32(nameCount))
        }
        set {
            var pptr = ptr.advanced(by: nameDataOffset)
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }
    
    var maxValueLength: UInt32 {
        get {
            return itemLength - minimumItemLength - UInt32(nameFieldLength)
        }
    }
}


// A default item structure.

internal struct UniversalItem: Item {
    let ptr: UnsafeMutableRawPointer
    let endianness: Endianness
}
