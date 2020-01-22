// =====================================================================================================================
//
//  File:       Portal.swift
//  Project:    BRBON
//
//  Version:    1.2.3
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2019 Marinus van der Lugt, All rights reserved.
//
//  License:    Use or redistribute this code any way you like with the following two provision:
//
//  1) You ACCEPT this source code AS IS without any guarantees that it will work as intended. Any liability from its
//  use is YOURS.
//
//  2) You WILL NOT seek damages from the author or balancingrock.nl.
//
//  I also ask you to please leave this header with the source code.
//
//  Like you, I need to make a living:
//
//   - You can send payment (you choose the amount) via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
// PLEASE let me know about bugs, improvements and feature requests. (rien@balancingrock.nl)
// =====================================================================================================================
//
// History
//
// 1.2.3 - Wrapped all ptest functions in conditional compilation
// 1.2.2 - Added code for runtime pointer checks when compiler condition PTEST is active
//       - Bugfix for updating the itemByteCount of container fields in tables
// 1.2.1 - Bugfix for table output
// 1.2.0 - Added CustomStringConvertable and CustomDebugStringConvertable
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


/// A portal is an access point for items in the BRBON data structure. It hides the implementation of the BRBON data structure and provides an API to manipulate the contents.
///
/// While the BRBON structure will undergo changes and shift in memory, the portal for an item will always point to the correct item. Until the item is removed, then the portal becomes invalid. When a portal is invalid, it will return nil on most operations.
///
/// Note that is it not necessary to use portals. But there is a performance advantage for using portals if a BRBON hierachy is largely stable. If however the root item hierachy changes a lot (adding and changing data size) then using a lot of portals may slow down access when items are added or increased in size. See the document on performance issues.

public final class Portal {

    #if PTEST
    /// The ptest must be disabled when moving portals
    
    static var ptest_enabled = true
    
    
    /// Tests if the ptr is between itemPtr and itemPtr + _itemByteCount
    
    func ptest_ptrInItemTest(_ ptr: UnsafeMutableRawPointer) {
        if ptest_itemPtr > ptr {
            fatalError("Illegal value: \(ptr) vs range \(ptest_itemPtr) .. \(ptest_itemPtr.advanced(by: Int(ptest_itemPtr.itemByteCount(machineEndianness))))")
        }
        if ptr > ptest_itemPtr.advanced(by: Int(ptest_itemPtr.itemByteCount(machineEndianness))) {
            fatalError("Illegal value: \(ptr) vs range \(ptest_itemPtr) .. \(ptest_itemPtr.advanced(by: Int(ptest_itemPtr.itemByteCount(machineEndianness))))")
        }
    }
    
    func ptest_ptrInItemTest(_ ptr: UnsafeMutableRawPointer, _ count: Int) {
        ptest_ptrInItemTest(ptr)
        ptest_ptrInItemTest(ptr.advanced(by: count))
    }

    func ptest_itemPtrValidTest() {
        if !isValid { return }
        if manager == nil { fatalError("Manager should not be nil") }
        if ptest_itemPtr < manager.bufferPtr {
            fatalError("Illegal value: \(ptest_itemPtr) vs range \(manager.bufferPtr) .. \(manager.bufferPtr.advanced(by: manager.buffer.count))")
        }
        if ptest_itemPtr.advanced(by: Int(ptest_itemPtr.itemByteCount(machineEndianness))) > manager.bufferPtr.advanced(by: manager.buffer.count) {
            fatalError("Illegal value: \(ptest_itemPtr) vs range \(manager.bufferPtr) .. \(manager.bufferPtr.advanced(by: manager.buffer.count))")
        }
    }
    #endif
    
    /// This pointer points to the first byte of the item.
    //
    // It is a 'var' because the pointer value must be updated when the data is shifted around by insert/add/remove operations.

