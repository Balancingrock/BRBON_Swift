//
//  Data-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the Coder protocol

extension Data: Coder {
    
    var valueByteCount: Int { return 4 + self.count }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        UInt32(self.count).storeValue(atPtr: atPtr, endianness)
        self.copyBytes(to: atPtr.advanced(by: 4).assumingMemoryBound(to: UInt8.self), count: self.count)
    }    
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let byteCount = Int(UInt32(fromPtr: fromPtr, endianness))
        self.init(Data(bytes: fromPtr.advanced(by: 4), count: byteCount))
    }
}
