//
//  Data-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the BrbonCoder protocol

extension Data: Coder {
    
    
    var valueByteCount: Int { return self.count }
    
    func itemByteCount(_ nfd: NameFieldDescriptor? = nil) -> Int { return minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount.roundUpToNearestMultipleOf8() }
    
    var elementByteCount: Int { return (valueByteCount + 4).roundUpToNearestMultipleOf8() }
    
    @discardableResult
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        self.copyBytes(to: atPtr.assumingMemoryBound(to: UInt8.self), count: self.count)
        return .success
    }
    
    @discardableResult
    func storeAsItem(
        atPtr: UnsafeMutableRawPointer,
        bufferPtr: UnsafeMutableRawPointer,
        parentPtr: UnsafeMutableRawPointer,
        nameField nfd: NameFieldDescriptor? = nil,
        valueByteCount: Int? = nil,
        _ endianness: Endianness) -> Result {
        
        var byteCount = itemByteCount(nfd)
        
        let nameFieldByteCount = nfd?.byteCount ?? 0

        if let valueByteCount = valueByteCount {
            let alternateByteCount = (minimumItemByteCount + nameFieldByteCount + 4 + valueByteCount).roundUpToNearestMultipleOf8()
            if alternateByteCount > byteCount { byteCount = alternateByteCount }
        }
        
        brbonType.storeValue(atPtr: atPtr.brbonItemTypePtr)
        
        ItemOptions.none.storeValue(atPtr: atPtr.brbonItemOptionsPtr)
        
        ItemFlags.none.storeValue(atPtr: atPtr.brbonItemFlagsPtr)
        
        UInt8(nameFieldByteCount).storeValue(atPtr: atPtr.brbonItemNameFieldByteCountPtr, endianness)
        
        UInt32(byteCount).storeValue(atPtr: atPtr.brbonItemByteCountPtr, endianness)
        
        UInt32(bufferPtr.distance(to: parentPtr)).storeValue(atPtr: atPtr.brbonItemParentOffsetPtr, endianness)
        
        UInt32(self.count).storeValue(atPtr: atPtr.brbonItemCountValuePtr, endianness)
        
        nfd?.storeValue(atPtr: atPtr.brbonItemNameFieldPtr, endianness)
        
        self.storeValue(atPtr: atPtr.brbonItemValuePtr, endianness)
        
        let remainderByteCount = byteCount - minimumItemByteCount - nameFieldByteCount - self.count
        if remainderByteCount > 0 {
            Data(count: remainderByteCount).storeValue(atPtr: atPtr.brbonItemNameFieldPtr.advanced(by: nameFieldByteCount + self.count), endianness)
        }

        return .success
    }
    
    @discardableResult
    func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        UInt32(self.count).storeValue(atPtr: atPtr, endianness)
        storeValue(atPtr: atPtr.advanced(by: 4), endianness)
        let remainder = (self.count + 4).roundUpToNearestMultipleOf8() - (self.count + 4)
        if remainder > 0 {
            Data(count: remainder).storeValue(atPtr: atPtr.advanced(by: self.count + 4), endianness)
        }
        return .success
    }
}

extension Data: Initialize {
    
    init(valuePtr: UnsafeMutableRawPointer, count: Int, _ endianness: Endianness) {
        self.init(Data(bytes: valuePtr, count: count))
    }
    
    init(itemPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let bytes = Int(UInt32(valuePtr: itemPtr.brbonItemCountValuePtr, endianness))
        self.init(valuePtr: itemPtr.brbonItemValuePtr, count: bytes, endianness)
    }
    
    init(elementPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let bytes = Int(UInt32(valuePtr: elementPtr, endianness))
        self.init(valuePtr: elementPtr.advanced(by: 4), count: bytes, endianness)
    }
}
