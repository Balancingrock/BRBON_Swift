//
//  UInt64-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the Coder protocol

extension UInt64: Coder {
    
    var valueByteCount: Int { return 8 }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            atPtr.storeBytes(of: self, as: UInt64.self)
        } else {
            atPtr.storeBytes(of: self.byteSwapped, as: UInt64.self)
        }
    }
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.init(fromPtr.assumingMemoryBound(to: UInt64.self).pointee)
        } else {
            self.init(fromPtr.assumingMemoryBound(to: UInt64.self).pointee.byteSwapped)
        }
    }
}
