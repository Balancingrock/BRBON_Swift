//
//  ItemOptions.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 20/01/18.
//
//

import Foundation
import BRUtils


/// The options for an item.

public enum ItemOptions: UInt8 {
    case none = 0
}


// Extend the enum with the brbon protocol

extension ItemOptions: BrbonBytes {
    
    public func brbonCount() -> UInt32 {
        return 1
    }
    
    public func brbonType() -> ItemType {
        return .null
    }
    
    public func brbonBytes(_ endianness: Endianness) -> Data {
        return Data(bytes: [self.rawValue])
    }
    
    public func brbonBytes(toPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        self.rawValue.brbonBytes(toPtr: toPtr, endianness)
    }
    
    public init?(_ fromPtr: UnsafeRawPointer, _ endianness: Endianness) {
        let v = UInt8.init(fromPtr, endianness)
        self.init(rawValue: v)
    }
}
