// =====================================================================================================================
//
//  File:       ItemManager
//  Project:    BRBON
//
//  Version:    1.3.4
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2020 Marinus van der Lugt, All rights reserved.
//
//  License:    MIT, see LICENSE file
//
//  And because I need to make a living:
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
// 1.3.4 - Limited Cocoa dependency to macOS only
// 1.3.2 - Updated LICENSE
// 1.3.1 - Linux compatibility
// 1.2.2 - Added code for runtime pointer checks when compiler condition PTEST is active
//         Fixed a bug in an assert statement
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils

#if os(macOS)

    import Cocoa

#endif

#if os(Linux)

    import Glibc

#endif

/// This key is used to keep track of active portals. Active portals are tracked by the item manager to update the portals when data is shifted and to invalidate them when the data has been removed.

internal struct PortalKey: Equatable, Hashable {
    let itemPtr: UnsafeMutableRawPointer
    let index: Int?
    let column: Int?
    static func == (lhs: PortalKey, rhs: PortalKey) -> Bool {
        return (lhs.itemPtr == rhs.itemPtr) && (lhs.index == rhs.index) && (lhs.column == rhs.column)
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(itemPtr)
        if let index = index { hasher.combine(index) }
        if let column = column { hasher.combine(column) }
    }
}


/// This struct is used to keep track of the number of portals that have been returned to the API user.

fileprivate class ActivePortals {
    
    
    /// The dictionary that associates an item pointer with a valueItem entry
    
    var dict: Dictionary<PortalKey, Portal> = [:]
    
    
    /// A pointer back to the manager that owns the active portals
    
    unowned var manager: ItemManager
    
    
    /// Create a new active portals object.
    
    init(manager: ItemManager) {
        self.manager = manager
    }
    
    
    /// Return the portal for the given parameters. A new one is created if it was not found in the dictionary.
    
    func getPortal(for ptr: UnsafeMutableRawPointer, index: Int? = nil, column: Int? = nil) -> Portal {
        let newPortal = Portal(itemPtr: ptr, index: index, column: column, manager: manager, endianness: manager.endianness)
        let portalKey = newPortal.key
        if let portal = dict[portalKey], portal.isValid {
            portal.refCount += 1
            return portal
        } else {
            newPortal.refCount += 1
            dict[newPortal.key] = newPortal
            return newPortal
        }
    }
    

    /// Inactivates and remove this portal from the active portals list and all portals that may refer to the contents of the item this portal refers to.

    func remove(_ portal: Portal) {
        
        // Remove any portal that may be contained inside an item or element within this portal
        
        let startAddress: UnsafeMutableRawPointer
        let endAddress: UnsafeMutableRawPointer
        
        if let column = portal.column, let index = portal.index {
            
            // Setup for remval of all portals in the content area
            startAddress = portal.itemPtr.itemValueFieldPtr.tableFieldPtr(row: index, column: column, portal.endianness)
            endAddress = startAddress.advanced(by: Int(portal.itemPtr.itemValueFieldPtr.tableColumnFieldByteCount(for: column, portal.endianness)))
            
            // Remove the portal itself
            portal.isValid = false
            dict.removeValue(forKey: portal.key)
        
        } else if let index = portal.index {
            
            // Setup for removal of all portals in the content area
            startAddress = portal._valuePtr.arrayElementPtr(for: index, portal.endianness)
            endAddress = startAddress.advanced(by: portal._arrayElementByteCount)

            // Remove the portal itself
            portal.isValid = false
            dict.removeValue(forKey: portal.key)
            
        } else {
            
            // Setup the portal itself for removal
            startAddress = portal.itemPtr
            endAddress = startAddress.advanced(by: portal._itemByteCount)
        }
        
        for (key, value) in dict {
            if value.itemPtr >= startAddress && value.itemPtr < endAddress {
                value.isValid = false
                dict.removeValue(forKey: key)
            }
        }
    }
    
    
    /// Inactivates and removes all portals that have an itemPtr that is equal to or above the first value and lower than the second value.
    ///
    /// Note: Element and Field portals refer to their parent item in their itemPtr.
    
    func removePortals(atAndAbove: UnsafeMutableRawPointer, below: UnsafeMutableRawPointer) {
        
        for (key, portal) in dict {

            if portal.itemPtr >= atAndAbove && portal.itemPtr < below {
            
                portal.isValid = false
                dict.removeValue(forKey: key)

            } else {
                
                if portal.index != nil {
                    
                    // table and array handling
                    
                    let ptr = portal._valuePtr
                    
                    if ptr >= atAndAbove && ptr < below {
                        portal.isValid = false
                        dict.removeValue(forKey: key)
                    }
                }
            }
        }
    }
    
    
    /// Update the active portals
    
    func updatePointers(atAndAbove: UnsafeMutableRawPointer, below: UnsafeMutableRawPointer, toNewBase: UnsafeMutableRawPointer) {
        // Note that the portals that need changing will modify their key. Key updates must be implemented through removal under the old key and adding under the new key. However doing that in the same dictionary will cause problems since the new keys may overlap with existing (as yet unmodified) keys due to (temporary) address duplication. Hence all keys are copied from one directory to another while updating the keys that need changing.
        var newDict: Dictionary<PortalKey, Portal> = [:]
        let delta = atAndAbove.distance(to: toNewBase)
        dict.forEach() { (_, portal) in
            if portal.itemPtr >= atAndAbove && portal.itemPtr < below {
                portal.itemPtr = portal.itemPtr.advanced(by: delta)
            }
            newDict[portal.key] = portal
        }
        dict = newDict
    }

    
    /// Decrement the reference counter of a portal and remove the entry of the refcount reaches zero.
    
    func decrementRefcountAndRemoveOnZero(for portal: Portal) {
        if let p = dict[portal.key] {
            p.refCount -= 1
            if p.refCount == 0 {
                dict.removeValue(forKey: portal.key)
            }
        }
    }
    
    
    /// Execute the given closure on each portal
    
    func forEachPortal(_ closure: @escaping (Portal) -> ()) {
        dict.forEach() { closure($0.value) }
    }
}


