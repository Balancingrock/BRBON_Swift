//
//  Int32-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the Coder protocol

extension Int32: Coder {
    
    var valueByteCount: Int { return 4 }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            atPtr.storeBytes(of: self, as: Int32.self)
        } else {
            atPtr.storeBytes(of: self.byteSwapped, as: Int32.self)
        }
    }
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.init(fromPtr.assumingMemoryBound(to: Int32.self).pointee)
        } else {
            self.init(fromPtr.assumingMemoryBound(to: Int32.self).pointee.byteSwapped)
        }
    }
}
