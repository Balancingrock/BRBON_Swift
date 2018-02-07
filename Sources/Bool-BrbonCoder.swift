//
//  Bool-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the BrbonCoder protocol

extension Bool: BrbonCoder {
    
    public typealias T = Bool
    
    
    public var brbonType: ItemType { return ItemType.bool }
    
    public var valueByteCount: Int { return 1 }
    
    public func byteCountItem(_ nfd: NameFieldDescriptor? = nil) -> Int { return minimumItemByteCount + (nfd?.byteCount ?? 0) }
    
    public var elementByteCount: Int { return valueByteCount }
    
    public func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if self {
            atPtr.storeBytes(of: 1, as: UInt8.self)
        } else {
            atPtr.storeBytes(of: 0, as: UInt8.self)
        }
    }
    
    public func storeAsItem(atPtr: UnsafeMutableRawPointer, nameField nfd: NameFieldDescriptor? = nil, parentOffset: Int, valueByteCount: Int? = nil, _ endianness: Endianness) {
        
        var byteCount: Int = byteCountItem(nfd).roundUpToNearestMultipleOf8()
        
        if let valueByteCount = valueByteCount {
            let alternateByteCount = (minimumItemByteCount + Int(nfd?.byteCount ?? 0) + valueByteCount).roundUpToNearestMultipleOf8()
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
        
        UInt32(parentOffset).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        self.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 1)
        
        UInt8(0).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 1)
        
        UInt16(0).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 1)
        
        nfd?.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: Int(nfd?.byteCount ?? 0))
        
        let remainderByteCount = ptr.distance(to: atPtr.advanced(by: byteCount))
        if remainderByteCount > 0 {
            Data(count: remainderByteCount).storeValue(atPtr: ptr, endianness)
        }
    }
    
    public func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        storeValue(atPtr: atPtr, endianness)
    }
        
    public static func readValue(atPtr: UnsafeMutableRawPointer, count: Int? = nil, _ endianness: Endianness) -> T {
        let ptr = atPtr.advanced(by: itemValueCountOffset)
        return 1 == ptr.assumingMemoryBound(to: UInt8.self).pointee
    }
    
    public static func readFromItem(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> T {
        let ptr = atPtr.advanced(by: itemValueCountOffset)
        return readValue(atPtr: ptr, endianness)
    }
    
    public static func readFromElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> T {
        return readValue(atPtr: atPtr, endianness)
    }
}
