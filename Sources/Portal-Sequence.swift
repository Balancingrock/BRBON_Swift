//
//  Portal-Sequence.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 24/03/18.
//
//

import Foundation
import BRUtils


fileprivate let sequenceItemCountOffset = 0
fileprivate let sequenceItemBaseOffset = 4


extension Portal {
    
        
    internal var _sequenceItemCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: sequenceItemCountOffset) }
        
    internal var _sequenceItemBasePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: sequenceItemBaseOffset) }
        
        
    /// The number of items in the dictionary this portal refers to.
    
    internal var _sequenceItemCount: Int {
        get { return Int(UInt32(fromPtr: _sequenceItemCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _sequenceItemCountPtr, endianness) }
    }
    
    
    /// The total area used in the value field.
    
    internal var _sequenceValueFieldUsedByteCount: Int {
        var seqItemPtr = _sequenceItemBasePtr
        for _ in 0 ..< _sequenceItemCount {
            seqItemPtr = seqItemPtr.advanced(by: Int(UInt32(fromPtr: seqItemPtr.advanced(by: itemByteCountOffset), endianness)))
        }
        return itemPtr.distance(to: seqItemPtr)
    }
}
