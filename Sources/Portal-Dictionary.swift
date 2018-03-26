//
//  Portal-Dictionary.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 24/03/18.
//
//

import Foundation
import BRUtils


fileprivate let dictionaryItemCountOffset = 0
fileprivate let dictionaryItemBaseOffset = 4


extension Portal {
    
    
    internal var _dictionaryItemCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: dictionaryItemCountOffset) }
    
    internal var _dictionaryItemBasePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: dictionaryItemBaseOffset) }

    
    /// The number of items in the dictionary this portal refers to.
    
    internal var _dictionaryItemCount: Int {
        get { return Int(UInt32(fromPtr: _dictionaryItemCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _dictionaryItemCountPtr, endianness) }
    }
    
    
    /// The total area used in the value field.
    
    internal var _dictionaryValueFieldUsedByteCount: Int {
        var dictItemPtr = _dictionaryItemBasePtr
        for _ in 0 ..< _dictionaryItemCount {
            dictItemPtr = dictItemPtr.advanced(by: Int(UInt32(fromPtr: dictItemPtr.advanced(by: itemByteCountOffset), endianness)))
        }
        return itemPtr.distance(to: dictItemPtr)
    }
}
