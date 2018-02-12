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
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer) {
        self.rawValue.storeValue(atPtr: atPtr, machineEndianness)
    }
    
    internal static func readValue(atPtr: UnsafeMutableRawPointer) -> ItemOptions? {
        let v = UInt8(valuePtr: atPtr, machineEndianness)
        return self.init(rawValue: v)
    }
}
