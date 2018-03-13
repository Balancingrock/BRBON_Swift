//
//  IdString.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 02/03/18.
//
//

import Foundation
import BRUtils


extension String {
    var brbonString: BrbonString { return BrbonString(self) }
}


public class BrbonString: Coder, Initialize, Equatable {
    
    public static func ==(lhs: BrbonString, rhs: BrbonString) -> Bool { return lhs.data == rhs.data }
    
    public let string: String
    public let data: Data
    public let crc: UInt16
    
    public var isValid: Bool { return data.crc16() == crc }
    
    
    public init(_ value: String) {
        string = value
        data = value.data(using: .utf8) ?? Data()
        crc = data.crc16()
    }
    
    public init(data: Data) {
        self.string = String(data: data, encoding: .utf8) ?? ""
        self.data = data
        self.crc = data.crc16()
    }
    
    public var brbonType: ItemType { return ItemType.brbonString }
    
    
    internal var valueByteCount: Int { return max(data.count + 6, 8) }
    
    internal func itemByteCount(_ nfd: NameFieldDescriptor? = nil) -> Int {
        return minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount.roundUpToNearestMultipleOf8()
    }
    
    internal var elementByteCount: Int { return valueByteCount.roundUpToNearestMultipleOf8() }
    
    @discardableResult
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        UInt32(data.count).storeValue(atPtr: atPtr, endianness)
        crc.storeValue(atPtr: atPtr.advanced(by: 4), endianness)
        if data.count == 0 {
            UInt16(0).storeValue(atPtr: atPtr.advanced(by: 6), endianness)
        } else if data.count == 1 {
            data.storeValue(atPtr: atPtr.advanced(by: 6), endianness)
            UInt8(0).storeValue(atPtr: atPtr.advanced(by: 7), endianness)
        } else {
            data.storeValue(atPtr: atPtr.advanced(by: 6), endianness)
        }
        return .success
    }
    
    @discardableResult
    internal func storeAsItem(
        atPtr: UnsafeMutableRawPointer,
        bufferPtr: UnsafeMutableRawPointer,
        parentPtr: UnsafeMutableRawPointer,
        nameField nfd: NameFieldDescriptor? = nil,
        valueByteCount: Int? = nil,
        _ endianness: Endianness) -> Result {
        
        var byteCount = itemByteCount(nfd)
        
        let nameFieldByteCount = nfd?.byteCount ?? 0
        
        if let valueByteCount = valueByteCount {
            let alternateByteCount = (minimumItemByteCount + valueByteCount).roundUpToNearestMultipleOf8()
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
        
        return storeValue(atPtr: atPtr.brbonItemValuePtr, endianness)
    }
    
    @discardableResult
    internal func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        return storeValue(atPtr: atPtr, endianness)
    }
    
    required public convenience init(valuePtr: UnsafeMutableRawPointer, count: Int = 0, _ endianness: Endianness) {
        let bytes = Int(UInt32(valuePtr: valuePtr, endianness))
        self.init(data: Data(bytes: valuePtr.advanced(by: 6), count: bytes))
    }
    
    convenience required public init(itemPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.init(valuePtr: itemPtr.brbonItemValuePtr, endianness)
    }
    
    convenience required public init(elementPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.init(valuePtr: elementPtr, endianness)
    }
}
