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
        
        
        // Ensure that the element byte count is sufficient
        
        let result = ensureElementByteCount(for: value)
        guard result == .success else { return result }
        

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
        
        
        // Ensure that the element byte count is sufficient
        
        var result = ensureElementByteCount(for: value)
        guard result == .success else { return result }
        
        
        // Ensure that the item storage capacity is sufficient

        let newCount = countValue + amount
        let neccesaryValueByteCount = 8 + elementByteCount * newCount
        result = ensureValueByteCount(for: neccesaryValueByteCount)
        guard result == .success else { return result }
        
        
        // Use default value to populate the new items
            
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
    @discardableResult
    public func createNewElements(_ value: Array<Bool>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .bool), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<UInt8>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .uint8), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<UInt16>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .uint16), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<UInt32>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .uint32), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<UInt64>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .uint64), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Int8>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .int8), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Int16>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .int16), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Int32>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .int32), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Int64>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .int64), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Float32>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .float32), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Float64>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .float64), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<String>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .string), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Data>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonArray(content: value, type: .binary), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Dictionary<String, IsBrbon>, amount: Int = 1) -> Result {
        return _createNewElements(BrbonDictionary(content: value), amount)
    }

    
    /// Inserts a new element at the given position.
    
    @discardableResult
    private func _insert(_ value: Coder, _ index: Int) -> Result {

        
        // Prevent errors
        
        guard isArray else { return .onlySupportedOnArray }
        guard value.brbonType == elementType else { return .typeConflict }
        guard index >= 0 else { return .indexBelowLowerBound }
        guard index < countValue else { return .indexAboveHigherBound }
        
        
        // Ensure that the element byte count is sufficient
        
        var result = ensureElementByteCount(for: value)
        guard result == .success else { return result }

        
        // Ensure that the item storage capacity is sufficient
        
        let newCount = countValue + 1
        let neccesaryValueByteCount = 8 + elementByteCount * newCount
        result = ensureValueByteCount(for: neccesaryValueByteCount)
        guard result == .success else { return result }

        
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
    @discardableResult
    public func insert(_ value: Array<Bool>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .bool), index) }
    @discardableResult
    public func insert(_ value: Array<UInt8>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .uint8), index) }
    @discardableResult
    public func insert(_ value: Array<UInt16>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .uint16), index) }
    @discardableResult
    public func insert(_ value: Array<UInt32>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .uint32), index) }
    @discardableResult
    public func insert(_ value: Array<UInt64>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .uint64), index) }
    @discardableResult
    public func insert(_ value: Array<Int8>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .int8), index) }
    @discardableResult
    public func insert(_ value: Array<Int16>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .int16), index) }
    @discardableResult
    public func insert(_ value: Array<Int32>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .int32), index) }
    @discardableResult
    public func insert(_ value: Array<Int64>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .int64), index) }
    @discardableResult
    public func insert(_ value: Array<Float32>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .float32), index) }
    @discardableResult
    public func insert(_ value: Array<Float64>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .float64), index) }
    @discardableResult
    public func insert(_ value: Array<String>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .string), index) }
    @discardableResult
    public func insert(_ value: Array<Data>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .binary), index) }
    @discardableResult
    public func insert(_ value: Dictionary<String, IsBrbon>, at index: Int) -> Result { return _insert(BrbonDictionary(content: value), index) }

}
