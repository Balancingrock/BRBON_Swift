//
//  NameFieldDescriptor.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 26/01/18.
//
//

import Foundation
import BRUtils


internal struct NameFieldDescriptor {
    
    let data: Data?
    let crc: UInt16
    let byteCount: UInt8
    
    init?(_ name: String?, _ fixedLength: UInt8? = nil) {
        
        var length: UInt8 = 0
        
        // Create a data object from the name with maximal 245 bytes
        
        if let name = name {
            guard let (nameData, charRemoved) = name.utf8CodeMaxBytes(245) else { return nil }
            guard !charRemoved else { return nil }
            self.data = nameData
        } else {
            self.data = nil
        }
        
        
        // If a fixed length is specified, determine if it can be used
        
        if let fixedLength = fixedLength {
            guard fixedLength <= 245 else { return nil }
            if Int(fixedLength) < (data?.count ?? 0) { return nil }
            length = fixedLength
        } else {
            let tmp = self.data?.count ?? 0
            length = UInt8(tmp)
        }
        
        
        // If there is a field, then add 3 bytes for the hash and length indicator
        
        self.byteCount = (length == 0) ? 0 : (length + 3).roundUpToNearestMultipleOf8()
        
        
        // Create the crc
        
        self.crc = data?.crc16() ?? 0
    }
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc = UInt16(fromPtr, endianness)
        let count = UInt8(fromPtr.advanced(by: 2), endianness)
        byteCount = 3 + count
        data = Data(bytes: fromPtr.advanced(by: 3), count: Int(count))
    }
    
    func brbonBytes(toPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        guard let data = data else { return }
        crc.brbonBytes(toPtr: toPtr, endianness)
        (byteCount - 3).brbonBytes(toPtr: toPtr.advanced(by: 2), endianness)
        let dataPtr = toPtr.advanced(by: 3).assumingMemoryBound(to: UInt8.self)
        data.copyBytes(to: dataPtr, count: data.count)
        let remainder = Int(byteCount - 3 - UInt8(data.count))
        if remainder > 0 {
            let remainderPtr = toPtr.advanced(by: Int(byteCount) - remainder).assumingMemoryBound(to: UInt8.self)
            Data(count: remainder).copyBytes(to: remainderPtr, count: remainder)
        }
    }
}
