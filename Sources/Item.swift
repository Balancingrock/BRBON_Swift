//
//  Item.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 31/12/17.
//
//

import Foundation
import BRUtils


// Within the item
internal let itemTypeOffset = 0
internal let itemOptionsOffset = 1
internal let itemFlagsOffset = 2
internal let itemNameFieldLengthOffset = 3
internal let itemLengthOffset = 4
internal let itemParentOffsetOffset = 8
internal let itemCountValueOffset = 12
internal let itemNvrFieldOffset = 16

// Within the name field
internal let nameAreaHashOffset = 0
internal let nameAreaCountOffset = 1
internal let nameAreaDataOffset = 2

// Within an array
internal let elementTypeOffset = 0
internal let elementLengthOffset = 4
internal let elementsOffset = 8


/// An Item Pointer points to the first byte of an item.

internal typealias ItemPointer = UnsafeMutableRawPointer


// ******************************************************************
// **                                                              **
// ** INTERNAL OPERATIONS ARE NOT PROTECTED AGAINST ILLEGAL VALUES **
// **                                                              **
// ******************************************************************
//
// The operation will always assume that the pointed at area's will indeed support the purported operations.


/// Tests if an item is of the required type.
///
/// - Parameters:
///   - itemPtr: Must point to the first byte of an item.
///   - type: The type to test the item for.
///
/// - Returns: True if the type of the item pointed at equals the given type.

internal func isType(_ itemPtr: ItemPointer, _ type: ItemType) -> Bool {
    return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == type.rawValue
}


/// In an Item the first pointer points to the first byte of the item header and the second pointer to the first byte of the NVR field. Note that Items contained in an array have spield storage for header/parent/nvr-length and nvr-field.

public struct Item {
    
    
    /// Points at the first byte of the item header
    
    internal let ptr: UnsafeMutableRawPointer
    
    
    /// Reflects the endiannes of the item
    
    internal let endianness: Endianness
    
    
    /// Create a new Item that occupies a contiguous memeory area.
    ///
    /// - Parameters:
    ///   - ptr: A pointer to the first byte of the item.
    ///   - endianness: The endianness of the multi-byte fields.
    
    internal init(_ ptr: ItemPointer, _ endianness: Endianness) {
        self.ptr = ptr
        self.endianness = endianness
    }
    
    
    /// - Returns: The type of this item.
    
    internal var type: ItemType? { return ItemType(ptr) }
    
    
    /// - Returns: True if the count/value field must be used as value
    
    internal var countValueIsValue: Bool { return type?.useValueField ?? false }
    
    
    /// - Returns: The length of the name field.
    
    internal var nameFieldLength: UInt8 { return ptr.advanced(by: itemNameFieldLengthOffset).assumingMemoryBound(to: UInt8.self).pointee }

    
    /// - Returns: The item length
    
    internal var itemLength: UInt32 { return UInt32(ptr.advanced(by: itemLengthOffset), endianness: endianness) }
    
    
    /// - Returns: The offset of the parent relative to the first item byte.
    
    internal var parentOffset: UInt32 { return UInt32(ptr.advanced(by: itemParentOffsetOffset), endianness: endianness) }
    
    
    /// - Returns: The number of contained items.
    
    internal var count: UInt32 { return UInt32(ptr.advanced(by: itemCountValueOffset), endianness: endianness) }

    
    /// - Returns: A pointer to the first value field byte
    
    internal var valuePtr: UnsafeMutableRawPointer {
        if countValueIsValue {
            return ptr.advanced(by: itemCountValueOffset)
        } else {
            return ptr.advanced(by: Int(nameFieldLength) + itemNvrFieldOffset)
        }
    }
    
    
    /// Returns true if the name of the item equals the given information.
    ///
    /// - Parameters:
    ///   - hash: The CRC16 has of the name.
    ///   - name: A data struct that contains the UTF8 bytes of the name to compare against.
    ///
    /// - Returns: True if the names match, false otherwise.
    
    internal func nameEquals(hash: UInt16, name: Data) -> Bool {
        guard nameFieldLength > 0 else { return false }
        guard hash == UInt16(ptr.advanced(by: itemNvrFieldOffset + nameAreaHashOffset), endianness: endianness) else { return false }
        guard name.count == Int(UInt8(ptr.advanced(by: itemNvrFieldOffset + nameAreaCountOffset), endianness: endianness)) else { return false }
        let nameData = Data(ptr.advanced(by: itemNvrFieldOffset + nameAreaDataOffset), endianness: endianness, count: UInt32(name.count))
        return name == nameData
    }

    
    /// Returns a pointer to the element value located at a specified and valid index if self is an array.
    ///
    /// - Parameter at: The index of the requested element.
    ///
    /// - Returns: The pointer to the value of the requested element.
    
