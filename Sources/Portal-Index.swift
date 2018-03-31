//
//  Portal-Subscript.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/01/18.
//
//

import Foundation
import BRUtils


/// Extension that implement indexed lookup and other array/sequence related operations.

public extension Portal {

    
    public subscript(index: Int) -> Portal {
        get {
            
            
            // The portal must be valid
            
            guard isValid else { return fatalOrNull("Portal is no longer valid") }
            
            
            // The index must be positive
            
            guard index >= 0 else { return fatalOrNull("Index (\(index)) is negative") }
            
            
            // Implement for array
            
            if isArray {
            
                
                // Index must be less than the number of elements
                
                guard index < _arrayElementCount else { return fatalOrNull("Index (\(index)) out of high bound (\(_arrayElementCount))") }
                
                return _arrayPortalForElement(at: index)
            }
            
            
            // Implement for sequence
            
            if isSequence {
                

                // Index must be less than the number of items

                guard index < _sequenceItemCount else { return fatalOrNull("Index (\(index)) out of high bound (\(_sequenceItemCount))") }

                return _sequencePortalForItem(at: index)
            }
            
            
            // For other type, return the NULL item
            
            return fatalOrNull("Integer index subscript not supported on \(itemType)")
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
    
    public subscript(index: Int) -> CrcString? {
        get { return self[index].crcString }
        set { self[index].crcString = newValue }
    }

    public subscript(index: Int) -> Data? {
        get { return self[index].binary }
        set { self[index].binary = newValue }
    }
    
    public subscript(index: Int) -> CrcBinary? {
        get { return self[index].crcBinary }
        set { self[index].crcBinary = newValue }
    }

    
    /// Appends one or more new elements to the end of an array.
    ///
    /// If a default value is given, it will be used. If no default value is specified the content bytes will be set to zero.
    ///
    /// - Note: Only for array item portals.
    ///
    /// - Parameters:
    ///   - amount: The number of elements to create, default = 1.
    ///   - value: The default value for the new elements, default = nil.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func createNewElements(amount: Int = 1, value: IsBrbon? = nil) -> Result {
        
        
        // The portal must be valid
        
        guard isValid else { fatalOrNull("Portal is invalid"); return .portalInvalid }
        
        
        // Operation is only allowed on array items
        
        guard isArray else {
            fatalOrNull("_createNewElements not supported for \(itemType)")
            return .operationNotSupported
        }
        
        
        // The number of new elements must be positive
        
        guard amount > 0 else { fatalOrNull("createNewElements must have amount > 0, found \(amount)"); return .illegalAmount }
        
        
        // Coder should be implemented for the default value
        
        if let value = value { assert(value is Coder) }
        
        
        // A default value should fit the element byte count
        
        if let value = value as? Coder {
            let result = _arrayEnsureElementByteCount(for: value)
            guard result == .success else { return result }
        }
        
        
        // Ensure that the item storage capacity is sufficient
        
        let newCount = _arrayElementCount + amount
        let neccesaryValueByteCount = 8 + _arrayElementByteCount * newCount
        let result = ensureValueFieldByteCount(of: neccesaryValueByteCount)
        guard result == .success else { return result }
        
        
        // Initialize the area of the new elements to zero
        
        _ = Darwin.memset(_arrayElementPtr(for: _arrayElementCount), 0, amount * _arrayElementByteCount)
        
        
        // Use the default value if provided
        
        if let value = value as? Coder {
            var loopCount = amount
            repeat {
                value.storeValue(atPtr: _arrayElementPtr(for: _arrayElementCount + loopCount - 1), endianness)
                loopCount -= 1
            } while loopCount > 0
        }
        
        
        // Increment the number of elements
        
        _arrayElementCount += amount
        
        
        return .success
    }
    

    /// Appends a new value to an array or sequence.
    ///
    /// - Note: Only for array and sequence items.
    ///
    /// - Parameters:
    ///   - value: The value to be added.
    ///   - forName: An optional name, only used when the target is a sequence. Ignored for array's.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func append(_ value: IsBrbon, forName name: String? = nil) -> Result {
        
        
        // Portal must be valid
        
        guard isValid else { return .portalInvalid }
        
        
        // The value should implement the Coder protocol
        
        guard let value = value as? Coder else { return .missingCoder }
        
        
        // Implement for array's
        
        if isArray {
            guard _arrayElementType == value.itemType else { return .typeConflict }
            return _arrayAppend(value)
        }
        
        
        // Implement for sequence's
        
        if isSequence {
            return _sequenceAppend(value, name: NameField(name))
        }
        
        
        // Not supported for other item types.
        
        fatalOrNull("Append operation not valid on \(itemType)")
        
        return .operationNotSupported
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
    public func remove(at index: Int) -> Result {
        
        
        // Portal must be valid
        
        guard isValid else { fatalOrNull("Portal is invalid"); return .portalInvalid }
        
        
        // Index should be positive
        
        guard index >= 0 else { fatalOrNull("Index (\(index)) below zero"); return .indexBelowLowerBound }

        
        // Implement for array
        
        if isArray {
            
            
            // Index must be lower than the number of elements
            
            guard index < _arrayElementCount else { fatalOrNull("Index (\(index)) above high bound (\(_arrayElementCount))"); return .indexAboveHigherBound }
            
            return _arrayRemove(at: index)
        }
        
        
        // Implement for sequence
        
        if isSequence {
        
            
            // Index must be lower than the number of items
            
            guard index < _sequenceItemCount else { fatalOrNull("Index (\(index)) above high bound (\(_sequenceItemCount))"); return .indexAboveHigherBound }
            
            return _sequenceRemove(at: index)
        }
        
        
        // Not supported for other types
        
        fatalOrNull("remove(int) not supported on \(itemPtr)")
        
        
        return .operationNotSupported
    }
    
    
    /// Inserts a new element.
    ///
    /// - Note: Only for array and sequence items.
    ///
    /// - Parameters:
    ///   - value: The value to be inserted.
    ///   - atIndex: The index at which to insert the value.
    ///   - withName: A name for the value, only used if the target is a sequence. Ignorded for arrays.
    ///
    /// - Returns: 'success' or an error indicator.

    @discardableResult
    public func insert(_ value: IsBrbon, atIndex index: Int, withName name: String? = nil) -> Result {
        
        
        // The portal must be valid
        
        guard isValid else { fatalOrNull("Portal is invalid"); return .portalInvalid }
        
        
        // The index must be positive
        
        guard index >= 0 else { fatalOrNull("Index (\(index)) below zero"); return .indexBelowLowerBound }

        
        // The new value must implement the Coder protocol
        
        guard let value = value as? Coder else { return .missingCoder }

        
        // Implement for array
        
        if isArray {
        
            
            // Index must be lower than the number of elements

            guard index < _arrayElementCount else { fatalOrNull("Index (\(index)) above high bound (\(_arrayElementCount))"); return .indexAboveHigherBound }
            
            
            // The type of the new element must match the existing element type
            
            guard value.itemType == _arrayElementType else { return .typeConflict }
            
            
            return _arrayInsert(value, atIndex: index)
        }
        
        
        // Implement for sequence
        
        if isSequence {
            

            // Index must be lower than the number of elements

            guard index < _sequenceItemCount else { fatalOrNull("Index (\(index)) above high bound (\(_sequenceItemCount))"); return .indexAboveHigherBound }
            
            
            return _sequenceInsert(value, atIndex: index, withName: name)
        }
        
        
        // Not supported for other types

        fatalOrNull("insert(Coder, int) not supported on \(itemPtr)")
        
        
        return .operationNotSupported
    }
}
