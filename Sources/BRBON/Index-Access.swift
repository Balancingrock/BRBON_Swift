// =====================================================================================================================
//
//  File:       Index-Access.swift
//  Project:    BRBON
//
//  Version:    1.0.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2019 Marinus van der Lugt, All rights reserved.
//
//  License:    Use or redistribute this code any way you like with the following two provision:
//
//  1) You ACCEPT this source code AS IS without any guarantees that it will work as intended. Any liability from its
//  use is YOURS.
//
//  2) You WILL NOT seek damages from the author or balancingrock.nl.
//
//  I also ask you to please leave this header with the source code.
//
//  Like you, I need to make a living:
//
//   - You can send payment (you choose the amount) via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
// PLEASE let me know about bugs, improvements and feature requests. (rien@balancingrock.nl)
// =====================================================================================================================
//
// History
//
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


/// Extension that implement indexed lookup and other array/sequence related operations.

public extension Portal {

    
    subscript(index: Int) -> Portal {
        get {
            
            
            // The portal must be valid
            
            guard isValid else { return Portal.nullPortal }
            
            
            // The index must be positive
            
            guard index >= 0 else { return Portal.nullPortal }
            
            
            // Implement for array
            
            if isArray {
            
                
                // Index must be less than the number of elements
                
                guard index < _arrayElementCount else { return Portal.nullPortal }
                
                return _arrayPortalForElement(at: index)
            }
            
            
            // Implement for sequence
            
            if isSequence {
                

                // Index must be less than the number of items

                guard index < _sequenceItemCount else { return Portal.nullPortal }

                return _sequencePortalForItem(at: index)
            }
            
            
            // For other type, return the NULL item
            
            return Portal.nullPortal
        }
    }

    subscript(index: Int) -> Bool? {
        get { return self[index].bool }
        set { self[index].bool = newValue }
    }
    
    subscript(index: Int) -> Int8? {
        get { return self[index].int8 }
        set { self[index].int8 = newValue }
    }
    
    subscript(index: Int) -> Int16? {
        get { return self[index].int16 }
        set { self[index].int16 = newValue }
    }
    
    subscript(index: Int) -> Int32? {
        get { return self[index].int32 }
        set { self[index].int32 = newValue }
    }
    
    subscript(index: Int) -> Int64? {
        get { return self[index].int64 }
        set { self[index].int64 = newValue }
    }
    
    subscript(index: Int) -> UInt8? {
        get { return self[index].uint8 }
        set { self[index].uint8 = newValue }
    }
    
    subscript(index: Int) -> UInt16? {
        get { return self[index].uint16 }
        set { self[index].uint16 = newValue }
    }
    
    subscript(index: Int) -> UInt32? {
        get { return self[index].uint32 }
        set { self[index].uint32 = newValue }
    }
    
    subscript(index: Int) -> UInt64? {
        get { return self[index].uint64 }
        set { self[index].uint64 = newValue }
    }
    
    subscript(index: Int) -> Float32? {
        get { return self[index].float32 }
        set { self[index].float32 = newValue }
    }
    
    subscript(index: Int) -> Float64? {
        get { return self[index].float64 }
        set { self[index].float64 = newValue }
    }
    
    subscript(index: Int) -> String? {
        get { return self[index].string }
        set { self[index].string = newValue }
    }
    
    subscript(index: Int) -> BRString? {
        get { return self[index].brString }
        set { self[index].brString = newValue }
    }

    subscript(index: Int) -> BRCrcString? {
        get { return self[index].crcString }
        set { self[index].crcString = newValue }
    }

    subscript(index: Int) -> Data? {
        get { return self[index].binary }
        set { self[index].binary = newValue }
    }

    subscript(index: Int) -> BRCrcBinary? {
        get { return self[index].crcBinary }
        set { self[index].crcBinary = newValue }
    }
    
    subscript(index: Int) -> UUID? {
        get { return self[index].uuid }
        set { self[index].uuid = newValue }
    }

    subscript(index: Int) -> BRFont? {
        get { return self[index].font }
        set { self[index].font = newValue }
    }
    
    subscript(index: Int) -> BRColor? {
        get { return self[index].color }
        set { self[index].color = newValue }
    }
}