    internal func arrayElementValuePtr(at index: UInt32) -> UnsafeMutableRawPointer {
        let elementLength = Int(UInt32(ptr.advanced(by: itemNvrFieldOffset + elementLengthOffset), endianness: endianness))
        return ptr.advanced(by: itemNvrFieldOffset + Int(Int64(index) * Int64(elementLength)))
    }

    
    /// - Returns: A pointer to the first byte after the current item assuming they are located in a dictionary or sequence.
    
    internal var pointerToFirstByteAfter: UnsafeMutableRawPointer {
        return ptr.advanced(by: Int(itemLength))
    }

    
    /// Decrements the counter for the number of child elements/items. Only for Array, Dictionary or Sequence items.
    
    internal func decrementCount() {
        var cptr = ptr.advanced(by: itemCountValueOffset)
        let c = UInt32(cptr, endianness: endianness)
        (c - 1).endianBytes(endianness, toPointer: &cptr)
    }

    
    /// Increments the counter for the number of child elements/items. Only for Array, Dictionary or Sequence items.
    
    internal func incrementCount() {
        var cptr = ptr.advanced(by: itemCountValueOffset)
        let c = UInt32(cptr, endianness: endianness)
        (c + 1).endianBytes(endianness, toPointer: &cptr)
    }
    

    /// Update the parent pointers of the children of the parent as well as their children etc (recursive)
    ///
    /// - Parameter parent: The parent for which to update the children's parent pointer.
    
    internal func updateParentPointers(bufferPtr: UnsafeRawPointer) {
        
        let parentOffset = UInt32(bufferPtr.distance(to: headerPtr))
        
        forEachDoWhileTrue() {
            var ptr = $0.headerPtr.advanced(by: itemParentOffsetOffset)
            parentOffset.endianBytes(endianness, toPointer: &ptr)
            if $0.isArray || $0.isDictionary || $0.isSequence {
                $0.updateParentPointers(bufferPtr: bufferPtr)
            }
            return true
        }
    }

    
    /// Returns the item at a path consisting of integers and strings.
    ///
    /// - Parameters:
    ///   - path: An array of strings and integers used to select an item..
    ///   - pathIndex: The index into the path for which find the designated item.
    ///
    /// - Returns: The designated item, or nil if none could be found (either an error, or it does not exist)
    
    internal func item(at path: [Any], _ pathIndex: Int = 0) -> Item? {
        
        
        // Make sure the path and its index are usable
        
        if path.count == 0 || pathIndex >= path.count { return nil }
        
        
        // Perform the lookup for an integer index
        
        if path[pathIndex] is Int {
            
            var index = path[pathIndex] as! Int
            
            
            // Check if the index is within range
            
            let itemCount = Int(self.count)
            guard itemCount > 0 else { return nil }
            guard index < itemCount else { return nil }
            
            
            // Array lookup
            
            if isArray {
                
                
                // Get the designated item at the requeted index
                
                let element = self.item(at: UInt32(index))
                
                
                // If this was the last path element then return it as the result, otherwise go deeper.
                
                if path.count == (pathIndex + 1) {
                    return element
                } else {
                    return element.item(at: path, pathIndex + 1)
                }
            }
            
            
            // Sequence lookup
            
            if isSequence {
                
                
                // Start at the first item and keep going until the required index
                
                var item = Item(valuePtr.advanced(by: valueFieldElementTypeOffset), endianness)
                while index > 0 {
                    item = Item(item.pointerToFirstByteAfter, endianness)
                    index -= 1
                }
                
                
                // If this was the last path element then return it as the result, otherwise go deeper.
                
                if path.count == (pathIndex + 1) {
                    return item
                } else {
                    return item.item(at: path, pathIndex + 1)
                }
            }
            
            return nil
        }
        
        
        // Perform the lookup for a name
        
        if path.first! is String {
            
            
            // Get the name of the item to look for
            
            let lookupName = path.first! as! String
            
            
            // The designated item must be a .dictionary or .sequence
            
            guard isDictionary || isSequence else { return nil }
            
            
            // Get the number of items in the designated item
            
            var itemCount = UInt32(valuePtr.advanced(by: valueFieldCounterOffset), endianness: endianness)
            guard itemCount > 0 else { return nil }
            
            
            // The name check will in fact use the utf8 byte representation
            
            guard let lookupData = lookupName.data(using: .utf8) else { return nil }
            
            
            // To speed up the name test, first test a hash value
            
            let lookupHash = lookupData.crc16()
            
            
            // Get a pointer to the first item to check
            
            var item = Item(valuePtr.advanced(by: valueFieldElementTypeOffset), endianness)
            
            
            // Keep on checking until all items have been checked or a match is found
            
            while itemCount > 0 {
                
                
                // If the name is found...
                
                if item.nameEquals(hash: lookupHash, name: lookupData) {
                    
                    
                    // If this was the last path element then return it as the result, otherwise go deeper.
                    
                    if path.count == (pathIndex + 1) {
                        return item
                    } else {
                        return item.item(at: path, pathIndex + 1)
                    }
                }
                
                
                // This item is not it, go to next item
                
                itemCount -= 1
                if itemCount > 0 { item = Item(item.pointerToFirstByteAfter, endianness) }
            }
            
            return nil
        }
        
        
        // Wrong type of lookup parameter
        
        return nil
    }
    
    
    /// Execute the given closure for each item until the last child item or until the closure returns 'false'. Works only for Arrays, Dictionaries or Sequences.
    ///
    /// - Parameters closure: The closure to execute. If the closure returns 'false' execution stops immediately.
    
