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
    
    
    /// The number of child-items, elements or rows in the referenced item
    
    public var count: Int {
        guard isValid else { return 0 }
        switch itemType! {
        case .null, .bool, .int8, .int16, .int32, .int64, .uint8, .uint16, .uint32, .uint64, .float32, .float64, .string, .crcString, .binary, .crcBinary: return 0
        case .dictionary: return _dictionaryItemCount
        case .sequence: return _sequenceItemCount
        case .array: return _arrayElementCount
        case .table: return _tableRowCount
        }
    }
    
    
    /// The key for this portal as used by the active portals manager
    
    internal var key: PortalKey { return PortalKey(itemPtr: itemPtr, index: index, column: column) }
    
    
    /// The NameField for this item, nil if there is none.
    
    public var nameField: NameField? {
        guard _itemNameFieldByteCount > 0 else { return nil }
        return NameField.readValue(fromPtr: _itemNameFieldPtr, endianness)
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
            guard let lOptions = lhs.itemOptions else { return false }
            guard let rOptions = rhs.itemOptions else { return false }
            guard lOptions == rOptions else { return false }
            
            // Do not test flags
            
            // Do not test length of name field
            
            // Do not test the byte count
            
            // Do not test parent offset
            
            // Test count/value field (note that unused bytes must be zero!
            guard UInt32(fromPtr: lhs.itemSmallValuePtr, lhs.endianness) == UInt32(fromPtr: rhs.itemSmallValuePtr, rhs.endianness) else { return false }
            
            // Test name field (if present)
            if lhs._itemNameFieldByteCount != 0 {
                guard let lnfd = lhs.nameField else { return false }
                guard let rnfd = rhs.nameField else { return false }
                guard lnfd == rnfd else { return false }
            }
            
            // Test value field
            switch lhs.itemType! {
                
            case .null, .bool, .int8, .int16, .int32, .uint8, .uint16, .uint32, .float32:

                return true // Was already tested in the count/value field
                
                
            case .int64, .uint64, .float64:

                return lhs.uint64 == rhs.uint64

                
            case .string:

                return lhs.string == rhs.string
                
                
            case .crcString:

                return lhs.crcString == rhs.crcString
                
                
            case .binary:

                return lhs.binary == rhs.binary
                
                
            case .crcBinary:
                
                return lhs.crcBinary == rhs.crcBinary
                
            case .array:
                
                // Test element type
                guard lhs._arrayElementType != nil else { return false }
                guard rhs._arrayElementType != nil else { return false }
                guard lhs._arrayElementType == rhs._arrayElementType else { return false }
                
                // Do not test the element byte count
                
                // Test the elements
                for index in 0 ..< lhs._arrayElementCount {
                    let lPortal = Portal(itemPtr: lhs.itemPtr, index: index, manager: lhs.manager, endianness: lhs.endianness)
                    let rPortal = Portal(itemPtr: rhs.itemPtr, index: index, manager: rhs.manager, endianness: rhs.endianness)
                    if lPortal != rPortal { return false }
                }
                
                return true
            
                
            case .dictionary:

                var result = true
                
                lhs.forEachAbortOnTrue(){
                    (lportal: Portal) -> Bool in
                    let rportal = rhs[lportal.itemName!].portal
                    result = (lportal == rportal)
                    return !result
                }
                
                return result
                
                
            case .sequence:

                for index in 0 ..< lhs._sequenceItemCount {
                    let lPortal = lhs[index].portal
                    let rPortal = rhs[index].portal
                    if lPortal != rPortal { return false }
                }
                return true
                
                
            case .table:
                
                if lhs._tableColumnCount != rhs._tableColumnCount { return false }
                if lhs._tableRowCount != rhs._tableRowCount { return false }
                
                for ci in 0 ..< lhs._tableColumnCount {
                    
                    let lnamecrc = lhs._tableGetColumnNameCrc(for: ci)
                    let rnamecrc = rhs._tableGetColumnNameCrc(for: ci)
                    if lnamecrc != rnamecrc { return false }
                    
                    let lname = lhs._tableGetColumnName(for: ci)
                    let rname = rhs._tableGetColumnName(for: ci)
                    if lname != rname { return false }
                    
                    guard let lType = lhs._tableGetColumnType(for: ci) else { return false }
                    guard let rType = rhs._tableGetColumnType(for: ci) else { return false }
                    if lType != rType { return false }
                    
                    for ri in 0 ..< lhs._tableRowCount {
                        
                        switch lType {
                        
                        case .null: break
                            
                        case .bool:
                            let lbool = Bool(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rbool = Bool(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lbool != rbool { return false }
                        
                        case .int8, .uint8:
                            if lhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt8.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt8.self).pointee { return false }
                            
                        case .int16, .uint16:
                            if lhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt16.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt16.self).pointee { return false }

                        case .int32, .uint32, .float32:
                            if lhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt32.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt32.self).pointee { return false }

                        case .int64, .uint64, .float64:
                            if lhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt64.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt64.self).pointee { return false }

                        case .string:
                            let lstr = String(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rstr = String(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .crcString:
                            let lstr = CrcString(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rstr = CrcString(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .binary:
                            let lstr = Data(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rstr = Data(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .crcBinary:
                            let lstr = CrcBinary(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rstr = CrcBinary(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }

                        case .array, .sequence, .dictionary, .table:
                            let lportal = Portal(itemPtr: lhs._tableFieldPtr(row: ri, column: ci), manager: lhs.manager, endianness: lhs.endianness)
                            let rportal = Portal(itemPtr: rhs._tableFieldPtr(row: ri, column: ci), manager: rhs.manager, endianness: rhs.endianness)
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
            case .crcString: return lhs.crcString == rhs.crcString
            case .binary: return lhs.binary == rhs.binary
            case .crcBinary: return lhs.crcBinary == rhs.crcBinary
            case .array, .dictionary, .sequence, .table:
                let lPortal = Portal(itemPtr: lhs._arrayElementPtr(for: lhs.index!), index: nil, manager: lhs.manager, endianness: lhs.endianness)
                let rPortal = Portal(itemPtr: rhs._arrayElementPtr(for: rhs.index!), index: nil, manager: rhs.manager, endianness: rhs.endianness)
                return lPortal == rPortal
            }
        }
    }
}




// MARK: - Memory management

extension Portal {
    
    
    /// Returns a pointer to the start of the value field or the small-value field depending on the value type the portal refers to.
    
    internal var valueFieldPtr: UnsafeMutableRawPointer {
        if let index = index {
            if let column = column {
                return _tableFieldPtr(row: index, column: column)
            } else {
                return _arrayElementPtr(for: index)
            }
        } else {
            return itemValueFieldPtr
        }
    }
    
    
    /// Returns the number of bytes that are currently available for the value this portal offers access to.
    
    internal var actualValueFieldByteCount: Int {
        return _itemByteCount - itemMinimumByteCount - _itemNameFieldByteCount
    }
    
    
    /// Returns the number of bytes that are currently needed to represent the value in an item.
    
    internal var usedValueFieldByteCount: Int {
        switch itemType! {
        case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32: return 0
        case .int64, .uint64, .float64: return 8
        case .string: return _stringValueFieldUsedByteCount
        case .crcString: return _crcStringValueFieldUsedByteCount
        case .binary: return _binaryValueFieldUsedByteCount
        case .crcBinary: return _crcBinaryValueFieldUsedByteCount
        case .array: return _arrayValueFieldUsedByteCount
        case .dictionary: return _dictionaryValueFieldUsedByteCount
        case .sequence: return _sequenceValueFieldUsedByteCount
        case .table: return _tableValueFieldUsedByteCount
        }
    }

    
    /// Ensures that the item can accomodate a value of the given length.
    ///
    /// - Parameter for: The number of bytes needed.
    ///
    /// - Returns: True if the item or element has sufficient bytes available.
    
    internal func ensureValueFieldByteCount(of bytes: Int) -> Result {
        
        
        // If the current value field byte count is sufficient, return immediately
        
        if actualValueFieldByteCount >= bytes { return .success }
        
        
        // The byte count should be increased
        
        let necessaryItemByteCount = itemMinimumByteCount + _itemNameFieldByteCount + bytes
        
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
                    
                    let necessaryParentItemByteCount = arrayMinimumItemByteCount + parent._arrayElementCount * newByteCount
                    
                    
                    // Check if the parent item byte count must be increased
                    
                    if parent._itemByteCount < necessaryParentItemByteCount {
                        
                        let result = parent.increaseItemByteCount(to: necessaryParentItemByteCount)
                        guard result == .success else { return result }
                    }
                    
                    
                    // Increase the byte count of the elements of the parent
                    
                    parent._arrayIncreaseElementByteCount(to: newByteCount)
                }
                
                
                // Only update the new byte count for self, other elements will be updated when necessary.
                
                _itemByteCount = newByteCount
                
                return .success
                
            } else if parent.isDictionary {
                
                
                // Check if the byte count of the parent must be grown
                
                let necessaryParentItemByteCount = itemMinimumByteCount + parent._itemNameFieldByteCount + parent.actualValueFieldByteCount - _itemByteCount + newByteCount
                
                if parent._itemByteCount < necessaryParentItemByteCount {

                    let result = parent.increaseItemByteCount(to: necessaryParentItemByteCount)
                    guard result == .success else { return result }
                }
                
                
                // Increase the size of self, first copy all the items above this item out of reach
                
                let srcPtr = itemPtr.advanced(by: _itemByteCount)
                let pastLastItemPtr = parent._dictionaryAfterLastItemPtr
                if srcPtr != pastLastItemPtr {
                    
                    // Items must be moved
                    
                    let len = pastLastItemPtr - srcPtr
                    let dstPtr = srcPtr.advanced(by: newByteCount - _itemByteCount)
                    
                    manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
                }
                
                
                // Now the size of self can be increased

                _itemByteCount = newByteCount
                
                
                return .success
                
            } else if parent.isSequence {

                // Check if the byte count of the parent must be grown
                
                let necessaryParentItemByteCount = itemMinimumByteCount + parent._itemNameFieldByteCount + parent.actualValueFieldByteCount - _itemByteCount + newByteCount
                
                if parent._itemByteCount < necessaryParentItemByteCount {
                    
                    let result = parent.increaseItemByteCount(to: necessaryParentItemByteCount)
                    guard result == .success else { return result }
                }
                
                
                // Increase the size of self, first copy all the items above this item out of reach
                
                let srcPtr = itemPtr.advanced(by: _itemByteCount)
                let pastLastItemPtr = parent._sequenceAfterLastItemPtr
                if srcPtr != pastLastItemPtr {
                    
                    // Items must be moved
                    
                    let len = pastLastItemPtr - srcPtr
                    let dstPtr = srcPtr.advanced(by: newByteCount - _itemByteCount)
                    
                    manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
                }

                
                // Increase the byte count of self
                
                _itemByteCount = newByteCount

                
                return .success
                
                
            } else if parent.isTable {
                
                // The column index could be nil if the column contains a container and the container must grow in size.
                // So determine the column index by searching for it.
                
                let rowColOffset = parent.itemValueFieldPtr.distance(to: itemPtr)
                let colOffset = rowColOffset % parent._tableRowByteCount
                
                var columnIndex: Int?
                for i in 0 ..< parent._tableColumnCount {
                    if colOffset == parent._tableGetColumnFieldOffset(for: i) { columnIndex = i; break }
                }
                
                assert(columnIndex != nil)
                
                
                // Check if the column is big enough (or is made bigger)
                
                return parent._tableEnsureColumnValueByteCount(of: newByteCount, in: columnIndex!)

                
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
            
            _itemByteCount = newByteCount
            
            
            return .success
        }
    }
}


// MARK: - Hierarchy traversing

extension Portal {

    
    /// Returns the pointer to the parent item. If there is no parent item, it returns a pointer to the item this portal refers to.
    
    internal var parentPtr: UnsafeMutableRawPointer {
        return manager.bufferPtr.advanced(by: _itemParentOffset)
    }
    
    
    /// Returns the parent as a new portal. Returns nil if there is no parent.
    
    internal var parentPortal: Portal? {
        if parentPtr == itemPtr { return nil }
        return Portal(itemPtr: parentPtr, manager: manager, endianness: endianness)
    }

    
    /// Returns a portal refering to the first item for a given name.
    ///
    /// - Returns: nil if the name cannot be found.
    
    internal func findPortalForItem(withName name: String) -> Portal? {
        
        guard let nameData = name.data(using: .utf8) else { return nil }
        
        let crc = nameData.crc16()
        
        return findPortalForItem(with: crc, utf8ByteCode: nameData)
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
            if $0._itemNameCrc != hash { return false }
            if $0._itemNameUtf8CodeByteCount != utf8ByteCode.count { return false }
            if $0._itemNameUtf8Code != utf8ByteCode { return false }
            ptrFound = $0.itemPtr
            return true
        }
        
        if let aptr = ptrFound {
            return Portal(itemPtr: aptr, manager: manager, endianness: endianness)
        } else {
            return nil
        }
    }
    
    
    /// A pointer to the first byte after the item this portal refers to.
    
    internal var _itemAfterItemPtr: UnsafeMutableRawPointer {
        return itemPtr.advanced(by: _itemByteCount)
    }
    
    /// Returns a pointer to the next byte after the last item in a dictionary or sequence.
/*
    internal var _afterLastItemPtr: UnsafeMutableRawPointer {
        var ptr = itemValueFieldPtr
        var remainder = isDictionary ? _dictionaryItemCount : _sequenceItemCount
        while remainder > 0 {
            ptr = ptr.advanced(by: Int(UInt32(fromPtr: ptr.advanced(by: itemByteCountOffset), endianness)))
            remainder -= 1
        }
        return ptr
    }*/
    
    
    /// The closure is called for each child item or until the closure returns true.
    ///
    /// - Parameter closure: The closure that is called for each item in the dictionary. If the closure returns true then the processing of further items is aborted. Note that the portals passed to the closure are not registered with the active portals in the ItemManager. (To obtain a managed activePortal, use the '.portal' accessor)
    
    internal func forEachAbortOnTrue(_ closure: (Portal) -> Bool) {
        
        if isArray {
            
            let nofChildren = _arrayElementCount
            var index = 0
            while index < nofChildren {
                let portal = Portal(itemPtr: itemPtr, index: index, manager: manager, endianness: endianness)
                if closure(portal) { return }
                index += 1
            }
    
        } else if isDictionary {
            
            var aPtr = itemValueFieldPtr.advanced(by: dictionaryItemBaseOffset)
            var remainder = _dictionaryItemCount
            while remainder > 0 {
                let portal = Portal(itemPtr: aPtr, manager: manager, endianness: endianness)
                if closure(portal) { return }
                aPtr = aPtr.advanced(by: portal._itemByteCount)
                remainder -= 1
            }
            
        } else if isSequence {
            
            var aPtr = itemValueFieldPtr.advanced(by: sequenceItemBaseOffset)
            var remainder = _sequenceItemCount
            while remainder > 0 {
                let portal = Portal(itemPtr: aPtr, manager: manager, endianness: endianness)
                if closure(portal) { return }
                aPtr = aPtr.advanced(by: portal._itemByteCount)
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
    
    
    /// Returns true if the value accessable through this portal is a Null.
    
    public var isNull: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.null }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.null.rawValue
    }
    

    /// Returns true if the value accessable through this portal is a Bool.

    public var isBool: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.bool }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.bool.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.bool.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is an UInt8.

    public var isUInt8: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint8 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint8.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint8.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is an UInt16.

    public var isUInt16: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint16 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint16.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint16.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is an UInt32.

    public var isUInt32: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint32 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint32.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint32.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is an UInt64.

    public var isUInt64: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.uint64 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint64.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.uint64.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is an Int8.

    public var isInt8: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int8 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int8.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is an Int16.

    public var isInt16: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int16 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int16.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int16.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is an Int32.

    public var isInt32: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int32 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int32.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int32.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is an Int64.

    public var isInt64: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.int64 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int64.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.int64.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a Float32.

    public var isFloat32: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.float32 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float32.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a Float64.

    public var isFloat64: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.float64 }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float64.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.float64.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a String.

    public var isString: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.string }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a CrcString.

    public var isCrcString: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.crcString }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.crcString.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.crcString.rawValue
    }

    
    /// Returns true if the value accessable through this portal is a Binary.

    public var isBinary: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.binary }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue
    }

    
    /// Returns true if the value accessable through this portal is a CrcBinary.
    
    public var isCrcBinary: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.crcBinary }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.crcBinary.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.crcBinary.rawValue
    }

    
    /// Returns true if the value accessable through this portal is an Array.

    public var isArray: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.array }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.array.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a Dictionary.

    public var isDictionary: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.dictionary }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.dictionary.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.dictionary.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a Sequence.

    public var isSequence: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.sequence }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.sequence.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.sequence.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a Table.

    public var isTable: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.table }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.table.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.table.rawValue
    }
    
    
    /// Returns true if the value accessable through the portal is a null
    
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
    
    
    /// Access the value through the portal as a Bool
    
    public var bool: Bool? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isBool else { fatalOrNull("Attempt to access \(itemType) as a bool"); return nil }
            return Bool(fromPtr: valueFieldPtr, endianness)
        }
        set { assistSmallValueAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as an UInt8

    public var uint8: UInt8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isUInt8 else { fatalOrNull("Attempt to access \(itemType) as a UInt8"); return nil }
            return UInt8(fromPtr: valueFieldPtr, endianness)
        }
        set { assistSmallValueAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as an UInt16

    public var uint16: UInt16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isUInt16 else { fatalOrNull("Attempt to access \(itemType) as a UInt16"); return nil }
            return UInt16(fromPtr: valueFieldPtr, endianness)
        }
        set { assistSmallValueAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as an UInt32

    public var uint32: UInt32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isUInt32 else { fatalOrNull("Attempt to access \(itemType) as a UInt32"); return nil }
            return UInt32(fromPtr: valueFieldPtr, endianness)
        }
        set { assistSmallValueAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as an UInt64

    public var uint64: UInt64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isUInt64 else { fatalOrNull("Attempt to access \(itemType) as a UInt64"); return nil }
            return UInt64(fromPtr: valueFieldPtr, endianness)
        }
        set { assistValueFieldAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as an Int8

    public var int8: Int8? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isInt8 else { fatalOrNull("Attempt to access \(itemType) as a Int8"); return nil }
            return Int8(fromPtr: valueFieldPtr, endianness)
        }
        set { assistSmallValueAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as an Int16

    public var int16: Int16? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isInt16 else { fatalOrNull("Attempt to access \(itemType) as a Int16"); return nil }
            return Int16(fromPtr: valueFieldPtr, endianness)
        }
        set { assistSmallValueAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as an Int32

    public var int32: Int32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isInt32 else { fatalOrNull("Attempt to access \(itemType) as a Int32"); return nil }
            return Int32(fromPtr: valueFieldPtr, endianness)
        }
        set { assistSmallValueAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as an Int64

    public var int64: Int64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isInt64 else { fatalOrNull("Attempt to access \(itemType) as a Int64"); return nil }
            return Int64(fromPtr: valueFieldPtr, endianness)
        }
        set { assistValueFieldAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as a Float32

    public var float32: Float32? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isFloat32 else { fatalOrNull("Attempt to access \(itemType) as a Float32"); return nil }
            return Float32(fromPtr: valueFieldPtr, endianness)
        }
        set { assistSmallValueAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as a Float64

    public var float64: Float64? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isFloat64 else { fatalOrNull("Attempt to access \(itemType) as a Float64"); return nil }
            return Float64(fromPtr: valueFieldPtr, endianness)
        }
        set { assistValueFieldAssignment(newValue) }
    }
    
    
    /// Access the value through the portal as a String

    public var string: String? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isString else { fatalOrNull("Attempt to access \(itemType) as a String"); return nil }
            return String(fromPtr: valueFieldPtr, endianness)
        }
        set { assistValueFieldAssignment(newValue) }
    }
    
    
    
    /// Access the value through the portal as a BrbonString

    public var crcString: CrcString? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isCrcString else { fatalOrNull("Attempt to access \(itemType) as a CrcString"); return nil }
            return CrcString(fromPtr: valueFieldPtr, endianness)
        }
        set { assistValueFieldAssignment(newValue) }
    }

    
    /// Access the value through the portal as a Binary

    public var binary: Data? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isBinary else { fatalOrNull("Attempt to access \(itemType) as a Binary"); return nil }
            return Data(fromPtr: valueFieldPtr, endianness)
        }
        set { assistValueFieldAssignment(newValue) }
    }
    

    /// Access the value through the portal as a CrcBinary

    public var crcBinary: CrcBinary? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isCrcBinary else { fatalOrNull("Attempt to access \(itemType) as a CrcBinary"); return nil }
            return CrcBinary(fromPtr: valueFieldPtr, endianness)
        }
        set { assistValueFieldAssignment(newValue) }
    }
    
    
    /// General purpose assignment assistance for small-value setters.
    ///
    /// Despite its name, the assignment may well be to a table element or column field. But there will be no calls made to ensure the size of the value field.
    
    private func assistSmallValueAssignment(_ newValue: Coder!) {
        
        guard isValid else { fatalOrNull("Portal is no longer valid"); return }
        
        if index != nil {
            
            guard let newValue = newValue, newValue.itemType == valueType else {
                fatalOrNull("Type change not allowed")
                return
            }
                
            newValue.storeValue(atPtr: valueFieldPtr, endianness)
        
        } else {
            
            if let newValue = newValue {
                
                if !isNull {
                    if newValue.itemType != valueType {
                        fatalOnTypeChange()
                        changeSelfToNull()
                    }
                }
                
                itemType = .string
                
                newValue.storeValue(atPtr: itemValueFieldPtr, endianness)
                
            } else {
                
                changeSelfToNull()
            }
        }
        
    }

    /// General purpose assignment assistance for setters.
    
    private func assistValueFieldAssignment(_ newValue: Coder!) {
        
        guard isValid else { fatalOrNull("Portal is no longer valid"); return }

        if let index = index {
            
            if let column = column {
                
                guard let newValue = newValue, newValue.itemType == valueType else {
                    fatalOrNull("Column type change not allowed")
                    return
                }
                
                guard _tableEnsureColumnValueByteCount(of: newValue.valueByteCount, in: column) == .success else {
                    fatalOrNull("Could not allocate additional memory")
                    return
                }
                
                newValue.storeValue(atPtr: _tableFieldPtr(row: index, column: column), endianness)
                
            } else {
                
                guard let newValue = newValue, newValue.itemType == valueType else {
                    fatalOrNull("Element type change not allowed (is: \(itemType))")
                    return
                }
                
                guard _arrayEnsureElementByteCount(for: newValue) == .success else {
                    fatalOrNull("Could not allocate additional memory")
                    return
                }
                
                newValue.storeValue(atPtr: _arrayElementPtr(for: index), endianness)
            }
        } else {
            
            if let newValue = newValue {
                
                if !isNull {
                    if newValue.itemType != valueType {
                        fatalOnTypeChange()
                        changeSelfToNull()
                    }
                }
                
                itemType = .string
                
                guard ensureValueFieldByteCount(of: newValue.valueByteCount) == .success else {
                    fatalOrNull("Could not allocate additional memory")
                    return
                }
                
                newValue.storeValue(atPtr: itemValueFieldPtr, endianness)
                
            } else {
                
                changeSelfToNull()
            }
        }
        
    }

    
    /// Changes the type of self to a null.
    ///
    /// If self is a container, all portals for the contained items and elements are removed from the active portal list.
    
    internal func changeSelfToNull(_ removeSelf: Bool = false) {
        if isArray || isDictionary || isSequence {
            forEachAbortOnTrue({ $0.changeSelfToNull(true); return false })
        }
        if removeSelf {
            manager.removeActivePortal(self)
        }
    }
}
