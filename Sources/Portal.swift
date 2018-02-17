//
//  Portal.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 14/02/18.
//
// A Portal is an object through which access is gained to an item or element in a BRBON data structure.
// Portals can be used to read & write variables in the BRBON data structure as wel as for traversing the struture.
// When the data that the portal has access to is shifted, the portal is kept in-sync with the new location.
// Each BRBON item or element has only one portal instance associated with it. This instance will be shared and a reference count is kept to ensure that it is not removed prematurely. BRBON API users do not need concern themselves with this reference counting.

import Foundation
import BRUtils


/// This variable controls the raising of fatal errors on problems in the BRBON API.
///
/// Some usage errors can create a recoverable error condition as far as the BRBON API is considered. This variable controls if the usage error should result in a fatal error, or if it should be ignored. If a return value is expected, then ignoring will return a nil or the nullPortal.
///
/// It is recommened to set this to 'true' during develeopment and testing. Depending on the application, you may consider setting this to 'false' on the shipping application.

public var allowFatalError = true


@discardableResult
internal func fatalOrNull(_ message: String = "") -> Portal {
    if allowFatalError { fatalError(message) }
    return Portal.nullPortal
}


public class Portal {
    
    var basePtr: UnsafeMutableRawPointer!
    
    var parentPtr: UnsafeMutableRawPointer!
    
    var endianness: Endianness
    
    var manager: ItemManager?
    
    var isValid: Bool
    
    var isElement: Bool
    
    init(basePtr: UnsafeMutableRawPointer, parentPtr: UnsafeMutableRawPointer?, manager: ItemManager?, endianness: Endianness) {
        self.basePtr = basePtr
        self.parentPtr = parentPtr 
        self.endianness = endianness
        self.manager = manager
        self.isValid = true
        self.isElement = (parentPtr?.assumingMemoryBound(to: UInt8.self).pointee ?? 0) == ItemType.array.rawValue
    }
    
    deinit {
        manager?.unsubscribe(portal: self)
    }
    
    
    // The null portal is used to avoid an excess of unwrapping for the API user. API calls that must return a portal can return the null portal instead of returing nil.
    
    static var nullPortal: Portal = {
        return Portal()
    }()
    
    private init() {
        isValid = false
        isElement = false
        endianness = machineEndianness
    }
    
    
    /// The internal pointers will be advanced by the given offset.
    
    internal func updatePointers(by offset: Int) {
        basePtr = basePtr.advanced(by: offset)
        parentPtr = parentPtr?.advanced(by: offset)
    }
    
    
    /// If an internal pointer is higher than the reference pointer, it will be advanced by the given offset.
    
    internal func update(atOrAboveThisPtr refPtr: UnsafeMutableRawPointer, belowThisPtr endPtr: UnsafeMutableRawPointer, by offset: Int) {
        if basePtr >= refPtr && basePtr < endPtr { basePtr = basePtr.advanced(by: offset) }
        guard let pptr = parentPtr else { return }
        if pptr >= refPtr && pptr < endPtr { parentPtr = pptr.advanced(by: offset) }
    }
    
    
    /// Invalidates this portal if the basePtr is in the given range
    
    internal func invalidate(atOrAboveThisPtr startPtr: UnsafeMutableRawPointer, belowThisPtr endPtr: UnsafeMutableRawPointer) {
        if basePtr >= startPtr && basePtr < endPtr { invalidate() }
    }
    
    
    /// Invalidates this portal
    
    internal func invalidate() {
        isValid = false
        manager?.unsubscribe(portal: self)
    }
}


// MARK: - Conveniance

extension Portal {
    
    var count: Int { return countValue }
}

// MARK: - Memory management

extension Portal {
    
    
    /// Returns the number of bytes that are currently available for the value this portal offers access to.
    
    internal var availableValueByteCount: Int {
        if isElement {
            return elementByteCount
        } else {
            if isArray {
                return itemByteCount - minimumItemByteCount - nameFieldByteCount - 8
            } else {
                return itemByteCount - minimumItemByteCount - nameFieldByteCount
            }
        }
    }
    
    
    /// Returns the number of bytes that are currently needed to represent the value in an item.
    
