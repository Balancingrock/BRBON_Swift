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
    
    
    init(array: Array<IsBrbon>? = nil, dict: Dictionary<String, IsBrbon>? = nil) {
        if let content = array {
            self.aContent = (content as! Array<Coder>)
        } else {
            self.aContent = nil
        }
        if let content = dict {
            self.dContent = (content as! Dictionary<String, Coder>)
        } else {
            self.dContent = nil
        }
    }

    
    // The content of this dictionary
    
    let aContent: Array<Coder>?
    let dContent: Dictionary<String, Coder>?
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    var brbonType: ItemType { return ItemType.sequence }
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream
    
    var valueByteCount: Int {
        var count = 0
        if let content = aContent {
            for e in content {
                count += e.itemByteCount(nil)
            }
        }
        if let content = dContent {
            for (key, value) in content {
                guard let nfd = NameFieldDescriptor(key) else { return 0 }
                count += value.itemByteCount(nfd)
            }
        }
        return count
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
        
        
        // Create the sequence structure
        
        ItemType.sequence.storeValue(atPtr: atPtr.brbonItemTypePtr)
        
        ItemOptions.none.storeValue(atPtr: atPtr.brbonItemOptionsPtr)
        
        ItemFlags.none.storeValue(atPtr: atPtr.brbonItemFlagsPtr)
        
        UInt8(nameFieldByteCount).storeValue(atPtr: atPtr.brbonItemNameFieldByteCountPtr, endianness)
        
        UInt32(itemBC).storeValue(atPtr: atPtr.brbonItemByteCountPtr, endianness)
        
        UInt32(bufferPtr.distance(to: parentPtr)).storeValue(atPtr: atPtr.brbonItemParentOffsetPtr, endianness)
        
        UInt32((aContent?.count ?? 0) + (dContent?.count ?? 0)).storeValue(atPtr: atPtr.brbonItemCountValuePtr, endianness)
        
        nfd?.storeValue(atPtr: atPtr.brbonItemNameFieldPtr, endianness)
        
        
        // Add the items
        
        var ptr = atPtr.brbonItemValuePtr
        
        
        // Array items first
        
        if let content = aContent {
            content.forEach({
                $0.storeAsItem(atPtr: ptr, bufferPtr: bufferPtr, parentPtr: atPtr, nameField: nil, valueByteCount: nil, endianness)
                ptr = ptr.advanced(by: $0.itemByteCount(nil))
            })
        }

        
        // Dictionary items second
        
        if let content = dContent {
            for (key, value) in content {
                guard let knfd = NameFieldDescriptor(key) else { return .nameFieldError }
                value.storeAsItem(atPtr: ptr, bufferPtr: bufferPtr, parentPtr: atPtr, nameField: knfd, valueByteCount: nil, endianness)
                ptr = ptr.advanced(by: value.itemByteCount(knfd))
            }
        }
        
        
        // Filler
        
        let remainder = itemBC - atPtr.distance(to: ptr)
        if remainder > 0 {
            Data(count: remainder).storeValue(atPtr: ptr, endianness)
        }
        
        
        // Success
        
        return .success
    }
    
    @discardableResult
    func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        fatalError("Do not use 'storeAsElement', use 'storeAsItem' instead")
    }
}

