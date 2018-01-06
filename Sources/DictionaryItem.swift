//
//  DictionaryItem.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 05/01/18.
//
//

import Foundation
import BRUtils


internal let itemCountValueOffset = 12
internal let itemNvrFieldOffset = 16


internal struct DictionaryItem {
    

    internal static func createInBuffer(_ name: String? = nil, fixedNameFieldLength: UInt8? = nil, fixedItemLength: UInt32? = nil, endianness: Endianness) -> UnsafeRawBufferPointer? {
    
    
        // Determine the name field info
        
        guard let (nameData, nameHash, nameFieldLength) = nameFieldDescriptor(for: name, fixedLength: fixedNameFieldLength) else { return nil }
        
        
        // Determine size of the value field
        // =================================
        
        var itemLength: UInt32 = 16 + UInt32(nameFieldLength)
        if let fixedItemLength = fixedItemLength {
            guard fixedItemLength <= UInt32(Int32.max) else { return nil }
            if fixedItemLength > itemLength {
                itemLength = fixedItemLength
            } else {
                return nil
            }
            itemLength = itemLength.roundUpToNearestMultipleOf8()
        }
        
        
        // Allocate the buffer area
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: Int(itemLength))
        
        var ptr = buffer.baseAddress!
        
        
        // Create the dictionary item
        
        ItemType.dictionary.rawValue.brbonBytes(endianness, toPointer: &ptr)        // Type
        UInt8(0).brbonBytes(endianness, toPointer: &ptr)                            // Options
        UInt8(0).brbonBytes(endianness, toPointer: &ptr)                            // Flags
        nameFieldLength.brbonBytes(endianness, toPointer: &ptr)                     // Name field length
        
        itemLength.brbonBytes(endianness, toPointer: &ptr)                          // Item length
        
        UInt32(0).brbonBytes(endianness, toPointer: &ptr)                           // Parent offset
        
        UInt32(0).brbonBytes(endianness, toPointer: &ptr)                           // Count
        
        if nameFieldLength > 0 {
            nameHash.brbonBytes(endianness, toPointer: &ptr)                        // Name hash
            UInt8(nameData!.count).brbonBytes(endianness, toPointer: &ptr)          // Name length
            nameData?.brbonBytes(endianness, toPointer: &ptr)                       // Name bytes
        }
        
        Data(count: Int(itemLength - 16)).brbonBytes(endianness, toPointer: &ptr)   // Filler
        
        
        // Exit
        
        return UnsafeRawBufferPointer(buffer)
    }
    
    
    internal let ptr: UnsafeMutableRawPointer
    internal let itemLengthPtr: UnsafeMutableRawPointer
    internal let parentOffsetPtr: UnsafeMutableRawPointer
    internal let countPtr: UnsafeMutableRawPointer
    internal var entryPtr: UnsafeMutableRawPointer
    
    internal let endianness: Endianness
    
    internal init(_ ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.ptr = ptr
        self.endianness = endianness
        self.itemLengthPtr = ptr.advanced(by: 4)
        self.parentOffsetPtr = ptr.advanced(by: 8)
        self.countPtr = ptr.advanced(by: itemCountValueOffset)
        self.entryPtr = ptr.advanced(by: itemNvrFieldOffset)
        fastForwardEntryPtr()
    }
    
    var itemLength: UInt32 {
        get {
            return UInt32(itemLengthPtr, endianness: endianness)
        }
        set {
            var iptr = itemLengthPtr
            newValue.brbonBytes(endianness, toPointer: &iptr)
        }
    }

    var parentOffset: UInt32 {
        get {
            return UInt32(parentOffsetPtr, endianness: endianness)
        }
        set {
            var pptr = parentOffsetPtr
            newValue.brbonBytes(endianness, toPointer: &pptr)
        }
    }
    
    var count: UInt32 {
        get {
            return UInt32(countPtr, endianness: endianness)
        }
        set {
            var cptr = countPtr
            newValue.brbonBytes(endianness, toPointer: &cptr)
        }
    }
        
    func incrementCounter() {
        let c = count
        if c < UInt32(Int32.max) {
            var cptr = countPtr
            (c + 1).brbonBytes(endianness, toPointer: &cptr)
        }
    }
    
    func decrementCounter() {
        let c = count
        if c > 0 {
            var cptr = countPtr
            (c - 1).brbonBytes(endianness, toPointer: &cptr)
        }
    }
    
    internal mutating func fastForwardEntryPtr() {
        var countDown = count
        while countDown > 0 {
            entryPtr = nextItem(entryPtr)
            countDown -= 1
        }
    }
    
    internal func nextItem(_ aptr: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        let length = Int(UInt32(aptr.advanced(by: 4), endianness: endianness))
        return aptr.advanced(by: length)
    }
    
}