    internal func forEachDoWhileTrue(_ closure: (Item) -> (Bool)) {
        
        if isArray {
            
            let count = self.count
            
            var index: UInt32 = 0
            
            while index < count {
                
                let element = self.item(at: index)
                
                if !closure(element) { return }
                
                index += 1
            }
            
            return
        }
        
        if isDictionary || isSequence {
            
            let count = self.count
            
            var index: UInt32 = 0
            
            var item = Item(valuePtr.advanced(by: valueFieldElementTypeOffset), endianness)
            
            while index < count {
                
                if !closure(item) { return }
                
                index += 1
                
                if index < count { item = Item(item.pointerToFirstByteAfter, endianness) }
            }
        }
    }
    
    
    /// - Returns: True if this item is an array, false otherwise.

    var isArray: Bool { return isType(headerPtr, .array) }

    
    /// - Returns: True if this item is a dictionary, false otherwise.
    
    var isDictionary: Bool { return isType(headerPtr, .dictionary) }

    
    /// - Returns: True if this item is a sequence, false otherwise.
    
    var isSequence: Bool { return isType(headerPtr, .sequence) }

    
    /// - Returns: True if this item contains a Bool?, false otherwise.
    
    var isBool: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .bool) : isType(headerPtr, .bool) }
    
    
    /// - Returns: The Bool? value. Nil if it does not contain a Bool?.
    
    var bool: Bool? {
        guard isType(headerPtr, .bool) else { return nil }
        return Bool(valuePtr, endianness: endianness)
    }
    
    
    /// - Returns: True if this item contains a Null, false otherwise.
    
    var isNull: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .null) : false }

    
    /// - Returns: True if the item is a null, False if the item is a nil of another type, nil if the type is not null or nil.
    
    var null: Bool? {
        guard isType(headerPtr, .null) else { return nil }
        guard isType(valuePtr, .null) else { return false }
        return true
    }
    
    
    /// - Returns: True if this item contains an UInt8?, false otherwise.
    
    var isUInt8: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .uint8) : isType(headerPtr, .uint8) }

    
    /// - Returns: The UInt8? value of self. Nil if it does not contain an UInt8?.
    
    var uint8: UInt8? {
        guard isType(headerPtr, .uint8) else { return nil }
        return valuePtr.assumingMemoryBound(to: UInt8.self).pointee
    }
    
    
    /// - Returns: True if this item contains an Int8?, false otherwise.
    
    var isInt8: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .int8) : isType(headerPtr, .int8) }
    
    
    /// - Returns: The Int8? value of self. Nil if it does not contain an Int8?.
    
    var int8: Int8? {
        guard isType(headerPtr, .int8) else { return nil }
        return valuePtr.assumingMemoryBound(to: Int8.self).pointee
    }
    
    
    /// - Returns: True if this item contains an UInt16?, false otherwise.
    
    var isUInt16: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .uint16) : isType(headerPtr, .uint16) }
    
    
    /// - Returns: The UInt16? value of self. Nil if it does not contain an UInt16?.
    
    var uint16: UInt16? {
        guard isType(headerPtr, .uint16) else { return nil }
        return UInt16(valuePtr, endianness: endianness)
    }
    
    
    /// - Returns: True if this item contains an Int16?, false otherwise.
    
    var isInt16: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .int16) : isType(headerPtr, .int16) }
    
    
    /// - Returns: The Int16? value of self. Nil if it does not contain an Int16?.
    
    var int16: Int16? {
        guard isType(headerPtr, .int16) else { return nil }
        return Int16(valuePtr, endianness: endianness)
    }
    
    
    /// - Returns: True if this item contains an UInt32?, false otherwise.
    
    var isUInt32: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .uint32) : isType(headerPtr, .uint32) }
    
    
    /// - Returns: The UInt32? value of self. Nil if it does not contain an UInt32?.
    
    var uint32: UInt32? {
        guard isType(headerPtr, .uint32) else { return nil }
        return UInt32(valuePtr, endianness: endianness)
    }
    
    
    /// - Returns: True if this item contains an Int32?, false otherwise.
    
    var isInt32: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .int32) : isType(headerPtr, .int32) }
    
    
    /// - Returns: The Int32? value of the designated item or nil if it does not contain an Int32?.
    
    var int32: Int32? {
        guard isType(headerPtr, .int32) else { return nil }
        return Int32(valuePtr, endianness: endianness)
    }
    
    
    /// - Returns: True if this item contains a UInt64?, false otherwise.
    
    var isUInt64: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .uint64) : isType(headerPtr, .uint64) }
    
    
    /// - Returns: The UInt64? value of self. Nil if it does not contain an UInt64?.
    
    var uint64: UInt64? {
        guard isType(headerPtr, .uint64) else { return nil }
        return UInt64(valuePtr, endianness: endianness)
    }
    
    
    /// - Returns: True if this item contains an Int64?, false otherwise.
    
    var isInt64: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .int64) : isType(headerPtr, .int64) }
    
    
    /// - Returns: The Int64? value of self. Nil if it does not contain an Int64?.
    
    var int64: Int64? {
        guard isType(headerPtr, .int64) else { return nil }
        return Int64(valuePtr, endianness: endianness)
    }
    
    
    /// - Returns: True if this item contains a Float32?, false otherwise.
    
    var isFloat32: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .float32) : isType(headerPtr, .float32) }
    
    
    /// - Returns: The Float32? value of self. Nil if it does not contain a Float32?.
    
    var float32: Float32? {
        guard isType(headerPtr, .float32) else { return nil }
        return Float32(valuePtr, endianness: endianness)
    }
    
    
    /// - Returns: True if this item contains a Float64?, false otherwise.
    
    var isFloat64: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .float64) : isType(headerPtr, .float64) }
    
    
    /// - Returns: The Float64? value of self. Nil if it does not contain a Float64?.
    
    var float64: Float64? {
        guard isType(headerPtr, .float64) else { return nil }
        return Float64(valuePtr, endianness: endianness)
    }
    
    
    /// - Returns: True if this item contains a Binary?, false otherwise.
    
    var isBinary: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .binary) : isType(headerPtr, .binary) }
    
    
    /// - Returns: The Binary? value of self. Nil if it does not contain a Binary?.
    
    var binary: Data? {
        guard isType(headerPtr, .binary) else { return nil }
        let valueStartPtr = valuePtr
        let length = UInt32(valueStartPtr, endianness: endianness)
        return Data(valueStartPtr.advanced(by: 4), endianness: endianness, count: length)
    }
    
    
    /// - Returns: True if this item contains a String?, false otherwise.
    
    var isString: Bool { return isType(headerPtr, .null) ? isType(nvrPtr, .string) : isType(headerPtr, .string) }
    
    
    /// - Returns: The String? value of self. Nil if it does not contain a String?.
    
    var string: String? {
        guard isType(headerPtr, .string) else { return nil }
        let valueStartPtr = valuePtr
        let length = UInt32(valueStartPtr, endianness: endianness)
        return String(valueStartPtr.advanced(by: 4), endianness: endianness, count: length)
    }
}
