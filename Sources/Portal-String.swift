//
//  Portal-String.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 23/03/18.
//
//

import Foundation


fileprivate let stringByteCountOffset = 0
fileprivate let stringUtf8CodeOffset = 4


extension Portal {

    
    internal var _stringItemCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: stringByteCountOffset) }
    
    internal var _stringUtf8CodePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: stringUtf8CodeOffset) }

    
    internal var _stringByteCount: Int {
        get { return Int(UInt32(fromPtr: _stringItemCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _stringItemCountPtr, endianness) }
    }
    
    internal var _stringValueFieldUsedByteCount: Int { return stringUtf8CodeOffset + _stringByteCount }
}