    #if PTEST
    internal var itemPtr: UnsafeMutableRawPointer
    {
        get {
            if Portal.ptest_enabled { ptest_itemPtrValidTest() }
            return ptest_itemPtr
        }
        set {
            ptest_itemPtr = newValue
            if Portal.ptest_enabled { ptest_itemPtrValidTest() }
        }
    }
    private var ptest_itemPtr: UnsafeMutableRawPointer
    #else
    internal var itemPtr: UnsafeMutableRawPointer
    #endif
    
    /// If the portal refers to an element of an array, or a row in a table, then this is the index of that element/row.

    public let index: Int?
    
    
    /// If the portal refers to a field of a table, this is the index of the column.
    
    public let column: Int?

    
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
        #if PTEST
        self.ptest_itemPtr = itemPtr
        #else
        self.itemPtr = itemPtr
        #endif
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
    
    
    /// The null portal is used to avoid an excess of unwrapping for the API user. API calls that must return a portal can return the null portal instead of returning nil.
    
    public static var nullPortal: Portal = {
        let p = Portal(itemPtr: UnsafeMutableRawPointer(bitPattern: 1)!, endianness: machineEndianness)
        p.isValid = false
        return p
    }()
    
    
    /// Initializer for the nullPortal and ephemeral portals.
    
    internal init(itemPtr: UnsafeMutableRawPointer, endianness: Endianness) {
        isValid = true
        index = nil
        column = nil
        self.endianness = endianness
        #if PTEST
        self.ptest_itemPtr = itemPtr
        #else
        self.itemPtr = itemPtr
        #endif
    }
    
    
    /// The number of child-items, elements or rows in the referenced item
    
    public var count: Int {
        guard isValid else { return 0 }
        switch itemType! {
        case .null, .bool, .int8, .int16, .int32, .int64, .uint8, .uint16, .uint32, .uint64, .float32, .float64, .string, .crcString, .binary, .crcBinary, .uuid, .color, .font: return 0
        case .dictionary: return _dictionaryItemCount
        case .sequence: return _sequenceItemCount
        case .array: return _arrayElementCount
        case .table: return _tableRowCount
        }
    }
    
    
    /// The key for this portal as used by the active portals manager
    
    internal var key: PortalKey { return PortalKey(itemPtr: itemPtr, index: index, column: column) }
    
    
    /// The NameField for this item, nil if there is none.
    
    public var itemNameField: NameField? {
        get {
            guard _itemNameFieldByteCount > 0 else { return nil }
            return NameField(fromPtr: itemPtr.itemNameFieldPtr, withFieldCount: _itemNameFieldByteCount, endianness)
        }
        set { _ = updateItemName(to: newValue) }
    }
}


// MARK: - Memory management

extension Portal {
    
    
    /// Returns a pointer to the start of the value field or the small-value field depending on the value type the portal refers to.
    
