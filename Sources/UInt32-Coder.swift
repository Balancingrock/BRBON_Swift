//
//  UInt32-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the BrbonCoder protocol

extension UInt32: Coder {
    
    
    var valueByteCount: Int { return 4 }
    
    func itemByteCount(_ nfd: NameFieldDescriptor? = nil) -> Int { return minimumItemByteCount + (nfd?.byteCount ?? 0) }
    
    var elementByteCount: Int { return valueByteCount }
    
    @discardableResult
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        if endianness == machineEndianness {
            atPtr.storeBytes(of: self, as: UInt32.self)
        } else {
            atPtr.storeBytes(of: self.byteSwapped, as: UInt32.self)
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
        
        var byteCount: Int = itemByteCount(nfd)
        
        if let valueByteCount = valueByteCount {
            let alternateByteCount = (minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount).roundUpToNearestMultipleOf8()
            if alternateByteCount > byteCount { byteCount = alternateByteCount }
        }
        
        var ptr = atPtr
        
        brbonType.storeValue(atPtr: ptr)
        ptr = ptr.advanced(by: 1)
        
        ItemOptions.none.storeValue(atPtr: ptr)
        ptr = ptr.advanced(by: 1)
        
        ItemFlags.none.storeValue(atPtr: ptr)
        ptr = ptr.advanced(by: 1)
        
        UInt8(nfd?.byteCount ?? 0).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 1)
        
        UInt32(byteCount).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        UInt32(bufferPtr.distance(to: parentPtr)).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        self.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        nfd?.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: Int(nfd?.byteCount ?? 0))
        
        let remainderByteCount = ptr.distance(to: atPtr.advanced(by: Int(byteCount)))
        if remainderByteCount > 0 {
            Data(count: remainderByteCount).storeValue(atPtr: ptr, endianness)
        }
        return .success
    }
    
    @discardableResult
    func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        storeValue(atPtr: atPtr, endianness)
        return .success
    }
}

extension UInt32: Initialize {
    
    init(valuePtr: UnsafeMutableRawPointer, count: Int = 0, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.init(valuePtr.assumingMemoryBound(to: UInt32.self).pointee)
        } else {
            self.init(valuePtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped)
        }
    }
    
    init(itemPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let ptr = itemPtr.advanced(by: itemValueCountOffset)
        self.init(valuePtr: ptr, endianness)
    }
    
    init(elementPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.init(valuePtr: elementPtr, endianness)
    }
}
