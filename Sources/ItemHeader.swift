//
//  ItemHeader.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 15/11/17.
//
//

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