    internal var _valuePtr: UnsafeMutableRawPointer {
        get {
            if let index = index {
                if let column = column {
                    #if PTEST
                    let ptr = itemPtr.itemValueFieldPtr.tableFieldPtr(row: index, column: column, endianness)
                    ptest_ptrInItemTest(ptr)
                    return ptr
                    #else
                    return itemPtr.itemValueFieldPtr.tableFieldPtr(row: index, column: column, endianness)
                    #endif
                } else {
                    #if PTEST
                    let ptr = itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness)
                    ptest_ptrInItemTest(ptr)
                    return ptr
                    #else
                    return itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness)
                    #endif
                }
            } else {
                if itemType!.usesSmallValue {
                    #if PTEST
                    let ptr = itemPtr.itemSmallValuePtr
                    ptest_ptrInItemTest(ptr)
                    return ptr
                    #else
                    return itemPtr.itemSmallValuePtr
                    #endif
                } else {
                    #if PTEST
                    let ptr = itemPtr.itemValueFieldPtr
                    ptest_ptrInItemTest(ptr)
                    return ptr
                    #else
                    return itemPtr.itemValueFieldPtr
                    #endif
                }
            }
        }
        set {} // Empty setter allows updating of the pointee
    }
    
    
    /// Returns the number of bytes that are currently available for the value this portal offers access to.
    
    internal var currentValueFieldByteCount: Int {
        return _itemByteCount - itemHeaderByteCount - _itemNameFieldByteCount
    }
    
    
    /// Returns the number of bytes that are currently needed to represent the value in an item.
    
    internal var usedValueFieldByteCount: Int {
        switch itemType! {
        case .null, .bool, .int8, .uint8, .int16, .uint16, .int32, .uint32, .float32: return 0
        case .int64, .uint64, .float64: return 8
        case .uuid, .color: return 16
        case .font: return _fontValueFieldUsedByteCount
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

    
    /// Ensures that the specified number of bytes can be stored at the value pointer.
    
    internal func ensureStorageAtValuePtr(of bytes: Int) -> Result {
        if index == nil {
            if currentValueFieldByteCount < bytes {
                return increaseItemByteCount(to: itemHeaderByteCount + _itemNameFieldByteCount + bytes)
            } else {
                return .success
            }
        } else if let column = column {
            return _tableEnsureColumnValueByteCount(of: bytes, in: column)
        } else {
            return _arrayEnsureElementByteCount(of: bytes)
        }
    }

    
    /// Increases the byte count of the item. Note that the actual number of bytes of the item will always be a multiple of 8.
    ///
    /// This operation might affect the itemByteCount and elementByteCount of multiple items if self is contained in other items. This can result in a total size increase many times the value in this call.
    ///
    /// This operation might fail if an upstream item cannot be increased in byte count.
    ///
    /// - Parameter to: The requested number of bytes for this item. Range 0 ... Int32.max. Will be rounded up to a multiple of 8 if necessary.
    ///
    /// - Returns:
    ///   success: If the operation succeeded.
    ///
    ///   error(code): When the operation failed, the code indicates the cause.
    
    internal func increaseItemByteCount(to bytes: Int) -> Result {
        
        let newByteCount = bytes.roundUpToNearestMultipleOf8()
        
        if newByteCount > Int(Int32.max) { return .error(.itemByteCountOutOfRange) }
        
        if let parent = parentPortal {
            
            
            // Check if the parent is an array
            
            if parent.isArray {
                
                
                // Check if the element byte count of the array must be grown
                
                if parent._arrayElementByteCount < newByteCount {
                    
                    
                    // Calculate the necessary byte count for the parent array
                    
                    let necessaryParentItemByteCount = itemHeaderByteCount + arrayElementBaseOffset + parent._arrayElementCount * newByteCount
                    
                    
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
                
                let necessaryParentItemByteCount = itemHeaderByteCount + parent._itemNameFieldByteCount + parent.currentValueFieldByteCount - _itemByteCount + newByteCount
                
                if parent._itemByteCount < necessaryParentItemByteCount {
                    let result = parent.increaseItemByteCount(to: necessaryParentItemByteCount)
                    guard result == .success else { return result }
                }
                
                
                // Increase the size of self, first copy all the items above this item out of reach
                
                let srcPtr = itemPtr.nextItemPtr(endianness)
                let pastLastItemPtr = parent._dictionaryAfterLastItemPtr
                let len = srcPtr.distance(to: pastLastItemPtr)
                if len > 0 {
                    
                    // Items must be moved
                    let dstPtr = itemPtr.advanced(by: newByteCount)
                    
                    manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)


                    // Set extra bytes in self conditionally to zero
                    
                    if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(srcPtr, 0, srcPtr.distance(to: dstPtr)) }
                }
                
                
                // Now the size of self can be increased

                _itemByteCount = newByteCount
                
                
                return .success
                
            } else if parent.isSequence {

                // Check if the byte count of the parent must be grown
                
                let necessaryParentItemByteCount = itemHeaderByteCount + parent._itemNameFieldByteCount + parent.currentValueFieldByteCount + newByteCount
                
                if parent._itemByteCount < necessaryParentItemByteCount {
                    
                    let result = parent.increaseItemByteCount(to: necessaryParentItemByteCount)
                    guard result == .success else { return result }
                }
                
                
                // Increase the size of self, first copy all the items above this item out of reach
                
                let srcPtr = itemPtr.nextItemPtr(endianness)
                let pastLastItemPtr = parent._sequenceAfterLastItemPtr
                let len = srcPtr.distance(to: pastLastItemPtr)
                if len > 0 {
                    
                    // Items must be moved
                    let dstPtr = itemPtr.advanced(by: newByteCount)
                    
                    manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
                    
                    
                    // Set extra bytes in self conditionally to zero
                    
                    if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(srcPtr, 0, srcPtr.distance(to: dstPtr)) }
                }

                
                // Increase the byte count of self
                
                _itemByteCount = newByteCount

                
                return .success
                
                
            } else if parent.isTable {
                
                // The column index could be nil if the column contains a container and the container must grow in size.
                // Determine the column index by searching for it.
                
                let rowColOffset = parent.itemPtr.itemValueFieldPtr.distance(to: itemPtr) - parent._tableRowsOffset
                let colOffset = rowColOffset % parent._tableRowByteCount
                
                var columnIndex: Int?
                for i in 0 ..< parent._tableColumnCount {
                    if colOffset == parent.itemPtr.itemValueFieldPtr.tableColumnFieldOffset(for: i, endianness) { columnIndex = i; break }
                }
                
                assert(columnIndex != nil)
                
                
                // Check if the column is big enough (or is made bigger)
                
                let result = parent._tableEnsureColumnValueByteCount(of: newByteCount, in: columnIndex!)
                
                if result == .success {
                    _itemByteCount = newByteCount
                }

                return result
                
            } else {
                
                return .error(.outOfStorage)
            }
            
            
        } else {
        
            // There is no parent, this must be the root item.

            
            // If the buffer manager cannot accomodate the increase of the item, then increase the buffer size.
            
            if manager.unusedByteCount < newByteCount {
                
                // Note: The following operation also updates all active portals
                
                guard manager.increaseBufferSize(to: newByteCount) else { return .error(.increaseFailed) }
            }
            
            
            // Zero the extra bytes conditionally
            
            if ItemManager.startWithZeroedBuffers {
                let extraBytes = newByteCount - _itemByteCount
                _ = Darwin.memset(itemPtr.advanced(by: _itemByteCount), 0, extraBytes)
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
        return manager.getActivePortal(for: parentPtr)
    }

    
    /// A pointer to the first byte after the item this portal refers to.
    
    internal var _itemAfterItemPtr: UnsafeMutableRawPointer {
        return itemPtr.advanced(by: _itemByteCount)
    }
    
    
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
            
            var aPtr = _itemValueFieldPtr.advanced(by: dictionaryItemBaseOffset)
            var remainder = _dictionaryItemCount
            while remainder > 0 {
                let portal = Portal(itemPtr: aPtr, manager: manager, endianness: endianness)
                if closure(portal) { return }
                aPtr = aPtr.advanced(by: portal._itemByteCount)
                remainder -= 1
            }
            
        } else if isSequence {
            
            var aPtr = _itemValueFieldPtr.advanced(by: sequenceItemBaseOffset)
            var remainder = _sequenceItemCount
            while remainder > 0 {
                let portal = Portal(itemPtr: aPtr, manager: manager, endianness: endianness)
                if closure(portal) { return }
                aPtr = aPtr.advanced(by: portal._itemByteCount)
                remainder -= 1
            }
        }
    }
    
    
    /// Calls the closure for each element of self if self is an array, dictionary or sequence.
    
    public func forEach(_ closure: (Portal) -> Void) {
        
        if isArray {
            
            let nofChildren = _arrayElementCount
            var index = 0
            while index < nofChildren {
                let portal = manager.getActivePortal(for: itemPtr, index: index, column: nil)
                closure(portal)
                index += 1
            }
            
        } else if isDictionary {
            
            var aPtr = _itemValueFieldPtr.advanced(by: dictionaryItemBaseOffset)
            var remainder = _dictionaryItemCount
            while remainder > 0 {
                let portal = manager.getActivePortal(for: aPtr)
                closure(portal)
                aPtr = aPtr.advanced(by: portal._itemByteCount)
                remainder -= 1
            }
            
        } else if isSequence {
            
            var aPtr = _itemValueFieldPtr.advanced(by: sequenceItemBaseOffset)
            var remainder = _sequenceItemCount
            while remainder > 0 {
                let portal = manager.getActivePortal(for: aPtr)
                closure(portal)
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
    
    public var portal: Portal? {
        guard isValid else { return nil }
        return manager.getActivePortal(for: itemPtr, index: index, column: column)
    }
    
    
    /// Returns true if the value accessable through this portal is an Array.

    public var isArray: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.array }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.array.rawValue }
        return itemPtr.itemType == ItemType.array.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a Dictionary.

    public var isDictionary: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.dictionary }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.dictionary.rawValue }
        return itemPtr.itemType == ItemType.dictionary.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a Sequence.

    public var isSequence: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.sequence }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.sequence.rawValue }
        return itemPtr.itemType == ItemType.sequence.rawValue
    }
    
    
    /// Returns true if the value accessable through this portal is a Table.

    public var isTable: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.table }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.table.rawValue }
        return itemPtr.itemType == ItemType.table.rawValue
    }
}


