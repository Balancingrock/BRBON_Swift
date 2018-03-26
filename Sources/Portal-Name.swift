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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
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
        
        
        guard let nfd = NameField(name) else { return .illegalNameField }

        if let value = value {
        
            if let item = findPortalForItem(with: nfd.crc, utf8ByteCode: nfd.data) {
            
                // Replace a value
                
                // Ensure enough space is available
            
                let neededItemByteCount = value.itemByteCount(nfd)
                
                if item._itemByteCount < neededItemByteCount {
                    let result = item.increaseItemByteCount(to: neededItemByteCount)
                    guard result == .success else { return result }
                }

                let pOffset = manager.bufferPtr.distance(to: itemPtr)
                value.storeAsItem(atPtr: item.itemPtr, name: nfd, parentOffset: pOffset, endianness)
                
                return .success
            
            } else {
            
                // Add new value
                
                // Ensure enough space is available
                
                let neededItemByteCount = itemMinimumByteCount + _itemNameFieldByteCount + usedValueFieldByteCount + value.itemByteCount(nfd)
                
                if _itemByteCount < neededItemByteCount {
                    let result = increaseItemByteCount(to: neededItemByteCount)
                    guard result == .success else { return result }
                }
                
                let pOffset = manager.bufferPtr.distance(to: itemPtr)
                value.storeAsItem(atPtr: _afterLastItemPtr, name: nfd, parentOffset: pOffset, endianness)

                if isDictionary {
                    _dictionaryItemCount += 1
                } else {
                    _sequenceItemCount += 1
                }
                
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
                
                let neededItemByteCount = itemMinimumByteCount + _itemNameFieldByteCount + usedValueFieldByteCount + null.itemByteCount(nfd)
                
                if _itemByteCount < neededItemByteCount {
                    let result = increaseItemByteCount(to: neededItemByteCount)
                    guard result == .success else { return result }
                }
                
                let pOffset = manager.bufferPtr.distance(to: itemPtr)
                null.storeAsItem(atPtr: _afterLastItemPtr, name: nfd, parentOffset: pOffset, endianness)

                if isDictionary {
                    _dictionaryItemCount += 1
                } else {
                    _sequenceItemCount += 1
                }
                
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
        
        var item = findPortalForItem(withName: name)
        
        if item == nil { return .itemNotFound }
        
        while item != nil {
            
            let aliPtr = _afterLastItemPtr
            
            // Last item does not need a block move
            if aliPtr == item!.itemPtr.advanced(by: item!._itemByteCount) {
                
                // Update the active portals list (remove deleted item)
                manager.removeActivePortal(item!)
                
            } else {
                
                // Move the items after the found item over the found item
                
                let srcPtr = item!.itemPtr.advanced(by: item!._itemByteCount)
                let dstPtr = item!.itemPtr
                let len = srcPtr.distance(to: aliPtr)
                
                manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: item!._itemByteCount, updateMovedPortals: true, updateRemovedPortals: true)
            }
            
            if isDictionary {
                _dictionaryItemCount += 1
            } else {
                _sequenceItemCount += 1
            }
            
            item = findPortalForItem(withName: name)
        }
        
        return .success
    }
}
