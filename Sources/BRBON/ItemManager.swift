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
// 0.7.0 - Added .rgba and .font
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
    

    func remove(_ portal: Portal) {
        
        // Remove any portal that may be contained inside an item or element within this portal
        
        let startAddress: UnsafeMutableRawPointer
        let endAddress: UnsafeMutableRawPointer
        
        if let column = portal.column, let index = portal.index {
            
            startAddress = portal._tableFieldPtr(row: index, column: column)
            endAddress = startAddress.advanced(by: portal._tableGetColumnFieldByteCount(for: column))
            
            portal.isValid = false
            dict.removeValue(forKey: portal.key)
        
        } else if let index = portal.index {
            
            startAddress = portal._arrayElementPtr(for: index)
            endAddress = startAddress.advanced(by: portal._arrayElementByteCount)

            portal.isValid = false
            dict.removeValue(forKey: portal.key)
            
        } else {
            
            startAddress = portal.itemPtr
            endAddress = startAddress.advanced(by: portal._itemByteCount)
            
            // The portal itself will be removed in the loop below.
        }
        
        for (key, value) in dict {
            if value.itemPtr >= startAddress && value.itemPtr < endAddress {
                value.isValid = false
                dict.removeValue(forKey: key)
            }
        }
    }
    
    
    /// Remove a series of portals from the list.
    
    func removePortals(atAndAbove: UnsafeMutableRawPointer, below: UnsafeMutableRawPointer) {
        
        for (key, portal) in dict {
            
            if portal.itemPtr >= atAndAbove && portal.itemPtr < below {
            
                portal.isValid = false
                dict.removeValue(forKey: key)

            } else {
                
                if let column = portal.column, let index = portal.index {
                    
                    let ptr = portal._tableFieldPtr(row: index, column: column)
                    
                    if ptr >= atAndAbove && ptr < below {
                        portal.isValid = false
                        dict.removeValue(forKey: key)
                    }
                    
                } else if let index = portal.index {
                    
                    let ptr = portal._arrayElementPtr(for: index)
                    
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
        let delta = atAndAbove.distance(to: toNewBase)
        for (_, portal) in dict {
            if portal.itemPtr >= atAndAbove && portal.itemPtr < below {
                let oldKey = portal.key
                portal.itemPtr = portal.itemPtr.advanced(by: delta)
                dict.removeValue(forKey: oldKey)
                dict[portal.key] = portal
            }
        }
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
    
    public var bufferIncrements: Int

    
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
    

    /// Returns an item manager that contains the same root item as in the given item manager.
    ///
    /// The size of the buffer may be changed to a new value. But the buffer size will always be large enough to accomodate at least the root item in self. If no new buffer size is specified, the same buffer size as in other will be used.
    ///
    /// - Parameters:
    ///   - from: the other item manager from which to duplicate self.
    ///   - allocation: When not specified, the size of the new buffer will be the same as the buffersize in other. When specified the buffer size will be as requested, but it will always be big enough to accomodate the root item in other. The interpretation of this parameter depends on the type of the root in other. For array it is in elements, for table it is in rows, for all other items it is in bytes.
    
    internal init(from other: ItemManager, allocation: Int? = nil) {
        
        
        // Determine the size of the buffer for self
        
        var newCount: Int
        if let asked = allocation {
            
            switch other.root.itemType! {
                
            case .null, .bool, .int8, .int16, .int32, .int64, .uint8, .uint16, .uint32, .uint64, .float32, .float64, .string, .crcString, .binary, .crcBinary, .uuid, .dictionary, .sequence, .rgba, .font:
                
                newCount = max(asked, other.count)

            case .array:
                
                newCount = max((other.root._arrayElementByteCount * asked), other.count)
                
            case .table:
                
                newCount = max((other.root._tableRowByteCount * asked), other.count)
            }
            
        } else {
            newCount = other.buffer.count
        }
        
        
        // Create self
        
        self.bufferIncrements = other.bufferIncrements
        self.endianness = other.endianness
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: newCount.roundUpToNearestMultipleOf8(), alignment: 8)
        self.bufferPtr = buffer.baseAddress!


        // Copy the data from other
        
        _ = Darwin.memcpy(other.bufferPtr, self.bufferPtr, other.count)
        
        
        // Setup the root portal
        
        self.root = getActivePortal(for: bufferPtr, index: nil, column: nil)
    }
    
    
    /// Create a new manager.
    ///
    /// - Parameters:
    ///   - value: A variable of the IsBrbon type that will be used as the root item.
    ///   - name: An optional name for the root item.
    ///   - itemValueByteCount: The room allocated for the value field. This number must at least be big enough to accomodate the presented value.
    ///   - initialBufferByteCount: The initial size for the buffer. In bytes. (default = 1024)
    ///   - minimalBufferIncrements: The minimum number of bytes with which to increase the buffersize when needed. In bytes. (default = 1024)
    ///   - endianness: The endianness to be used (default = machineEndianness).
    
    internal init(
        value: IsBrbon,
        name: NameField? = nil,
        itemValueByteCount: Int? = nil,
        initialBufferByteCount: Int = 1024,
        minimalBufferIncrements: Int = 1024,
        endianness: Endianness = machineEndianness) {
        
        self.bufferIncrements = minimalBufferIncrements
        self.endianness = endianness
        
        let value: Coder = value as! Coder

        // Guarantee that the value can be stored in the buffer
        let ibc = max(value.itemByteCount(name), initialBufferByteCount)
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: ibc.roundUpToNearestMultipleOf8(), alignment: 8)
        self.bufferPtr = buffer.baseAddress!
        
        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(self.bufferPtr, 0, buffer.count) }

        value.storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: itemValueByteCount, endianness)
        
        self.root = getActivePortal(for: bufferPtr, index: nil, column: nil)
    }

    
    /// Create a new manager.
    ///
    /// - Parameters:
    ///   - rootItemType: The ItemType of the root item. All subsequent access will go through the root item and are limited to the operations supported by this root item.
    ///   - elementType: If the root item is an array, this associated type is the type of the element in the array.
    ///   - rootValueByteCount: The byte count reserved for the root.
    ///   - elementValueByteCount: The byte count for each value, only used if the root is an array and is then mandatory. Minimum value is 32.
    ///   - initialBufferByteCount: The initial size for the buffer. In bytes. Note that items and elements need more space than just their value byte count. The minimum item size -for example- is 16 bytes.
    ///   - minimalBufferIncrements: The minimum number of bytes with which to increase the buffersize when needed. In bytes.
    ///   - endianness: The endianness of the data structure to be generated.
    
    internal init(
        rootItemType: ItemType,
        name: NameField? = nil,
        elementType: ItemType? = nil,
        rootValueByteCount: Int? = nil,
        elementValueByteCount: Int? = nil,
        initialBufferByteCount: Int = 1024,
        minimalBufferIncrements: Int = 1024,
        endianness: Endianness = machineEndianness) {
        
        self.bufferIncrements = minimalBufferIncrements
        self.endianness = endianness
        
        let ibc = max((itemMinimumByteCount + (name?.byteCount ?? 0) + rootItemType.defaultElementByteCount), initialBufferByteCount)
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: ibc.roundUpToNearestMultipleOf8(), alignment: 8)
        self.bufferPtr = buffer.baseAddress!

        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(self.bufferPtr, 0, buffer.count) }
        
        switch rootItemType {
        case .null:
            
            Null().storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .bool:
            
            false.storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)

            
        case .int8:
            
            Int8(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .int16:
            
            Int16(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .int32:
            
            Int32(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .int64:
            
            Int64(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .uint8:
            
            UInt8(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .uint16:
            
            UInt16(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .uint32:
            
            UInt32(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .uint64:
            
            UInt64(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .float32:
            
            Float32(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .float64:
            
            Float64(0).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .uuid:
            
            UUID().storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .rgba:
            
            Rgba(NSColor.black).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .font:
            
            Font(NSFont.systemFont(ofSize: 11.0)).storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .string:
            
            "".storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)

            
        case .crcString:
            
            "".crcString.storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            

        case .binary:
            
            Data().storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
            
        case .crcBinary:
            Data().crcBinary.storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            

        case .array:
            
            let arr = BrbonArray(content: [], type: elementType!, elementByteCount: elementValueByteCount)
            arr.storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
        case .dictionary:
            
            let dict = BrbonDictionary()!
            dict.storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
            
        case .sequence: break
            
        case .table:
            
            let tb = BrbonTable(columnSpecifications: [])
            tb.storeAsItem(atPtr: bufferPtr, name: name, parentOffset: 0, initialValueByteCount: rootValueByteCount, endianness)
        }
        
        self.root = getActivePortal(for: bufferPtr, index: nil, column: nil)
    }
    
    
    /// Create an item manager that contains an ItemType 'null'.
    ///
    /// - Parameters:
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createNullManager(
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
    ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .null, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        return im
    }
    
    
    /// Create an item manager that contains an ItemType 'bool'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createBoolManager(
        _ value: Bool,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .bool, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.bool = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'int8'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createInt8Manager(
        _ value: Int8,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .int8, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.int8 = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'int16'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createInt16Manager(
        _ value: Int16,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .int16, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.int16 = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'int32'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createInt32Manager(
        _ value: Int32,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .int32, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.int32 = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'int64'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createInt64Manager(
        _ value: Int64,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .int64, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.int64 = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'uint8'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createUInt8Manager(
        _ value: UInt8,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .uint8, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.uint8 = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'uint16'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createUInt16Manager(
        _ value: UInt16,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .uint16, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.uint16 = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'uint32'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createUInt32Manager(
        _ value: UInt32,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .uint32, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
    
        im.root.uint32 = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'uint64'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createUInt64Manager(
        _ value: UInt64,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .uint64, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.uint64 = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'float32'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createFloat32Manager(
        _ value: Float32,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .float32, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.float32 = value
        
        return im
    }
    
    
    /// Create an item manager that contains an ItemType 'float64'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createFloat64Manager(
        _ value: Float64,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .float64, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.float64 = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'uuid'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 0 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createUuidManager(
        _ value: UUID,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .uuid, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.uuid = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'rgba'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.

    public static func createRgbaManager(
        _ value: Rgba,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .rgba, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)

        im.root.rgba = value
        
        return im
    }
    
    
    /// Create an item manager that contains an ItemType 'font'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createFontManager(
        _ value: Font,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 0,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .font, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.font = value
        
        return im
    }
    

    /// Create an item manager that contains an ItemType 'string'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createStringManager(
        _ value: String,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .string, name: name, elementType: nil, rootValueByteCount: value.valueByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.string = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'crcString'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createCrcStringManager(
        _ value: CrcString,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .crcString, name: name, elementType: nil, rootValueByteCount: value.valueByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.crcString = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'binary'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createBinaryManager(
        _ value: Data,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .binary, name: name, elementType: nil, rootValueByteCount: value.valueByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.binary = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'crcBinary'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The size of the value field.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createCrcBinaryManager(
        _ value: CrcBinary,
        name: NameField? = nil,
        valueFieldByteCount: Int = 0,
        minimalBufferIncrement: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .crcBinary, name: name, elementType: nil, rootValueByteCount: value.valueByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        im.root.crcBinary = value
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'array'.
    ///
    /// - Parameters:
    ///   - value: The initial value for the type.
    ///   - name: The name to be used for the root item.
    ///   - elementAllocation: The number of elements for which an initial alocation must be made.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createArrayManager(
        _ value: BrbonArray,
        name: NameField? = nil,
        elementAllocation: Int = 0,
        minimalBufferIncrement: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(value: value, name: name, itemValueByteCount: value.elementValueByteCount, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'array'.
    ///
    /// - Parameters:
    ///   - elementType: The type of element for the array.
    ///   - elementByteCount
    ///   - name: The name to be used for the root item.
    ///   - elementAllocation: The number of elements for which an initial alocation must be made.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. Note that for this to happen the type of the root item must be changed to something different. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createArrayManager(
        elementType: ItemType,
        elementByteCount: Int? = nil,
        elementAllocation: Int = 0,
        name: NameField? = nil,
        minimalBufferIncrement: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let ebc = max(elementType.defaultElementByteCount, (elementByteCount ?? 0))
        let vbc = elementAllocation * ebc
        
        let im = ItemManager(rootItemType: .array, name: name, elementType: elementType, rootValueByteCount: vbc, elementValueByteCount: ebc, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)

        return im
    }

    
    /// Create an item manager that contains an ItemType 'dictionary'.
    ///
    /// - Parameters:
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The number of bytes allocated for the value field. Default value is 256.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createDictionaryManager(
        name: NameField? = nil,
        valueFieldByteCount: Int = 256,
        minimalBufferIncrement: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .dictionary, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'sequence'.
    ///
    /// - Parameters:
    ///   - name: The name to be used for the root item.
    ///   - valueFieldByteCount: The number of bytes allocated for the value field. Default value is 256.
    ///   - minimalBufferIncrement: The number of bytes the buffer will minimally grow when necessary. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createSequenceManager(
        name: NameField? = nil,
        valueFieldByteCount: Int = 256,
        minimalBufferIncrement: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let im = ItemManager(rootItemType: .sequence, name: name, elementType: nil, rootValueByteCount: valueFieldByteCount, elementValueByteCount: nil, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        return im
    }

    
    /// Create an item manager that contains an ItemType 'table'.
    ///
    /// - Parameters:
    ///   - columns: The columns for the table.
    ///   - name: The name to be used for the root item.
    ///   - initialRowAllocation: The number of rows allocated for the value field. Default value is 1.
    ///   - minimalBufferIncrement: The number of rows the buffer will minimally grow when necessary. Note that this is only valid for the columns specificied in this call. This value is 1 by default. Note that the minimalBufferIncrements property can be changed afterwards.
    ///   - endianness: The kind of endian representation to be used.
    ///
    /// - Returns: A new item manager.
    
    public static func createTableManager(
        columns: Array<ColumnSpecification>,
        name: NameField? = nil,
        initialRowAllocation: Int = 1,
        minimalBufferIncrement: Int = 1,
        endianness: Endianness = machineEndianness
        ) -> ItemManager {
        
        let rowByteCount: Int = columns.reduce(0) { $0 + $1.fieldByteCount }
        
        let table = BrbonTable(columnSpecifications: columns)
        
        let tm = ItemManager(value: table, name: name, itemValueByteCount: initialRowAllocation * rowByteCount, initialBufferByteCount: 0, minimalBufferIncrements: minimalBufferIncrement, endianness: endianness)
        
        return tm
    }

    
    /// Duplicate an item manager.
    ///
    /// - Parameters:
    ///   - from: The item manager to duplicate
    ///   - initialAllocation: When not specified, the size of the new buffer will be the same as the buffersize in other. When specified the buffer size will be as requested, but it will always be big enough to accomodate the root item in other. The interpretation of this parameter depends on the type of the root in other. For an array it is in elements, for a table it is in rows, for all other items it is in bytes.

    public static func createManager(
        from other: ItemManager,
        initialAllocation: Int? = nil
        ) -> ItemManager {
        
        return ItemManager.init(from: other, allocation: initialAllocation)
    }
    
    deinit {
        
        
        // The active portals are no longer valid
        
        activePortals.forEachPortal() { _ = $0.isValid = false }

        
        // Release the buffer area
        
        buffer.deallocate()
    }
    
    internal func getActivePortal(for ptr: UnsafeMutableRawPointer, index: Int? = nil, column: Int? = nil) -> Portal {
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
    
    internal func increaseBufferSize(by bytes: Int) -> Bool {
        
        guard bufferIncrements > 0 else { return false }
        
        let increase = Int(max(bytes, bufferIncrements)).roundUpToNearestMultipleOf8()
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: buffer.count + increase, alignment: 8)
        
        if ItemManager.startWithZeroedBuffers { _ = Darwin.memset(newBuffer.baseAddress!, 0, newBuffer.count) }

        _ = Darwin.memmove(newBuffer.baseAddress!, buffer.baseAddress!, buffer.count)
        
        activePortals.updatePointers(atAndAbove: bufferPtr, below: bufferPtr.advanced(by: buffer.count), toNewBase: newBuffer.baseAddress!)

        buffer.deallocate()
        
        buffer = newBuffer
        bufferPtr = newBuffer.baseAddress!
        
        return true
    }

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