// MARK: - Text representation

extension Portal: CustomStringConvertible {
    
    fileprivate func valueDescription(prefix: String) -> String {
        switch itemType! {
        case .null: return "null"
        case .bool: return "\(bool!)"
        case .int8: return "\(int8!)"
        case .int16: return "\(int16!)"
        case .int32: return "\(int32!)"
        case .int64: return "\(int64!)"
        case .uint8: return "\(uint8!)"
        case .uint16: return "\(uint16!)"
        case .uint32: return "\(uint32!)"
        case .uint64: return "\(uint64!)"
        case .float32: return "\(float32!)"
        case .float64: return "\(float64!)"
        case .string: return "\(string!)"
        case .crcString: return "Crc: \(crc!), String: \(string!)"
        case .color: return "Red: \(_colorRed), Green: \(_colorGreen), Blue: \(_colorBlue), Alpha: \(_colorAlpha)"
        case .uuid: return "\(uuid!.uuidString)"
        case .font: return "Family: \(String(data: font!.familyNameUtf8Code!, encoding: .utf8) ?? "cannot make utf8"), Font: \(String(data: font!.fontNameUtf8Code, encoding: .utf8) ?? "cannot make utf8"), Size: \(font!.pointSize)"
        case .binary: return "Bytes: \(binary!.count)"
        case .crcBinary: return "Crc: \(crc!), Bytes: \(binary!.count)"
        
        case .array:
            var txt =
            """
            Element type  = \(self._arrayElementType!)
            Element bytes = \(self._arrayElementByteCount)
            Element count = \(self._arrayElementCount)
            Elements:\n
            """
            var i = 0
            forEach { (e) in
                switch _arrayElementType! {
                case .null: txt += "\(prefix)\(String(format: "%3d", i)): null\n"
                case .bool: txt += "\(prefix)\(String(format: "%3d", i)): \(e.bool!)\n"
                case .int8: txt += "\(prefix)\(String(format: "%3d", i)): \(e.int8!)\n"
                case .int16: txt += "\(prefix)\(String(format: "%3d", i)): \(e.int16!)\n"
                case .int32: txt += "\(prefix)\(String(format: "%3d", i)): \(e.int32!)\n"
                case .int64: txt += "\(prefix)\(String(format: "%3d", i)): \(e.int64!)\n"
                case .uint8: txt += "\(prefix)\(String(format: "%3d", i)): \(e.uint8!)\n"
                case .uint16: txt += "\(prefix)\(String(format: "%3d", i)): \(e.uint16!)\n"
                case .uint32: txt += "\(prefix)\(String(format: "%3d", i)): \(e.uint32!)\n"
                case .uint64: txt += "\(prefix)\(String(format: "%3d", i)): \(e.uint64!)\n"
                case .float32: txt += "\(prefix)\(String(format: "%3d", i)): \(e.float32!)\n"
                case .float64: txt += "\(prefix)\(String(format: "%3d", i)): \(e.float64!)\n"
                case .string: txt += "\(prefix)\(String(format: "%3d", i)): \(e.string!)\n"
                case .crcString: txt += "\(prefix)\(String(format: "%3d", i)): Crc: \(e.crc!), String: \(e.string!)\n"
                case .color: txt += "\(prefix)\(String(format: "%3d", i)): Red: \(e._colorRed), Green: \(e._colorGreen), Blue: \(e._colorBlue), Alpha: \(e._colorAlpha)\n"
                case .uuid: txt += "\(prefix)\(String(format: "%3d", i)): \(e.uuid!.uuidString)\n"
                case .font: txt += "\(prefix)\(String(format: "%3d", i)): Family: \(String(data: e.font!.familyNameUtf8Code!, encoding: .utf8) ?? "cannot make utf8"), Font: \(String(data: e.font!.fontNameUtf8Code, encoding: .utf8) ?? "cannot make utf8"), Size: \(e.font!.pointSize)\n"
                case .binary: txt += "\(prefix)\(String(format: "%3d", i)): Bytes: \(e.binary!.count)\n"
                case .crcBinary: txt += "\(prefix)\(String(format: "%3d", i)): Crc: \(e.crc!), Bytes: \(e.binary!.count)\n"
                case .array, .dictionary, .sequence, .table:
                    let subs = e.description(prefix: prefix).split(separator: "\n")
                    let pres = subs.map() { "\(prefix)\(prefix)\($0)" }
                    let all = pres.joined(separator: "\n")
                    txt += "\(prefix)\(String(format: "%3d", i)):\n\(all)\n"
                }
                i += 1
            }
            return txt
            
        case .dictionary:
            var txt =
            """
            Item count = \(self.count)
            Items:\n
            """
            forEach { (i) in
                let id = i.description(prefix: prefix)
                let subs = id.split(separator: "\n").map { "\(prefix)\($0)" }
                let tot = subs.joined(separator: "\n")
                txt += "\(prefix)\(i.itemName!):\n"
                txt += "\(tot)\n"
            }
            return txt
            
        case .sequence:
            var txt =
            """
            Item count = \(self.count)
            Items:\n
            """
            var i = 0
            forEach { (e) in
                let subs = e.description(prefix: prefix).split(separator: "\n")
                let pres = subs.map() { "\(prefix)\($0)" }
                let all = pres.joined(separator: "\n")
                txt +=
                """
                \(prefix)\(i):
                \(all)\n
                """
                i += 1
            }
            return txt
            
        case .table:
            var txt =
            """
            Row count    = \(self._tableRowCount)
            Row size     = \(self._tableRowByteCount)
            Column count = \(self._tableColumnCount)
            Columns:\n
            """
            self.itterateColumnSpecifications { (i, spec) in
                txt +=
                """
                \(prefix)index      = \(i)
                \(prefix)\(prefix)fieldName  = \(spec.nameField.string)
                \(prefix)\(prefix)fieldType  = \(spec.fieldType)
                \(prefix)\(prefix)fieldSize  = \(spec.fieldByteCount)\n
                """
            }
            txt +=
            """
            Row:\n
            """
            var row = 0
            while row < _tableRowCount {
                txt +=
                """
                \(prefix)\(String(format: "%3d", row)):\n
                """
                self.itterateFields(ofRow: row) { (field, col) -> Bool in
                    txt += "\(prefix)\(prefix)\(_tableGetColumnName(for: col)):"
                    switch _tableGetColumnType(for: col) {
                        case .null: txt += " null\n"
                        case .bool: txt += " \(field.bool!)\n"
                        case .int8: txt += " \(field.int8!)\n"
                        case .int16: txt += " \(field.int16!)\n"
                        case .int32: txt += " \(field.int32!)\n"
                        case .int64: txt += " \(field.int64!)\n"
                        case .uint8: txt += " \(field.uint8!)\n"
                        case .uint16: txt += " \(field.uint16!)\n"
                        case .uint32: txt += " \(field.uint32!)\n"
                        case .uint64: txt += " \(field.uint64!)\n"
                        case .float32: txt += " \(field.float32!)\n"
                        case .float64: txt += " \(field.float64!)\n"
                        case .string: txt += " \(field.string!)\n"
                    case .crcString: txt += " Crc: \(field.crc!), String: \(field.string!)\n"
                        case .color: txt += " Red: \(field._colorRed), Green: \(field._colorGreen), Blue: \(field._colorBlue), Alpha: \(field._colorAlpha)\n"
                        case .uuid: txt += " \(field.uuid!.uuidString)\n"
                    case .font: txt += " Family: \(String(data: field.font!.familyNameUtf8Code!, encoding: .utf8) ?? "cannot make utf8"), Font: \(String(data: field.font!.fontNameUtf8Code, encoding: .utf8) ?? "cannot make utf8"), Size: \(field.font!.pointSize)\n"
                        case .binary: txt += " Bytes: \(field.binary!.count)\n"
                        case .crcBinary: txt += " Crc: \(field.crc!), Bytes: \(field.binary!.count)\n"
                        case .array, .dictionary, .sequence, .table:
                            let subs = field.description(prefix: prefix).split(separator: "\n")
                            let pres = subs.map() { "\(prefix)\(prefix)\(prefix)\($0)" }
                            let all = pres.joined(separator: "\n")
                            txt += "\n\(all)\n"
                    }
                    return true
                }
                row += 1
            }
            return txt
        }
    }
    
