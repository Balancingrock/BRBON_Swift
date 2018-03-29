//
//  Portal-Dictionary.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 26/02/18.
//
//

import Foundation

public extension Portal {
    
    public subscript(name: String) -> Portal {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return Portal.nullPortal }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return Portal.nullPortal }
            return findPortalForItem(withName: name) ?? Portal.nullPortal
        }
    }
    
    public subscript(name: String) -> Bool? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.bool
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> Int8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.int8
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> Int16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.int16
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> Int32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.int32
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> Int64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.int64
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> UInt8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.uint8
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> UInt16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.uint16
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> UInt32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.uint32
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> UInt64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.uint64
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> Float32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.float32
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> Float64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.float64
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> String? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.string
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }
    
    public subscript(name: String) -> Data? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findPortalForItem(withName: name)?.binary
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if isDictionary { _ = _dictionaryUpdateValue(newValue ?? Null(), forName: name) }
            if isSequence { _ = _sequenceUpdateValue(newValue ?? Null(), forName: name) }
            fatalOrNull("Type (\(itemType)) does not support named subscripts")
        }
    }


    /// Updates the value of the item or adds a new item.
    ///
    /// Only valid for dictionary and sequence items.
    ///
    /// - Parameters:
    ///   - value: The new value, may be nil. If nil, the value will be changed to a .null.
    ///   -forName: The name of the item to update. If the portal points to a sequence, only the first item wit this name will be updated.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func updateValue(_ value: IsBrbon?, forName name: String) -> Result {
        
        guard isValid else { fatalOrNull("Portal is no longer valid"); return .portalInvalid }
        
        guard let value = (value ?? Null()) as? Coder else { return .missingCoder }
        
        if isDictionary { return _dictionaryUpdateValue(value, forName: name) }
        
        if isSequence { return _sequenceUpdateValue(value, forName: name) }
            
        fatalOrNull("Type (\(itemType)) does not support named subscripts")
        
        return .operationNotSupported
    }
    
    
    
    /// Removes an item with the given name from the dictionary or all the items with the given name from a sequence.
    ///
    /// Works only on dictionaries and sequences.
    ///
    /// - Parameter forName: The name of the item to remove.
    ///
    /// - Returns: 'success' or an error indicator (including 'itemNotFound').
    
    @discardableResult
    public func removeValue(forName name: String) -> Result {

        guard isValid else { fatalOrNull("Portal is no longer valid"); return .portalInvalid }
        
        if isDictionary { return _dictionaryRemoveValue(forName: name) }
        
        if isSequence { return _sequenceRemoveValue(forName: name) }
        
        fatalOrNull("Type (\(itemType)) does not support named subscripts")
        
        return .operationNotSupported
    }
}
