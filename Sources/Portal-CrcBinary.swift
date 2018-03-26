//
//  Portal-CrcBinary.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 23/03/18.
//
//

import Foundation


fileprivate let crcBinaryCrcOffset = 0
fileprivate let crcBinaryByteCountOffset = 4
fileprivate let crcBinaryDataOffset = 8


extension Portal {
    
    
    internal var _crcBinaryCrcPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: crcBinaryCrcOffset) }
    
    internal var _crcBinaryByteCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: crcBinaryByteCountOffset) }
    
    internal var _crcBinaryDataPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: crcBinaryDataOffset) }

    
    internal var _crcBinaryByteCount: Int {
        get { return Int(UInt32(fromPtr: _crcBinaryByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _crcBinaryByteCountPtr, endianness) }
    }
    
    internal var _crcBinaryValueFieldUsedByteCount: Int {
        return crcBinaryDataOffset + _crcBinaryByteCount
    }
}