    fileprivate func description(prefix: String) -> String {
        var txt = ""
        if isValid {
            txt +=
            """
            \(prefix)itemType       = \(itemType!)
            \(prefix)itemOptions    = \(itemOptions!)
            \(prefix)itemFlags      = \(itemFlags!)
            \(prefix)nameByteCount  = \(_itemNameFieldByteCount)
            \(prefix)itemByteCount  = \(_itemByteCount)
            \(prefix)itemValueField = \(String(format: "0x%08X", _itemSmallValue(endianness)))
            \(prefix)itemName       = \(itemName ?? "(none)")\n
            """
            switch itemType! {
            case .null, .bool, .int8, .int16, .int32, .int64, .uint8, .uint16, .uint32, .uint64, .float32, .float64, .string, .crcString, .binary, .crcBinary, .uuid, .color, .font:
                txt +=
                """
                \(prefix)value          = \(valueDescription(prefix: ""))
                """
            case .array, .dictionary, .sequence, .table:
                let subs = valueDescription(prefix: prefix).split(separator: "\n")
                let pres = subs.map() { "\(prefix)\(prefix)\($0)" }
                let all = pres.joined(separator: "\n")
                txt +=
                """
                \(prefix)value:
                \(all)
                """
            }
        }
        return txt
    }
    
    public var description: String {
        let prefix = "    "
        let txt =
        """
        Portal:
        \(prefix)isValid        = \(isValid)
        \(prefix)endianness     = \(endianness)
        \(prefix)index          = \(index != nil ? String(index!) : "nil")
        \(prefix)column         = \(column != nil ? String(column!) : "nil")
        \(prefix)refCount       = \(refCount)
        
        Item:\n
        """
        return txt + description(prefix: prefix)
    }
}


extension Portal: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}
