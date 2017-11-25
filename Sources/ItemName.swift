// =====================================================================================================================
//
//  File:       ItemName.swift
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


/// Represents the name of an item.

public struct ItemName: EndianBytes {
    
    
    /// The actual string used as the name.
    
    public let string: String
    
    
    /// The string in UTF8 encoded data.
    
    public let utf8bytes: Data
    
    
    /// The number of bytes the string needs to represent itself in UTF8 code
    
    public var stringByteCount: UInt8 { return UInt8(utf8bytes.count) }
    
    
    /// The number of bytes the name field will need
    
    public var byteCount: UInt8 { return stringByteCount + 3 }
    
    
    /// The hash of the string. Can be used to speed up comparison of strings.
    
    public let hash: UInt16
    
        
    // Note: Does not filled out to fixed byte count
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        var bytes = hash.endianBytes(endianness)
        bytes.append(stringByteCount.endianBytes(endianness))
        bytes.append(utf8bytes)
        return bytes
    }
    
    
    // Note:  The hash value is ignored and replaced by a calculated hash.
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        
        guard let _ = UInt16(&bytePtr, count: &count, endianness: endianness) else { return nil }
        
        guard let b = UInt8(&bytePtr, count: &count, endianness: endianness) else { return nil }
        guard count >= UInt32(b) else { return nil }
        
        self.utf8bytes = Data.init(bytes: bytePtr, count: Int(b))
        
        guard let s = String.init(data: self.utf8bytes, encoding: .utf8) else { return nil }
        
        self.string = s
        self.hash = self.utf8bytes.crc16()
        
        bytePtr = bytePtr.advanced(by: Int(b))
        count -= UInt32(b)
    }
    
    
    /// Creates a new ItemName from the given name. It will truncate the name to the maximum number of bytes allowable. Which is either 248 or the fixed byte count. A fixed byte count must be a multiple of 8.
    ///
    /// The truncation will always be based on a UTF8 code boundary, hence no invalid UTF8 code will result.
    ///
    /// - Note: Even though a fixed byte count must be a multiple of 8, this is only used for creation. No other operations will use this knowledge, specifically: the endianBytes operation does not fill out the generated data to a multiple of 8 bytes.
    ///
    /// - Parameters:
    ///   - string: The name for this object.
    ///   - fixedByteCount: The maximum number of bytes the name field may occupy. Nil if there is no fixed number of bytes. If a fixed number of bytes is given, it must be a multiple of 8 or the init operation will fail.
    
    public init?(_ string: String, fixedByteCount: UInt8? = nil) {
        
        
        // Prepare

        if let fixedByteCount = fixedByteCount, (fixedByteCount & 0b0000_0111) != 0 { return nil }
        let maxByteCount = (fixedByteCount ?? 248) - 3 // -2 for the hash, -1 for the used byte count
        guard let strdata = string.utf8CodeMaxBytes(Int(maxByteCount)) else { return nil }
        guard let str = String(data: strdata, encoding: .utf8) else { return nil }
        
        
        // Setup
        
        self.string = str
        self.utf8bytes = strdata
        self.hash = self.utf8bytes.crc16()
    }
    
    public static func normalizedByteCount(_ c: UInt8) -> UInt8 {
        if c >= 248 { return 248 }
        if (c & 0b0000_0111) == 0 { return c }
        return (c & 0b1111_1000) + 0b0000_1000
    }
}
