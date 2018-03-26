//
//  Dictionary-Coder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 12/02/18.
//
//

import Foundation
import BRUtils


internal class BrbonDictionary: Coder {

    
    init?(content: Dictionary<String, IsBrbon>? = nil) {
        if let content = content {
            for i in content {
                guard NameField(i.key) != nil else { return nil }
            }
            self.content = content as! Dictionary<String, Coder>
        } else {
            self.content = [:]
        }
    }

    
    // The content of this dictionary
    
    let content: Dictionary<String, Coder>
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    var itemType: ItemType { return ItemType.dictionary }
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream
    
    var valueByteCount: Int {
        return content.reduce(4) { $0 + $1.value.itemByteCount(NameField($1.key)!) }
    }
    
    
    /// The parent offset for the items contained in the dictionary. I.e. the offset of the .dictionary item type itself. This must be set before 'storeValue' is called if the dictionary is not the top level (root) item in the buffer.
    
    var parentOffset: Int = 0
    
    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Note: Before calling, first set the parentOffset!
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        // Count
        UInt32(content.count).storeValue(atPtr: atPtr, endianness)
        
        // The items
        var offset = 4
        for i in content {
            let name = NameField(i.key)!
            i.value.storeAsItem(atPtr: atPtr.advanced(by: offset), name: name, parentOffset: parentOffset, endianness)
            offset += i.value.itemByteCount(name)
        }
    }
}
