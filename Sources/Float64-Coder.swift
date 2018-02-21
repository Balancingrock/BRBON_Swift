//
//  Float64-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the BrbonCoder protocol

extension Float64: Coder {
    
        
    var valueByteCount: Int { return 8 }
    
    func itemByteCount(_ nfd: NameFieldDescriptor? = nil) -> Int { return minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount }
    
    var elementByteCount: Int { return valueByteCount }
    
    @discardableResult
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        if endianness == machineEndianness {
            atPtr.storeBytes(of: self.bitPattern, as: UInt64.self)
        } else {
            atPtr.storeBytes(of: self.bitPattern.byteSwapped, as: UInt64.self)
        }
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
            let alternateByteCount = (minimumItemByteCount + nameFieldByteCount + valueByteCount).roundUpToNearestMultipleOf8()
            if alternateByteCount > byteCount { byteCount = alternateByteCount }
        }
        
        brbonType.storeValue(atPtr: atPtr.brbonItemTypePtr)
        
        ItemOptions.none.storeValue(atPtr: atPtr.brbonItemOptionsPtr)
        
        ItemFlags.none.storeValue(atPtr: atPtr.brbonItemFlagsPtr)
        
        UInt8(nameFieldByteCount).storeValue(atPtr: atPtr.brbonItemNameFieldByteCountPtr, endianness)
        
        UInt32(byteCount).storeValue(atPtr: atPtr.brbonItemByteCountPtr, endianness)
        
        UInt32(bufferPtr.distance(to: parentPtr)).storeValue(atPtr: atPtr.brbonItemParentOffsetPtr, endianness)
        
        UInt32(0).storeValue(atPtr: atPtr.brbonItemCountValuePtr, endianness)
        
        nfd?.storeValue(atPtr: atPtr.brbonItemNameFieldPtr, endianness)

        self.storeValue(atPtr: atPtr.brbonItemValuePtr, endianness)
        
        let remainderByteCount = byteCount - minimumItemByteCount - nameFieldByteCount - 8
        if remainderByteCount > 0 {
            Data(count: remainderByteCount).storeValue(atPtr: atPtr.brbonItemNameFieldPtr.advanced(by: nameFieldByteCount + 8), endianness)
        }

        return .success
    }
    
    @discardableResult
    func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        storeValue(atPtr: atPtr, endianness)
        return .success
    }
}


extension Float64: Initialize {
    
    init(valuePtr: UnsafeMutableRawPointer, count: Int = 0, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.init(bitPattern: valuePtr.assumingMemoryBound(to: UInt64.self).pointee)
        } else {
            self.init(bitPattern: valuePtr.assumingMemoryBound(to: UInt64.self).pointee.byteSwapped)
        }
    }
    
    init(itemPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.init(valuePtr: itemPtr.brbonItemValuePtr, endianness)
    }
    
    init(elementPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.init(valuePtr: elementPtr, endianness)
    }
}
