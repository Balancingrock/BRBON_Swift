//
//  Sequence-Coder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 12/02/18.
//
//

import Foundation
import BRUtils

internal class BrbonSequence: Coder {
    
    
    init?(array: Array<IsBrbon>? = nil, dict: Dictionary<String, IsBrbon>? = nil) {
        if let content = array {
            self.aContent = (content as! Array<Coder>)
        } else {
            self.aContent = []
        }
        if let content = dict {
            for i in content {
                guard NameField(i.key) != nil else { return nil }
            }
            self.dContent = (content as! Dictionary<String, Coder>)
        } else {
            self.dContent = [:]
        }
    }

    
    // The content of this dictionary
    
    let aContent: Array<Coder>
    let dContent: Dictionary<String, Coder>
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    var itemType: ItemType { return ItemType.sequence }
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream
    
    var valueByteCount: Int {
        var count = sequenceItemBaseOffset
        for e in aContent {
            count += e.itemByteCount(nil)
        }
        for (key, value) in dContent {
            count += value.itemByteCount(NameField(key)!)
        }
        return count
    }
    
    
    /// The parent offset, i.e. the offset of self in the buffer. This must be set before calling 'storeValue' if self is not the first item in the buffer.
    
    var parentOffset: Int = 0
    
    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        // Reserved
        UInt32(0).storeValue(atPtr: atPtr.advanced(by: sequenceReservedOffset), endianness)

        // Count
        UInt32(aContent.count + dContent.count).storeValue(atPtr: atPtr.advanced(by: sequenceItemCountOffset), endianness)
        
        // The dictionary items
        var offset = sequenceItemBaseOffset
        
        for i in dContent {
            let name = NameField(i.key)!
            i.value.storeAsItem(atPtr: atPtr.advanced(by: offset), name: name, parentOffset: parentOffset, endianness)
            offset += i.value.itemByteCount(name)
        }

        for e in aContent {
            e.storeAsItem(atPtr: atPtr.advanced(by: offset), parentOffset: parentOffset, endianness)
            offset += e.itemByteCount(nil)
        }
    }
}

