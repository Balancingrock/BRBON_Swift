//
//  CrcBinary.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 23/03/18.
//
//

import Foundation
import BRUtils


extension Data {
    var crcBinary: CrcBinary { return CrcBinary(data: self) }
}


public final class CrcBinary: Coder, Equatable {
    
    public static func ==(lhs: CrcBinary, rhs: CrcBinary) -> Bool {
        if lhs.crc != rhs.crc { return false }
        return lhs.data == rhs.data
    }
    
    public let data: Data
    public let crc: UInt32
    
    public var itemType: ItemType { return ItemType.crcBinary }
    
    internal var valueByteCount: Int { return 8 + data.count }
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc.storeValue(atPtr: atPtr, endianness)
        data.storeValue(atPtr: atPtr.advanced(by: 4), endianness)
    }
    
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc = UInt32(fromPtr: fromPtr, endianness)
        let byteCount = Int(UInt32(fromPtr: fromPtr.advanced(by: 4), endianness))
        data = Data(bytes: fromPtr, count: byteCount)
    }
    
    public init(data: Data) {
        self.data = data
        self.crc = data.crc32()
    }
    
    public var isValid: Bool { return data.crc32() == crc }
}
