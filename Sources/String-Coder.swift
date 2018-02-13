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

extension String: Coder {
    
    
    var valueByteCount: Int { return (self.data(using: .utf8)?.count ?? 0) }
    
    func itemByteCount(_ nfd: NameFieldDescriptor? = nil) -> Int { return minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount.roundUpToNearestMultipleOf8() }
    
    var elementByteCount: Int { return valueByteCount + 4 }
    
    @discardableResult
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        let data = self.data(using: .utf8) ?? Data()
        data.storeValue(atPtr: atPtr, endianness)
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
        
        guard let data = self.data(using: .utf8) else { return .cannotConvertStringToUtf8 }

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
        
        UInt32(bufferPtr.distance(to: parentPtr)).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        UInt32(data.count).storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: 4)
        
        nfd?.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: Int(nfd?.byteCount ?? 0))
        
        data.storeValue(atPtr: ptr, endianness)
        ptr = ptr.advanced(by: data.count)
        
        let remainderByteCount = ptr.distance(to: atPtr.advanced(by: Int(byteCount)))
        if remainderByteCount > 0 {
            Data(count: remainderByteCount).storeValue(atPtr: ptr, endianness)
        }
        return .success
    }
    
    @discardableResult
    func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        guard let data = self.data(using: .utf8) else { return .cannotConvertStringToUtf8 }
        data.storeAsElement(atPtr: atPtr, endianness)
        return .success
    }
}

extension String: Initialize {
    
    init(valuePtr: UnsafeMutableRawPointer, count: Int, _ endianness: Endianness) {
        let data = Data(valuePtr: valuePtr, count: count, endianness)
        self.init(data: data, encoding: .utf8)!
    }
    
    init(itemPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let nameFieldByteCount = Int(UInt8(valuePtr: itemPtr.advanced(by: itemNameFieldByteCountOffset), endianness))
        let bytes = Int(UInt32(valuePtr: itemPtr.advanced(by: itemValueCountOffset), endianness))
        let ptr = itemPtr.advanced(by: itemNvrFieldOffset + nameFieldByteCount)
        self.init(valuePtr: ptr, count: bytes, endianness)
    }
    
    init(elementPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let bytes = Int(UInt32(valuePtr: elementPtr.advanced(by: itemValueCountOffset), endianness))
        self.init(valuePtr: elementPtr.advanced(by: 4), count: bytes, endianness)
    }
}
