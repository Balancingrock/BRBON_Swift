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
    
    var elementByteCount: Int { return (valueByteCount + 4).roundUpToNearestMultipleOf8() }
    
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
        
        UInt32(data.count).storeValue(atPtr: atPtr.brbonItemCountValuePtr, endianness)
        
        nfd?.storeValue(atPtr: atPtr.brbonItemNameFieldPtr, endianness)
        
        data.storeValue(atPtr: atPtr.brbonItemValuePtr, endianness)
        
        let remainderByteCount = byteCount - minimumItemByteCount - nameFieldByteCount - data.count
        if remainderByteCount > 0 {
            Data(count: remainderByteCount).storeValue(atPtr: atPtr.brbonItemNameFieldPtr.advanced(by: nameFieldByteCount + data.count), endianness)
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
        let bytes = Int(UInt32(valuePtr: itemPtr.brbonItemCountValuePtr, endianness))
        self.init(valuePtr: itemPtr.brbonItemValuePtr, count: bytes, endianness)
    }
    
    init(elementPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let bytes = Int(UInt32(valuePtr: elementPtr, endianness))
        self.init(valuePtr: elementPtr.advanced(by: 4), count: bytes, endianness)
    }
}