    internal var usedValueByteCount: Int {
        switch itemType! {
        case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32: return 0
        case .int64, .uint64, .float64: return 8
        case .string, .binary: return countValue
        case .array: return 8 + countValue * elementByteCount
        case .dictionary, .sequence:
            var usedByteCount: Int = 0
            forEachAbortOnTrue({ usedByteCount += Int($0.itemByteCount) ; return false })
            return usedByteCount
        }
    }

    
    /// Ensures that an item can accomodate a value of the given length. If necessary it will try to increase the size of the item. Note that increasing the size is only possible for contiguous items and for variable length elements.
    ///
    /// - Parameter for: The number of bytes needed.
    ///
    /// - Returns: True if the item or element has sufficient bytes available.
    
    internal func ensureValueStorage(for bytes: Int) -> Result {
        if availableValueByteCount >= bytes { return .success }
        if !isElement || itemType!.hasVariableLength {
            var recursiveItems: Array<Portal> = [self]
            return increaseItemByteCount(by: (bytes - availableValueByteCount), recursiveItems: &recursiveItems)
        }
        return .outOfStorage
    }
    
    
    /// Increases the byte count of the item if possible.
    ///
    /// This operation is recursive back to the top level and the buffer manager. Also, if the operation affects an item that is contained in an array or sequence the change will be applied to all elements of that array. Hence a minimum increase of 8 bytes can (worst case) result in a multi megabyte increase in total.
    ///
    /// - Parameters:
    ///   - by: The number by which to increase the size of an item. Note that the actual size increase will happen in multiples of 8 bytes.
    ///   - recursiveItems: A list of items that may need their pointers to be updated. This list is in the order of the recursivity of calls. I.e. initially this list is empty and then a new item is added at the end for each recursive call.
    ///
    /// - Returns: .noManager or .increaseFailed if the increase failed, .success if it was successful.
    