/// ItemManagers are the top level objects for BRBON hierarchies.
///
/// An item manager contains 1 top level item, this top level item can contain a hierachy of child items. Typically the top level item is either a Dictionary, Sequence, Array or Table. This top level object is accessed by the _root_ member of the item manager.
///
/// There are three ways to create an ItemManager, use one of the 'create...' operations, create one from file/data or create a copy from an existing ItemManager.

public final class ItemManager {

    
    /// The endianness of the root item and all child items
    
    public let endianness: Endianness
    
    
    /// The number of bytes by which to increment the internal buffer if there is insufficient free space available for a new item.
    
    public var bufferIncrements: Int = 1

    
    /// The root item (top most item in the buffer)
    
    public private(set) var root: Portal!
    
    
    /// The number of unused bytes in the buffer
    
    public var unusedBufferArea: Int { return buffer.count - root._itemByteCount }
    

    /// The buffer containing the items, the root item as the top level item.
    
    internal var buffer: UnsafeMutableRawBufferPointer
    internal var bufferPtr: UnsafeMutableRawPointer
    
    
    /// This flag controls the initialisation to zero of a buffer upon allocation. It is used for testing purposes only.
    
    internal static var startWithZeroedBuffers: Bool = false
    
    
    /// A data object with the entire rootItem in it as a sequence of bytes.
    
    public var data: Data {
        return Data(bytesNoCopy: bufferPtr, count: root._itemByteCount, deallocator: Data.Deallocator.none)
    }
    
    
    /// The array with all active portals.
    
    fileprivate var activePortals: ActivePortals!

    
    /// Load an ItemManager from file
    
    public convenience init?(from url: URL) {
        guard let data = try? Data.init(contentsOf: url) else { return nil }
        self.init(from: data)
    }
    

