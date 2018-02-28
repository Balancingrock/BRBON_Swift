//
//  Portal-Dictionary.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 26/02/18.
//
//

import Foundation

public extension Portal {
    
    public subscript(key: String) -> Portal {
        get {
            guard isValid, (isDictionary || isSequence) else { return Portal.nullPortal }
            return findItem(for: key)
        }
    }
    
    public subscript(key: String) -> Bool? { get { return getHelper(key).bool } set { setHelper(key, newValue) } }
    public subscript(key: String) -> Int8? { get { return getHelper(key).int8 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> Int16? { get { return getHelper(key).int16 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> Int32? { get { return getHelper(key).int32 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> Int64? { get { return getHelper(key).int64 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> UInt8? { get { return getHelper(key).uint8 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> UInt16? { get { return getHelper(key).uint16 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> UInt32? { get { return getHelper(key).uint32 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> UInt64? { get { return getHelper(key).uint64 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> Float32? { get { return getHelper(key).float32 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> Float64? { get { return getHelper(key).float64 } set { setHelper(key, newValue) } }
    public subscript(key: String) -> String? { get { return getHelper(key).string } set { setHelper(key, newValue) } }
    public subscript(key: String) -> Data? { get { return getHelper(key).binary } set { setHelper(key, newValue) } }

    private func getHelper(_ key: String) -> Portal {
        if isDictionary {
            return findItem(for: key)
        } else if isSequence {
            return fatalOrNull("Sequence not implemented yet")
        } else {
            return fatalOrNull("Portal type does not support String subscript access")
        }
    }

    private func setHelper(_ key: String, _ newValue: Coder?) {
        if isDictionary {
            let item = findItem(for: key)
            if item === Portal.nullPortal {
                _updateValue(newValue, forName: key)
            } else {
                newValue?.storeValue(atPtr: item.itemPtr.brbonItemValuePtr, endianness)
            }
        } else if isSequence {
            fatalError("Sequence not implemented yet")
        } else {
            fatalOrNull("Portal type does not support String subscript access")
        }
    }

    @discardableResult
    internal func _updateValue(_ value: Coder?, forName name: String) -> Result {
        
        guard isDictionary else { return .onlySupportedOnDictionary }
        
        guard let nfd = NameFieldDescriptor(name), nfd.data != nil else { return .illegalNameField }

        if let value = value {
        
            if let item = findItem(with: nfd.crc, utf8ByteCode: nfd.data!) {
            
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
            
            if let item = findItem(with: nfd.crc, utf8ByteCode: nfd.data!) {
                
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
    public func updateValue(_ value: Bool?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: Int8?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: Int16?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: Int32?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: Int64?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: UInt8?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: UInt16?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: UInt32?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: UInt64?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: Float32?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: Float64?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: String?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    @discardableResult
    public func updateValue(_ value: Data?, forName name: String) -> Result { return _updateValue(value, forName: name) }
    
    
    /// Removes an item from the dictionary.
    ///
    /// The dictionary will decrease by one item as a result. If the name cannot be found the operation will fail. Notice that the itemByteCount of the dictionary will not decrease.
    ///
    /// - Parameter forKey: The name of the item to remove.
    ///
    /// - Returns: success or an error indicator.
    
    @discardableResult
    public func removeValue(forKey key: String) -> Result {

        guard isDictionary else { return .onlySupportedOnDictionary }
        let item = findItem(for: key)
        guard item != Portal.nullPortal else { return .itemNotFound }
        
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
        
        
        return .success
    }
}
