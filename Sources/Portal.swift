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

internal struct PortalKey: Equatable, Hashable {
    let itemPtr: UnsafeMutableRawPointer
    let valuePtr: UnsafeMutableRawPointer
    var hashValue: Int { return itemPtr.hashValue ^ valuePtr.hashValue }
    static func == (lhs: PortalKey, rhs: PortalKey) -> Bool {
        return (lhs.itemPtr == rhs.itemPtr) && (lhs.valuePtr == rhs.valuePtr)
    }
}

public final class Portal {
    
    var itemPtr: UnsafeMutableRawPointer
    
    var valuePtr: UnsafeMutableRawPointer
    
    var endianness: Endianness
    
    var manager: ItemManager?
    
    var isValid: Bool
    
    var isElement: Bool
        
    init(itemPtr: UnsafeMutableRawPointer, elementPtr: UnsafeMutableRawPointer?, manager: ItemManager?, endianness: Endianness) {
        self.itemPtr = itemPtr
        self.endianness = endianness
        self.manager = manager
        self.isValid = true
        if let elementPtr = elementPtr {
            self.valuePtr = elementPtr
            self.isElement = true
        } else {
            self.valuePtr = itemPtr.brbonItemValuePtr
            self.isElement = false
        }
        
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
        itemPtr = UnsafeMutableRawPointer(bitPattern: 1)!
        valuePtr = UnsafeMutableRawPointer(bitPattern: 1)!
    }
    
    
    // Derived values
    
    var key: PortalKey { return PortalKey(itemPtr: itemPtr, valuePtr: valuePtr) }
    
    var parentIsArray: Bool {
        guard let manager = manager else { return false }
        let parentPtr = manager.bufferPtr.advanced(by: parentOffset)
        return parentPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue
    }
}


// The active portals management needs the Equatable and Hashable

extension Portal: Equatable {
        
    /// Compares the content pointed at by two portals and returns true if they are the same, regardless of endianness.
    ///
    /// Note that this opration only compares used bytes and excluding the flag bits and parent-offsets. A bit by bit compare would probably find differences even when this operation returns equality. Invalid item types will always be considered unequal.
    