    internal func increaseItemByteCount(by bytes: Int, recursiveItems: inout Array<Portal>) -> Result {
        
        
        if parentPtr == nil {
            
            
            // If there is no buffer manager, the size cannot be changed.
            
            guard let manager = manager else { return .noManager }
            
            
            // If the buffer manager cannot accomodate the increase of the item, then increase the buffer size.
            
            if manager.unusedByteCount < bytes {
                
                
                // Continue only when the buffer manager has increased its size.
                
                let oldPtr = basePtr!
                guard manager.increaseBufferSize(by: bytes.roundUpToNearestMultipleOf8()) else { return .increaseFailed }
                
                
                // All pointers must be updated
                
                let offset = basePtr.distance(to: oldPtr)
                for item in recursiveItems {
                    item.basePtr = item.basePtr.advanced(by: offset)
                    if item.parentPtr != nil {
                        item.parentPtr = item.parentPtr?.advanced(by: offset)
                    }
                }
            }
            
            
            // No matter what this item is, its value area can be increased. Update the byte count
            
            itemByteCount += bytes.roundUpToNearestMultipleOf8()
            
            
            return .success
            
            
        } else {
            
            
            // There is a parent item, get it.
            
            let parent = parentPortal!
            
            
            // Ensure the multiple-of-8 boundaries for non-elements
            
            let increase: Int
            if parent.isArray {
                increase = bytes
            } else {
                increase = bytes.roundUpToNearestMultipleOf8()
            }
            
            
            // The number of bytes the parent item has available for child byte count increases
            
            let freeByteCount = parent.availableValueByteCount - parent.usedValueByteCount
            
            
            // The number of bytes needed for the increase in the parent item
            
            let needed: Int
            
            if isArray {
                needed = (countValue * increase).roundUpToNearestMultipleOf8()
            } else {
                needed = increase
            }
            
            
            // If more is needed than available, then ask the parent to increase the available byte count
            
            if needed > freeByteCount {
                recursiveItems.append(self)
                let result = parent.increaseItemByteCount(by: needed, recursiveItems: &recursiveItems)
                guard result == .success else { return .increaseFailed }
                _ = recursiveItems.popLast()
            }
            
            
            // The parent is big enough.
            
            if parent.isArray {
                
                // Increase the size of all elements by the same amount
                
                var index = parent.countValue
                while index > 0 {
                    
                    let srcPtr = parent.basePtr.brbonItemValuePtr.advanced(by: 8 + (index - 1) * parent.elementByteCount)
                    let dstPtr = parent.basePtr.brbonItemValuePtr.advanced(by: 8 + (index - 1) * parent.elementByteCount + increase)
                    let length = parent.elementByteCount
                    
                    moveBlock(dstPtr, srcPtr, length)
                    
                    
                    // Check if the point to self has to be updated
                    
                    if basePtr == srcPtr {
                        
                        
                        // Yes, self must be updated.
                        
                        basePtr = dstPtr
                        
                        
                        // Also update the pointer values in the recursiveItems by the same offset
                        
                        let offset = srcPtr.distance(to: dstPtr)
                        for item in recursiveItems {
                            if item.basePtr > srcPtr { item.basePtr = item.basePtr.advanced(by: offset) }
                            if item.parentPtr! > srcPtr { item.parentPtr = item.parentPtr!.advanced(by: offset) }
                        }
                    }
                    
                    index -= 1
                }
                
                // Update the size of the elements in the parent
                
                parent.elementByteCount += increase
                
                return .success
            }
            
            
            if parent.isDictionary || parent.isSequence {
                
                // Shift all the items after self by the amount of increase of self.
                
                var srcPtr: UnsafeMutableRawPointer?
                var length: Int = 0
                
                var itemPtr = parent.basePtr.brbonItemValuePtr
                var childCount = parent.countValue
                while childCount > 0 {
                    
                    if (srcPtr == nil) && (itemPtr > basePtr) {
                        srcPtr = itemPtr
                    }
                    if srcPtr != nil {
                        length += Int(UInt32(valuePtr: itemPtr.advanced(by: itemByteCountOffset), endianness))
                    }
                    itemPtr = itemPtr.advanced(by: Int(UInt32(valuePtr: itemPtr.advanced(by: itemByteCountOffset), endianness)))
                    childCount -= 1
                }
                if srcPtr == nil { srcPtr = itemPtr }
                
                if itemByteCount > 0 {
                    let dstPtr = srcPtr!.advanced(by: Int(increase))
                    moveBlock(dstPtr, srcPtr!, length)
                }
                
                
                // Update the item size of self
                
                itemByteCount += increase
                
                
                return .success
            }
            
            fatalError("No other parent possible")
        }
    }
    
    
    /// Moves a block of memory from the source pointer to the destination pointer.
    ///
    /// This operation is passed on to the buffer manager to allow updating of pointer values in items that the API has made visible.
    
    internal func moveBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer, _ length: Int) {
        if let parent = parentPortal {
            return parent.moveBlock(dstPtr, srcPtr, length)
        } else {
            guard let manager = manager else { return }
            manager.moveBlock(dstPtr, srcPtr, length)
        }
    }
    
    
    /// Moves a block of memory from the source pointer to the destination pointer. The size of the block is given by the distance from the source pointer to the last byte used in the buffer area.
    ///
    /// This operation is passed on to the buffer manager to allow updating of pointer values in items that the API has made visible.
    
    internal func moveEndBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer) {
        if let parent = parentPortal {
            return parent.moveEndBlock(dstPtr, srcPtr)
        } else {
            guard let manager = manager else { return }
            manager.moveEndBlock(dstPtr, srcPtr)
        }
    }
    
    
    /// The offset for the given pointer from the start of the buffer.
    
    internal func offsetInBuffer(for aptr: UnsafeMutableRawPointer) -> Int {
        var pit = parentPortal
        var ptr = basePtr!
        while pit != nil {
            ptr = pit!.basePtr      // The base pointer of the first item is the buffer base address
            pit = pit!.parentPortal   // Go up the parent/child chain
        }
        return ptr.distance(to: aptr)
    }
    
    
    internal var bufferPtr: UnsafeMutableRawPointer {
        var pit = parentPortal
        var ptr = basePtr!
        while pit != nil {
            ptr = pit!.basePtr      // The base pointer of the first item is the buffer base address
            pit = pit!.parentPortal   // Go up the parent/child chain
        }
        return ptr
    }
}


