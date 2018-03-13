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

    
    init(content: Dictionary<String, IsBrbon>? = nil) {
        if let content = content {
            self.content = content as! Dictionary<String, Coder>
        } else {
            self.content = [:]
        }
    }

    
    // The content of this dictionary
    
    let content: Dictionary<String, Coder>
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    var brbonType: ItemType { return ItemType.dictionary }
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream
    
    var valueByteCount: Int {
        if content.count == 0 { return 0 }
        var bc = 0
        for (key, value) in content {
            guard let nfd = NameFieldDescriptor(key) else { return 0 }
            bc += value.itemByteCount(nfd)
        }
        return bc
    }
    
    func itemByteCount(_ nfd: NameFieldDescriptor? = nil) -> Int {
        return minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount
    }
    
    var elementByteCount: Int {
        return minimumItemByteCount + valueByteCount
    }
    
    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    @discardableResult
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        fatalError("Do not use 'storeValue', use 'storeAsItem' instead.")
    }
    
    
    /// Create a dictionary item of the contents of this dictionary.
    ///
    /// - Note: All keys must be of the type String.
    
    @discardableResult
    func storeAsItem(
        atPtr: UnsafeMutableRawPointer,
        bufferPtr: UnsafeMutableRawPointer,
        parentPtr: UnsafeMutableRawPointer,
        nameField nfd: NameFieldDescriptor? = nil,
        valueByteCount: Int? = nil,
        _ endianness: Endianness) -> Result {

        
        // Determine size of the value field
        // =================================

        let nameFieldByteCount = nfd?.byteCount ?? 0

        let usedValueByteCount: Int

        if let valueByteCount = valueByteCount {
            
            
            // Range limit
            
            guard valueByteCount <= Int(Int32.max) else { return .valueByteCountTooLarge }
            
            
            // If specified, the fixed item length must be large enough (add the 8 overhead bytes as that is unknown to the API user)
            
            guard valueByteCount >= self.valueByteCount else { return .valueByteCountTooSmall }
            
            
            // Use the fixed value byte count, but ensure that it is a multiple of 8 bytes.
            
            usedValueByteCount = valueByteCount.roundUpToNearestMultipleOf8()
        
        } else {
            
            usedValueByteCount = self.valueByteCount
        }

        let itemBC = (minimumItemByteCount + nameFieldByteCount + usedValueByteCount).roundUpToNearestMultipleOf8()

        
        // Create the dictionary structure
        
        var p = atPtr
        
        ItemType.dictionary.storeValue(atPtr: p)
        p = p.advanced(by: 1)
        
        ItemOptions.none.storeValue(atPtr: p)
        p = p.advanced(by: 1)
        
        ItemFlags.none.storeValue(atPtr: p)
        p = p.advanced(by: 1)
        
        UInt8(nameFieldByteCount).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 1)
        
        UInt32(itemBC).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 4)
        
        UInt32(bufferPtr.distance(to: parentPtr)).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 4)
        
        UInt32(content.count).storeValue(atPtr: p, endianness)
        p = p.advanced(by: 4)
        
        nfd?.storeValue(atPtr: p, endianness)
        p = p.advanced(by: nameFieldByteCount)
        
        
        // Items
        
        for (key, value) in content {
            guard let knfd = NameFieldDescriptor(key) else { return .nameFieldError }
            value.storeAsItem(atPtr: p, bufferPtr: bufferPtr, parentPtr: atPtr, nameField: knfd, valueByteCount: nil, endianness)
            p = p.advanced(by: Int(UInt32(valuePtr: p.advanced(by: itemByteCountOffset), endianness)))
        }
        
        
        // Filler
        
        let remainder = itemBC - atPtr.distance(to: p)
        if remainder > 0 {
            Data(count: remainder).storeValue(atPtr: p, endianness)
        }
        
        
        // Success
        
        return .success
    }
    
    @discardableResult
    func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        fatalError("Do not use 'storeAsElement', use 'storeAsItem' instead")
    }
}
