//
//  UInt16-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the BrbonCoder protocol

extension UInt16: BrbonCoder {
    
    public typealias T = UInt16
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    public var brbonType: ItemType { return ItemType.uint16 }
    
    
    public var valueByteCount: Int { return 2 }
    
    public func byteCountItem(_ nfd: NameFieldDescriptor? = nil) -> Int { return minimumItemByteCount + (nfd?.byteCount ?? 0) }
    
    public var elementByteCount: Int { return valueByteCount }
    
    public func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        if endianness == machineEndianness {
            atPtr.storeBytes(of: self, as: UInt16.self)
        } else {
            atPtr.storeBytes(of: self.byteSwapped, as: UInt16.self)
        }
    }
    
    public func storeAsItem(atPtr: UnsafeMutableRawPointer, nameField nfd: NameFieldDescriptor? = nil, parentOffset: Int, valueByteCount: Int? = nil, _ endianness: Endianness) {
        
        var byteCount: Int = byteCountItem(nfd).roundUpToNearestMultipleOf8()
        
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
        
        UInt32(parentOffset).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        self.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 2)
        
        UInt16(0).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 2)
        
        nfd?.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: Int(nfd?.byteCount ?? 0))
        
        let remainderByteCount = ptr.distance(to: atPtr.advanced(by: Int(byteCount)))
        if remainderByteCount > 0 {
            Data(count: remainderByteCount).storeValue(atPtr: ptr, endianness)
        }
    }
    
    public func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        storeValue(atPtr: atPtr, endianness)
    }
    
    
    public static func readValue(atPtr: UnsafeMutableRawPointer, count: Int? = nil, _ endianness: Endianness) -> T {
        if endianness == machineEndianness {
            return atPtr.assumingMemoryBound(to: UInt16.self).pointee
        } else {
            return atPtr.assumingMemoryBound(to: UInt16.self).pointee.byteSwapped
        }
    }
    
    public static func readFromItem(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> T {
        let ptr = atPtr.advanced(by: itemValueCountOffset)
        return readValue(atPtr: ptr, endianness)
    }
    
    public static func readFromElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> T {
        return readValue(atPtr: atPtr, endianness)
    }
}
