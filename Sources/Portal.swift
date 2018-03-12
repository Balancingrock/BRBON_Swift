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


/// Allows fatal error's for recoverable conditions. I.e. the API can continue, but there is a chance that the API user has made an error.

public var allowFatalError = true


/// Raises a fatal error if 'allowFatalError' is set to true. Otherwise returns the NullPortal.

@discardableResult
internal func fatalOrNull(_ message: String = "") -> Portal {
    if allowFatalError { fatalError(message) }
    return Portal.nullPortal
}


/// Allows the value accessors to raise a fatal error when a type change is implied.

public var allowFatalOnTypeChange = true


/// Raises a fatal error when the value-access set operator receives a different type than stored in the item.

internal func fatalOnTypeChange() {
    if allowFatalOnTypeChange { fatalError("Type change not allowed") }
}


/// This key is used to keep tracl of active portals. Active portals are tracked by the item manager to update the portals when data is shifted and to invalidate them when the data has been removed.

internal struct PortalKey: Equatable, Hashable {
    let itemPtr: UnsafeMutableRawPointer
    let index: Int?
    let column: Int?
    var hashValue: Int { return itemPtr.hashValue ^ (index ?? 0).hashValue ^ (column ?? 0).hashValue }
    static func == (lhs: PortalKey, rhs: PortalKey) -> Bool {
        return (lhs.itemPtr == rhs.itemPtr) && (lhs.index == rhs.index) && (lhs.column == rhs.column)
    }
}


/// A portal is an access point for items in the BRBON data structure. It hides the implementation of the BRBON data structure and provides an API to manipulate it at a higher abstraction level.

public final class Portal {
    
    
    /// This pointer points to the first byte of the item.
    //
    // It is a 'var' because the pointer value must be updated when the data is shifted around by insert/add/remove operations.
    
    internal var itemPtr: UnsafeMutableRawPointer
    
    
    /// If the portal refers to an element of an array, or a row in a table, then this is the index of that element/row.

    internal let index: Int?
    
    
    /// If the portal refers to a field of a table, this is the index of the column.
    
    internal let column: Int?

    
    /// The endianness of the data and its surrounding structure.
    
    internal let endianness: Endianness
    
    
    /// The item manager used to keep track of active portals and manage the memory buffer used for the items.
    
    internal weak var manager: ItemManager!
    
    
    /// The portal can be used when this variable is 'true'. Portals may become invalid, when that happens the active portals manager will signal the invalidity of a portal by setting this flag to 'false'.
    
    public var isValid: Bool
    
    
    /// This variable is used by the active portal manager. The portal will be removed from the active portals when this variable goes from 1 to 0.
    
    internal var refCount = 0
    
    
    /// Create a new portal.
    ///
    /// - Parameters:
    ///   - itemPtr: A pointer to the first byte of the item.
    ///   - index: The index for a row or element.
    ///   - column: The column index for a table field.
    ///   - manager: The memory and portals manager.
    ///   - endianness: The endianness of the data in the item.
    
    internal init(itemPtr: UnsafeMutableRawPointer, index: Int? = nil, column: Int? = nil, manager: ItemManager, endianness: Endianness) {
        self.itemPtr = itemPtr
        self.endianness = endianness
        self.manager = manager
        self.isValid = true
        self.index = index
        self.column = column
    }
    
    
    /// Deinitializes this portal. I.e. it removes it from the active portals.
    
    deinit {
        if refCount > 0 {
            manager?.decrementActivePortalRefcountAndRemoveOnZero(for: self)
        }
    }
    
    
    // The null portal is used to avoid an excess of unwrapping for the API user. API calls that must return a portal can return the null portal instead of returing nil.
    
    public static var nullPortal: Portal = {
        return Portal()
    }()
    
    
    /// Initializer for the nullPortal only.
    
    private init() {
        isValid = false
        index = nil
        column = nil
        endianness = machineEndianness
        itemPtr = UnsafeMutableRawPointer(bitPattern: 1)!
    }
    
    
    /// The key for this portal as used by the active portals manager
    
    internal var key: PortalKey { return PortalKey(itemPtr: itemPtr, index: index, column: column) }
    
    
    /// The NameFieldDescriptor for this item, nil if there is none.
    
    public var nameFieldDescriptor: NameFieldDescriptor? {
        if nameFieldByteCount == 0 { return nil }
        return NameFieldDescriptor.readValue(atPtr: itemPtr.brbonItemNameFieldPtr, endianness)
    }
}


