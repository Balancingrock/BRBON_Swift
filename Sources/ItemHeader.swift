// =====================================================================================================================
//
//  File:       ItemHeader.swift
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


/// The structure for an item header.
///
/// Note that while all members are public readable, updates should only be made through the proper Item operations.

public struct ItemHeader: EndianBytes {
    
    
    /// The type for the Item that contains this header.
    
    public let type: ItemType
    
    
    /// The options for the Item that contains this header.
    
    public internal(set) var options: ItemOptions
    
    
    /// The length of the name field of the Item that contains this header. Note that this field is only valid when the Item is decoded from a byte stream. During use the actual length of a Name field may change irrespective of this value, unless the fixedNameByteCount option is set.
    
    public internal(set) var nameLength: UInt8
    
    
    /// The byte count of the Name field when encoding the Item containing this header. Will be nil if the byte count of the name field is not fixed.
    
    public var fixedNameByteCount: UInt8? { return options.fixedNameByteCount ? nameLength : nil }
    

    // Encoding a header
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var data = type.endianBytes(endianness)
        data.append(options.endianBytes(endianness))
        data.append(UInt8(0))
        data.append(nameLength.endianBytes(endianness))
        return data
    }
    
    
    // Decoding a header
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        
        
        // Read
        
        guard let t = ItemType(&bytePtr, count: &count, endianness: endianness) else { return nil }
        guard let o = ItemOptions(&bytePtr, count: &count, endianness: endianness) else { return nil }
        guard let z = UInt8(&bytePtr, count: &count, endianness: endianness) else { return nil }
        guard let n = UInt8(&bytePtr, count: &count, endianness: endianness) else { return nil }
        
        
        // Verify
        
        guard z == 0 else { return nil }
        
        
        // Create
        
        self.init(t, options: o, nameLength: n)
    }
    
    
    /// Creating a header from scratch
    
    public init(_ type: ItemType, options: ItemOptions = ItemOptions(), nameLength: UInt8 = 0) {
        self.type = type
        self.options = options
        self.nameLength = nameLength
    }
}