// MARK: - Hierarchy traversing

extension Portal {
    
    
    /// Returns the parent as a new portal
    
    internal var parentPortal: Portal? {
        guard let parentPtr = parentPtr else { return nil }
        guard let manager = manager else { return nil }
        let greatParentOffset = Int(parentPtr.brbonItemParentOffsetPtr.assumingMemoryBound(to: UInt32.self).pointee)
        var greatParentPtr: UnsafeMutableRawPointer?
        if greatParentOffset != 0 { greatParentPtr = bufferPtr.advanced(by: greatParentOffset) }
        return manager.getPortal(for: parentPtr, parentPtr: greatParentPtr)
    }

    
    /// Returns the element pointer for a given index.
    ///
    /// - Note: This operation is purly mathematical, no checking performed.
    
    internal func elementPtr(for index: Int) -> UnsafeMutableRawPointer {
        let elementBasePtr = basePtr.brbonItemValuePtr.advanced(by: 8)
        let elementOffset = index * elementByteCount
        return elementBasePtr.advanced(by: elementOffset)
    }
    
    
    /// Get an element from an array as a portal.
    ///
    /// - Parameter index: The index of the element to retrieve.
    /// - Returns: A portal for the requested element, or the null-portal if the element does not exist
    
    internal func element(at index: Int) -> Portal {
        guard isArray else { return fatalOrNull("Int subscript access on non-array") }
        guard index >= 0 else { return fatalOrNull("Index below zero") }
        guard index < countValue else { return fatalOrNull("Index out of upper limit") }
        guard let manager = manager else { return fatalOrNull("No manager available") }
        return manager.getPortal(for: elementPtr(for: index), parentPtr: basePtr)
    }

}


// MARK: - Item/Element fields access

extension Portal {
    
    var itemType: ItemType? {
        get { return ItemType.readValue(atPtr: basePtr.brbonItemTypePtr) }
        set { newValue?.storeValue(atPtr: basePtr.brbonItemTypePtr) }
    }
    
    var elementType: ItemType? {
        get {
            if isElement {
                return ItemType.readValue(atPtr: parentPtr.brbonArrayElementTypePtr)
            } else {
                return ItemType.readValue(atPtr: basePtr.brbonArrayElementTypePtr)
            }
        }
        set {
            if isElement {
                newValue?.storeValue(atPtr: parentPtr.brbonArrayElementTypePtr)
            } else {
                newValue?.storeValue(atPtr: basePtr.brbonArrayElementTypePtr)
            }
        }
    }
    
    var options: ItemOptions? {
        get { return ItemOptions.readValue(atPtr: basePtr.brbonItemOptionsPtr) }
        set { newValue?.storeValue(atPtr: basePtr.brbonItemOptionsPtr) }
    }
    
    var flags: ItemFlags? {
        get { return ItemFlags.readValue(atPtr: basePtr.brbonItemFlagsPtr) }
        set { newValue?.storeValue(atPtr: basePtr.brbonItemFlagsPtr) }
    }
    
