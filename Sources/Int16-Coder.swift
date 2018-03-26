//
//  Int16-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the Coder protocol

extension Int16: Coder {
    
    var valueByteCount: Int { return 2 }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            atPtr.storeBytes(of: self, as: Int16.self)
        } else {
            atPtr.storeBytes(of: self.byteSwapped, as: Int16.self)
        }
    }
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.init(fromPtr.assumingMemoryBound(to: Int16.self).pointee)
        } else {
            self.init(fromPtr.assumingMemoryBound(to: Int16.self).pointee.byteSwapped)
        }
    }
}
