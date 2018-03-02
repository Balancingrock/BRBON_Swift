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
            guard isValid else { return fatalOrNull("Portal is no longer valid") }
            guard index >= 0 else { return fatalOrNull("Index (\(index)) is negative") }
            guard index < countValue else { return fatalOrNull("Index (\(index)) out of high bound (\(countValue))") }
            if isArray {
                return element(at: index)
            } else if isSequence {
                return item(at: index)
            } else {
                return fatalOrNull("Integer index subscript not supported on \(itemType)")
            }
        }
    }

    public subscript(index: Int) -> Bool? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).bool
            } else if isSequence {
                return item(at: index).bool
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).bool = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Int8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).int8
            } else if isSequence {
                return item(at: index).int8
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).int8 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Int16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).int16
            } else if isSequence {
                return item(at: index).int16
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).int16 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Int32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).int32
            } else if isSequence {
                return item(at: index).int32
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).int32 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Int64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).int64
            } else if isSequence {
                return item(at: index).int64
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).int64 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> UInt8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).uint8
            } else if isSequence {
                return item(at: index).uint8
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).uint8 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> UInt16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).uint16
            } else if isSequence {
                return item(at: index).uint16
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).uint16 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> UInt32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).uint32
            } else if isSequence {
                return item(at: index).uint32
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).uint32 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> UInt64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).uint64
            } else if isSequence {
                return item(at: index).uint64
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).uint64 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Float32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).float32
            } else if isSequence {
                return item(at: index).float32
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).float32 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Float64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).float64
            } else if isSequence {
                return item(at: index).float64
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).float64 = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> String? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).string
            } else if isSequence {
                return item(at: index).string
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).string = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    public subscript(index: Int) -> Data? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return nil }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return nil }
            if isArray {
                return element(at: index).binary
            } else if isSequence {
                return item(at: index).binary
            } else {
                fatalOrNull("Integer index subscript not supported on \(itemType)")
                return nil
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard index >= 0 else { fatalOrNull("Index (\(index)) is negative"); return }
            guard index < countValue else { fatalOrNull("Index (\(index)) out of high bound (\(countValue))"); return }
            if isArray { element(at: index).binary = newValue }
            else if isSequence { _ = item(at: index).replaceWith(newValue) }
            else { fatalOrNull("Integer index subscript not supported on \(itemType)") }
        }
    }
    
    
    /// Adds a new bool value to the end of the array.
    ///
    /// - Parameter value: The value to be added to the array.
    ///
    /// - Returns: success or an error indicator.
    
    @discardableResult
    private func _append(_ value: Coder, forName name: String? = nil) -> Result {
        
        guard isValid else { return .portalInvalid }
        
        if isArray {
            
            guard elementType == value.brbonType else { return .typeConflict }
            
            
            // Ensure that the element byte count is sufficient
            
            let result = ensureElementByteCount(for: value)
            guard result == .success else { return result }
            
            
            // The new value can be added
            
            if value.brbonType.isContainer {
                value.storeAsItem(atPtr: elementPtr(for: countValue), bufferPtr: manager.bufferPtr, parentPtr: itemPtr, nameField: nil, valueByteCount: nil, endianness)
            } else {
                value.storeAsElement(atPtr: elementPtr(for: countValue), endianness)
            }
            
            
            // Increase child counter
            
            countValue += 1
            
            return .success
        
        } else if isSequence {
            
            
            // Ensure that there is enough space available
            
            let nfd: NameFieldDescriptor? = {
                guard let name = name else { return nil }
                return NameFieldDescriptor(name)
            }()
            
            let newItemByteCount = value.itemByteCount(nfd)
                        
            if valueByteCount - usedValueByteCount < newItemByteCount {
                let result = increaseItemByteCount(to: minimumItemByteCount + usedValueByteCount + newItemByteCount)
                guard result == .success else { return result }
            }
            
            value.storeAsItem(atPtr: afterLastItemPtr, bufferPtr: manager.bufferPtr, parentPtr: itemPtr, nameField: nfd, valueByteCount: nil, endianness)
            
            countValue += 1
            
            return .success
            
        } else {
            fatalOrNull("Append operation not valid on \(itemType)")
            return .operationNotSupported
        }
    }
    
    
    @discardableResult
    public func append(_ value: IsBrbon, forName name: String? = nil) -> Result { return _append(value as! Coder, forName: name) }
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
        
        guard isValid else { fatalOrNull("Portal is invalid"); return .portalInvalid }
        
        guard index >= 0 else { fatalOrNull("Index (\(index)) below zero"); return .indexBelowLowerBound }
        guard index < countValue else { fatalOrNull("Index (\(index)) above high bound (\(countValue))"); return .indexAboveHigherBound }

        if isArray {
            
            let srcPtr = elementPtr(for: index + 1)
            let dstPtr = elementPtr(for: index)
            let len = (countValue - 1 - index) * elementByteCount
            
            moveBlock(dstPtr, srcPtr, len)
            
            countValue -= 1
            
            let key = PortalKey(itemPtr: itemPtr, index: countValue)
            manager.activePortals.removePortal(for: key)
            
            return .success
        
        } else if isSequence {
            
            let itm = item(at: index)
            let aliPtr = afterLastItemPtr
                
            let srcPtr = itm.itemPtr.advanced(by: itm.itemByteCount)
            let dstPtr = itm.itemPtr
            let len = srcPtr.distance(to: aliPtr)
            
            manager.activePortals.removePortal(for: itm.key)

            if len > 0 {
                moveBlock(dstPtr, srcPtr, len)
                manager.activePortals.updatePointers(atAndAbove: srcPtr, below: aliPtr, toNewBase: dstPtr)
            }
            
            countValue -= 1

            return .success
            
        } else {
            
            fatalOrNull("remove(int) not supported on \(itemPtr)")
            return .operationNotSupported
        }
    }

    
    /// Creates 1 or a number of new elements at the end of the array. If a default value is given, it will be used. If no default value is specified the content bytes will be set to zero.
    ///
    /// - Parameters:
    ///   - amount: The number of elements to create, default = 1.
    ///   - value: The default value for the new elements, default = nil.
    ///
    /// - Returns: .success or an error indicator.
    
    @discardableResult
    private func createNewElements(_ value: Coder, _ amount: Int = 1) -> Result {
        
        guard isValid else { fatalOrNull("Portal is invalid"); return .portalInvalid }

        guard isArray else { fatalOrNull("_createNewElements not supported for \(itemType)"); return .operationNotSupported }
        guard amount > 0 else { fatalOrNull("createNewElements must have amount > 0, found \(amount)"); return .success }
        
        
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
    public func createNewElements(_ value: IsBrbon, amount: Int = 1) -> Result {
        return createNewElements(value as! Coder, amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Bool>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .bool), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<UInt8>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .uint8), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<UInt16>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .uint16), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<UInt32>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .uint32), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<UInt64>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .uint64), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Int8>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .int8), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Int16>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .int16), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Int32>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .int32), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Int64>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .int64), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Float32>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .float32), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Float64>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .float64), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<String>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .string), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Array<Data>, amount: Int = 1) -> Result {
        return createNewElements(BrbonArray(content: value, type: .binary), amount)
    }
    @discardableResult
    public func createNewElements(_ value: Dictionary<String, IsBrbon>, amount: Int = 1) -> Result {
        return createNewElements(BrbonDictionary(content: value), amount)
    }

    
    /// Inserts a new element at the given position.
    
    @discardableResult
    private func _insert(_ value: Coder, atIndex index: Int, withName name: String? = nil) -> Result {

        
        guard isValid else { fatalOrNull("Portal is invalid"); return .portalInvalid }
        
        guard index >= 0 else { fatalOrNull("Index (\(index)) below zero"); return .indexBelowLowerBound }
        guard index < countValue else { fatalOrNull("Index (\(index)) above high bound (\(countValue))"); return .indexAboveHigherBound }
        
        
        if isArray {
            
            // Type must match the element type
            
            guard value.brbonType == elementType else { return .typeConflict }
            
            
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

            // Note that the active portals are not updated.
            
            
            // Insert the new element
            
            value.storeValue(atPtr: elementPtr(for: index), endianness)
            
            
            // Increase the number of elements
            
            countValue += 1
            
            
            return .success
            
            
        } else if isSequence {
            
            // Ensure that there is enough space available
            
            let nfd: NameFieldDescriptor? = {
                guard let name = name else { return nil }
                return NameFieldDescriptor(name)
            }()
            
            let newItemByteCount = value.itemByteCount(nfd)
            
            if valueByteCount - usedValueByteCount < newItemByteCount {
                let result = increaseItemByteCount(to: minimumItemByteCount + usedValueByteCount + newItemByteCount)
                guard result == .success else { return result }
            }
            
            
            // Copy the existing items upward
            
            let itm = item(at: index)
            
            let dstPtr = itm.itemPtr.advanced(by: newItemByteCount)
            let srcPtr = itm.itemPtr
            let length = newItemByteCount
            
            manager.activePortals.updatePointers(atAndAbove: srcPtr, below: afterLastItemPtr, toNewBase: dstPtr)
            
            moveBlock(dstPtr, srcPtr, length)
            
            
            // Insert the new element
            
            value.storeAsItem(atPtr: srcPtr, bufferPtr: manager.bufferPtr, parentPtr: itemPtr, nameField: nfd, valueByteCount: nil, endianness)
            
            
            countValue += 1
            
            return .success

            
        } else {
            
            fatalOrNull("insert(Coder, int) not supported on \(itemPtr)")
            return .operationNotSupported
        }
    }

    @discardableResult
    public func insert(_ value: IsBrbon, atIndex index: Int) -> Result { return _insert(value as! Coder, atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<Bool>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .bool), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<UInt8>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .uint8), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<UInt16>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .uint16), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<UInt32>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .uint32), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<UInt64>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .uint64), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<Int8>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .int8), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<Int16>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .int16), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<Int32>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .int32), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<Int64>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .int64), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<Float32>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .float32),atIndex:  index) }
    @discardableResult
    public func insert(_ value: Array<Float64>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .float64),atIndex:  index) }
    @discardableResult
    public func insert(_ value: Array<String>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .string), atIndex: index) }
    @discardableResult
    public func insert(_ value: Array<Data>, at index: Int) -> Result { return _insert(BrbonArray(content: value, type: .binary), atIndex: index) }
    @discardableResult
    public func insert(_ value: Dictionary<String, IsBrbon>, at index: Int) -> Result { return _insert(BrbonDictionary(content: value), atIndex: index) }

    
    /// Replaces the item at self.
    ///
    /// The item at self is replaced by the new value. The byte count will be preserved as is, or enlarged as necessary. If there is an existing name it will be preserved. If the new value is nil, the item will be converted into a null.
    
    internal func replaceWith(_ value: Coder?) -> Result {
        
        if let value = value {
            
            
            // Make sure the item byte count is big enough
            
            let necessaryItemByteCount = value.itemByteCount(nameFieldDescriptor)
            
            if itemByteCount < necessaryItemByteCount {
                let result = increaseItemByteCount(to: necessaryItemByteCount)
                guard result == .success else { return result }
            }
            
            
            // Create the new item, but remember the old size as it must be re-used
            
            let oldByteCount = itemByteCount
            
            
            // Write the new value as an item
            
            value.storeAsItem(atPtr: itemPtr, bufferPtr: manager.bufferPtr, parentPtr: parentPtr, nameField: nameFieldDescriptor, valueByteCount: nil, endianness)
            
            
            // Restore the old byte count
            
            itemByteCount = oldByteCount
            
            
            return .success
            
        } else {
            
            itemType = .null
            return .success
        }
    }
}