    /// Load an ItemManager from Data
    
    public init(from data: Data) {
        self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: data.count, alignment: 8)
        self.buffer.copyBytes(from: data)
        self.bufferPtr = buffer.baseAddress!
        self.endianness = machineEndianness
        self.activePortals = ActivePortals(manager: self)
        self.root = getActivePortal(for: self.bufferPtr)
    }

    
    /// Creates a new ItemManager but does not create an initial item in the buffer.
    ///
    /// - Note: This results in an incomplete item manager, be sure to create an initial item and set the root portal before using the manager.
    
    internal init(requestedByteCount: Int = 1024, endianness: Endianness) {
        
        let actualByteCount = requestedByteCount.roundUpToNearestMultipleOf8()
        
        self.endianness = endianness
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: actualByteCount, alignment: 8)
        self.bufferPtr = buffer.baseAddress!
        
        if ItemManager.startWithZeroedBuffers {
            _ = memset(self.bufferPtr, 0, buffer.count)
        }
        
        self.activePortals = ActivePortals(manager: self)
    }

    
    /// Return a new item manager with the contents of self and optionally a larger buffer.
    ///
    /// - Parameter ask: When not specified, the size of the new buffer will be the same as the buffersize in other. When specified the buffer size will be as requested, but it will always be big enough to accomodate the root item in other. The interpretation of this parameter depends on the type of the root in other. For array it is in elements, for table it is in rows, for all other items it is in bytes.

    
    public func copyWithRecalculatedBufferSize(ask: Int? = nil) -> ItemManager {
        
        // Determine the size of the buffer for self
        
        var newByteCount: Int
        if let ask = ask {
            
            switch root.itemType! {
                
            case .null, .bool, .int8, .int16, .int32, .int64, .uint8, .uint16, .uint32, .uint64, .float32, .float64, .string, .crcString, .binary, .crcBinary, .uuid, .dictionary, .sequence, .color, .font:
                
                newByteCount = max(ask, root._itemByteCount)
                
            case .array:
                
                newByteCount = max(itemHeaderByteCount + arrayElementBaseOffset + (root._arrayElementByteCount * ask), root._itemByteCount)
                
            case .table:
                
                newByteCount = max(itemHeaderByteCount + root._tableRowsOffset + (root._tableRowByteCount * ask), root._itemByteCount)
            }
            
        } else {
            newByteCount = buffer.count
        }

        
        // Create the new manager
        
        let newManager = ItemManager(requestedByteCount: newByteCount, endianness: endianness)
        
        
        // Copy the data from other
        
        _ = memcpy(newManager.bufferPtr, bufferPtr, root._itemByteCount)
        
        
        // Setup the root portal
        
        newManager.root = newManager.getActivePortal(for: newManager.bufferPtr, index: nil, column: nil)

        
        // Return the new manager
        
        return newManager
    }
    
    
    /// Create a new item manager.
    ///
    /// - Parameters:
    ///   - withValue: The initial value of the root item.
    ///   - withNameField: The name for the root item.
    ///   - requestedValueFieldByteCount: The number of bytes to allocate for the value field (actual value may be larger, never smaller).
    ///   - endianness: The endianness used by the item manager and items under its control.
    
    public static func createManager(withValue value: Coder, withNameField nameField: NameField? = nil, requestedValueFieldByteCount: Int = 0, endianness: Endianness = machineEndianness) -> ItemManager {
        
        
        // Determine the size of the buffer
        
        let byteCount = itemHeaderByteCount + (nameField?.byteCount ?? 0) + max(value.minimumValueFieldByteCount, requestedValueFieldByteCount.roundUpToNearestMultipleOf8())
        
        
        // Create the new item manager
        
        let im = ItemManager(requestedByteCount: byteCount, endianness: endianness)
        
        
        // Build the item structure
        
        buildItem(withValue: value, withNameField: nameField, atPtr: im.bufferPtr, endianness)
        
        
        // initialize the root portal
        
        im.root = im.getActivePortal(for: im.bufferPtr)
        
        return im
    }

    
    /// Create a new item manager containing an Array item as the root item.
    ///
    /// - Parameters:
    ///   - withNameField: The name for the root item.
    ///   - elementType: The type of the elements in the array, notice that container items are interchangeable. I.e while sameness of scalar types is enforced, sameness of container types is not enforced.
    ///   - elementByteCount: The initial byte count (available) for each element. Notice that this is for speed improvement only, there is no limit enforced (with the exception of Int32.max). When necessary the elementByteCount will be expanded to accomodate a larger item.
    ///   - elementCount: The number of elements for which initial memory allocation is made. Notice that this is for speed improvement only, there is no limit enforced upon the number of elements (with the exception of Int32.max).
    ///   - endianness: The endianness used by the item manager and items under its control.
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withNameField nameField: NameField?, elementType: ItemType, elementByteCount: Int = 0, elementCount: Int = 0, endianness: Endianness) -> ItemManager {
        
        let neededElementByteCount = elementByteCount
        
        
        // Determine the size of the buffer
        
        let byteCount = itemHeaderByteCount + (nameField?.byteCount ?? 0) + arrayElementBaseOffset + (neededElementByteCount * elementCount).roundUpToNearestMultipleOf8()
        
        
        // Create the new item manager
        
        let im = ItemManager(requestedByteCount: byteCount, endianness: endianness)
        
        
        // Build the item structure
        
        buildArrayItem(withNameField: nameField, elementType: elementType, elementByteCount: neededElementByteCount, elementCount: elementCount, atPtr: im.bufferPtr, endianness)
        
        // initialize the root portal
        im.root = im.getActivePortal(for: im.bufferPtr)
        
        return im
    }

    
    /// Create a new item manager containing an Array item as the root item.
    ///
    /// - Parameters:
    ///   - withName: The name for the root item.
    ///   - elementType: The type of the elements in the array, notice that container items are interchangeable. I.e while sameness of scalar types is enforced, sameness of container types is not enforced.
    ///   - elementByteCount: The initial byte count (available) for each element. Notice that this is for speed improvement only, there is no limit enforced (with the exception of Int32.max). When necessary the elementByteCount will be expanded to accomodate a larger item.
    ///   - elementCount: The number of elements for which initial memory allocation is made. Notice that this is for speed improvement only, there is no limit enforced upon the number of elements (with the exception of Int32.max).
    ///   - endianness: The endianness used by the item manager and items under its control.
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(withName name: String, elementType: ItemType, elementByteCount: Int = 0, elementCount: Int = 0, endianness: Endianness) -> ItemManager? {
        
        guard let nameField = NameField(name) else { return nil }

        return createArrayManager(withNameField: nameField, elementType: elementType, elementByteCount: elementByteCount, elementCount: elementCount, endianness: endianness)
    }

    
    /// Create a new item manager containing an Array item as the root item.
    ///
    /// - Parameters:
    ///   - elementType: The type of the elements in the array, notice that container items are interchangeable. I.e while sameness of scalar types is enforced, sameness of container types is not enforced.
    ///   - elementByteCount: The initial byte count (available) for each element. Notice that this is for speed improvement only, there is no limit enforced (with the exception of Int32.max). When necessary the elementByteCount will be expanded to accomodate a larger item.
    ///   - elementCount: The number of elements for which initial memory allocation is made. Notice that this is for speed improvement only, there is no limit enforced upon the number of elements (with the exception of Int32.max).
    ///   - endianness: The endianness used by the item manager and items under its control.
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(elementType: ItemType, elementByteCount: Int = 0, elementCount: Int = 0, endianness: Endianness) -> ItemManager {
        
        return createArrayManager(withNameField: nil, elementType: elementType, elementByteCount: elementByteCount, elementCount: elementCount, endianness: endianness)
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(withName name: String?, values array: Array<Bool>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }
        
        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .bool, elementByteCount: 1, elementCount: array.count, endianness: endianness)
    
        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<Bool>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<UInt8>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .uint8, elementByteCount: 1, elementCount: array.count, endianness: endianness)
        
        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }
    
    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<UInt8>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<UInt16>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .uint16, elementByteCount: 2, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }
    
    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<UInt16>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }


    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<UInt32>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .uint32, elementByteCount: 4, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<UInt32>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }
    
    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<UInt64>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .uint64, elementByteCount: 8, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<UInt64>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<Int8>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .int8, elementByteCount: 1, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }


    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<Int8>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }


    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<Int16>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .int16, elementByteCount: 2, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }
    
    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<Int16>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }
    
    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<Int32>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .int32, elementByteCount: 4, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<Int32>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<Int64>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .int64, elementByteCount: 8, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }
    
    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<Int64>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<Float32>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .float32, elementByteCount: 4, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<Float32>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<Float64>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .float64, elementByteCount: 8, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<Float64>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<Data>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        let maxByteCount = array.max(by: { $1.count > $0.count })?.count ?? 0
        
        let elementByteCount = (maxByteCount + 4).roundUpToNearestMultipleOf8()
        
        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .binary, elementByteCount: elementByteCount, elementCount: array.count, endianness: endianness)

        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<Data>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(withName name: String?, values array: Array<BRCrcBinary>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }
        
        let maxByteCount = array.max(by: { $1.data.count > $0.data.count })?.data.count ?? 0
        
        let elementByteCount = (maxByteCount + 8).roundUpToNearestMultipleOf8()
        
        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .crcBinary, elementByteCount: elementByteCount, elementCount: array.count, endianness: endianness)
        
        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<BRCrcBinary>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<String>, endianness: Endianness = machineEndianness) -> ItemManager? {

        let arrayData = array.compactMap({ $0.data(using: .utf8)})
        
        let im = ItemManager.createArrayManager(withName: name, values: arrayData, endianness:  endianness)
        im?.root._arrayElementType = .string
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<String>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(withName name: String?, values array: Array<BRCrcString>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }
        
        let maxByteCount = array.max(by: { $1.utf8Code.count > $0.utf8Code.count })?.utf8Code.count ?? 0
        
        let elementByteCount = (maxByteCount + 8).roundUpToNearestMultipleOf8()
        
        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .crcString, elementByteCount: elementByteCount, elementCount: array.count, endianness: endianness)
        
        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }
    
    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<BRCrcString>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(withName name: String?, values array: Array<UUID>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }
        
        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .uuid, elementByteCount: uuidValueByteCount, elementCount: array.count, endianness: endianness)
        
        for (i, element) in array.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }
    
    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<UUID>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    
    #if os(macOS)
    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(withName name: String?, values array: Array<NSColor>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }
        
        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .color, elementByteCount: colorValueByteCount, elementCount: array.count, endianness: endianness)
        
        for (i, element) in array.map({ BRColor($0) }).enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }
    
    #endif
    
    
    #if os(macOS)

    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<NSColor>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }

    #endif
    
    
    #if os(macOS)

    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(withName name: String?, values array: Array<NSFont>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }
        
        let fontArr = array.compactMap({ BRFont($0) })
        
        let maxByteCount = fontArr.max(by: { $1.nofValueBytesNecessary > $0.nofValueBytesNecessary })?.nofValueBytesNecessary ?? 0
        
        let elementByteCount = maxByteCount.roundUpToNearestMultipleOf8()

        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .font, elementByteCount: elementByteCount, elementCount: array.count, endianness: endianness)
        
        for (i, element) in fontArr.enumerated() {
            let eptr = im.root._valuePtr.arrayElementPtr(for: i, endianness)
            element.copyBytes(to: eptr, endianness)
        }
        
        im.root._arrayElementCount = array.count
        
        return im
    }
    
    #endif
    
    
    #if os(macOS)

    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<NSFont>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }
    
    #endif

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item (optional)
    ///   - array: The values to include in the root item of the item manager. Note that only those strings will be included in the array that can be coded in UTF8. If the conversion produces an error, the string will not be included and no error will be generated.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.

    public static func createArrayManager(withName name: String?, values array: Array<ItemManager>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var nameField: NameField?
        
        if name != nil {
            nameField = NameField(name)
            guard nameField != nil else { return nil }
        }

        
        // Determine the largest new byte count of the elements
        
        var maxByteCount: Int = 0
        array.forEach({ maxByteCount = max($0.root._itemByteCount, maxByteCount) })


        // Create array
        
        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .array, elementByteCount: maxByteCount, elementCount: array.count, endianness: endianness)
        

        // Add the new items
        
        array.forEach() {
            let srcPtr = $0.bufferPtr
            let dstPtr = im.root._valuePtr.arrayElementPtr(for: im.root._arrayElementCount, endianness)
            let length = $0.root._itemByteCount
            _ = memcpy(dstPtr, srcPtr, length)
            UInt32(0).copyBytes(to: dstPtr.advanced(by: itemParentOffsetOffset), endianness)
            im.root._arrayElementCount += 1
        }

        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - array: The values to include in the root item of the item manager. Note that only those strings will be included in the array that can be coded in UTF8. If the conversion produces an error, the string will not be included and no error will be generated.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    ///
    /// - Returns: An ItemManager with a array as the root item, nil if the name could not be used in a NameField.
    
    public static func createArrayManager(values array: Array<ItemManager>, endianness: Endianness = machineEndianness) -> ItemManager {
        return ItemManager.createArrayManager(withName: nil, values: array, endianness: endianness)!
    }


    /// Create an item manager that contains an ItemType 'dictionary'.
    ///
    /// - Parameters:
    ///   - withNameField: The name to be used for the root item.
    ///   - valueFieldByteCount: The number of bytes allocated for the value field. Default value is 256.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createDictionaryManager(
        withNameField nameField: NameField?,
        valueFieldByteCount: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let newItemByteCount = itemHeaderByteCount + (nameField?.byteCount ?? 0) + dictionaryItemBaseOffset + valueFieldByteCount.roundUpToNearestMultipleOf8()
        
        let im = ItemManager(requestedByteCount: newItemByteCount, endianness: endianness)
        
        buildDictionaryItem(withNameField: nameField, valueByteCount: valueFieldByteCount, atPtr: im.bufferPtr, endianness)
        
        im.root = im.getActivePortal(for: im.bufferPtr)
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'dictionary'.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item.
    ///   - valueFieldByteCount: The number of bytes allocated for the value field. Default value is 256.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager. Nil if the name cannot be converted into a NameField.
    
    public static func createDictionaryManager(
        withName name: String,
        valueFieldByteCount: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager? {
        
        guard let nameField = NameField(name) else { return nil }

        return createDictionaryManager(withNameField: nameField, valueFieldByteCount: valueFieldByteCount, endianness: endianness)
    }
    
    
    /// Create an item manager that contains an ItemType 'dictionary'.
    ///
    /// - Parameters:
    ///   - valueFieldByteCount: The number of bytes allocated for the value field. Default value is 256.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager. Nil if the name cannot be converted into a NameField.
    
    public static func createDictionaryManager(
        valueFieldByteCount: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        return createDictionaryManager(withNameField: nil, valueFieldByteCount: valueFieldByteCount, endianness: endianness)
    }

    
    /// Create an item manager that contains an ItemType 'sequence'.
    ///
    /// - Parameters:
    ///   - withNameField: The name to be used for the root item.
    ///   - valueFieldByteCount: The number of bytes allocated for the value field. Default value is 256.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createSequenceManager(
        withNameField nameField: NameField?,
        valueFieldByteCount: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let newItemByteCount = itemHeaderByteCount + (nameField?.byteCount ?? 0) + sequenceItemBaseOffset + valueFieldByteCount.roundUpToNearestMultipleOf8()
        
        let im = ItemManager(requestedByteCount: newItemByteCount, endianness: endianness)
        
        _ = buildSequenceItem(withNameField: nameField, valueByteCount: valueFieldByteCount, atPtr: im.bufferPtr, endianness)

        im.root = im.getActivePortal(for: im.bufferPtr)

        return im
    }
    
    
    /// Create an item manager that contains an ItemType 'sequence'.
    ///
    /// - Parameters:
    ///   - withNameField: The name to be used for the root item.
    ///   - valueFieldByteCount: The number of bytes allocated for the value field. Default value is 256.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createSequenceManager(
        withName name: String,
        valueFieldByteCount: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager? {
        
        guard let nameField = NameField(name) else { return nil }
        
        return createSequenceManager(withNameField: nameField, valueFieldByteCount: valueFieldByteCount, endianness: endianness)
    }

    
    /// Create an item manager that contains an ItemType 'sequence'.
    ///
    /// - Parameters:
    ///   - valueFieldByteCount: The number of bytes allocated for the value field. Default value is 256.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createSequenceManager(
        valueFieldByteCount: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        return createSequenceManager(withNameField: nil, valueFieldByteCount: valueFieldByteCount, endianness: endianness)
    }


    /// Create an item manager that contains an ItemType 'table'.
    ///
    /// - Parameters:
    ///   - withNameField: The name to be used for the root item.
    ///   - columns: The columns for the table.
    ///   - initialRowsAllocated: The number of rows allocated for the value field. Default value is 1.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createTableManager(
        withNameField nameField: NameField?,
        columns: inout Array<ColumnSpecification>,
        initialRowsAllocated: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let rowByteCount: Int = columns.reduce(0) { $0 + $1.fieldByteCount }
        let descriptorByteCount = tableColumnDescriptorByteCount * columns.count
        let columnNamesByteCount: Int = columns.reduce(0) { $0 + $1.nameField.byteCount }

        var newItemByteCount = itemHeaderByteCount + (nameField?.byteCount ?? 0)
        newItemByteCount += tableColumnDescriptorBaseOffset
        newItemByteCount += descriptorByteCount + columnNamesByteCount
        newItemByteCount += initialRowsAllocated * rowByteCount
        
        let im = ItemManager(requestedByteCount: newItemByteCount, endianness: endianness)
        
        buildTableItem(withNameField: nameField, columns: &columns, initialRowsAllocated: initialRowsAllocated, atPtr: im.bufferPtr, endianness)
        
        im.root = im.getActivePortal(for: im.bufferPtr)
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'table'.
    ///
    /// - Parameters:
    ///   - withName: The name to be used for the root item.
    ///   - columns: The columns for the table.
    ///   - initialRowsAllocated: The number of rows allocated for the value field. Default value is 1.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager. Nil if the name cannot be converted into a NameField.
    
    public static func createTableManager(
        withName name: String,
        columns: inout Array<ColumnSpecification>,
        initialRowsAllocated: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager? {
        
        guard let nameField = NameField(name) else { return nil }
        
        return createTableManager(withNameField: nameField, columns: &columns, initialRowsAllocated: initialRowsAllocated, endianness: endianness)
    }

    
    /// Create an item manager that contains an ItemType 'table'.
    ///
    /// - Parameters:
    ///   - columns: The columns for the table.
    ///   - initialRowsAllocated: The number of rows allocated for the value field. Default value is 1.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager. Nil if the name cannot be converted into a NameField.
    
    public static func createTableManager(
        columns: inout Array<ColumnSpecification>,
        initialRowsAllocated: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        return createTableManager(withNameField: nil, columns: &columns, initialRowsAllocated: initialRowsAllocated, endianness: endianness)
    }

    
    // Clean up.
    
    deinit {
        
        
        // The active portals are no longer valid
        
        activePortals.forEachPortal() { _ = $0.isValid = false }

        
        // Release the buffer area
        
        buffer.deallocate()
    }
    
    
    /// Portal management
    
    internal func getActivePortal(for ptr: UnsafeMutableRawPointer, index: Int? = nil, column: Int? = nil) -> Portal {
        assert(ptr >= bufferPtr && ptr < bufferPtr.advanced(by: buffer.count), "Pointer points outside buffer area")
        return activePortals.getPortal(for: ptr, index: index, column: column)
    }
        
    internal func removeActivePortal(_ portal: Portal) {
        activePortals.remove(portal)
    }
    
    internal func removeActivePortals(atAndAbove: UnsafeMutableRawPointer, below: UnsafeMutableRawPointer) {
        activePortals.removePortals(atAndAbove: atAndAbove, below: below)
    }

    internal func updateActivePortalPointers(atAndAbove: UnsafeMutableRawPointer, below: UnsafeMutableRawPointer, toNewBase: UnsafeMutableRawPointer) {
        activePortals.updatePointers(atAndAbove: atAndAbove, below: below, toNewBase: toNewBase)
    }
    
    internal func decrementActivePortalRefcountAndRemoveOnZero(for portal: Portal) {
        activePortals.decrementRefcountAndRemoveOnZero(for: portal)
    }
}

