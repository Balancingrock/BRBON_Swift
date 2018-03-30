//
//  Null-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 08/02/18.
//
//

import Foundation
import BRUtils


internal final class Null: Coder {
    
    var itemType: ItemType { return ItemType.null }
    
    var valueByteCount: Int { return 0 }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) { }
}
