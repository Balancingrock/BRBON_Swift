// =====================================================================================================================
//
//  File:       ItemManager
//  Project:    BRBON
//
//  Version:    0.7.0
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
// 0.7.0 - Added .color and .font
// 0.5.0 - Migration to Swift 4
//         Changed ActivePortal from struct to class to avoid concurrent memory access problem.
// 0.4.3 - Added init:from:withMinimumBufferByteCount
//       - Added protection against initial buffer counts that may be too low for the assigned value or type
//       - Changed name parameter in init from string to NameField
//       - Changed access level for init to internal, and added 'create' factories for each type
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import Cocoa

import BRUtils


/// This key is used to keep track of active portals. Active portals are tracked by the item manager to update the portals when data is shifted and to invalidate them when the data has been removed.

internal struct PortalKey: Equatable, Hashable {
    let itemPtr: UnsafeMutableRawPointer
    let index: Int?
    let column: Int?
    var hashValue: Int { return itemPtr.hashValue ^ (index ?? 0).hashValue ^ (column ?? 0).hashValue }
    static func == (lhs: PortalKey, rhs: PortalKey) -> Bool {
        return (lhs.itemPtr == rhs.itemPtr) && (lhs.index == rhs.index) && (lhs.column == rhs.column)
    }
}


/// This struct is used to keep track of the number of portals that have been returned to the API user.

