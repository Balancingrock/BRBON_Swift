//
//  Element.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 20/01/18.
//
//

import Foundation
import BRUtils


/// ValueItems are non-organisational items stored in a dictionary or sequence. They contain data that is used by the API user.

public class Element: Item {
    
    
    /// - Returns: True if the item still refers to a valid memory area. False otherwise.
    
    public internal(set) var isValid: Bool = true
    
    
    /// - Returns: True if this item contains a Bool, false otherwise.
    
    public var isBool: Bool { return type == .bool }
    
    
    /// - Returns: The Bool value. Nil if it does not contain a Bool.
    
    public var bool: Bool? {
        get {
            guard isValid && (type == .bool) else { return nil }
            return Bool(ptr.advanced(by: itemValueCountOffset), endianness: endianness)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.bool.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .bool else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains an UInt8, false otherwise.
    
    public var isUInt8: Bool { return type == .uint8 }
    
    
    /// - Returns: The UInt8 value of self. Nil if it does not contain an UInt8.
    
    public var uint8: UInt8? {
        get {
            guard isValid && (type == .uint8) else { return nil }
            return ptr.advanced(by: itemValueCountOffset).assumingMemoryBound(to: UInt8.self).pointee
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.uint8.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .uint8 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains an Int8, false otherwise.
    
    public var isInt8: Bool { return type == .int8 }
    
    
    /// - Returns: The Int8 value of self. Nil if it does not contain an Int8.
    
    public var int8: Int8? {
        get {
            guard isValid && (type == .int8) else { return nil }
            return ptr.advanced(by: itemValueCountOffset).assumingMemoryBound(to: Int8.self).pointee
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.int8.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .int8 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains an UInt16, false otherwise.
    
    public var isUInt16: Bool { return type == .uint16 }
    
    
    /// - Returns: The UInt16 value of self. Nil if it does not contain an UInt16.
    
    public var uint16: UInt16? {
        get {
            guard isValid && (type == .uint16) else { return nil }
            return UInt16(valuePtr, endianness: endianness)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.uint16.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .uint16 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains an Int16, false otherwise.
    
    public var isInt16: Bool { return type == .int16 }
    
    
    /// - Returns: The Int16 value of self. Nil if it does not contain an Int16.
    
    public var int16: Int16? {
        get {
            guard isValid && (type == .int16) else { return nil }
            return Int16(valuePtr, endianness: endianness)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.int16.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .int16 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains an UInt32?, false otherwise.
    
    public var isUInt32: Bool { return type == .uint32 }
    
    
    /// - Returns: The UInt32 value of self. Nil if it does not contain an UInt32.
    
    public var uint32: UInt32? {
        get {
            guard isValid && (type == .uint32) else { return nil }
            return UInt32(valuePtr, endianness: endianness)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.uint32.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .uint32 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains an Int32, false otherwise.
    
    public var isInt32: Bool { return type == .int32 }
    
    
    /// - Returns: The Int32 value of the designated item or nil if it does not contain an Int32.
    
    public var int32: Int32? {
        get {
            guard isValid && (type == .int32) else { return nil }
            return Int32(valuePtr, endianness: endianness)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.int32.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .int32 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
        
    }
    
    
    /// - Returns: True if this item contains a UInt64, false otherwise.
    
    public var isUInt64: Bool { return type == .uint64 }
    
    
    /// - Returns: The UInt64 value of self. Nil if it does not contain an UInt64.
    
    public var uint64: UInt64? {
        get {
            guard isValid && (type == .uint64) else { return nil }
            return UInt64(valuePtr, endianness: endianness)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.uint64.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .uint64 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains an Int64, false otherwise.
    
    public var isInt64: Bool { return type == .int64 }
    
    
    /// - Returns: The Int64 value of self. Nil if it does not contain an Int64.
    
    public var int64: Int64? {
        get {
            guard isValid && (type == .int64) else { return nil }
            return Int64(valuePtr, endianness: endianness)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.int64.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .int64 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains a Float32, false otherwise.
    
    public var isFloat32: Bool { return type == .float32 }
    
    
    /// - Returns: The Float32 value of self. Nil if it does not contain a Float32.
    
    public var float32: Float32? {
        get {
            guard isValid && (type == .float32) else { return nil }
            return Float32(valuePtr, endianness: endianness)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.float32.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .float32 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains a Float64, false otherwise.
    
    public var isFloat64: Bool { return type == .float64 }
    
    
    /// - Returns: The Float64 value of self. Nil if it does not contain a Float64.
    
    public var float64: Float64? {
        get {
            guard isValid && (type == .float64) else { return nil }
            return Float64(valuePtr, endianness: endianness)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.float64.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .float64 else { return }
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains a Binary, false otherwise.
    
    public var isBinary: Bool { return type == .binary }
    
    
    /// - Returns: The Binary value of self. Nil if it does not contain a Binary.
    
    public var binary: Data? {
        get {
            guard isValid && (type == .binary) else { return nil }
            let length = UInt32(ptr.advanced(by: itemValueCountOffset), endianness: endianness)
            return Data(valuePtr, endianness: endianness, count: length)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.binary.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .binary else { return }
                var cptr = ptr.advanced(by: itemValueCountOffset)
                newValue.brbonCount().brbonBytes(endianness, toPointer: &cptr)
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// - Returns: True if this item contains a String, false otherwise.
    
    public var isString: Bool { return type == .string }
    
    
    /// - Returns: The String value of self. Nil if it does not contain a String.
    
    public var string: String? {
        get {
            guard isValid && (type == .string) else { return nil }
            let length = UInt32(ptr.advanced(by: itemValueCountOffset), endianness: endianness)
            return String(valuePtr, endianness: endianness, count: length)
        }
        set {
            guard isValid else { return }
            if let newValue = newValue {
                if type == .null {
                    var tptr = ptr.advanced(by: itemTypeOffset)
                    ItemType.string.rawValue.brbonBytes(endianness, toPointer: &tptr)
                }
                guard type == .string else { return }
                var cptr = ptr.advanced(by: itemValueCountOffset)
                newValue.brbonCount().brbonBytes(endianness, toPointer: &cptr)
                var vptr = valuePtr
                newValue.brbonBytes(endianness, toPointer: &vptr)
            } else {
                var tptr = ptr.advanced(by: itemTypeOffset)
                ItemType.null.rawValue.brbonBytes(endianness, toPointer: &tptr)
            }
        }
    }
    
    
    /// Creates a new Element
    ///
    /// - Parameters:
    ///   - eptr: The pointer to the first byte of the element.
    ///   - pptr: The pointer to the first byte of the parent item.
    ///   - endianness: The endianness of the ValueItem bytes.
    
    internal init(elementPtr eptr: UnsafeMutableRawPointer, parentPtr pptr: UnsafeMutableRawPointer, endianness: Endianness) {
        self.ptr = eptr
        self.pptr = pptr
        self.endianness = endianness
    }
    
    
    /// Pointer to an Element  (is contained in a dictionary or sequence)
    
    internal var ptr: UnsafeMutableRawPointer
    
    
    /// The endianness of the ValueItem bytes
    
    internal let endianness: Endianness
    
    
    /// The dictionary manager
    
    internal var dictionaryManager: DictionaryManager?
    
    
    deinit {
        buffer?.deallocate()
        dictionaryManager?.unsubscribe(item: self)
    }
    
    
    /// Returns a pointer to the value field.
    ///
    /// - Note: The type must be a valid type
    
    internal var valuePtr: UnsafeMutableRawPointer {
        if type!.useValueCountFieldAsValue { return ptr.advanced(by: itemValueCountOffset) }
        return ptr.advanced(by: itemNvrFieldOffset + Int(nameFieldLength))
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
        guard hash == UInt16(ptr.advanced(by: nameHashOffset), endianness: endianness) else { return false }
        guard name.count == Int(UInt8(ptr.advanced(by: nameCountOffset), endianness: endianness)) else { return false }
        return name == nameData
    }
    
    
    /// When the dictionary manager updates its data structure in a way that affects the pointer of this value item, this operation is called to update its pointer. If the memory area is no longer available, the isValid flag is reset and the item is no longer subscribed to the dictionary manager.
    
    internal func updateFromDictionaryManager(isValid: Bool, oldPtr: UnsafeMutableRawPointer, newPtr: UnsafeMutableRawPointer) {
        if oldPtr == ptr {
            if isValid {
                self.ptr = newPtr
            } else {
                self.isValid = false
                dictionaryManager?.unsubscribe(item: self)
                dictionaryManager = nil
            }
        }
    }
    
    
    /*
     /// Insert the buffer content at the end of the given parent which should be a dictionary or sequence.
     ///
     /// - Parameters:
     ///   - rawBuffer: The buffer with the content to be inserted.
     ///   - toDictionary: The dictionary or sequence item to which to append the buffer content.
     
     internal func append(_ rawBuffer: UnsafeRawBufferPointer, toDictionary dict: Item) {
     
     let srcPtr = dict.pointerToFirstByteAfter
     let dstPtr = srcPtr.advanced(by: rawBuffer.count)
     let count = srcPtr.distance(to: entryPtr)
     
     // Free up the area for insertion
     _ = Darwin.memmove(dstPtr, srcPtr, count)
     
     // Insert
     _ = Darwin.memmove(srcPtr, rawBuffer.baseAddress!, rawBuffer.count)
     }
     
     
     /// Removes a block of memory from the internal data structure.
     ///
     /// - Parameters:
     ///   - fromPtr: A pointer to the first byte to be removed.
     ///   - upToPtr: A pointer to the first byte NOT to be removed.
     
     internal func removeBlock(fromPtr: UnsafeMutableRawPointer, upToPtr: UnsafeMutableRawPointer) {
     let bytes = upToPtr.distance(to: entryPtr)
     _ = Darwin.memmove(fromPtr, upToPtr, bytes)
     let newCount = buffer.baseAddress!.distance(to: entryPtr) - bytes
     entryPtr = buffer.baseAddress!.advanced(by: newCount)
     }
     
     
     /// Removes an item from a parent. The item count will be decremented.
     ///
     /// - Parameters:
     ///   - item: The item to be removed.
     ///   - parent: The parent from which the item is removed.
     
     internal func remove(_ item: Item, parent: Item) {
     
     if parent.isArray {
     remove(item, fromArray: parent)
     return
     }
     
     if parent.isDictionary || parent.isSequence {
     remove(item, fromDictionary: parent)
     return
     }
     }
     
     
     /// Removes an item from an array. The item count in the array will be decremented.
     ///
     /// - Parameters:
     ///   - item: The item to be removed.
     ///   - fromArray: The array from which the item is removed.
     
     private func remove(_ item: Item, fromArray: Item) {
     
     
     // Get the source address for the removal
     
     let elementSize = UInt32(fromArray.valuePtr.advanced(by: valueFieldElementTypeOffset), endianness: endianness)
     let srcPtr = item.nvrPtr.advanced(by: Int(elementSize))
     
     
     // If the item is the last item
     
     if srcPtr == entryPtr {
     
     
     // Just move the entryPtr to the first byte to be removed
     
     entryPtr = item.headerPtr
     
     
     // Decrement the counter index in the parent
     
     fromArray.decrementCount()
     
     } else {
     
     
     // Remove by shifting the data downward
     
     removeBlock(fromPtr: item.headerPtr, upToPtr: srcPtr)
     
     
     // Decrement the counter index in the parent
     
     fromArray.decrementCount()
     
     
     // Any parents in the dictionary after the removal pointer must update the parent pointers in their children
     
     fromArray.forEachDoWhileTrue() {
     if $0.headerPtr <= item.headerPtr { $0.updateParentPointers(bufferPtr: buffer.baseAddress!) }
     return true
     }
     }
     }
     
     
     /// Removes an item from a dictionary or sequence. The item count will be decremented.
     ///
     /// - Parameters:
     ///   - item: The item to be removed.
     ///   - fromDictionary: The dictionary or sequence from which the item is removed.
     
     
     private func remove(_ item: Item, fromDictionary: Item) {
     
     
     // Get the source address for the removal
     
     let srcPtr = item.pointerToFirstByteAfter
     
     
     // If the item is the last item
     
     if srcPtr == entryPtr {
     
     
     // Just move the entryPtr to the first byte to be removed
     
     entryPtr = item.headerPtr
     
     
     // Decrement the counter index in the parent
     
     fromDictionary.decrementCount()
     
     } else {
     
     
     // Remove by shifting the data downward
     
     removeBlock(fromPtr: item.headerPtr, upToPtr: srcPtr)
     
     
     // Decrement the counter index in the parent
     
     fromDictionary.decrementCount()
     
     
     // Any parents in the dictionary after the removal pointer must update the parent pointers in their children
     
     fromDictionary.forEachDoWhileTrue() {
     if $0.headerPtr <= item.headerPtr { $0.updateParentPointers(bufferPtr: buffer.baseAddress!) }
     return true
     }
     }
     }*/
}








