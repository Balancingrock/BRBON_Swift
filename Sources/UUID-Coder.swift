//
//  UUID-Coder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 31/03/18.
//
//

import Foundation
import BRUtils


/// Adds the Coder protocol

extension UUID: Coder {
    
    var valueByteCount: Int { return 16 }
    
    var elementByteCount: Int { return valueByteCount }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        atPtr.storeBytes(of: self.uuid, as: uuid_t.self)
    }
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let ptr = fromPtr.bindMemory(to: uuid_t.self, capacity: 1)
        self.init(uuid: ptr.pointee)
    }
}
