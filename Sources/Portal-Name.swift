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
            return findItem(forName: name)
        }
    }
    
    public subscript(name: String) -> Bool? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return nil }
            return findItem(forName: name).bool
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
            return findItem(forName: name).int8
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
            return findItem(forName: name).int16
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
            return findItem(forName: name).int32
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
            return findItem(forName: name).int64
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
            return findItem(forName: name).uint8
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
            return findItem(forName: name).uint16
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
            return findItem(forName: name).uint32
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
            return findItem(forName: name).uint64
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
            return findItem(forName: name).float32
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
            return findItem(forName: name).float64
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
            return findItem(forName: name).string
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
            return findItem(forName: name).binary
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return }
            _updateValue(newValue, forName: name)
        }
    }


    @discardableResult
    internal func _updateValue(_ value: Coder?, forName name: String) -> Result {
        
        guard isValid else { fatalOrNull("Portal is no longer valid"); return .portalInvalid }
        guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return .operationNotSupported }
        
        guard let nfd = NameFieldDescriptor(name), nfd.data != nil else { return .illegalNameField }

        if let value = value {
        
            if let item = findItem(with: nfd.crc, utf8ByteCode: nfd.data) {
            
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
                
                let result =  value.storeAsItem(atPtr: afterLastItemPtr, bufferPtr: manager!.bufferPtr, parentPtr: itemPtr, nameField: nfd, valueByteCount: nil, endianness)
                guard result == .success else { return result }

                countValue += 1
                
                return .success
            }
            
        } else {
            
            // Set the item to null, or add a new null item
            
            if let item = findItem(with: nfd.crc, utf8ByteCode: nfd.data) {
                
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
                
                let result = null.storeAsItem(atPtr: afterLastItemPtr, bufferPtr: manager!.bufferPtr, parentPtr: itemPtr, nameField: nfd, valueByteCount: nil, endianness)
                guard result == .success else { return result }

                countValue += 1
                
                return .success
            }
        }
        return .success
    }
    
    @discardableResult
    public func updateValue(_ value: IsBrbon?, forName name: String) -> Result { return _updateValue(value as? Coder, forName: name) }
    
    
    /// Removes an item with the given name from the dictionary or all items wit hthe given name from a sequence.
    ///
    /// - Parameter forName: The name of the item to remove.
    ///
    /// - Returns: success or itemNotFound.
    
    @discardableResult
    public func removeValue(forName name: String) -> Result {

        guard isValid else { fatalOrNull("Portal is no longer valid"); return .portalInvalid }
        guard isDictionary || isSequence else { fatalOrNull("Type (\(itemType)) does not support named subscripts"); return .operationNotSupported }
        
        var item = findItem(forName: name)
        
        if item === Portal.nullPortal { return .itemNotFound }
        
        while !(item === Portal.nullPortal) {
            
            let aliPtr = afterLastItemPtr
            
            // Last item does not need a block move
            if aliPtr == item.itemPtr.advanced(by: item.itemByteCount) {
                
                // Update the active portals list (remove deleted item)
                manager.activePortals.removePortal(for: item.key)
                
            } else {
                
                // Move the items after the found item over the found item
                
                let srcPtr = item.itemPtr.advanced(by: item.itemByteCount)
                let dstPtr = item.itemPtr
                let len = srcPtr.distance(to: aliPtr)
                
                moveBlock(dstPtr, srcPtr, len)
                
                // Update the active portals list
                manager.activePortals.removePortal(for: item.key)
                manager.activePortals.updatePointers(atAndAbove: srcPtr, below: aliPtr, toNewBase: dstPtr)
            }
            
            countValue -= 1
            
            item = findItem(forName: name)
        }
        
        return .success
    }
}
