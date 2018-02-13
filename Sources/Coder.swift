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

    
    /// The number of bytes needed to encode self into an BrbonBytes stream
    
    var valueByteCount: Int { get }
    
    func itemByteCount(_ nfd: NameFieldDescriptor?) -> Int
    
    var elementByteCount: Int { get }

    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    @discardableResult
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result

    /// Stores the value as an item.
    ///
    /// - Parameters:
    ///   - atPtr: The address of the first byte to be stored.
    ///   - bufferPtr: The startaddress of the buffer of in which the item will be stored.
    ///   - parentPtr: The address of the first byte of the parent item of the to be stored item. Must be equal to bufferPtr for the first item in a buffer.
    ///   - nameField: A name field descriptor if the item has a name.
    ///   - valueByteCount: If present, then the item will have a value field of at least this many bytes.
    ///   - endianness: The endianness for the value and its item structure.
    ///
    /// - Returns: Either .success or an error code.
    
    @discardableResult
    func storeAsItem(
        atPtr: UnsafeMutableRawPointer,
        bufferPtr: UnsafeMutableRawPointer,
        parentPtr: UnsafeMutableRawPointer,
        nameField nfd: NameFieldDescriptor?,
        valueByteCount: Int?,
        _ endianness: Endianness) -> Result
    
    
    /// Stores the value in an array.
    ///
    /// This operation is only usable for non-containers. Containers are always stored as items, even in an array. The container types are: .array, .dictionary, .sequence and .table. All other types are value types.
    ///
    /// - Parameters:
    ///   - atPtr: The address of the first byte where the value will be stored.
    ///   - endianness: The endianness for the value and its item structure.
    ///
    /// - Returns: Either .success or an error code.

    @discardableResult
    func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result
}

internal protocol Initialize {
    
    init(valuePtr: UnsafeMutableRawPointer, count: Int, _ endianness: Endianness)
    
    init(itemPtr: UnsafeMutableRawPointer, _ endianness: Endianness)
    
    init(elementPtr: UnsafeMutableRawPointer, _ endianness: Endianness)
}
