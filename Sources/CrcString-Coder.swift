//
//  CrcString.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 02/03/18.
//
//

import Foundation
import BRUtils


extension String {
    var crcString: CrcString { return CrcString(self) }
}


public final class CrcString: Coder, Equatable {
    
    public static func ==(lhs: CrcString, rhs: CrcString) -> Bool {
        if lhs.crc != rhs.crc { return false }
        return lhs.data == rhs.data
    }
    
    public let string: String
    public let data: Data
    public let crc: UInt32
    
    public var itemType: ItemType { return ItemType.crcString }
    
    internal var valueByteCount: Int { return max(data.count + 6, 8) }
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc.storeValue(atPtr: atPtr, endianness)
        data.storeValue(atPtr: atPtr.advanced(by: 4), endianness)
    }
    
    public init(_ value: String) {
        string = value
        data = value.data(using: .utf8) ?? Data()
        crc = data.crc32()
    }
    
    public var isValid: Bool { return data.crc32() == crc }

    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc = UInt32(fromPtr: fromPtr, endianness)
        data = Data(fromPtr: fromPtr.advanced(by: 4), endianness)
        string = String(data: data, encoding: .utf8) ?? ""
    }
}
