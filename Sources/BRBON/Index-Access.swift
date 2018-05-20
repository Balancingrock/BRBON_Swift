// =====================================================================================================================
//
//  File:       Index-Access.swift
//  Project:    BRBON
//
//  Version:    0.5.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2018 Marinus van der Lugt, All rights reserved.
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
//  I strongly believe that voluntarism is the way for societies to function optimally. Thus I have choosen to leave it
//  up to you to determine the price for this code. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  wishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to check the website http://www.balancingrock.nl before payment)
//
//  For private and non-profit use the suggested price is the price of 1 good cup of coffee, say $4.
//  For commercial use the suggested price is the price of 1 good meal, say $20.
//
//  You are however encouraged to pay more ;-)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// History
//
// 0.5.0 - Migration to Swift 4
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


/// Extension that implement indexed lookup and other array/sequence related operations.

public extension Portal {

    
    public subscript(index: Int) -> Portal {
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

    public subscript(index: Int) -> Bool? {
        get { return self[index].bool }
        set { self[index].bool = newValue }
    }
    
    public subscript(index: Int) -> Int8? {
        get { return self[index].int8 }
        set { self[index].int8 = newValue }
    }
    
    public subscript(index: Int) -> Int16? {
        get { return self[index].int16 }
        set { self[index].int16 = newValue }
    }
    
    public subscript(index: Int) -> Int32? {
        get { return self[index].int32 }
        set { self[index].int32 = newValue }
    }
    
    public subscript(index: Int) -> Int64? {
        get { return self[index].int64 }
        set { self[index].int64 = newValue }
    }
    
    public subscript(index: Int) -> UInt8? {
        get { return self[index].uint8 }
        set { self[index].uint8 = newValue }
    }
    
    public subscript(index: Int) -> UInt16? {
        get { return self[index].uint16 }
        set { self[index].uint16 = newValue }
    }
    
    public subscript(index: Int) -> UInt32? {
        get { return self[index].uint32 }
        set { self[index].uint32 = newValue }
    }
    
    public subscript(index: Int) -> UInt64? {
        get { return self[index].uint64 }
        set { self[index].uint64 = newValue }
    }
    
    public subscript(index: Int) -> Float32? {
        get { return self[index].float32 }
        set { self[index].float32 = newValue }
    }
    
    public subscript(index: Int) -> Float64? {
        get { return self[index].float64 }
        set { self[index].float64 = newValue }
    }
    
    public subscript(index: Int) -> String? {
        get { return self[index].string }
        set { self[index].string = newValue }
    }
    
    public subscript(index: Int) -> BRString? {
        get { return self[index].brString }
        set { self[index].brString = newValue }
    }

    public subscript(index: Int) -> BRCrcString? {
        get { return self[index].crcString }
        set { self[index].crcString = newValue }
    }

    public subscript(index: Int) -> Data? {
        get { return self[index].binary }
        set { self[index].binary = newValue }
    }

    public subscript(index: Int) -> BRCrcBinary? {
        get { return self[index].crcBinary }
        set { self[index].crcBinary = newValue }
    }
    
    public subscript(index: Int) -> UUID? {
        get { return self[index].uuid }
        set { self[index].uuid = newValue }
    }

    public subscript(index: Int) -> BRFont? {
        get { return self[index].font }
        set { self[index].font = newValue }
    }
    
    public subscript(index: Int) -> BRColor? {
        get { return self[index].color }
        set { self[index].color = newValue }
    }
    
    /// Removes an item.
    ///
    /// If the index is out of bounds the operation will fail. Notice that the itemByteCount of the array will not decrease.
    ///
    /// - Note: Only for array or sequence items.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.

    @discardableResult
    public func removeItem(at index: Int) -> Result {
        
        
        // Portal must be valid
        
        guard isValid else { return .portalInvalid }
        
        
        // Index should be positive
        
        guard index >= 0 else { return .indexBelowLowerBound }

        
        // Implement for sequence
        
        if isSequence {
        
            
            // Index must be lower than the number of items
            
            guard index < _sequenceItemCount else { return .indexAboveHigherBound }
            
            return _sequenceRemoveItem(atIndex: index)
        }
        
        
        // Not supported for other types
        
        return .operationNotSupported
    }
    
    
    /// Inserts a new element.
    ///
    /// - Note: Only for array and sequence items.
    ///
    /// - Parameters:
    ///   - value: The value to be inserted. Note that adding a nil will be reported as success, but will not change an array nor a sequence.
    ///   - atIndex: The index at which to insert the value.
    ///   - withName: A name for the value, only used if the target is a sequence. Ignorded for arrays.
    ///
    /// - Returns: 'success' or an error indicator.

    @discardableResult
    public func insertItem(_ value: Coder?, atIndex index: Int, withName name: String? = nil) -> Result {
        
        
        // Ignore nil's
        
        guard let value = value else { return .success }

        
        // The portal must be valid
        
        guard isValid else { return .portalInvalid }
        
        
        // The index must be positive
        
        guard index >= 0 else { return .indexBelowLowerBound }

        
        // Implement for array
        /*
        if isArray {
            
            // Names are not allowed for Coders in an array (only for ItemManagers, but then they are 'hidden' inside the item)
            
            guard name == nil else { return .noNameAllowed }
            
            
            // Index must be lower than the number of elements

            guard index < _arrayElementCount else { return .indexAboveHigherBound }
            
            
            // The type of the new element must match the existing element type
            
            guard value.itemType == _arrayElementType else { return .typeConflict }
            
            
            return _arrayInsert(value, atIndex: index)
        }*/
        
        
        // Implement for sequence
        
        if isSequence {
            
            // Index must be lower than the number of elements

            guard index < _sequenceItemCount else { return .indexAboveHigherBound }

            return _sequenceInsertItem(value, atIndex: index, withNameField: NameField(name))
        }
        
        
        // Not supported for other types        
        
        return .operationNotSupported
    }
}