    var nameFieldByteCount: Int {
        get { return Int(UInt8(valuePtr: basePtr.brbonItemNameFieldByteCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: basePtr.brbonItemNameFieldByteCountPtr, endianness) }
    }
    
    var itemByteCount: Int {
        get { return Int(UInt32(valuePtr: basePtr.brbonItemByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: basePtr.brbonItemByteCountPtr, endianness) }
    }
    
    var elementByteCount: Int {
        get {
            if isElement {
                return Int(UInt32(valuePtr: basePtr.brbonArrayElementByteCountPtr, endianness))
            } else {
                return Int(UInt32(valuePtr: basePtr.brbonArrayElementByteCountPtr, endianness))
            }
        }
        set {
            if isElement {
                UInt32(newValue).storeValue(atPtr: parentPtr.brbonArrayElementByteCountPtr, endianness)
            } else {
                UInt32(newValue).storeValue(atPtr: basePtr.brbonArrayElementByteCountPtr, endianness)
            }
        }
    }
    
    var parentOffset: Int {
        get { return Int(UInt32(valuePtr: basePtr.brbonItemParentOffsetPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: basePtr.brbonItemParentOffsetPtr, endianness) }
    }
    
    var countValue: Int {
        get { return Int(UInt32(valuePtr: basePtr.brbonItemCountValuePtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: basePtr.brbonItemCountValuePtr, endianness) }
    }
    
    var nameHash: UInt16 {
        get { return UInt16(valuePtr: basePtr.brbonItemNameHashPtr, endianness) }
        set { newValue.storeValue(atPtr: basePtr.brbonItemNameHashPtr, endianness) }
    }
    
    var nameCount: Int {
        get { return Int(UInt8(valuePtr: basePtr.brbonItemNameCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: basePtr.brbonItemNameCountPtr, endianness) }
    }
    
    var nameData: Data {
        get {
            if nameFieldByteCount == 0 { return Data() }
            return Data(bytes: basePtr.brbonItemNameDataPtr, count: nameCount)
        }
        set {
            guard newValue.count <= (nameFieldByteCount - 3) else { return }
            newValue.withUnsafeBytes({ basePtr.brbonItemNameDataPtr.copyBytes(from: $0, count: newValue.count)})
        }
    }
    
    var name: String {
        get {
            if nameFieldByteCount == 0 { return "" }
            return String.init(data: nameData, encoding: .utf8) ?? ""
        }
        set {
            guard let nfd = NameFieldDescriptor(name) else { return }
            nfd.storeValue(atPtr: basePtr.brbonItemNameFieldPtr, endianness)
        }
    }
}


// MARK: - Subscript accessors

extension Portal {
    
    public subscript(key: String) -> Portal {
        get { return Portal.nullPortal }
        set { return }
    }
}


// MARK: - Value accessors

extension Portal {
    
    public var portal: Portal {
        return manager?.getPortal(for: basePtr, parentPtr: parentPtr) ?? Portal.nullPortal
    }
    
    public var isNull: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue
    }
    
    public var isBool: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.bool.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.bool.rawValue
    }
    
    public var isUInt8: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint8.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint8.rawValue
    }
    
    public var isUInt16: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint16.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint16.rawValue
    }
    
    public var isUInt32: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint32.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint32.rawValue
    }
    
