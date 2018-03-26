//
//  Binary-Access.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 23/03/18.
//
//

import Foundation
import BRUtils


fileprivate let binaryByteCountOffset = 0
fileprivate let binaryDataOffset = 4


extension Portal {
    
    
    internal var _binaryByteCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: binaryByteCountOffset) }
    
    internal var _binaryDataPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: binaryDataOffset) }
    
    
    internal var _binaryByteCount: Int {
        get { return Int(UInt32(fromPtr: _binaryByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _binaryByteCountPtr, endianness) }
    }
    
    internal var _binaryValueFieldUsedByteCount: Int { return binaryDataOffset + _binaryByteCount }    
}
