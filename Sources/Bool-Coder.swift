//
//  Bool-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the Coder protocol

extension Bool: Coder {
    
    var valueByteCount: Int { return 1 }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if self {
            atPtr.storeBytes(of: 1, as: UInt8.self)
        } else {
            atPtr.storeBytes(of: 0, as: UInt8.self)
        }
    }
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.init(!(0 == fromPtr.assumingMemoryBound(to: UInt8.self).pointee))
    }
}
