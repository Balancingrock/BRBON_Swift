// =====================================================================================================================
//
//  File:       Index-Access.swift
//  Project:    BRBON
//
//  Version:    1.0.1
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
// 1.0.1 _ Documentation updates
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


/// Extension that implement indexed lookup and other array/sequence related operations.

public extension Portal {

    
    /// Returns a portal for the item at the given index. Returns a null-portal if the item does not exist.
    
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

    
    /// Returns a bool for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> Bool? {
        get { return self[index].bool }
        set { self[index].bool = newValue }
    }

    
    /// Returns a Int8 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> Int8? {
        get { return self[index].int8 }
        set { self[index].int8 = newValue }
    }
    
    
    /// Returns a Int16 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> Int16? {
        get { return self[index].int16 }
        set { self[index].int16 = newValue }
    }
    
    
    /// Returns a Int32 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> Int32? {
        get { return self[index].int32 }
        set { self[index].int32 = newValue }
    }
    
    
    /// Returns a Int64 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> Int64? {
        get { return self[index].int64 }
        set { self[index].int64 = newValue }
    }
    
    
    /// Returns an UInt8 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> UInt8? {
        get { return self[index].uint8 }
        set { self[index].uint8 = newValue }
    }

    
    /// Returns an UInt16 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> UInt16? {
        get { return self[index].uint16 }
        set { self[index].uint16 = newValue }
    }
    
    
    /// Returns an UInt32 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> UInt32? {
        get { return self[index].uint32 }
        set { self[index].uint32 = newValue }
    }
    
    
    /// Returns an UInt64 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> UInt64? {
        get { return self[index].uint64 }
        set { self[index].uint64 = newValue }
    }
    
    
    /// Returns a Float32 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> Float32? {
        get { return self[index].float32 }
        set { self[index].float32 = newValue }
    }

    
    /// Returns a Float64 for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> Float64? {
        get { return self[index].float64 }
        set { self[index].float64 = newValue }
    }

    
    /// Returns a String for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> String? {
        get { return self[index].string }
        set { self[index].string = newValue }
    }

    
    /// Returns a BRString for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> BRString? {
        get { return self[index].brString }
        set { self[index].brString = newValue }
    }

    
    /// Returns a BRCrcString for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> BRCrcString? {
        get { return self[index].crcString }
        set { self[index].crcString = newValue }
    }

    
    /// Returns the Data in the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> Data? {
        get { return self[index].binary }
        set { self[index].binary = newValue }
    }

    
    /// Returns a BRCrcBinary for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> BRCrcBinary? {
        get { return self[index].crcBinary }
        set { self[index].crcBinary = newValue }
    }
    
    
    /// Returns a UUID for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> UUID? {
        get { return self[index].uuid }
        set { self[index].uuid = newValue }
    }

    
    /// Returns a BRFont for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> BRFont? {
        get { return self[index].font }
        set { self[index].font = newValue }
    }
    
    
    /// Returns a BRColor for the item at the given index. Returns a nil if the item does not exist or does not contain the correct type.

    subscript(index: Int) -> BRColor? {
        get { return self[index].color }
        set { self[index].color = newValue }
    }
}
