//
//  String-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/02/18.
//
//

import Foundation
import BRUtils


/// Adds the BrbonCoder protocol

extension String: BrbonCoder {
    
    public typealias T = String
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    public var brbonType: ItemType { return ItemType.string }
    
    
    public var valueByteCount: Int { return (self.data(using: .utf8)?.count ?? 0) }
    
    public func byteCountItem(_ nfd: NameFieldDescriptor? = nil) -> Int { return minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount }
    
    public var elementByteCount: Int { return valueByteCount + 4 }
    
    public func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let data = self.data(using: .utf8) ?? Data()
        data.storeValue(atPtr: atPtr, endianness)
    }
    
    public func storeAsItem(atPtr: UnsafeMutableRawPointer, nameField nfd: NameFieldDescriptor? = nil, parentOffset: Int, valueByteCount: Int? = nil, _ endianness: Endianness) {
        
        guard let data = self.data(using: .utf8) else { return }

        var byteCount: Int = (minimumItemByteCount + (nfd?.byteCount ?? 0) + data.count).roundUpToNearestMultipleOf8()
        
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
        
        UInt32(data.count).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        nfd?.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: Int(nfd?.byteCount ?? 0))
        
        data.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        let remainderByteCount = ptr.distance(to: atPtr.advanced(by: Int(byteCount)))
        if remainderByteCount > 0 {
            Data(count: remainderByteCount).storeValue(atPtr: ptr, endianness)
        }
    }
    
    public func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        guard let data = self.data(using: .utf8) else { return }
        data.storeAsElement(atPtr: atPtr, endianness)
    }
    
    
    public static func readValue(atPtr: UnsafeMutableRawPointer, count: Int? = nil, _ endianness: Endianness) -> T {
        let data = Data.readValue(atPtr: atPtr, count: count, endianness)
        if let str = String.init(data: data, encoding: .utf8) { return str }
        return ""
    }
    
    public static func readFromItem(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> T {
        let byteCount = Int(UInt32.readValue(atPtr: atPtr.advanced(by: itemValueCountOffset), endianness))
        let nameFieldByteCount = Int(UInt8.readValue(atPtr: atPtr.advanced(by: itemNameFieldByteCountOffset), endianness))
        let ptr = atPtr.advanced(by: itemValueCountOffset + nameFieldByteCount)
        return readValue(atPtr: ptr, count: byteCount, endianness)
    }
    
    public static func readFromElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> T {
        let byteCount = Int(UInt32.readValue(atPtr: atPtr, endianness))
        return readValue(atPtr: atPtr, count: byteCount, endianness)
    }
}
