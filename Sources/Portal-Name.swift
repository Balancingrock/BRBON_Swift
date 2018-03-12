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
            return _dictionaryPortalForItem(withName: name) ?? Portal.nullPortal
        }
    }
    
    public subscript(name: String) -> Bool? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.bool
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> Int8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.int8
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> Int16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.int16
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> Int32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.int32
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> Int64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.int64
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> UInt8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.uint8
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> UInt16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.uint16
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> UInt32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.uint32
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> UInt64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.uint64
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> Float32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.float32
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> Float64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.float64
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> String? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.string
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }
    
    public subscript(name: String) -> Data? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return _dictionaryPortalForItem(withName: name)?.binary
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
        guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return .operationNotSupported }
        
        if value != nil {
            guard let value = value as? Coder else { return .missingCoder }
            return _updateValue(value, forName: name)
        } else {
            return _updateValue(nil, forName: name)
        }
    }

    @discardableResult
    private func _updateValue(_ value: Coder?, forName name: String) -> Result {
        
        
        guard let nfd = NameFieldDescriptor(name) else { return .illegalNameField }

        if let value = value {
        
            if let item = findPortalForItem(with: nfd.crc, utf8ByteCode: nfd.data) {
            
                // Replace a value
                
                // Ensure enough space is available
            
                let neededItemByteCount = value.itemByteCount(nfd)
                
                if item.itemByteCount < neededItemByteCount {
                    let result = item.increaseItemByteCount(to: neededItemByteCount)
                    guard result == .success else { return result }
                }

                return value.storeAsItem(atPtr: item.itemPtr, bufferPtr: manager!.bufferPtr, parentPtr: itemPtr, nameField: nfd, valueByteCount: nil, endianness)
            
            } else {
            
                // Add new value
                
                // Ensure enough space is available
                
                let neededItemByteCount = minimumItemByteCount + nameFieldByteCount + usedValueByteCount + value.itemByteCount(nfd)
                
                if itemByteCount < neededItemByteCount {
                    let result = increaseItemByteCount(to: neededItemByteCount)
                    guard result == .success else { return result }
                }
                
                let result =  value.storeAsItem(atPtr: _afterLastItemPtr, bufferPtr: manager!.bufferPtr, parentPtr: itemPtr, nameField: nfd, valueByteCount: nil, endianness)
                guard result == .success else { return result }

                countValue += 1
                
                return .success
            }
            
        } else {
            
            // Set the item to null, or add a new null item
            
            if let item = findPortalForItem(with: nfd.crc, utf8ByteCode: nfd.data) {
                
                // Replace a value
                
                // Make the item a null item by chaning its type, the itemByteCount remains unchanged.
                
                item.itemType = .null
                
            } else {
                
                // Add new value
                
                let null = Null()
                
                
                // Ensure enough space is available
                
                let neededItemByteCount = minimumItemByteCount + nameFieldByteCount + usedValueByteCount + null.itemByteCount(nfd)
                
                if itemByteCount < neededItemByteCount {
                    let result = increaseItemByteCount(to: neededItemByteCount)
                    guard result == .success else { return result }
                }
                
                let result = null.storeAsItem(atPtr: _afterLastItemPtr, bufferPtr: manager!.bufferPtr, parentPtr: itemPtr, nameField: nfd, valueByteCount: nil, endianness)
                guard result == .success else { return result }

                countValue += 1
                
                return .success
            }
        }
        return .success
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
        guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return .operationNotSupported }
        
        var item = _dictionaryPortalForItem(withName: name)
        
        if item == nil { return .itemNotFound }
        
        while item != nil {
            
            let aliPtr = _afterLastItemPtr
            
            // Last item does not need a block move
            if aliPtr == item!.itemPtr.advanced(by: item!.itemByteCount) {
                
                // Update the active portals list (remove deleted item)
                manager.removeActivePortal(item!)
                
            } else {
                
                // Move the items after the found item over the found item
                
                let srcPtr = item!.itemPtr.advanced(by: item!.itemByteCount)
                let dstPtr = item!.itemPtr
                let len = srcPtr.distance(to: aliPtr)
                
                manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: item!.itemByteCount, updateMovedPortals: true, updateRemovedPortals: true)
            }
            
            countValue -= 1
            
            item = _dictionaryPortalForItem(withName: name)
        }
        
        return .success
    }
    
    
    /// Returns a portal refering to the first item for a given name.
    ///
    /// - Returns: nil if the name cannot be found.
    
    internal func _dictionaryPortalForItem(withName name: String) -> Portal? {
        
        guard let nameData = name.data(using: .utf8) else { return nil }
        
        let crc = nameData.crc16()
        
        return findPortalForItem(with: crc, utf8ByteCode: nameData)
    }
}
