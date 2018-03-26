// =====================================================================================================================
//
//  File:       BrbonCoder.swift
//  Project:    BRBON
//
//  Version:    0.1.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2017 Marinus van der Lugt, All rights reserved.
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
// 0.1.0  - Initial version
// =====================================================================================================================
 
import Foundation
import BRUtils


/// This protocol is used to encode/decode types to/from a byte stream.

internal protocol Coder: IsBrbon {

    
    /// The number of bytes needed to encode the raw value of self into bytes.
    
    var valueByteCount: Int { get }
    
    
    /// The number of bytes needed to encode self into an item.
    
    func itemByteCount(_ nfd: NameField?) -> Int
    
    
    /// Stores the raw bytes of the value.
    ///
    /// - Note: A fatal error will occur for container types and the null type. Container types and the null type must always be stored as items.
    ///
    /// - Parameters:
    ///   - atPtr: The address at which the first byte will be stored.
    ///   - endianness: Specifies the endian ordering of the bytes. Only used when necessary.
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness)
    

    /// Initializes a new type from a byte stream
    ///
    /// - Note: Objects that cannot be created from a byte stream will raise a fatal error
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness)

    
    /// Stores the value as a BRBON item.
    ///
    /// - Parameters:
    ///   - atPtr: The address at which the first byte will be stored.
    ///   - options: The item options field content.
    ///   - flags: The item flags field content.
    ///   - name: An optional name field descriptor if the item has a name.
    ///   - parentOffset: The offset of the parent item this item is located in. The offset of the parent should be given in bytes from the first byte of the buffer the parent is in..
    ///   - initialValueByteCount: If present, then the item will have a value field of at least this many bytes. Note that this value has 'suggestive' value only, if the actual byte count is larger, the larger value will be used. Any value will be rounded up to the nearest mutiple of 8. Range 0 ... Int32.max. Note: If this parameter is set, there will be a value field, even if the small-value field is used to store the data.
    ///   - endianness: Specifies the endian ordering of the bytes. Only used when necessary.
    
    func storeAsItem(
        atPtr: UnsafeMutableRawPointer,
        options: ItemOptions,
        flags: ItemFlags,
        name: NameField?,
        parentOffset: Int,
        initialValueByteCount: Int?,
        _ endianness: Endianness)
}

extension Coder {
    
    func itemByteCount(_ nfd: NameField?) -> Int {
        return itemMinimumByteCount + (nfd?.byteCount ?? 0) + (itemType.usesSmallValue ? 0 : valueByteCount).roundUpToNearestMultipleOf8()
    }
    
    func storeAsItem(
        atPtr: UnsafeMutableRawPointer,
        options: ItemOptions = ItemOptions.none,
        flags: ItemFlags = ItemFlags.none,
        name: NameField? = nil,
        parentOffset: Int,
        initialValueByteCount: Int? = nil,
        _ endianness: Endianness) {
        
        let nameFieldByteCount = name?.byteCount ?? 0

        let itemByteCount: Int
        
        if let initialValueByteCount = initialValueByteCount {
            
            // Using a fixed byte count means not using the value field even if the small-value field would be enough.
            
            if valueByteCount > initialValueByteCount {
                itemByteCount = itemMinimumByteCount + nameFieldByteCount + valueByteCount.roundUpToNearestMultipleOf8()
            } else {
                itemByteCount = itemMinimumByteCount + nameFieldByteCount + initialValueByteCount.roundUpToNearestMultipleOf8()
            }
            
        } else {
            
            // Using the default value means ignoring the value field if possible
            
            itemByteCount = itemMinimumByteCount + nameFieldByteCount + (itemType.usesSmallValue ? 0 : valueByteCount.roundUpToNearestMultipleOf8())
        }
        
        // Type
        itemType.storeValue(atPtr: atPtr.advanced(by: itemTypeOffset))
        
        // Options
        options.storeValue(atPtr: atPtr.advanced(by: itemOptionsOffset))
        
        // Flags
        flags.storeValue(atPtr: atPtr.advanced(by:itemFlagsOffset))
        
        // Name field byte count
        UInt8(nameFieldByteCount).storeValue(atPtr: atPtr.advanced(by: itemNameFieldByteCountOffset), endianness)
        
        // Item byte count
        UInt32(itemByteCount).storeValue(atPtr: atPtr.advanced(by: itemByteCountOffset), endianness)
        
        // Parent offset
        UInt32(parentOffset).storeValue(atPtr: atPtr.advanced(by: itemParentOffsetOffset), endianness)
        
        // Small-value
        UInt32(0).storeValue(atPtr: atPtr.advanced(by: itemSmallValueOffset), endianness)
        
        // Name field (if present)
        name?.storeValue(atPtr: atPtr.advanced(by: itemNameFieldOffset), endianness)
        
        // Value
        if itemType.usesSmallValue {
            storeValue(atPtr: atPtr.advanced(by: itemSmallValueOffset), endianness)
        } else {
            storeValue(atPtr: atPtr.advanced(by: itemValueFieldOffset + nameFieldByteCount), endianness)
        }
    }
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        fatalError("This type cannot be recreated from a byte stream")
    }
}
