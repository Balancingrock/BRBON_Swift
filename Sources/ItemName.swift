//
//  ItemName.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 17/11/17.
//
//

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
