// =====================================================================================================================
//
//  File:       Portal.swift
//  Project:    BRBON
//
//  Version:    0.7.1
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2018 Marinus van der Lugt, All rights reserved.
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
//  I strongly believe that voluntarism is the way for societies to function optimally. Thus I have choosen to leave it
//  up to you to determine the price for this code. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  wishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to check the website http://www.balancingrock.nl before payment)
//
//  For private and non-profit use the suggested price is the price of 1 good cup of coffee, say $4.
//  For commercial use the suggested price is the price of 1 good meal, say $20.
//
//  You are however encouraged to pay more ;-)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// History
//
// 0.7.1 - Changed access level of index and column to public (necessary for table initializers)
// 0.7.0 - Code restructuring & simplification
//       - Added type .color and .font
// 0.5.0 - Migration to Swift 4
// 0.4.3 - Changed access levels for index and column
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================
//
// A Portal is an object through which access is gained to an item or element in a BRBON data structure.
// Portals can be used to read & write variables in the BRBON data structure as wel as for traversing the struture.
// When the data that the portal has access to is shifted, the portal is kept in-sync with the new location.
// Each BRBON item or element has only one portal instance associated with it. This instance will be shared and a reference count is kept to ensure that it is not removed prematurely. BRBON API users do not need concern themselves with this reference counting.

import Foundation
import BRUtils


/// A portal is an access point for items in the BRBON data structure. It hides the implementation of the BRBON data structure and provides an API to manipulate it at a higher abstraction level.

public final class Portal {
    
    
    /// This pointer points to the first byte of the item.
    //
    // It is a 'var' because the pointer value must be updated when the data is shifted around by insert/add/remove operations.
    
    internal var itemPtr: UnsafeMutableRawPointer
    
    
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
    
    
    // The null portal is used to avoid an excess of unwrapping for the API user. API calls that must return a portal can return the null portal instead of returning nil.
    
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
        self.itemPtr = itemPtr
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
                    return itemPtr.itemValueFieldPtr.tableFieldPtr(row: index, column: column, endianness)
                } else {
                    return itemPtr.itemValueFieldPtr.arrayElementPtr(for: index, endianness)
                }
            } else {
                if itemType!.usesSmallValue {
                    return itemPtr.itemSmallValuePtr
                } else {
                    return itemPtr.itemValueFieldPtr
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
                // So determine the column index by searching for it.
                
                let rowColOffset = parent.itemPtr.itemValueFieldPtr.distance(to: itemPtr) - parent._tableRowsOffset
                let colOffset = rowColOffset % parent._tableRowByteCount
                
                var columnIndex: Int?
                for i in 0 ..< parent._tableColumnCount {
                    if colOffset == parent.itemPtr.itemValueFieldPtr.tableColumnFieldOffset(for: i, endianness) { columnIndex = i; break }
                }
                
                assert(columnIndex != nil)
                
                
                // Check if the column is big enough (or is made bigger)
                
                return parent._tableEnsureColumnValueByteCount(of: newByteCount, in: columnIndex!)

                
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
