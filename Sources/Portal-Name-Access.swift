// =====================================================================================================================
//
//  File:       Portal-Name-Access.swift
//  Project:    BRBON
//
//  Version:    0.4.2
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
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

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
