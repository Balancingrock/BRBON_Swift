//
//  Array-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 09/02/18.
//
//

import Foundation
import BRUtils


internal class BrbonArray: Coder {
    
    init(content: Array<Coder>, type: ItemType, elementByteCount: Int? = nil) {
        
        assert(type != .null)
        
        self.content = content
        
        self.elementType = type
        
        var ebc = max((elementByteCount ?? 0), type.defaultElementByteCount)
        
        if type.isContainer {
            ebc = content.reduce(ebc) { max($0, $1.valueByteCount) }
        }

        self.elementValueByteCount = ebc
    }
    
    let content: Array<Coder>
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    var itemType: ItemType { return ItemType.array }
    
    let elementType: ItemType
    
    let elementValueByteCount: Int
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream.
    
    var valueByteCount: Int { return 12 + content.count * elementValueByteCount }
    
    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        // Element type + zero's
        UInt32(0).storeValue(atPtr: atPtr, endianness)
        elementType.storeValue(atPtr: atPtr)
        
        // Element count
        UInt32(content.count).storeValue(atPtr: atPtr.advanced(by: 4), endianness)
        
        // Element byte count
        UInt32(elementValueByteCount).storeValue(atPtr: atPtr.advanced(by: 8), endianness)
        
        // Elements
        for i in 0 ..< content.count {
            content[i].storeValue(atPtr: atPtr.advanced(by: 12 + i * elementValueByteCount), endianness)
        }
    }
}