    public static func ==(left: Portal, right: Portal) -> Bool {
        
        if (left.itemPtr == right.itemPtr) && (left.valuePtr == right.valuePtr) { return true }
        
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
            case .array:
                let leftItem = Portal(itemPtr: left.valuePtr, elementPtr: nil, manager: nil, endianness: left.endianness)
                let rightItem = Portal(itemPtr: right.valuePtr, elementPtr: nil, manager: nil, endianness: right.endianness)
                return leftItem == rightItem
            case .dictionary: fatalError("Comparing dictionary elements not yet implemented")
            case .sequence: fatalError("Comparing sequence elements not yet implemented")
            }
        } else {
            guard left.itemType != nil else { return false }
            guard right.itemType != nil else { return false }
            
            if left.itemPtr.assumingMemoryBound(to: UInt16.self).pointee != right.itemPtr.assumingMemoryBound(to: UInt16.self).pointee { return false }
            if left.nameFieldByteCount != right.nameFieldByteCount { return false }
            if left.itemByteCount != right.itemByteCount { return false }
            if left.countValue != right.countValue { return false }
            if left.nameFieldByteCount != 0 {
                if left.itemPtr.brbonItemNameFieldPtr.assumingMemoryBound(to: UInt32.self).pointee != right.itemPtr.brbonItemNameFieldPtr.assumingMemoryBound(to: UInt32.self).pointee { return false }
                if left.nameData != right.nameData { return false }
            }
            switch left.itemType! {
            case .null, .bool, .int8, .int16, .int32, .uint8, .uint16, .uint32, .float32: return true
            case .int64, .uint64, .float64: return left.itemPtr.brbonItemValuePtr.assumingMemoryBound(to: UInt64.self).pointee == right.itemPtr.brbonItemValuePtr.assumingMemoryBound(to: UInt64.self).pointee
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


// MARK: - Item fields access

extension Portal {
    
    var itemType: ItemType? {
        get { return ItemType.readValue(atPtr: itemPtr.brbonItemTypePtr) }
        set { newValue?.storeValue(atPtr: itemPtr.brbonItemTypePtr) }
    }
    
    var elementType: ItemType? {
        get { return ItemType.readValue(atPtr: itemPtr.brbonArrayElementTypePtr) }
        set { newValue?.storeValue(atPtr: itemPtr.brbonArrayElementTypePtr) }
    }
    
    var options: ItemOptions? {
        get { return ItemOptions.readValue(atPtr: itemPtr.brbonItemOptionsPtr) }
        set { newValue?.storeValue(atPtr: itemPtr.brbonItemOptionsPtr) }
    }
    
    var flags: ItemFlags? {
        get { return ItemFlags.readValue(atPtr: itemPtr.brbonItemFlagsPtr) }
        set { newValue?.storeValue(atPtr: itemPtr.brbonItemFlagsPtr) }
    }
    
    var nameFieldByteCount: Int {
        get { return Int(UInt8(valuePtr: itemPtr.brbonItemNameFieldByteCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: itemPtr.brbonItemNameFieldByteCountPtr, endianness) }
    }
    
    var itemByteCount: Int {
        get { return Int(UInt32(valuePtr: itemPtr.brbonItemByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemByteCountPtr, endianness) }
    }
    
    var elementByteCount: Int {
        get { return Int(UInt32(valuePtr: itemPtr.brbonArrayElementByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemPtr.brbonArrayElementByteCountPtr, endianness) }
    }
    
    var parentOffset: Int {
        get { return Int(UInt32(valuePtr: itemPtr.brbonItemParentOffsetPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemParentOffsetPtr, endianness) }
    }
    
    var countValue: Int {
        get { return Int(UInt32(valuePtr: itemPtr.brbonItemCountValuePtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness) }
    }
    
    var nameHash: UInt16 {
        get { return UInt16(valuePtr: itemPtr.brbonItemNameHashPtr, endianness) }
        set { newValue.storeValue(atPtr: itemPtr.brbonItemNameHashPtr, endianness) }
    }
    
    var nameCount: Int {
        get { return Int(UInt8(valuePtr: itemPtr.brbonItemNameCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: itemPtr.brbonItemNameCountPtr, endianness) }
    }
    
    var nameData: Data {
        get {
            if nameFieldByteCount == 0 { return Data() }
            return Data(bytes: itemPtr.brbonItemNameDataPtr, count: nameCount)
        }
        set {
            guard newValue.count <= (nameFieldByteCount - 3) else { return }
            newValue.withUnsafeBytes({ itemPtr.brbonItemNameDataPtr.copyBytes(from: $0, count: newValue.count)})
        }
    }
    
    var name: String {
        get {
            if nameFieldByteCount == 0 { return "" }
            return String.init(data: nameData, encoding: .utf8) ?? ""
        }
        set {
            guard let nfd = NameFieldDescriptor(name) else { return }
            nfd.storeValue(atPtr: itemPtr.brbonItemNameFieldPtr, endianness)
        }
    }
}


// MARK: - Memory management

extension Portal {
    
    
    /// Returns the number of bytes that are currently available for the value this portal offers access to.
    
    internal var valueByteCount: Int {
        if isElement {
            return elementByteCount
        } else {
            return itemByteCount - minimumItemByteCount - nameFieldByteCount
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
    
    internal func ensureValueByteCount(for bytes: Int) -> Result {
        if valueByteCount >= bytes { return .success }
        if let parentPortal = parentPortal, parentPortal.isArray {
            // This is being called from the update of an element, thus the entire needed area must be calculated
            let arrayBytes = parentPortal.elementByteCount * parentPortal.countValue
            let result = parentPortal.ensureValueByteCount(for: arrayBytes)
            guard result == .success else { return result }
            parentPortal.increaseElementByteCount(to: arrayBytes)
            return .success
        } else {
            if !itemType!.hasVariableLength { return .outOfStorage }
            var recursiveItems: Array<Portal> = [self]
            return increaseItemByteCount(by: (bytes - valueByteCount), recursiveItems: &recursiveItems)
        }
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
        
        
        if parentOffset == 0 {
            
            
            // If there is no buffer manager, the size cannot be changed.
            
            guard let manager = manager else { return .noManager }
            
            
            // If the buffer manager cannot accomodate the increase of the item, then increase the buffer size.
            
            if manager.unusedByteCount < bytes {
                
                
                // Continue only when the buffer manager has increased its size.
                
                let oldPtr = itemPtr
                guard manager.increaseBufferSize(by: bytes.roundUpToNearestMultipleOf8()) else { return .increaseFailed }
                
                
                // All pointers must be updated
                
                let offset = itemPtr.distance(to: oldPtr)
                for item in recursiveItems {
                    item.itemPtr = item.itemPtr.advanced(by: offset)
                    item.valuePtr = item.valuePtr.advanced(by: offset)
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
            
            let freeByteCount = parent.valueByteCount - parent.usedValueByteCount
            
            
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
                    
                    let srcPtr = parent.itemPtr.brbonItemValuePtr.advanced(by: 8 + (index - 1) * parent.elementByteCount)
                    let dstPtr = parent.itemPtr.brbonItemValuePtr.advanced(by: 8 + (index - 1) * parent.elementByteCount + increase)
                    let length = parent.elementByteCount
                    
                    moveBlock(dstPtr, srcPtr, length)
                    
                    
                    // Check if the point to self has to be updated
                    
                    if itemPtr == srcPtr {
                        
                        
                        // Yes, self must be updated.
                        
                        itemPtr = dstPtr
                        
                        
                        // Also update the pointer values in the recursiveItems by the same offset
                        
                        let offset = srcPtr.distance(to: dstPtr)
                        for item in recursiveItems {
                            if item.itemPtr > srcPtr { item.itemPtr = item.itemPtr.advanced(by: offset) }
                            if item.valuePtr > srcPtr { item.valuePtr = item.valuePtr.advanced(by: offset) }
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
                
                var itemPtr = parent.itemPtr.brbonItemValuePtr
                var childCount = parent.countValue
                while childCount > 0 {
                    
                    if (srcPtr == nil) && (itemPtr > itemPtr) {
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
    /// This operation is passed on to the buffer manager to allow updating of pointer values in items that the API has made visible. If no manager is available it is done directly.
    
    internal func moveBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer, _ length: Int) {
        if let manager = manager {
            manager.moveBlock(dstPtr, srcPtr, length)
        } else {
            _ = Darwin.memmove(dstPtr, srcPtr, length)
        }
    }
    

    internal func increaseElementByteCount(to newByteCount: Int) {

        let elementBasePtr = itemPtr.brbonArrayElementsBasePtr
        let oldByteCount = self.elementByteCount
        
        for index in (0 ..< countValue).reversed() {
            let dstPtr = elementBasePtr.advanced(by: index * newByteCount)
            let srcPtr = elementBasePtr.advanced(by: index * oldByteCount)
            moveBlock(dstPtr, srcPtr, oldByteCount)
            manager?.activePortals.updatePointers(atAndAbove: srcPtr, below: dstPtr, toNewBase: dstPtr)
        }
        
        elementByteCount = newByteCount
    }
}


// MARK: - Hierarchy traversing

extension Portal {
    
    
    /// Returns a pointer to the parent if there is one.
    /*
    internal var parentPointer: UnsafeMutableRawPointer? {
        guard let manager = manager else { return nil }
        guard parentOffset != 0 else { return nil }
        return manager.bufferPtr.advanced(by: parentOffset)
    }*/
    
    
    /// Returns the parent as a new portal
    
    internal var parentPortal: Portal? {
        guard parentOffset != 0 else { return nil }
        guard let manager = manager else { return nil }
        let parentPtr = manager.bufferPtr.advanced(by: parentOffset)
        return manager.getPortal(for: parentPtr, elementPtr: nil)
    }

    
    /// Returns the element pointer for a given index.
    ///
    /// - Note: This operation is purly mathematical, no checking performed.
    
    internal func elementPtr(for index: Int) -> UnsafeMutableRawPointer {
        let elementBasePtr = itemPtr.brbonItemValuePtr.advanced(by: 8)
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
        if let manager = manager {
            if elementType!.isContainer {
                return manager.getPortal(for: elementPtr(for: index), elementPtr: nil)
            } else {
                return manager.getPortal(for: itemPtr, elementPtr: elementPtr(for: index))
            }
        } else {
            if elementType!.isContainer {
                return Portal(itemPtr: elementPtr(for: index), elementPtr: nil, manager: nil, endianness: endianness)
            } else {
                return Portal(itemPtr: itemPtr, elementPtr: elementPtr(for: index), manager: nil, endianness: endianness)
            }
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
        let eptr: UnsafeMutableRawPointer? = isElement ? valuePtr : nil
        return manager?.getPortal(for: itemPtr, elementPtr: eptr) ?? Portal.nullPortal
    }
    
    public var isNull: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue
    }
    
    public var isBool: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.bool.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.bool.rawValue
    }
    
    public var isUInt8: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint8.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint8.rawValue
    }
    
    public var isUInt16: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint16.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint16.rawValue
    }
    
    public var isUInt32: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint32.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint32.rawValue
    }
    
    public var isUInt64: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint64.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint64.rawValue
    }
    
    public var isInt8: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue
    }
    
    public var isInt16: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int16.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int16.rawValue
    }
    
    public var isInt32: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int32.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int32.rawValue
    }
    
    public var isInt64: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int64.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int64.rawValue
    }
    
    public var isFloat32: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue
    }
    
    public var isFloat64: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float64.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float64.rawValue
    }
    
    public var isString: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue
    }
    
    public var isBinary: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue
    }
    
    public var isArray: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue
    }
    
    public var isDictionary: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.dictionary.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.dictionary.rawValue
    }
    
    public var isSequence: Bool {
        guard isValid else { return false }
        return isElement ?
            itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.sequence.rawValue
            :
            itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.sequence.rawValue
    }
    
    
    public var null: Bool? {
        get { return isNull ? true : nil }
        set { return }
    }
    
    public var bool: Bool? {
        get {
            guard isValid, isBool else { return nil }
            return Bool(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isBool else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .bool }
                    guard isBool else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isBool { itemType = .null }
                }
            }
        }
    }
    
    public var uint8: UInt8? {
        get {
            guard isValid, isUInt8 else { return nil }
            return UInt8(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isUInt8 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .uint8 }
                    guard isUInt8 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isUInt8 { itemType = .null }
                }
            }
        }
    }
    
    public var uint16: UInt16? {
        get {
            guard isValid, isUInt16 else { return nil }
            return UInt16(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isUInt16 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .uint16 }
                    guard isUInt16 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isUInt16 { itemType = .null }
                }
            }
        }
    }
    
    public var uint32: UInt32? {
        get {
            guard isValid, isUInt32 else { return nil }
            return UInt32(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isUInt32 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .uint32 }
                    guard isUInt32 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isUInt32 { itemType = .null }
                }
            }
        }
    }
    
    public var uint64: UInt64? {
        get {
            guard isValid, isUInt64 else { return nil }
            return UInt64(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isUInt64 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueByteCount(for: newValue.valueByteCount) == .success else { return }
                        itemType = .uint64
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
                    guard isUInt64 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isUInt64 {
                        itemType = .null
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
                }
            }
        }
    }
    
    public var int8: Int8? {
        get {
            guard isValid, isInt8 else { return nil }
            return Int8(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isInt8 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .int8 }
                    guard isInt8 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isInt8 { itemType = .null }
                }
            }
        }
    }
    
    public var int16: Int16? {
        get {
            guard isValid, isInt16 else { return nil }
            return Int16(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isInt16 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .int16 }
                    guard isInt16 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isInt16 { itemType = .null }
                }
            }
        }
    }
    
    public var int32: Int32? {
        get {
            guard isValid, isInt32 else { return nil }
            return Int32(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isInt32 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .int32 }
                    guard isInt32 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isInt32 { itemType = .null }
                }
            }
        }
    }
    
    public var int64: Int64? {
        get {
            guard isValid, isInt64 else { return nil }
            return Int64(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isInt64 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueByteCount(for: newValue.valueByteCount) == .success else { return }
                        itemType = .int64
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
                    guard isInt64 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isInt64 {
                        itemType = .null
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
                }
            }
        }
    }
    
    public var float32: Float32? {
        get {
            guard isValid, isFloat32 else { return nil }
            return Float32(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isFloat32 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull { itemType = .float32 }
                    guard isFloat32 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isFloat32 { itemType = .null }
                }
            }
        }
    }
    
    public var float64: Float64? {
        get {
            guard isValid, isFloat64 else { return nil }
            return Float64(valuePtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isFloat64 else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        guard ensureValueByteCount(for: newValue.valueByteCount) == .success else { return }
                        itemType = .float64
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
                    guard isFloat64 else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isFloat64 {
                        itemType = .null
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
                }
            }
        }
    }
    
    public var string: String? {
        get {
            guard isValid, isString else { return nil }
            return isElement ?
                String(elementPtr: valuePtr, endianness)
                :
                String(itemPtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isString else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        itemType = .string
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
                    guard isString else { return }
                    guard ensureValueByteCount(for: newValue.valueByteCount) == .success else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isString {
                        itemType = .null
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
                }
            }
        }
    }
    
    public var binary: Data? {
        get {
            guard isValid, isBinary else { return nil }
            return isElement ?
                Data(elementPtr: valuePtr, endianness)
                :
                Data(itemPtr: valuePtr, endianness)
        }
        set {
            guard isValid else { return }
            if isElement {
                guard isBinary else { return }
                newValue?.storeValue(atPtr: valuePtr, endianness)
            } else {
                if let newValue = newValue {
                    if isNull {
                        itemType = .binary
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
                    guard isBinary else { return }
                    guard ensureValueByteCount(for: newValue.valueByteCount) == .success else { return }
                    newValue.storeValue(atPtr: valuePtr, endianness)
                } else {
                    if isBinary {
                        itemType = .null
                        valuePtr = itemPtr.brbonItemValuePtr
                    }
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
            let elementPtr = itemPtr.brbonItemValuePtr.advanced(by: 8)
            let nofChildren = countValue
            var index = 0
            let ebc = elementByteCount
            while index < nofChildren {
                let portal = Portal(itemPtr: itemPtr, elementPtr: elementPtr.advanced(by: index * ebc), manager: nil, endianness: endianness)
                if closure(portal) { return }
                index += 1
            }
            return
        }
        if isDictionary {
            var aPtr = itemPtr.brbonItemValuePtr
            var remainder = countValue
            while remainder > 0 {
                let portal = Portal(itemPtr: aPtr, elementPtr: nil, manager: nil, endianness: endianness)
                if closure(portal) { return }
                aPtr = aPtr.advanced(by: portal.itemByteCount)
                remainder -= 1
            }
        }
    }
    
    
}
