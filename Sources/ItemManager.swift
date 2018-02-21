//
//  ItemManager.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 13/02/18.
//
//

import Foundation
import BRUtils


/// This struct is used to keep track of the number of portals that have been returned to the API user.

internal struct ActivePortals {
    
    
    /// Associate a portal with a reference counter
    
    class Entry {
        let portal: Portal
        var refcount: Int = 0
        init(_ portal: Portal) { self.portal = portal }
    }
    
    
    /// The dictionary that associates an item pointer with a valueItem entry
    
    var dict: Dictionary<PortalKey, Entry> = [:]
    
    
    /// Return the portal for the given parameters. A new one is created if it was not found in the dictionary.
    
    mutating func getPortal(for ptr: UnsafeMutableRawPointer, elementPtr: UnsafeMutableRawPointer?, mgr: ItemManager) -> Portal {
        let newPortal = Portal(itemPtr: ptr, elementPtr: elementPtr, manager: mgr, endianness: mgr.endianness)
        if let entry = dict[newPortal.key], entry.portal.isValid {
            entry.refcount += 1
            return entry.portal
        } else {
            let entry = Entry(newPortal)
            entry.refcount += 1
            dict[newPortal.key] = entry
            return newPortal
        }
    }
    
    
    /// Remove a portal from the list.
    
    mutating func removePortal(for key: PortalKey) {
        if let entry = dict[key] {
            entry.portal.isValid = false
            dict.removeValue(forKey: entry.portal.key)
        }
    }
    
    
    /// Update the active portals
    
    mutating func updatePointers(atAndAbove: UnsafeMutableRawPointer, below: UnsafeMutableRawPointer, toNewBase: UnsafeMutableRawPointer) {
        let delta = atAndAbove.distance(to: toNewBase)
        for (_, entry) in dict {
            var change = false
            let oldKey = entry.portal.key
            if entry.portal.itemPtr >= atAndAbove && entry.portal.itemPtr < below {
                entry.portal.itemPtr = entry.portal.itemPtr.advanced(by: delta)
                change = true
            }
            if (entry.portal.valuePtr >= atAndAbove && entry.portal.valuePtr < below) {
                entry.portal.valuePtr = entry.portal.valuePtr.advanced(by: delta)
                change = true
            }
            if change {
                dict.removeValue(forKey: oldKey)
                dict[entry.portal.key] = entry
            }
        }
    }

    
    /// Decrement the reference counter of a portal and remove the entry of the refcount reaches zero.
    
    mutating func decrementRefcountAndRemoveOnZero(for portal: Portal) {
        if let vi = dict[portal.key] {
            vi.refcount -= 1
            if vi.refcount == 0 {
                dict.removeValue(forKey: portal.key)
            }
        }
    }
    
    
    /// Execute the given closure on each portal
    
    func forEachPortal(_ closure: @escaping (Portal) -> ()) {
        dict.forEach() { closure($0.value.portal) }
    }
}


public final class ItemManager {

    
    /// The endianness of the root item and all child items
    
    public let endianness: Endianness
    
    
    /// The number of bytes with which to increment the buffer size if there is insufficient free space available.
    
    public var bufferIncrements: Int

    
    /// The root item (top most item in the buffer)
    
    public let root: Portal
    
    
    /// The number of bytes used by the root item (equal to all bytes that are used in the buffer)
    
    public var count: Int { return root.itemByteCount }
    
    
    /// The number of unused bytes in the buffer
    
    public var unusedBufferArea: Int { return buffer.count - count }
    

    /// The buffer containing the items, the root item as the top level item.
    
    internal var buffer: UnsafeMutableRawBufferPointer
    internal var bufferPtr: UnsafeMutableRawPointer
    
    
    /// A data object with the entire rootItem in it as a sequence of bytes.
    
    public var data: Data {
        return Data(bytesNoCopy: bufferPtr, count: root.itemByteCount, deallocator: Data.Deallocator.none)
    }
    
    
    /// The array with all active portals.
    
    internal var activePortals = ActivePortals()
    

    /// Create a new manager.
    ///
    /// - Parameters:
    ///   - value: A variable of the IsBrbon type that will be used as the root item.
    ///   - initialBufferByteCount: The initial size for the buffer. In bytes.
    ///   - minimalBufferIncrements: The minimum number of bytes with which to increase the buffersize when needed. In bytes.
    ///   -
    
