//
//  CrcString-Access.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 23/03/18.
//
//

import Foundation


fileprivate let crcStringCrcOffset = 0
fileprivate let crcStringByteCountOffset = crcStringCrcOffset + 4
fileprivate let crcStringUtf8CodeOffset = crcStringByteCountOffset + 4


extension Portal {
    

    internal var _crcStringCrcPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: crcStringCrcOffset) }
    
    internal var _crcStringByteCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: crcStringByteCountOffset) }
    
    internal var _crcStringUtf8CodePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: crcStringUtf8CodeOffset) }


    internal var _crcStringByteCount: Int {
        get { return Int(UInt32(fromPtr: _crcStringByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _crcStringByteCountPtr, endianness) }
    }
    
    internal var _crcStringValueFieldUsedByteCount: Int {
        return crcStringUtf8CodeOffset + _crcStringByteCount
    }
}
