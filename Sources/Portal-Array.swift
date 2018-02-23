//
//  Portal-Subscript.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/01/18.
//
//

import Foundation
import BRUtils


///

public extension Portal {

    
    public subscript(index: Int) -> Portal {
        get { return element(at: index) }
    }

    public subscript(index: Int) -> Bool? { get { return getHelper(index).bool } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> Int8? { get { return getHelper(index).int8 } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> Int16? { get { return getHelper(index).int16 } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> Int32? { get { return getHelper(index).int32 } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> Int64? { get { return getHelper(index).int64 } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> UInt8? { get { return getHelper(index).uint8 } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> UInt16? { get { return getHelper(index).uint16 } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> UInt32? { get { return getHelper(index).uint32 } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> UInt64? { get { return getHelper(index).uint64 } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> Float32? { get { return getHelper(index).float32 } set { setHelper(index, newValue) } }
    public subscript(index: Int) -> Float64? { get { return getHelper(index).float64 } set { setHelper(index, newValue) } }
    
    public subscript(index: Int) -> String? { get { return getHelper(index).string }
        set {
            if isArray {
                guard (newValue?.elementByteCount ?? 0) <= elementByteCount else { fatalOrNull("Not sufficient storage for new value"); return }
            } else if isSequence {
                fatalError("Sequence not implemented yet")
            }
            setHelper(index, newValue)
        }
    }
    public subscript(index: Int) -> Data? { get { return getHelper(index).binary }
        set {
            if isArray {
                guard (newValue?.elementByteCount ?? 0) <= elementByteCount else { fatalOrNull("Not sufficient storage for new value"); return }
            } else if isSequence {
                fatalError("Sequence not implemented yet")
            }
            setHelper(index, newValue)
        }
    }
    
    
    private func getHelper(_ index: Int) -> Portal {
        if isArray {
            return element(at: index)
        } else if isSequence {
            return fatalOrNull("Sequence not implemented yet")
        } else {
            return fatalOrNull("Portal type does not support Int subscript access")
        }
    }
    
    private func setHelper(_ index: Int, _ newValue: Coder?) {
        guard index >= 0 else { fatalOrNull("Index below zero"); return }
        guard index < countValue else { fatalOrNull("Index too high"); return }
        if isArray {
            guard elementType == (newValue?.brbonType ?? .null) else { fatalOrNull("Type mismatch, try to store \((newValue?.brbonType ?? .null)) in an array of \(elementType)"); return }
            newValue?.storeAsElement(atPtr: elementPtr(for: index), endianness)
        } else if isSequence {
            fatalError("Sequence not implemented yet")
        }
    }

    
    /// Adds a new bool value to the end of the array.
    ///
    /// - Parameter value: The value to be added to the array.
    ///
    /// - Returns: success or an error indicator.
    
    @discardableResult
    private func _append(_ value: Coder) -> Result {
        
        
        // Prevent errors
        
        guard isArray else { return .onlySupportedOnArray }
        guard elementType == value.brbonType else { return .typeConflict }
        
        
        // Check to see if the element byte count of the array must be increased.
        
        if value.elementByteCount > elementByteCount {
            
            
            // The value byte count is bigger than the existing element byte count.
            // Enlarge the item to accomodate extra bytes.
            
            let necessaryElementByteCount: Int
            if value.brbonType.isContainer {
                necessaryElementByteCount = value.elementByteCount.roundUpToNearestMultipleOf8()
            } else {
                necessaryElementByteCount = value.elementByteCount
            }
            
            
            // This is the byte count that self has to become in order to accomodate the new value
            
            let necessaryItemByteCount = itemByteCount - valueByteCount + 8 + ((countValue + 1) * necessaryElementByteCount)
        
            
            if necessaryItemByteCount > itemByteCount {
                // It is necessary to increase the bytecount for the array item itself
                let result = increaseItemByteCount(to: necessaryItemByteCount.roundUpToNearestMultipleOf8())
                guard result == .success else { return result }
            }
            
            
            // Increase the byte count of the elements by shifting them up inside the enlarged array.
            
            increaseElementByteCount(to: necessaryElementByteCount)

            
        } else {
            
            
            // The element byte count of the array is big enough to hold the new value.
            
            // Make sure a new value can be added to the array
            
            let necessaryItemByteCount = itemByteCount - valueByteCount + 8 + ((countValue + 1) * elementByteCount)
            
            if necessaryItemByteCount > itemByteCount {
                let result = increaseItemByteCount(to: necessaryItemByteCount.roundUpToNearestMultipleOf8())
                guard result == .success else { return result }
            }
        }
        

        // The new value can be added
        
        if value.brbonType.isContainer {
            value.storeAsItem(atPtr: elementPtr(for: countValue), bufferPtr: (manager?.bufferPtr ?? elementPtr(for: countValue)), parentPtr: itemPtr, nameField: nil, valueByteCount: nil, endianness)
        } else {
            value.storeAsElement(atPtr: elementPtr(for: countValue), endianness)
        }
        
        
        // Increase child counter
        
        countValue += 1
        
        
        return .success
    }
    
    
    @discardableResult
    public func append(_ value: Bool) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: UInt8) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: UInt16) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: UInt32) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: UInt64) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Int8) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Int16) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Int32) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Int64) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Float32) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Float64) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: String) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Data) -> Result { return _append(value) }
    @discardableResult
    public func append(_ value: Array<Bool>) -> Result { return _append(BrbonArray(content: value, type: .bool)) }
    @discardableResult
    public func append(_ value: Array<UInt8>) -> Result { return _append(BrbonArray(content: value, type: .uint8)) }
    @discardableResult
    public func append(_ value: Array<UInt16>) -> Result { return _append(BrbonArray(content: value, type: .uint16)) }
    @discardableResult
    public func append(_ value: Array<UInt32>) -> Result { return _append(BrbonArray(content: value, type: .uint32)) }
    @discardableResult
    public func append(_ value: Array<UInt64>) -> Result { return _append(BrbonArray(content: value, type: .uint64)) }
    @discardableResult
    public func append(_ value: Array<Int8>) -> Result { return _append(BrbonArray(content: value, type: .int8)) }
    @discardableResult
    public func append(_ value: Array<Int16>) -> Result { return _append(BrbonArray(content: value, type: .int16)) }
    @discardableResult
    public func append(_ value: Array<Int32>) -> Result { return _append(BrbonArray(content: value, type: .int32)) }
    @discardableResult
    public func append(_ value: Array<Int64>) -> Result { return _append(BrbonArray(content: value, type: .int64)) }
    @discardableResult
    public func append(_ value: Array<Float32>) -> Result { return _append(BrbonArray(content: value, type: .float32)) }
    @discardableResult
    public func append(_ value: Array<Float64>) -> Result { return _append(BrbonArray(content: value, type: .float64)) }
    @discardableResult
    public func append(_ value: Array<String>) -> Result { return _append(BrbonArray(content: value, type: .string)) }
    @discardableResult
    public func append(_ value: Array<Data>) -> Result { return _append(BrbonArray(content: value, type: .binary)) }
    @discardableResult
    public func append(_ value: Dictionary<String, IsBrbon>) -> Result { return _append(BrbonDictionary(content: value)) }

    
    /// Removes an item from the array.
    ///
    /// The array will decrease by item as a result. If the index is out of bounds the operation will fail. Notice that the bytecount of the array will not decrease. To remove unnecessary bytes use the "minimizeByteCount" operation.
    ///
    /// - Parameter index: The index of the element to remove.
    ///
    /// - Returns: success or an error indicator.
    
    @discardableResult
    public func remove(at index: Int) -> Result {
        guard isArray else { return .onlySupportedOnArray }
        guard index >= 0 else { return .indexBelowLowerBound }
        guard index < countValue else { return .indexAboveHigherBound }
        let srcPtr = elementPtr(for: index + 1)
        let dstPtr = elementPtr(for: index)
        let len = (countValue - 1 - index) * elementByteCount
        moveBlock(dstPtr, srcPtr, len)
        countValue -= 1
        let key = PortalKey(itemPtr: itemPtr, index: countValue)
        manager?.activePortals.removePortal(for: key)
        return .success
    }

    
    /// Creates 1 or a number of new elements at the end of the array. If a default value is given, it will be used. If no default value is specified the content bytes will be set to zero.
    ///
    /// - Parameters:
    ///   - amount: The number of elements to create, default = 1.
    ///   - value: The default value for the new elements, default = nil.
    ///
    /// - Returns: .success or an error indicator.
    
    @discardableResult
    private func _createNewElements(_ value: Coder, _ amount: Int) -> Result {
        
        guard isArray else { return .onlySupportedOnArray }
        
        guard amount > 0 else { return .success }
        
        
        // Not implemented yet
        
        guard !elementType!.isContainer else { fatalOrNull("Not implemented"); return .typeConflict }


        // Ensure storage area
        
        let bytesNeeded = amount * value.elementByteCount + 8
        guard ensureValueByteCount(for: bytesNeeded) == .success else { return .outOfStorage }
        
        
        // Use default value
            
        var loopCount = amount
        repeat {
            value.storeValue(atPtr: elementPtr(for: countValue + loopCount - 1), endianness)
            loopCount -= 1
        } while loopCount > 0
        
        
        // Increment the number of elements

        countValue += amount
        
        
        return .success
    }
    
    @discardableResult
    public func createNewElements(_ value: Bool, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: UInt8, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: UInt16, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: UInt32, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: UInt64, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Int8, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Int16, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Int32, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Int64, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Float32, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Float64, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: String, amount: Int = 1) -> Result { return _createNewElements(value, amount) }
    @discardableResult
    public func createNewElements(_ value: Data, amount: Int = 1) -> Result { return _createNewElements(value, amount) }

    
    /// Inserts a new element at the given position.
    
    @discardableResult
    private func _insert(_ value: Coder, _ index: Int) -> Result {

        
        // Prevent errors
        
        guard isArray else { return .onlySupportedOnArray }
        guard value.brbonType == elementType else { return .typeConflict }
        guard index >= 0 else { return .indexBelowLowerBound }
        guard index < countValue else { return .indexAboveHigherBound }
        
        
        // Not implemented yet
        
        guard !value.brbonType.isContainer else { fatalOrNull("Not implemented"); return .typeConflict }
        
        
        // Ensure enough storage area is available
        
        let newElementByteCount = max(elementByteCount, value.elementByteCount)
        guard ensureValueByteCount(for: ((countValue  + 1) * newElementByteCount) + 8) == .success else { return .outOfStorage }
        if newElementByteCount > elementByteCount {
            increaseElementByteCount(to: newElementByteCount)
        }
        value.storeAsElement(atPtr: elementPtr(for: countValue), endianness)
        
        
        // Copy the existing elements upward
        
        let dstPtr = elementPtr(for: index + 1)
        let srcPtr = elementPtr(for: index)
        let length = (countValue - index) * elementByteCount
        moveBlock(dstPtr, srcPtr, length)
        
        
        // Insert the new element
        
        value.storeValue(atPtr: elementPtr(for: index), endianness)
        
        
        // Increase the number of elements
        
        countValue += 1
        
        
        return .success
    }

    @discardableResult
    public func insert(_ value: Bool, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: UInt8, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: UInt16, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: UInt32, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: UInt64, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Int8, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Int16, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Int32, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Int64, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Float32, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Float64, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: String, at index: Int) -> Result { return _insert(value, index) }
    @discardableResult
    public func insert(_ value: Data, at index: Int) -> Result { return _insert(value, index) }

}