// The active portals management needs the Equatable and Hashable

extension Portal: Equatable {
        
    /// Compares the content pointed at by two portals and returns true if they are the same, regardless of endianness.
    ///
    /// Note that this opration only compares used bytes and excluding the flag bits and parent-offsets. A bit by bit compare would probably find differences even when this operation returns equality. Invalid item types will always be considered unequal.
    
    public static func ==(lhs: Portal, rhs: Portal) -> Bool {
        
        // Test if the portals are still valid
        guard lhs.isValid, rhs.isValid else { return false }
        
        // Check indicies
        if lhs.index != rhs.index { return false }
        
        // Check columns
        if lhs.column != rhs.column { return false }

        if lhs.index == nil {

            // Compare items
            
            // Test type
            guard let lType = lhs.itemType else { return false }
            guard let rType = rhs.itemType else { return false }
            guard lType == rType else { return false }
            
            // Test options
            guard let lOptions = lhs.options else { return false }
            guard let rOptions = rhs.options else { return false }
            guard lOptions == rOptions else { return false }
            
            // Do not test flags
            
            // Test length of name field
            guard lhs.nameFieldByteCount == rhs.nameFieldByteCount else { return false }
            
            // Do not test the byte count
            
            // Do not test parent offset
            
            // Test count/value field (note that unused bytes must be zero!
            guard lhs.countValue == rhs.countValue else { return false }
            
            // Test name field (if present)
            if lhs.nameFieldByteCount != 0 {
                guard let lnfd = lhs.nameFieldDescriptor else { return false }
                guard let rnfd = rhs.nameFieldDescriptor else { return false }
                guard lnfd == rnfd else { return false }
            }
            
            // Test value field
            switch lhs.itemType! {
                
            case .null, .bool, .int8, .int16, .int32, .uint8, .uint16, .uint32, .float32:

                return true // Was already tested in the count/value field
                
                
            case .int64, .uint64, .float64:

                return
                    lhs.itemPtr.brbonItemValuePtr.assumingMemoryBound(to: UInt64.self).pointee
                    ==
                    rhs.itemPtr.brbonItemValuePtr.assumingMemoryBound(to: UInt64.self).pointee
                
                
            case .string:

                return lhs.string == rhs.string
                
                
            case .idString:

                return lhs.idString == rhs.idString
                
                
            case .binary:

                return lhs.binary == rhs.binary
                
                
            case .array:
                
                // Test element type
                guard lhs._arrayElementType != nil else { return false }
                guard rhs._arrayElementType != nil else { return false }
                guard lhs._arrayElementType == rhs._arrayElementType else { return false }
                
                // Do not test the element byte count
                
                // Test the elements
                for index in 0 ..< lhs.countValue {
                    let lPortal = Portal(itemPtr: lhs.itemPtr, index: index, manager: lhs.manager, endianness: lhs.endianness)
                    let rPortal = Portal(itemPtr: rhs.itemPtr, index: index, manager: rhs.manager, endianness: rhs.endianness)
                    if lPortal != rPortal { return false }
                }
                
                return true
            
                
            case .dictionary:

                var result = true
                
                lhs.forEachAbortOnTrue(){
                    (lportal: Portal) -> Bool in
                    let rportal = rhs[lportal.name!].portal
                    result = (lportal == rportal)
                    return !result
                }
                
                return result
                
                
            case .sequence:

                for index in 0 ..< lhs.countValue {
                    let lPortal = lhs[index].portal
                    let rPortal = rhs[index].portal
                    if lPortal != rPortal { return false }
                }
                return true
                
                
            case .table:
                
                if lhs._tableColumnCount != rhs._tableColumnCount { return false }
                if lhs._tableRowCount != rhs._tableRowCount { return false }
                
                for ci in 0 ..< lhs._tableColumnCount {
                    
                    guard let lType = lhs._tableGetColumnType(for: ci) else { return false }
                    guard let rType = rhs._tableGetColumnType(for: ci) else { return false }
                    
                    if lType != rType { return false }
                    
                    for ri in 0 ..< lhs._tableRowCount {
                        
                        switch lType {
                        
                        case .null: break
                            
                        case .bool:
                            let lbool = Bool(valuePtr: lhs._tableFieldValuePtr(row: ri, column: ci), lhs.endianness)
                            let rbool = Bool(valuePtr: rhs._tableFieldValuePtr(row: ri, column: ci), rhs.endianness)
                            if lbool != rbool { return false }
                        
                        case .int8, .uint8:
                            if lhs._tableFieldValuePtr(row: ri, column: ci).assumingMemoryBound(to: UInt8.self).pointee
                                != rhs._tableFieldValuePtr(row: ri, column: ci).assumingMemoryBound(to: UInt8.self).pointee { return false }
                            
                        case .int16, .uint16:
                            if lhs._tableFieldValuePtr(row: ri, column: ci).assumingMemoryBound(to: UInt16.self).pointee
                                != rhs._tableFieldValuePtr(row: ri, column: ci).assumingMemoryBound(to: UInt16.self).pointee { return false }

                        case .int32, .uint32, .float32:
                            if lhs._tableFieldValuePtr(row: ri, column: ci).assumingMemoryBound(to: UInt32.self).pointee
                                != rhs._tableFieldValuePtr(row: ri, column: ci).assumingMemoryBound(to: UInt32.self).pointee { return false }

                        case .int64, .uint64, .float64:
                            if lhs._tableFieldValuePtr(row: ri, column: ci).assumingMemoryBound(to: UInt64.self).pointee
                                != rhs._tableFieldValuePtr(row: ri, column: ci).assumingMemoryBound(to: UInt64.self).pointee { return false }

                        case .string:
                            let lstr = String(elementPtr: lhs._tableFieldValuePtr(row: ri, column: ci), lhs.endianness)
                            let rstr = String(elementPtr: rhs._tableFieldValuePtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .idString:
                            let lstr = IdString(elementPtr: lhs._tableFieldValuePtr(row: ri, column: ci), lhs.endianness)
                            let rstr = IdString(elementPtr: rhs._tableFieldValuePtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .binary:
                            let lstr = Data(elementPtr: lhs._tableFieldValuePtr(row: ri, column: ci), lhs.endianness)
                            let rstr = Data(elementPtr: rhs._tableFieldValuePtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .array, .sequence, .dictionary, .table:
                            let lportal = Portal(itemPtr: lhs._tableFieldValuePtr(row: ri, column: ci), manager: lhs.manager, endianness: lhs.endianness)
                            let rportal = Portal(itemPtr: rhs._tableFieldValuePtr(row: ri, column: ci), manager: rhs.manager, endianness: rhs.endianness)
                            if lportal != rportal { return false }
                        }
                    }
                }
                
                return true
            }
            
            
        } else {
            
            // The lhs and rhs are an array element or a table field.
            
            // Test a single value
            switch lhs.valueType! {
                
            case .null: return true
            case .bool: return lhs.bool == rhs.bool
            case .int8: return lhs.int8 == rhs.int8
            case .int16: return lhs.int16 == rhs.int16
            case .int32: return lhs.int32 == rhs.int32
            case .int64: return lhs.int64 == rhs.int64
            case .uint8: return lhs.uint8 == rhs.uint8
            case .uint16: return lhs.uint16 == rhs.uint16
            case .uint32: return lhs.uint32 == rhs.uint32
            case .uint64: return lhs.uint64 == rhs.uint64
            case .float32: return lhs.float32 == rhs.float32
            case .float64: return lhs.float64 == rhs.float64
            case .string: return lhs.string == rhs.string
            case .idString: return lhs.idString == rhs.idString
            case .binary: return lhs.binary == rhs.binary
            case .array, .dictionary, .sequence, .table:
                let lPortal = Portal(itemPtr: lhs._arrayElementPtr(for: lhs.index!), index: nil, manager: lhs.manager, endianness: lhs.endianness)
                let rPortal = Portal(itemPtr: rhs._arrayElementPtr(for: rhs.index!), index: nil, manager: rhs.manager, endianness: rhs.endianness)
                return lPortal == rPortal
            }
        }
    }
}


// MARK: - Item fields access

extension Portal {
    
    
    /// The type of item this portal refers to.
    ///
    /// - Note: The type of the value and the type of the item may differ when the item is a container type.
    
    public internal(set) var itemType: ItemType? {
        get {
            guard isValid else { return nil }
            return ItemType.readValue(atPtr: itemPtr.brbonItemTypePtr)
        }
        set { newValue?.storeValue(atPtr: itemPtr.brbonItemTypePtr) }
    }

    
    /// The type of value this portal refers to.
    
    public internal(set) var valueType: ItemType? {
        get {
            guard isValid else { return nil }
            if let column = column {
                return _tableGetColumnType(for: column)
            } else if index != nil {
                return _arrayElementType
            } else {
                return itemType
            }
        }
        set {
            if column != nil {
                // column types cannot be changed
            } else if index != nil {
                newValue?.storeValue(atPtr: itemPtr.brbonArrayElementTypePtr)
            } else {
                itemType = newValue
            }
        }
    }
    
    
    /// The options for the item this portal refers to.
    
    internal var options: ItemOptions? {
        get {
            return ItemOptions.readValue(atPtr: itemPtr.brbonItemOptionsPtr)
        }
        set { newValue?.storeValue(atPtr: itemPtr.brbonItemOptionsPtr) }
    }

    
    /// The flags for the item this portal refers to.

    internal var flags: ItemFlags? {
        get { return ItemFlags.readValue(atPtr: itemPtr.brbonItemFlagsPtr) }
        set { newValue?.storeValue(atPtr: itemPtr.brbonItemFlagsPtr) }
    }
    
    
    /// The byte count of the name field in the item this portal refers to.

    internal var nameFieldByteCount: Int {
        get { return Int(UInt8(valuePtr: itemPtr.brbonItemNameFieldByteCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: itemPtr.brbonItemNameFieldByteCountPtr, endianness) }
    }
    
    
    /// The byte count of the item this portal refers to.

    internal var itemByteCount: Int {
        get { return Int(UInt32(valuePtr: itemPtr.brbonItemByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemByteCountPtr, endianness) }
    }
    
    
    /// The parent offset for the item this portal refers to.
    
    internal var parentOffset: Int {
        get { return Int(UInt32(valuePtr: itemPtr.brbonItemParentOffsetPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemParentOffsetPtr, endianness) }
    }
    
    
    /// The content of the count/value field for the item this portal refers to.
    ///
    /// Depending on the type of item, the count / value field is used to store either the count a value or is not used at all.

    internal var countValue: Int {
        get { return Int(UInt32(valuePtr: itemPtr.brbonItemCountValuePtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness) }
    }
    
    
    /// The hash of name of the item this portal refers to.
    
    internal var _nameHash: UInt16 {
        get { return UInt16(valuePtr: itemPtr.brbonItemNameHashPtr, endianness) }
        set { newValue.storeValue(atPtr: itemPtr.brbonItemNameHashPtr, endianness) }
    }
    
    
    /// The number of used bytes in the data area of the name field of the item this portal refers to.
    
    internal var _nameCount: Int {
        get { return Int(UInt8(valuePtr: itemPtr.brbonItemNameCountPtr, endianness)) }
        set { UInt8(newValue).storeValue(atPtr: itemPtr.brbonItemNameCountPtr, endianness) }
    }
    
    
    /// A data struc with the bytes of the UTF8 code sequence used in the name field of the item this portal refers to.
    
    internal var _nameData: Data {
        get {
            if nameFieldByteCount == 0 { return Data() }
            return Data(bytes: itemPtr.brbonItemNameDataPtr, count: _nameCount)
        }
        set {
            guard newValue.count <= (nameFieldByteCount - 3) else { return }
            newValue.withUnsafeBytes({ itemPtr.brbonItemNameDataPtr.copyBytes(from: $0, count: newValue.count)})
        }
    }
    
    
    /// A string with the name fo the item this portal refers to.
    ///
    /// Empty if the item does not have a name. Nil if the conversion of UTF8 code to a string failed.
    
    public internal(set) var name: String? {
        get {
            guard isValid else { return nil }
            if nameFieldByteCount == 0 { return "" }
            return String.init(data: _nameData, encoding: .utf8) ?? ""
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
    
    internal var valueFieldByteCount: Int {
        return itemByteCount - minimumItemByteCount - nameFieldByteCount
    }
    
    
    /// Returns the number of bytes that are currently needed to represent the value in an item.
    
    internal var usedValueByteCount: Int {
        switch itemType! {
        case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32: return 0
        case .int64, .uint64, .float64: return 8
        case .string, .binary: return countValue
        case .idString: return max(Int(UInt32(valuePtr: itemPtr.brbonItemValuePtr, endianness) + 2), 8)
        case .array: return 8 + countValue * _arrayElementByteCount
        case .dictionary, .sequence:
            var usedByteCount: Int = 0
            forEachAbortOnTrue({ usedByteCount += $0.itemByteCount ; return false })
            return usedByteCount
        case .table: return minimumItemByteCount + 16 + _tableColumnCount * 16 + _tableRowCount * _tableRowByteCount
        }
    }

    
    /// Ensures that the item can accomodate a value of the given length.
    ///
    /// - Parameter for: The number of bytes needed.
    ///
    /// - Returns: True if the item or element has sufficient bytes available.
    
    internal func ensureValueFieldByteCount(of bytes: Int) -> Result {
        
        
        // If the current value field byte count is sufficient, return immediately
        
        if valueFieldByteCount >= bytes { return .success }
        
        
        // The byte count should be increased
        
        let necessaryItemByteCount = itemType!.minimumItemByteCount + bytes
        
        return increaseItemByteCount(to: necessaryItemByteCount)
    }
    
    
    /// Increases the byte count of the item.
    ///
    /// This operation might affect the itemByteCount and elementByteCount of multiple items if self is contained in other items. This can result in a total size increase many times the value in this call.
    ///
    /// This operation might fail if an upstream item cannot be increased in byte count.
    ///
    /// - Parameter newByteCount: The number of bytes this item should encompass.
    ///
    /// - Returns: Success if the operation succeeded. An error id if not.
    
    internal func increaseItemByteCount(to newByteCount: Int) -> Result {
        
        if let parent = parentPortal {
            
            
            // Check if the parent is an array
            
            if parent.isArray {
                
                
                // Check if the element byte count of the array must be grown
                
                if parent._arrayElementByteCount < newByteCount {
                    
                    
                    // Calculate the necessary byte count for the parent array
                    
                    //let necessaryParentItemByteCount = parent.itemByteCount - parent.valueByteCount + 8 + parent.countValue * newByteCount
                    let necessaryParentItemByteCount = ItemType.array.minimumItemByteCount + parent.countValue * newByteCount
                    
                    
                    // Check if the parent item byte count must be increased
                    
                    if parent.itemByteCount < necessaryParentItemByteCount {
                        
                        let result = parent.increaseItemByteCount(to: necessaryParentItemByteCount)
                        guard result == .success else { return result }
                    }
                    
                    
                    // Increase the byte count of the elements of the parent
                    
                    parent._arrayIncreaseElementByteCount(to: newByteCount)
                }
                
                
                // Only update the new byte count for self, other elements will be updated when necessary.
                
                itemByteCount = newByteCount
                
                return .success
                
            } else if parent.isDictionary {
                
                
                // Check if the byte count of the parent must be grown
                
                let necessaryParentItemByteCount = minimumItemByteCount + parent.nameFieldByteCount + parent.valueFieldByteCount - itemByteCount + newByteCount
                
                if parent.itemByteCount < necessaryParentItemByteCount {

                    let result = parent.increaseItemByteCount(to: necessaryParentItemByteCount)
                    guard result == .success else { return result }
                }
                
                
                // Increase the size of self, first copy all the items above this item out of reach
                
                let srcPtr = itemPtr.advanced(by: itemByteCount)
                let pastLastItemPtr = parent._afterLastItemPtr
                if srcPtr != pastLastItemPtr {
                    
                    // Items must be moved
                    
                    let len = pastLastItemPtr - srcPtr
                    let dstPtr = srcPtr.advanced(by: newByteCount - itemByteCount)
                    
                    manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
                }
                
                
                // Now the size of self can be increased

                itemByteCount = newByteCount
                
                
                return .success
                
            } else if parent.isSequence {

                // Check if the byte count of the parent must be grown
                
                let necessaryParentItemByteCount = minimumItemByteCount + parent.nameFieldByteCount + parent.valueFieldByteCount - itemByteCount + newByteCount
                
                if parent.itemByteCount < necessaryParentItemByteCount {
                    
                    let result = parent.increaseItemByteCount(to: necessaryParentItemByteCount)
                    guard result == .success else { return result }
                }
                
                
                // Increase the size of self, first copy all the items above this item out of reach
                
                let srcPtr = itemPtr.advanced(by: itemByteCount)
                let pastLastItemPtr = parent._afterLastItemPtr
                if srcPtr != pastLastItemPtr {
                    
                    // Items must be moved
                    
                    let len = pastLastItemPtr - srcPtr
                    let dstPtr = srcPtr.advanced(by: newByteCount - itemByteCount)
                    
                    manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
                }

                
                // Increase the byte count of self
                
                itemByteCount = newByteCount

                
                return .success
            
            } else {
                
                return .outOfStorage
            }
            
        } else {
            
            // There is no parent, this must be the root item.

            
            // If the buffer manager cannot accomodate the increase of the item, then increase the buffer size.
            
            if manager.unusedByteCount < newByteCount {
                
                // Note: The following operation also updates all active portals
                
                guard manager.increaseBufferSize(to: newByteCount) else { return .increaseFailed }
            }
            
            
            // Update the byte count
            
            itemByteCount = newByteCount
            
            
            return .success
        }
    }
}


// MARK: - Hierarchy traversing

extension Portal {

    
    /// Returns the pointer to the parent item. If there is no parent item, it returns a pointer to the item this portal refers to.
    
    internal var parentPtr: UnsafeMutableRawPointer {
        return manager.bufferPtr.advanced(by: parentOffset)
    }
    
    
    /// Returns the parent as a new portal. Returns nil if there is no parent.
    
    internal var parentPortal: Portal? {
        if parentPtr == itemPtr { return nil }
        return Portal(itemPtr: parentPtr, manager: manager, endianness: endianness)
    }

    
    /// Searches for an item with the same hash and string data as the search paremeters.
    ///
    /// Only for dictionaries, sequences and array's.
    ///
    /// - Parameters:
    ///   - with: A CRC16 over the stringData.
    ///   - utf8ByteCode: The bytes that make up a name string.
    ///
    /// - Returns: A pointer to the first byte
    
    internal func findPortalForItem(with hash: UInt16, utf8ByteCode: Data) -> Portal? {
        
        var ptrFound: UnsafeMutableRawPointer?
        
        forEachAbortOnTrue() {
            if $0._nameHash != hash { return false }
            if $0._nameCount != utf8ByteCode.count { return false }
            if $0._nameData != utf8ByteCode { return false }
            ptrFound = $0.itemPtr
            return true
        }
        
        if let aptr = ptrFound {
            return Portal(itemPtr: aptr, manager: manager, endianness: endianness)
        } else {
            return nil
        }
    }
    
    
    /// Returns a pointer to the next byte after the last item in a dictionary or sequence.

    internal var _afterLastItemPtr: UnsafeMutableRawPointer {
        var ptr = itemPtr.brbonItemValuePtr
        var remainder = countValue
        while remainder > 0 {
            ptr = ptr.advanced(by: Int(UInt32(valuePtr: ptr.brbonItemByteCountPtr, endianness)))
            remainder -= 1
        }
        return ptr
    }
    
    
    /// The closure is called for each child item or until the closure returns true.
    ///
    /// - Parameter closure: The closure that is called for each item in the dictionary. If the closure returns true then the processing of further items is aborted. Note that the portals passed to the closure are not registered with the active portals in the ItemManager. (To obtain a managed activePortal, use the '.portal' accessor)
    
    internal func forEachAbortOnTrue(_ closure: (Portal) -> Bool) {
        
        if isArray {
            
            let nofChildren = countValue
            var index = 0
            while index < nofChildren {
                let portal = Portal(itemPtr: itemPtr, index: index, manager: manager, endianness: endianness)
                if closure(portal) { return }
                index += 1
            }
    
        } else if isDictionary || isSequence {
            
            var aPtr = itemPtr.brbonItemValuePtr
            var remainder = countValue
            while remainder > 0 {
                let portal = Portal(itemPtr: aPtr, manager: manager, endianness: endianness)
                if closure(portal) { return }
                aPtr = aPtr.advanced(by: portal.itemByteCount)
                remainder -= 1
            }
        }
    }
}


// MARK: - Value accessors

extension Portal {
    
    
    /// Returns a managed portal for self.
    ///
    /// - Subscript operators return unmanaged portals and should not be stored locally. To obtain a managed portal, use this operation.
    
    public var portal: Portal {
        guard isValid else { return fatalOrNull("Portal is no longer valid") }
        return manager.getActivePortal(for: itemPtr, index: index, column: column)
    }
    
    public var isNull: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.null }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue
    }
    
    public var isBool: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.bool }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.bool.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.bool.rawValue
    }
    
    public var isUInt8: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint8 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint8.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint8.rawValue
    }
    
    public var isUInt16: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint16 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint16.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint16.rawValue
    }
    
    public var isUInt32: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint32 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint32.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint32.rawValue
    }
    
    public var isUInt64: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint64 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint64.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint64.rawValue
    }
    
    public var isInt8: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int8 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue
    }
    
