// =====================================================================================================================
//
//  File:       NameField.swift
//  Project:    BRBON
//
//  Version:    1.0.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2019 Marinus van der Lugt, All rights reserved.
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
//  Like you, I need to make a living:
//
//   - You can send payment (you choose the amount) via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
// PLEASE let me know about bugs, improvements and feature requests. (rien@balancingrock.nl)
// =====================================================================================================================
//
// History
//
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


/// The NameField structure contains the name field information for an item name or column name.

public struct NameField: Equatable, Hashable {
    
    public static func ==(lhs: NameField, rhs: NameField) -> Bool {
        if lhs.crc != rhs.crc { return false }
        if lhs.byteCount != rhs.byteCount { return false }
        return lhs.data == rhs.data
    }

    
    /// UTF8 code of the name
    
    internal let data: Data
    
    
    /// The CRC(16) of the name data
    
    internal let crc: UInt16
    
    
    /// The byteCount of the name field (including filler)
    
    internal let byteCount: Int
    
    
    /// Reonstructs the string that was used to create this namefield
    
    public var string: String { return String(data: data, encoding: .utf8)! }
    
    
    /// The hashable protocol
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
    
    
    /// Create a new NameField.
    ///
    /// Creation fails if the parameters are out of range, the name is nil, the name is empty, if the name cannot be converted into UTF8 or if the resulting UTF8 code exceeds either 245 bytes or the fixedByteCount (when present).
    ///
    /// - Parameters:
    ///   - name: The string to be converted to a UTF8 code sequence. Maximum length of the UTF8 byte code 245 bytes.
    ///   - fixedByteCount: When present, the byteCount will be fixed to this number. Range 8 ... 248, only multiples of 8 can be used.

    public init?(_ name: String?, fixedByteCount: Int? = nil) {
        
        
        // Name must be present
        
        guard let name = name, !name.isEmpty else { return nil }
        
        
        // fixedByteCount must be in range 8 ... 248 and only a multiple of 8
        
        if let fixedByteCount = fixedByteCount {
            guard fixedByteCount >= 8, fixedByteCount <= 248, fixedByteCount % 8 == 0 else { return nil }
        }
        
        
        // Create a data object from the name with maximal 245 bytes
        
        guard let (nameData, charRemoved) = name.utf8CodeMaxBytes(245) else { return nil }
        guard !charRemoved else { return nil }

        
        // Limit the byte count to the fixed byte count if given
        
        if let fixedByteCount = fixedByteCount {
            guard nameData.count <= (fixedByteCount - 3) else { return nil }
        }
        
        
        // Initialization
        
        self.data = nameData
        self.crc = nameData.crc16()
        self.byteCount = fixedByteCount ?? (nameData.count + 3).roundUpToNearestMultipleOf8()
    }
    
    internal init(data: Data, crc: UInt16, byteCount: Int) {
        self.data = data
        self.crc = crc
        self.byteCount = byteCount
    }
    
    
    internal func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc.copyBytes(to: ptr, endianness)
        UInt8(data.count).copyBytes(to: ptr.advanced(by: 2), endianness)
        let dataPtr = ptr.advanced(by: 3).assumingMemoryBound(to: UInt8.self)
        data.copyBytes(to: dataPtr, count: data.count)
        let remainder = byteCount - 3 - data.count
        if remainder > 0 {
            let remainderPtr = ptr.advanced(by: Int(byteCount) - remainder).assumingMemoryBound(to: UInt8.self)
            Data(count: remainder).copyBytes(to: remainderPtr, count: remainder)
        }
    }

    internal init(fromPtr: UnsafeMutableRawPointer, withFieldCount: Int, _ endianness: Endianness) {
        var crc: UInt16
        if endianness == machineEndianness {
            crc = fromPtr.assumingMemoryBound(to: UInt16.self).pointee
        } else {
            crc = fromPtr.assumingMemoryBound(to: UInt16.self).pointee.byteSwapped
        }
        let count = fromPtr.advanced(by: 2).assumingMemoryBound(to: UInt8.self).pointee
        let data = Data(bytes: fromPtr.advanced(by: 3), count: Int(count))
        self.init(data: data, crc: crc, byteCount: withFieldCount)
    }
}