    public var isUInt64: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint64.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint64.rawValue
    }
    
    public var isInt8: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue
    }
    
    public var isInt16: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int16.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int16.rawValue
    }
    
    public var isInt32: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int32.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int32.rawValue
    }
    
    public var isInt64: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int64.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int64.rawValue
    }
    
    public var isFloat32: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue
    }
    
    public var isFloat64: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float64.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float64.rawValue
    }
    
    public var isString: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue
    }
    
    public var isBinary: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue
    }
    
    public var isArray: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue
    }
    
    public var isDictionary: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.dictionary.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.dictionary.rawValue
    }
    
    public var isSequence: Bool {
        guard isValid else { return false }
        return isElement ?
            parentPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.sequence.rawValue
            :
            basePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.sequence.rawValue
    }
    
    
    public var null: Bool? {
        get { return isNull ? true : nil }
        set { return }
    }
    
    public var bool: Bool? {
        get {
            guard isValid, isBool else { return nil }
            return isElement ?
                Bool(valuePtr: basePtr, endianness)
                :
                Bool(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isBool else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .bool }
                    guard isBool else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isBool { itemType = .null }
                }
            }
        }
    }
    
    public var uint8: UInt8? {
        get {
            guard isValid, isUInt8 else { return nil }
            return isElement ?
                UInt8(valuePtr: basePtr, endianness)
                :
                UInt8(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isUInt8 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .uint8 }
                    guard isUInt8 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isUInt8 { itemType = .null }
                }
            }
        }
    }
    
    public var uint16: UInt16? {
        get {
            guard isValid, isUInt16 else { return nil }
            return isElement ?
                UInt16(valuePtr: basePtr, endianness)
                :
                UInt16(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isUInt16 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .uint16 }
                    guard isUInt16 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isUInt16 { itemType = .null }
                }
            }
        }
    }
    
    public var uint32: UInt32? {
        get {
            guard isValid, isUInt32 else { return nil }
            return isElement ?
                UInt32(valuePtr: basePtr, endianness)
                :
                UInt32(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isUInt32 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .uint32 }
                    guard isUInt32 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isUInt32 { itemType = .null }
                }
            }
        }
    }
    
    public var uint64: UInt64? {
        get {
            guard isValid, isUInt64 else { return nil }
            return isElement ?
                UInt64(valuePtr: basePtr, endianness)
                :
                UInt64(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isUInt64 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        itemType = .uint64
                    }
                    guard isUInt64 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isUInt64 { itemType = .null }
                }
            }
        }
    }
    
    public var int8: Int8? {
        get {
            guard isValid, isInt8 else { return nil }
            return isElement ?
                Int8(valuePtr: basePtr, endianness)
                :
                Int8(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isInt8 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .int8 }
                    guard isInt8 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isInt8 { itemType = .null }
                }
            }
        }
    }
    
    public var int16: Int16? {
        get {
            guard isValid, isInt16 else { return nil }
            return isElement ?
                Int16(valuePtr: basePtr, endianness)
                :
                Int16(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isInt16 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .int16 }
                    guard isInt16 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isInt16 { itemType = .null }
                }
            }
        }
    }
    
    public var int32: Int32? {
        get {
            guard isValid, isInt32 else { return nil }
            return isElement ?
                Int32(valuePtr: basePtr, endianness)
                :
                Int32(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isInt32 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .int32 }
                    guard isInt32 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isInt32 { itemType = .null }
                }
            }
        }
    }
    
    public var int64: Int64? {
        get {
            guard isValid, isInt64 else { return nil }
            return isElement ?
                Int64(valuePtr: basePtr, endianness)
                :
                Int64(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isInt64 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        itemType = .int64
                    }
                    guard isInt64 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isInt64 { itemType = .null }
                }
            }
        }
    }
    
    public var float32: Float32? {
        get {
            guard isValid, isFloat32 else { return nil }
            return isElement ?
                Float32(valuePtr: basePtr, endianness)
                :
                Float32(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isFloat32 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .float32 }
                    guard isFloat32 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isFloat32 { itemType = .null }
                }
            }
        }
    }
    
    public var float64: Float64? {
        get {
            guard isValid, isFloat64 else { return nil }
            return isElement ?
                Float64(valuePtr: basePtr, endianness)
                :
                Float64(valuePtr: basePtr.brbonItemValuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isFloat64 else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        itemType = .float64
                    }
                    guard isFloat64 else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isFloat64 { itemType = .null }
                }
            }
        }
    }
    
    public var string: String? {
        get {
            guard isValid, isString else { return nil }
            return isElement ?
                String(elementPtr: basePtr, endianness)
                :
                String(itemPtr: basePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isString else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        itemType = .string
                    }
                    guard isString else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isString { itemType = .null }
                }
            }
        }
    }
    
    public var binary: Data? {
        get {
            guard isValid, isBinary else { return nil }
            return isElement ?
                Data(elementPtr: basePtr, endianness)
                :
                Data(itemPtr: basePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isBinary else { return }
                newValue?.storeValue(atPtr: basePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueStorage(for: newValue.valueByteCount) == .success else { return }
                        itemType = .binary
                    }
                    guard isBinary else { return }
                    newValue.storeValue(atPtr: basePtr.brbonItemValuePtr, endianness)
                } else {
                    if isBinary { itemType = .null }
                }
            }
        }
    }
}


// MARK: - Support operations

extension Portal {
    
    
    /// The closure is called for each child item or until the closure returns true.
    ///
    /// - Parameter closure: The closure that is called for each item in the dictionary. If the closure returns true then the processing of further items is aborted. Note that the portals passed to the closure are not registered with the active portals in the ItemManager
    