    public var isInt16: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int16 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int16.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int16.rawValue
    }
    
    public var isInt32: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int32 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int32.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int32.rawValue
    }
    
    public var isInt64: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int64 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int64.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int64.rawValue
    }
    
    public var isFloat32: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.float32 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue
    }
    
    public var isFloat64: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.float64 }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float64.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float64.rawValue
    }
    
    public var isString: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.string }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue
    }
    
    public var isIdString: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.idString }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.idString.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.idString.rawValue
    }

    public var isBinary: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.binary }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue
    }
    
    public var isArray: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.array }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue
    }
    
    public var isDictionary: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.dictionary }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.dictionary.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.dictionary.rawValue
    }
    
    public var isSequence: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.sequence }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.sequence.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.sequence.rawValue
    }
    
    public var isTable: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.table }
        if index != nil { return itemPtr.brbonArrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.table.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.table.rawValue
    }
    
    
    public var null: Bool? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            return isNull ? true : nil
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if index == nil { return }
            changeSelfToNull()
        }
    }
    
    public var bool: Bool? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isBool else { fatalOrNull("Attempt to access \(itemType) as a bool"); return nil }
            if let index = index {
                if let column = column {
                    return Bool(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return Bool(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return Bool(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isBool else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isBool else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isBool && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .bool
                    newValue.storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var uint8: UInt8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isUInt8 else { fatalOrNull("Attempt to access \(itemType) as a UInt8"); return nil }
            if let index = index {
                if let column = column {
                    return UInt8(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return UInt8(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return UInt8(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isUInt8 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isUInt8 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isUInt8 && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .uint8
                    newValue.storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var uint16: UInt16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isUInt16 else { fatalOrNull("Attempt to access \(itemType) as a UInt16"); return nil }
            if let index = index {
                if let column = column {
                    return UInt16(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return UInt16(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return UInt16(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isUInt16 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isUInt16 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isUInt16 && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .uint16
                    newValue.storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var uint32: UInt32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isUInt32 else { fatalOrNull("Attempt to access \(itemType) as a UInt32"); return nil }
            if let index = index {
                if let column = column {
                    return UInt32(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return UInt32(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return UInt32(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isUInt32 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isUInt32 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isUInt32 && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .uint32
                    newValue.storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var uint64: UInt64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isUInt64 else { fatalOrNull("Attempt to access \(itemType) as a UInt64"); return nil }
            if let index = index {
                if let column = column {
                    return UInt64(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return UInt64(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return UInt64(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isUInt64 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isUInt64 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isUInt64 {
                        if !isNull { fatalOnTypeChange(); changeSelfToNull() }
                        guard ensureValueFieldByteCount(of: newValue.valueByteCount) == .success else { return }
                    }
                    itemType = .uint64
                    newValue.storeValue(atPtr: itemPtr.brbonItemValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var int8: Int8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isInt8 else { fatalOrNull("Attempt to access \(itemType) as a Int8"); return nil }
            if let index = index {
                if let column = column {
                    return Int8(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return Int8(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return Int8(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isInt8 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isInt8 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isInt8 && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .int8
                    newValue.storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var int16: Int16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isInt16 else { fatalOrNull("Attempt to access \(itemType) as a Int16"); return nil }
            if let index = index {
                if let column = column {
                    return Int16(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return Int16(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return Int16(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isInt16 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isInt16 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isInt16 && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .int16
                    newValue.storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var int32: Int32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isInt32 else { fatalOrNull("Attempt to access \(itemType) as a Int32"); return nil }
            if let index = index {
                if let column = column {
                    return Int32(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return Int32(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return Int32(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isInt32 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isInt32 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isInt32 && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .int32
                    newValue.storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var int64: Int64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isInt64 else { fatalOrNull("Attempt to access \(itemType) as a Int64"); return nil }
            if let index = index {
                if let column = column {
                    return Int64(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return Int64(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return Int64(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isInt64 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isInt64 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isInt64 {
                        if !isNull { fatalOnTypeChange(); changeSelfToNull() }
                        guard ensureValueFieldByteCount(of: newValue.valueByteCount) == .success else { return }
                    }
                    itemType = .int64
                    newValue.storeValue(atPtr: itemPtr.brbonItemValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var float32: Float32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isFloat32 else { fatalOrNull("Attempt to access \(itemType) as a Float32"); return nil }
            if let index = index {
                if let column = column {
                    return Float32(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return Float32(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return Float32(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isFloat32 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isFloat32 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isFloat32 && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .float32
                    newValue.storeValue(atPtr: itemPtr.brbonItemCountValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var float64: Float64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isFloat64 else { fatalOrNull("Attempt to access \(itemType) as a Float64"); return nil }
            if let index = index {
                if let column = column {
                    return Float64(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return Float64(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return Float64(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard isFloat64 else { fatalOrNull("Column type change not allowed"); return }
                    newValue?.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard isFloat64 else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    newValue?.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isFloat64 {
                        if !isNull { fatalOnTypeChange(); changeSelfToNull() }
                        guard ensureValueFieldByteCount(of: newValue.valueByteCount) == .success else {
                            fatalOrNull("Could not allocate additional memory")
                            return
                        }
                    }
                    itemType = .float64
                    newValue.storeValue(atPtr: itemPtr.brbonItemValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var string: String? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isString else { fatalOrNull("Attempt to access \(itemType) as a String"); return nil }
            if let index = index {
                if let column = column {
                    return String(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return String(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return String(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard let newValue = newValue, isString else { fatalOrNull("Column type change not allowed"); return }
                    guard _tableEnsureColumnValueByteCount(for: newValue, in: column) == .success else { fatalOrNull("Could not allocate additional memory"); return }
                    newValue.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard let newValue = newValue, isString else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    guard _arrayEnsureElementByteCount(for: newValue) == .success else { fatalOrNull("Could not allocate additional memory"); return }
                    newValue.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isString && !isNull {
                        fatalOnTypeChange()
                        changeSelfToNull()
                    }
                    itemType = .string
                    guard ensureValueFieldByteCount(of: newValue.valueByteCount) == .success else {
                        fatalOrNull("Could not allocate additional memory")
                        return
                    }
                    newValue.storeValue(atPtr: itemPtr.brbonItemValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    public var idString: IdString? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isString else { fatalOrNull("Attempt to access \(itemType) as a String"); return nil }
            if let index = index {
                if let column = column {
                    return IdString(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return IdString(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return IdString(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard let newValue = newValue, isString else { fatalOrNull("Column type change not allowed"); return }
                    guard _tableEnsureColumnValueByteCount(for: newValue, in: column) == .success else {
                        fatalOrNull("Could not allocate additional memory"); return
                    }
                    newValue.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard let newValue = newValue, isString else { fatalOrNull("Element type change not allowed (is: \(itemType))"); return }
                    guard _arrayEnsureElementByteCount(for: newValue) == .success else {
                        fatalOrNull("Could not allocate additional memory"); return
                    }
                    newValue.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isIdString && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .string
                    guard ensureValueFieldByteCount(of: newValue.valueByteCount) == .success else { fatalOrNull("Could not allocate additional memory"); return }
                    newValue.storeValue(atPtr: itemPtr.brbonItemValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }

    
    public var binary: Data? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isBinary else { fatalOrNull("Attempt to access \(itemType) as a Binary"); return nil }
            if let index = index {
                if let column = column {
                    return Data(elementPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    return Data(elementPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                return Data(itemPtr: itemPtr, endianness)
            }
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            if let index = index {
                if let column = column {
                    guard let newValue = newValue, isString else { fatalOrNull("Column type change not allowed"); return }
                    guard _tableEnsureColumnValueByteCount(for: newValue, in: column) == .success else {
                        fatalOrNull("Could not allocate additional memory"); return
                    }
                    newValue.storeAsElement(atPtr: _tableFieldValuePtr(row: index, column: column), endianness)
                } else {
                    guard let newValue = newValue, isString else {
                        fatalOrNull("Element type change not allowed (is: \(itemType))"); return
                    }
                    guard _arrayEnsureElementByteCount(for: newValue) == .success else {
                        fatalOrNull("Could not allocate additional memory"); return
                    }
                    newValue.storeAsElement(atPtr: _arrayElementPtr(for: index), endianness)
                }
            } else {
                if let newValue = newValue {
                    if !isBinary && !isNull { fatalOnTypeChange(); changeSelfToNull() }
                    itemType = .binary
                    guard ensureValueFieldByteCount(of: newValue.valueByteCount) == .success else {
                        fatalOrNull("Could not allocate additional memory")
                        return
                    }
                    newValue.storeValue(atPtr: itemPtr.brbonItemValuePtr, endianness)
                } else {
                    changeSelfToNull()
                }
            }
        }
    }
    
    
    /// Changes the type of self to a null.
    ///
    /// If self is a container, all portal for the contained items and elements are removed from the active portal list.
    
    internal func changeSelfToNull(_ removeSelf: Bool = false) {
        if isArray || isDictionary || isSequence {
            forEachAbortOnTrue({ $0.changeSelfToNull(true); return false })
        }
        if removeSelf {
            manager.removeActivePortal(self)
        }
    }
}
