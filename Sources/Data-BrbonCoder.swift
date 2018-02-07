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

extension Data: BrbonCoder {
    
    public typealias T = Data
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    public var brbonType: ItemType { return ItemType.binary }
    
    
    public var valueByteCount: Int { return self.count }
    
    public func itemByteCount(_ nfd: NameFieldDescriptor? = nil) -> Int { return minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount.roundUpToNearestMultipleOf8() }
    
    public var elementByteCount: Int { return valueByteCount + 4 }
    
    public func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.copyBytes(to: atPtr.assumingMemoryBound(to: UInt8.self), count: self.count)
    }
    
    public func storeAsItem(atPtr: UnsafeMutableRawPointer, nameField nfd: NameFieldDescriptor? = nil, parentOffset: Int, valueByteCount: Int? = nil, _ endianness: Endianness) {
        
        var byteCount = itemByteCount(nfd)
        
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
        
        UInt32(self.count).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        nfd?.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: (nfd?.byteCount ?? 0))
        
        self.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: self.count)
        
        let remainderByteCount = ptr.distance(to: atPtr.advanced(by: byteCount))
        if remainderByteCount > 0 {
            Data(count: remainderByteCount).storeValue(atPtr: ptr, endianness)
        }
    }
    
    public func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        UInt32(self.count).storeValue(atPtr: atPtr, endianness)
        storeValue(atPtr: atPtr.advanced(by: 4), endianness)
    }
    
    
    public static func readValue(atPtr: UnsafeMutableRawPointer, count: Int? = nil, _ endianness: Endianness) -> T {
        return Data(bytes: atPtr, count: (count ?? 0))
    }
    
    public static func readFromItem(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> T {
        let bytes = Int(UInt32.readValue(atPtr: atPtr.advanced(by: itemValueCountOffset), endianness))
        let nameFieldByteCount = Int(UInt8.readValue(atPtr: atPtr.advanced(by: itemNameFieldByteCountOffset), endianness))
        let ptr = atPtr.advanced(by: itemNvrFieldOffset + nameFieldByteCount)
        return readValue(atPtr: ptr, count: bytes, endianness)
    }
    
    public static func readFromElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> T {
        let bytes = Int(UInt32.readValue(atPtr: atPtr, endianness))
        return readValue(atPtr: atPtr.advanced(by: 4), count: bytes, endianness)
    }
}
