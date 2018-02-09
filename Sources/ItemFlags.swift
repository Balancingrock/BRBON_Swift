//
//  ItemFlags.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 20/01/18.
//
//

import Foundation
import BRUtils


// The flags for an item

public enum ItemFlags: UInt8 {
    case none = 0
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer) {
        self.rawValue.storeValue(atPtr: atPtr, machineEndianness)
    }
    
    internal static func readValue(atPtr: UnsafeMutableRawPointer) -> ItemFlags? {
        let v = UInt8.readValue(atPtr: atPtr, machineEndianness)
        return self.init(rawValue: v)
    }
}