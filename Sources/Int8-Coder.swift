//
//  Int8-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the Coder protocol

extension Int8: Coder {
    
    var valueByteCount: Int { return 1 }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        atPtr.storeBytes(of: self, as: Int8.self)
    }
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.init(fromPtr.assumingMemoryBound(to: Int8.self).pointee)
    }
}
