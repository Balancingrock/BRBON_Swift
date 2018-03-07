//
//  NameFieldDescriptor.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 26/01/18.
//
//

import Foundation
import BRUtils


public struct NameFieldDescriptor: Equatable, Hashable {
    
    internal let data: Data
    internal let crc: UInt16
    internal let byteCount: Int
    
    public internal(set) var hashValue: Int
    
    internal init?(_ name: String?, fixedLength: Int? = nil) {
        
        guard let name = name else { return nil }
        
        var length: Int = 0
        
        
        // Create a data object from the name with maximal 245 bytes
        
        guard let (nameData, charRemoved) = name.utf8CodeMaxBytes(245) else { return nil }
        guard !charRemoved else { return nil }
        self.data = nameData
        
        
        // If a fixed length is specified, determine if it can be used
        
        if let fixedLength = fixedLength {
            guard fixedLength <= 245 else { return nil }
            if fixedLength < data.count { return nil }
            length = Int(fixedLength)
        } else {
            length = self.data.count
        }
        
        
        // If there is a field, then add 3 bytes for the hash and length indicator
        
        self.byteCount = (length == 0) ? 0 : (length + 3).roundUpToNearestMultipleOf8()
        
        
        // Create the crc
        
        self.crc = data.crc16()
        
        
        // And the hash
        
        self.hashValue = data.hashValue
    }
    
    internal init(data: Data, crc: UInt16, byteCount: Int) {
        self.data = data
        self.crc = crc
        self.byteCount = byteCount
        self.hashValue = data.hashValue
    }
    
    public static func ==(lhs: NameFieldDescriptor, rhs: NameFieldDescriptor) -> Bool {
        guard lhs.crc == rhs.crc else { return false }
        guard lhs.byteCount == rhs.byteCount else { return false }
        guard lhs.data == rhs.data else { return false }
        return true
    }
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc.storeValue(atPtr: atPtr, endianness)
        UInt8(data.count).storeValue(atPtr: atPtr.advanced(by: 2), endianness)
        let dataPtr = atPtr.advanced(by: 3).assumingMemoryBound(to: UInt8.self)
        data.copyBytes(to: dataPtr, count: data.count)
        let remainder = byteCount - 3 - data.count
        if remainder > 0 {
            let remainderPtr = atPtr.advanced(by: Int(byteCount) - remainder).assumingMemoryBound(to: UInt8.self)
            Data(count: remainder).copyBytes(to: remainderPtr, count: remainder)
        }
    }

    internal static func readValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> NameFieldDescriptor {
        let crc = UInt16(valuePtr: atPtr, endianness)
        let count = Int(UInt8(valuePtr: atPtr.advanced(by: 2), endianness))
        let byteCount = 3 + count
        let data = Data(valuePtr: atPtr.advanced(by: 3), count: count, endianness)
        return NameFieldDescriptor(data: data, crc: crc, byteCount: byteCount)
    }
}
