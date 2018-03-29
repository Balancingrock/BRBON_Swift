//
//  Portal-Array.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 24/03/18.
//
//

import Foundation
import BRUtils


internal let arrayReservedOffset = 0
internal let arrayElementTypeOffset = arrayReservedOffset + 4
internal let arrayElementCountOffset = arrayElementTypeOffset + 4
internal let arrayElementByteCountOffset = arrayElementCountOffset + 4
internal let arrayElementBaseOffset = arrayElementByteCountOffset + 4

internal let arrayMinimumItemByteCount = itemMinimumByteCount + arrayElementBaseOffset


extension Portal {
    

    internal var _arrayElementTypePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: arrayElementTypeOffset) }

    internal var _arrayElementCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: arrayElementCountOffset) }
    
    internal var _arrayElementByteCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: arrayElementByteCountOffset) }
    
    internal var _arrayElementBasePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: arrayElementBaseOffset) }
    
    
    /// The type of the element stored in the array this portal refers to.
    
    internal var _arrayElementType: ItemType? {
        get { return ItemType.readValue(atPtr: _arrayElementTypePtr) }
        set { newValue?.storeValue(atPtr: _arrayElementTypePtr) }
    }
    

    /// The number of elements in the array this portal refers to.
    
    internal var _arrayElementCount: Int {
        get { return Int(UInt32(fromPtr: _arrayElementCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _arrayElementCountPtr, endianness) }
    }
    
    
    /// The byte count of the elements in the array this portal refers to.
    
    internal var _arrayElementByteCount: Int {
        get { return Int(UInt32(fromPtr: _arrayElementByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _arrayElementByteCountPtr, endianness) }
    }
    
    
    /// The element pointer for a given index.
    ///
    /// - Note: No range check performed.
    
    internal func _arrayElementPtr(for index: Int) -> UnsafeMutableRawPointer {
        let elementOffset = index * _arrayElementByteCount
        return _arrayElementBasePtr.advanced(by: elementOffset)
    }

    
    /// The total area used in the value field.
    
    internal var _arrayValueFieldUsedByteCount: Int {
        return arrayElementBaseOffset + _arrayElementCount * _arrayElementByteCount
    }
}