    internal func forEachAbortOnTrue(_ closure: (Portal) -> Bool) {
        if isArray {
            let elementPtr = basePtr.brbonItemValuePtr.advanced(by: 8)
            let nofChildren = countValue
            var index = 0
            let ebc = elementByteCount
            while index < nofChildren {
                let portal = Portal(basePtr: elementPtr.advanced(by: index * ebc), parentPtr: basePtr, manager: nil, endianness: endianness)
                if closure(portal) { return }
                index += 1
            }
            return
        }
        if isDictionary {
            var itemPtr = basePtr.brbonItemValuePtr
            var remainder = countValue
            while remainder > 0 {
                let portal = Portal(basePtr: itemPtr, parentPtr: basePtr, manager: nil, endianness: endianness)
                if closure(portal) { return }
                itemPtr = itemPtr.advanced(by: portal.itemByteCount)
                remainder -= 1
            }
        }
    }
    
    
    /// Compares the content pointed at by two portals and returns true if they are the same.
    ///
    /// Note that this opration only compares used bytes and excluding the flag bits and parent-offsets. A data based compare would probably find differences even when this operation returns equality. Invalid item types will always be unequal.
    
    public static func ==(left: Portal, right: Portal) -> Bool {
        
        guard left.isValid, right.isValid else { return false }
        if left.isElement != right.isElement { return false }
        
        if left.isElement {
            
            switch left.elementType! {
            case .null: return true
            case .bool: return left.bool! == right.bool!
            case .int8: return left.int8! == right.int8!
            case .int16: return left.int16! == right.int16!
            case .int32: return left.int32! == right.int32!
            case .int64: return left.int64! == right.int64!
            case .uint8: return left.uint8! == right.uint8!
            case .uint16: return left.uint16! == right.uint16!
            case .uint32: return left.uint32! == right.uint32!
            case .uint64: return left.uint64! == right.uint64!
            case .float32: return left.float32! == right.float32!
            case .float64: return left.float64! == right.float64!
            case .string: return left.string! == right.string!
            case .binary: return left.binary! == right.binary!
            case .array: fatalError("Comparing array elements not yet implemented")
            case .dictionary: fatalError("Comparing dictionary elements not yet implemented")
            case .sequence: fatalError("Comparing sequence elements not yet implemented")
            }
        } else {
            guard left.itemType != nil else { return false }
            guard right.itemType != nil else { return false }
            
            if left.basePtr.assumingMemoryBound(to: UInt16.self).pointee != right.basePtr.assumingMemoryBound(to: UInt16.self).pointee { return false }
            if left.nameFieldByteCount != right.nameFieldByteCount { return false }
            if left.itemByteCount != right.itemByteCount { return false }
            if left.countValue != right.countValue { return false }
            if left.nameFieldByteCount != 0 {
                if left.basePtr.brbonItemNameFieldPtr.assumingMemoryBound(to: UInt32.self).pointee != right.basePtr.brbonItemNameFieldPtr.assumingMemoryBound(to: UInt32.self).pointee { return false }
                if left.nameData != right.nameData { return false }
            }
            switch left.itemType! {
            case .null, .bool, .int8, .int16, .int32, .uint8, .uint16, .uint32, .float32: return true
            case .int64, .uint64, .float64: return left.basePtr.brbonItemValuePtr.assumingMemoryBound(to: UInt64.self).pointee == right.basePtr.brbonItemValuePtr.assumingMemoryBound(to: UInt64.self).pointee
            case .string: return left.string == right.string
            case .binary: return left.binary == right.binary
            case .array:
                
                guard left.elementType != nil else { return false }
                guard right.elementType != nil else { return false }
                
                if left.elementType != right.elementType { return false }
                if left.elementByteCount != right.elementByteCount { return false }
                
                for index in 0 ..< left.countValue {
                    let leftPortal: Portal = left[index]
                    let rightPortal: Portal = right[index]
                    if leftPortal != rightPortal { return false }
                }
                return true
                
            case .dictionary:
                fatalError("dictionary compare not yet implemented")
            case .sequence:
                fatalError("sequence compare not yet implemented")
            }
        }
    }
    
    public static func !=(left: Portal, right: Portal) -> Bool {
        return !(left == right)
    }
}