fileprivate class ActivePortals {
    
    
    /// The dictionary that associates an item pointer with a valueItem entry
    
    var dict: Dictionary<PortalKey, Portal> = [:]
    
    
    /// Return the portal for the given parameters. A new one is created if it was not found in the dictionary.
    
    func getPortal(for ptr: UnsafeMutableRawPointer, index: Int? = nil, column: Int? = nil, mgr: ItemManager) -> Portal {
        let newPortal = Portal(itemPtr: ptr, index: index, column: column, manager: mgr, endianness: mgr.endianness)
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
                /*
                if let _ = portal.column, let _ = portal.index {
                    
                    let ptr = portal._valuePtr // itemPtr.itemValueFieldPtr.tableFieldPtr(row: index, column: column, portal.endianness)
                    
                    if ptr >= atAndAbove && ptr < below {
                        portal.isValid = false
                        dict.removeValue(forKey: key)
                    }
                
                } else if portal.index != nil {
                    
                    let ptr = portal._valuePtr
                    
                    if ptr >= atAndAbove && ptr < below {
                        portal.isValid = false
                        dict.removeValue(forKey: key)
                    }
                }*/
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


public final class ItemManager {

    
    /// The endianness of the root item and all child items
    
    public let endianness: Endianness
    
    
    /// The number of bytes with which to increment the buffer size if there is insufficient free space available.
    
    public var bufferIncrements: Int = 1

    
    /// The root item (top most item in the buffer)
    
    public private(set) var root: Portal!
    
    
    /// The number of bytes used by the root item (equal to all bytes that are used in the buffer)
    
    public var count: Int { return root._itemByteCount }
    
    
    /// The number of unused bytes in the buffer
    
    public var unusedBufferArea: Int { return buffer.count - count }
    

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
    
    fileprivate var activePortals = ActivePortals()


    /// Creates a new ItemManager but does not create an initial item in the buffer.
    ///
    /// - Note: This results in an incomplete item manager, be sure to create an initial item and set the root portal before using the manager.
    
    internal init(requestedByteCount: Int = 1024, endianness: Endianness) {
        
        let actualByteCount = requestedByteCount.roundUpToNearestMultipleOf8()
        
        self.endianness = endianness
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: actualByteCount, alignment: 8)
        self.bufferPtr = buffer.baseAddress!
        
        if ItemManager.startWithZeroedBuffers {
            _ = Darwin.memset(self.bufferPtr, 0, buffer.count)
        }
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
                
                newByteCount = max(ask, count)
                
            case .array:
                
                newByteCount = max(itemHeaderByteCount + arrayElementBaseOffset + (root._arrayElementByteCount * ask), count)
                
            case .table:
                
                newByteCount = max(itemHeaderByteCount + root._tableRowsOffset + (root._tableRowByteCount * ask), count)
            }
            
        } else {
            newByteCount = buffer.count
        }

        
        // Create the new manager
        
        let newManager = ItemManager(requestedByteCount: newByteCount, endianness: endianness)
        
        
        // Copy the data from other
        
        _ = Darwin.memcpy(newManager.bufferPtr, bufferPtr, count)
        
        
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
        _ = buildItem(withValue: value, withNameField: nameField, atPtr: im.bufferPtr, endianness)
        
        // initialize the root portal
        im.root = im.getActivePortal(for: im.bufferPtr)
        
        return im
    }

    
    /// Create a new item manager containing an Array item as the root item.
    ///
    /// - Parameters:
    ///   - withName: The name for the root item.
    ///   - elementType: The type of the elements in the array, notice that container items are interchangeable. I.e while sameness of scalar types is enforced, sameness of container types is not enforced.
    ///   - elementByteCount: The byte count (available) for each element.
    ///   - elementCount: The number of elements for which initial memory allocation is made. Notice that this is for speed improvement only, there is no limit enforced upon the number of elements (with the exception of Int32.max).
    ///   - endianness: The endianness used by the item manager and items under its control.
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, elementType: ItemType, elementByteCount: Int = 0, elementCount: Int = 0, endianness: Endianness) -> ItemManager {
        
        let neededElementByteCount = elementType.hasFlexibleLength ? elementByteCount : max(elementType.minimumElementByteCount, elementByteCount)
        
        // Determine the size of the buffer
        let byteCount = itemHeaderByteCount + (nameField?.byteCount ?? 0) + arrayElementBaseOffset + (neededElementByteCount * elementCount).roundUpToNearestMultipleOf8()
        
        // Create the new item manager
        let im = ItemManager(requestedByteCount: byteCount, endianness: endianness)
        
        // Build the item structure
        _ = buildArrayItem(withNameField: nameField, elementType: elementType, elementByteCount: neededElementByteCount, elementCount: elementCount, atPtr: im.bufferPtr, endianness)
        
        // initialize the root portal
        im.root = im.getActivePortal(for: im.bufferPtr)
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<Bool>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<UInt8>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<UInt16>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<UInt32>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<UInt64>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<Int8>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<Int16>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<Int32>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - name: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<Int64>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<Float32>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<Float64>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<Data>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        var maxByteCount = array.max(by: { $0.count > $1.count })?.count ?? 0
        maxByteCount = maxByteCount.roundUpToNearestMultipleOf8()
        
        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .binary, elementByteCount: maxByteCount, elementCount: array.count, endianness: endianness)

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
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - values: The values to include in the root item of the item manager.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<String>, endianness: Endianness = machineEndianness) -> ItemManager? {

        let arrayData = array.compactMap({ $0.data(using: .utf8)})
        
        let im = ItemManager.createArrayManager(withNameField: nameField, values: arrayData, endianness:  endianness)
        im?.root._arrayElementType = .string
        
        return im
    }

    
    /// Create an Array item manager with the contents of the given array.
    ///
    /// - Parameters:
    ///   - withNameField: The name to be used for the root item (optional)
    ///   - array: The values to include in the root item of the item manager. Note that only those strings will be included in the array that can be coded in UTF8. If the conversion produces an error, the string will not be included and no error will be generated.
    ///   - endianness: The endianness to use for the data managed by the item manager (optional).
    
    public static func createArrayManager(withNameField nameField: NameField? = nil, values array: Array<ItemManager>, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        
        // Determine the largest new byte count of the elements
        
        var maxByteCount: Int = 0
        array.forEach({ maxByteCount = max($0.count, maxByteCount) })


        // Create array
        
        let im = ItemManager.createArrayManager(withNameField: nameField, elementType: .array, elementByteCount: maxByteCount, elementCount: array.count, endianness: endianness)
        

        // Add the new items
        
        array.forEach() {
            let srcPtr = $0.bufferPtr
            let dstPtr = im.root._valuePtr.arrayElementPtr(for: im.root._arrayElementCount, endianness)
            let length = $0.count
            _ = Darwin.memcpy(dstPtr, srcPtr, length)
            UInt32(0).copyBytes(to: dstPtr.advanced(by: itemParentOffsetOffset), endianness)
            im.root._arrayElementCount += 1
            
        }

        return im
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
        withNameField nameField: NameField? = nil,
        valueFieldByteCount: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let newItemByteCount = itemHeaderByteCount + (nameField?.byteCount ?? 0) + dictionaryItemBaseOffset + valueFieldByteCount.roundUpToNearestMultipleOf8()
        
        let im = ItemManager(requestedByteCount: newItemByteCount, endianness: endianness)
        
        _ = buildDictionaryItem(withNameField: nameField, valueByteCount: valueFieldByteCount, atPtr: im.bufferPtr, endianness)
        
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
        withNameField nameField: NameField? = nil,
        valueFieldByteCount: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let newItemByteCount = itemHeaderByteCount + (nameField?.byteCount ?? 0) + sequenceItemBaseOffset + valueFieldByteCount.roundUpToNearestMultipleOf8()
        
        let im = ItemManager(requestedByteCount: newItemByteCount, endianness: endianness)
        
        _ = buildSequenceItem(withNameField: nameField, valueByteCount: valueFieldByteCount, atPtr: im.bufferPtr, endianness)

        im.root = im.getActivePortal(for: im.bufferPtr)

        return im
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
        withNameField nameField: NameField? = nil,
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

    
    // Clean up.
    
    deinit {
        
        
        // The active portals are no longer valid
        
        activePortals.forEachPortal() { _ = $0.isValid = false }

        
        // Release the buffer area
        
        buffer.deallocate()
    }
    
    
    /// Portal management
    
    internal func getActivePortal(for ptr: UnsafeMutableRawPointer, index: Int? = nil, column: Int? = nil) -> Portal {
        assert(ptr >= bufferPtr || ptr < bufferPtr.advanced(by: buffer.count), "Pointer points outside buffer area")
        return activePortals.getPortal(for: ptr, index: index, column: column, mgr: self)
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
        
        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(newBuffer.baseAddress!, 0, newBuffer.count) }

        _ = Darwin.memmove(newBuffer.baseAddress!, buffer.baseAddress!, buffer.count)
        
        activePortals.updatePointers(atAndAbove: bufferPtr, below: bufferPtr.advanced(by: buffer.count), toNewBase: newBuffer.baseAddress!)
        
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
        
        _ = Darwin.memmove(dstPtr, srcPtr, moveCount)
        
        if updateRemovedPortals {
            activePortals.removePortals(atAndAbove: dstPtr, below: dstPtr.advanced(by: removeCount))
        }
        if updateMovedPortals {
            activePortals.updatePointers(atAndAbove: srcPtr, below: srcPtr.advanced(by: moveCount), toNewBase: dstPtr)
        }
    }
}

