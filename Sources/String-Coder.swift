//
//  String-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the Coder protocol

extension String: Coder {
    
    var valueByteCount: Int { return 4 + (self.data(using: .utf8)?.count ?? 0) }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let data = self.data(using: .utf8) ?? Data()
        data.storeValue(atPtr: atPtr, endianness)
    }
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let data = Data(fromPtr: fromPtr, endianness)
        self.init(data: data, encoding: .utf8)!
    }
}