    public init?(
        value: IsBrbon,
        name: String? = nil,
        itemValueByteCount: Int? = nil,
        initialBufferByteCount: Int = 1024,
        minimalBufferIncrements: Int = 1024,
        endianness: Endianness = machineEndianness) {
        
        guard initialBufferByteCount > 0 else { return nil }
        guard minimalBufferIncrements >= 0 else { return nil }
        
        var nfd: NameFieldDescriptor?
        if name != nil {
            guard let n = NameFieldDescriptor(name) else { return nil }
            nfd = n
        }
        
        self.bufferIncrements = minimalBufferIncrements
        self.endianness = endianness
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: initialBufferByteCount.roundUpToNearestMultipleOf8())
        self.bufferPtr = buffer.baseAddress!

        let value: Coder = value as! Coder

        value.storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
        
        self.root = Portal(itemPtr: bufferPtr, elementPtr: nil, manager: nil, endianness: endianness)
        self.root.manager = self
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
    
    public init?(
        rootItemType: ItemType,
        name: String? = nil,
        elementType: ItemType? = nil,
        rootValueByteCount: Int? = nil,
        elementValueByteCount: Int? = nil,
        initialBufferByteCount: Int = 1024,
        minimalBufferIncrements: Int = 1024,
        endianness: Endianness = machineEndianness) {
        
        
        guard initialBufferByteCount > 0 else { return nil }
        guard minimalBufferIncrements >= 0 else { return nil }
        
        var nfd: NameFieldDescriptor?
        if name != nil {
            guard let n = NameFieldDescriptor(name) else { return nil }
            nfd = n
        }

        self.bufferIncrements = minimalBufferIncrements
        self.endianness = endianness
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: initialBufferByteCount.roundUpToNearestMultipleOf8())
        self.bufferPtr = buffer.baseAddress!

        
        switch rootItemType {
        case .null:
            
            Null().storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .bool:
            
            false.storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)

            
        case .int8:
            
            Int8(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .int16:
            
            Int16(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .int32:
            
            Int32(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .int64:
            
            Int64(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .uint8:
            
            UInt8(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .uint16:
            
            UInt16(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .uint32:
            
            UInt32(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .uint64:
            
            UInt64(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .float32:
            
            Float32(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .float64:
            
            Float64(0).storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
            
        case .binary:
            
            Data().storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)

            
        case .string:
            
            "".storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)

            
        case .array:
            
            guard let elementType = elementType else { buffer.deallocate() ; return nil }
            if elementType == .array {
                guard let elementValueByteCount = elementValueByteCount, elementValueByteCount >= (minimumItemByteCount + 16) else { buffer.deallocate() ;return nil }
            }
            let arr = BrbonArray(content: [], type: elementType, elementByteCount: elementValueByteCount)
            arr.storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
        case .dictionary:
            
            let dict = BrbonDictionary(content: [:])
            dict.storeAsItem(atPtr: bufferPtr, bufferPtr: bufferPtr, parentPtr: bufferPtr, nameField: nfd, valueByteCount: rootValueByteCount, endianness)
            
        case .sequence: break
        }
        
        self.root = Portal(itemPtr: bufferPtr, elementPtr: nil, manager: nil, endianness: endianness)
        self.root.manager = self
    }
    
    
    deinit {
        
        
        // The active portals are no longer valid
        
        activePortals.forEachPortal() { _ = $0.isValid = false }

        
        // Release the buffer area
        
        buffer.deallocate()
    }
    
    internal func getPortal(for ptr: UnsafeMutableRawPointer, elementPtr: UnsafeMutableRawPointer?) -> Portal {
        return activePortals.getPortal(for: ptr, elementPtr: elementPtr, mgr: self)
    }
    
    internal func unsubscribe(portal: Portal) {
        activePortals.decrementRefcountAndRemoveOnZero(for: portal)
    }
}

extension ItemManager {
    
    internal var unusedByteCount: Int { return buffer.count - root.itemByteCount }
    
    internal func increaseBufferSize(by bytes: Int) -> Bool {
        
        guard bufferIncrements > 0 else { return false }
        
        let increase = Int(max(bytes, bufferIncrements)).roundUpToNearestMultipleOf8()
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(count: buffer.count + increase)
        
        _ = Darwin.memmove(newBuffer.baseAddress!, buffer.baseAddress!, buffer.count)
        _ = Darwin.memset(newBuffer.baseAddress!.advanced(by: buffer.count), 0, increase/4)
        
        activePortals.updatePointers(atAndAbove: bufferPtr, below: bufferPtr.advanced(by: buffer.count), toNewBase: newBuffer.baseAddress!)

        
        buffer = newBuffer
        bufferPtr = newBuffer.baseAddress!
        
        return true
    }
    
    internal func moveBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer, _ length: Int) {
        _ = Darwin.memmove(dstPtr, srcPtr, length)
    }
}