extension ItemManager {
    
    internal var unusedByteCount: Int { return buffer.count - root._itemByteCount }

    internal func increaseBufferSize(to bytes: Int) -> Bool {
        
        guard bufferIncrements > 0 else { return false }
        
        let increase = max(bytes, bufferIncrements).roundUpToNearestMultipleOf8()
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: increase, alignment: 8)
        if ItemManager.startWithZeroedBuffers { _ = memset(newBuffer.baseAddress!, 0, newBuffer.count) }
        
        _ = memmove(newBuffer.baseAddress!, buffer.baseAddress!, buffer.count)
        
        #if PTEST
        Portal.ptest_enabled = false
        #endif
        
        activePortals.updatePointers(atAndAbove: bufferPtr, below: bufferPtr.advanced(by: buffer.count), toNewBase: newBuffer.baseAddress!)
        
        #if PTEST
        Portal.ptest_enabled = true
        #endif

        buffer.deallocate()
        
        buffer = newBuffer
        bufferPtr = newBuffer.baseAddress!
        
        return true
    }

    
    /// Moves a block of memory.
    ///
    /// The active portals can be updated, if so, the portals in the destination area will be removed and the portals in the source area will be updated for the amount moved.
    ///
    /// - Parameters:
    ///   - to: The address to move the block to.
    ///   - from: The address to copy the block from.
    ///   - moveCount: The number of bytes to move and the size of the area for which active portals must be updated.
    ///   - removeCount: The size of the area from which active portals must be removed. Starts at the 'to' address.
    ///   - updateRemovedPortals: When set to true, the active portals in dstPtr..dstPtr+byteCount will be removed.
    ///   - updateMovedPortals: When set to true, the active portals in srcPtr..srcPtr+byteCount will be updated.
    
    internal func moveBlock(
        to dstPtr: UnsafeMutableRawPointer,
        from srcPtr: UnsafeMutableRawPointer,
        moveCount: Int,
        removeCount: Int,
        updateMovedPortals: Bool,
        updateRemovedPortals: Bool) {
        
        #if PTEST
        if dstPtr < bufferPtr { fatalError("Destination is outside the buffer (lower)") }
        if dstPtr.advanced(by: moveCount) > bufferPtr.advanced(by: buffer.count) { fatalError("Destination is outside the buffer (higher)") }
        #endif
        _ = memmove(dstPtr, srcPtr, moveCount)
        
        if updateRemovedPortals {
            activePortals.removePortals(atAndAbove: dstPtr, below: dstPtr.advanced(by: removeCount))
        }
        if updateMovedPortals {
            activePortals.updatePointers(atAndAbove: srcPtr, below: srcPtr.advanced(by: moveCount), toNewBase: dstPtr)
        }
    }
}

