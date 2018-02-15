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

fileprivate struct ActivePortals {
    
    
    /// Associate a portal with a reference counter
    
    class Entry {
        let portal: Portal
        var refcount: Int = 0
        init(_ portal: Portal) { self.portal = portal }
    }
    
    
    /// The dictionary that associates an item pointer with a valueItem entry
    
    var dict: Dictionary<UnsafeMutableRawPointer, Entry> = [:]
    
    
    /// Return the portal for the given parameters. A new one is created if it was not found in the dictionary.
    
    mutating func getPortal(for ptr: UnsafeMutableRawPointer, mgr: ItemManager) -> Portal {
        if let entry = dict[ptr] {
            entry.refcount += 1
            return entry.portal
        } else {
            let vi = Portal(basePtr: ptr, parentPtr: nil, manager: mgr, endianness: mgr.endianness)
            let entry = Entry(vi)
            dict[ptr] = entry
            return vi
        }
    }
    
    
    /// Decrement the reference counter of a portal and remove the entry of the refcount reaches zero.
    
    mutating func decrementRefcountAndRemoveOnZero(for portal: Portal) {
        if let vi = dict[portal.basePtr] {
            vi.refcount -= 1
            if vi.refcount == 0 {
                dict.removeValue(forKey: portal.basePtr)
            }
        }
    }
    
    
    /// Execute the given closure on each portal
    
    func forEachPortal(_ closure: (Portal) -> ()) {
        dict.forEach() { closure($0.value.portal) }
    }
}


public final class ItemManager {

    
    /// The endianness of the root item and all child items
    
    public let endianness: Endianness
    
    
    /// The number of bytes with which to increment the buffer size if there is insufficient free space available.
    
    public var bufferIncrements: Int

    
    /// The root item (top most item in the buffer)
    
    public let rootItem: Item
    
    
    /// The number of bytes used by the root item (equal to all bytes that are used in the buffer)
    
    public var count: Int { return rootItem.byteCount }
    
    
    /// The number of unused bytes in the buffer
    
    public var unusedBufferArea: Int { return buffer.count - count }
    

    /// The buffer containing the items, the root item as the top level item.
    
    internal var buffer: UnsafeMutableRawBufferPointer
    internal var basePtr: UnsafeMutableRawPointer
    
    
    /// A data object with the entire rootItem in it as a sequence of bytes.
    
    public var data: Data {
        return Data(bytesNoCopy: basePtr, count: rootItem.byteCount, deallocator: Data.Deallocator.none)
    }
    
    
    /// The array with all active portals.
    
    fileprivate var activePortals = ActivePortals()
    

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
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: initialBufferByteCount)
        self.basePtr = buffer.baseAddress!

        let value: Coder = value as! Coder

        value.storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
        
        self.rootItem = Item(basePtr: basePtr, parentPtr: nil, endianness: endianness)
        
        rootItem.manager = self
    }

    
    /// Create a new manager.
    ///
    /// - Parameters:
    ///   - rootItemType: The ItemType of the root item. All subsequent access will go through the root item and are limited to the operations supported by this root item.
    ///   - elementType: If the root item is an array, the associated type is the type of the element in the array.
    ///   - initialBufferByteCount: The initial size for the buffer. In bytes.
    ///   - minimalBufferIncrements: The minimum number of bytes with which to increase the buffersize when needed. In bytes.
    ///   -
    
    public init?(
        rootItemType: ItemType,
        name: String? = nil,
        elementType: ItemType? = nil,
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
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: initialBufferByteCount)
        self.basePtr = buffer.baseAddress!

        
        switch rootItemType {
        case .null:
            
            Null().storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .bool:
            
            false.storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)

            
        case .int8:
            
            Int8(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .int16:
            
            Int16(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .int32:
            
            Int32(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .int64:
            
            Int64(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .uint8:
            
            UInt8(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .uint16:
            
            UInt16(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .uint32:
            
            UInt32(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .uint64:
            
            UInt64(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .float32:
            
            Float32(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .float64:
            
            Float64(0).storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
            
        case .binary:
            
            Data().storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)

            
        case .string:
            
            "".storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)

            
        case .array:
            
            guard let elementType = elementType else { buffer.deallocate() ; return nil }
            let arr = BrbonArray(content: [], type: elementType)
            arr.storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
        case .dictionary:
            
            let dict = BrbonDictionary(content: [:])
            dict.storeAsItem(atPtr: basePtr, bufferPtr: basePtr, parentPtr: basePtr, nameField: nfd, valueByteCount: itemValueByteCount, endianness)
            
        case .sequence: break
        }
        
        self.rootItem = Item(basePtr: basePtr, parentPtr: nil, endianness: endianness)
        self.rootItem.manager = self
    }
    
    
    deinit {
        
        
        // The active portals are no longer valid
        
        activePortals.forEachPortal() { _ = $0.invalidate() }

        
        // Release the buffer area
        
        buffer.deallocate()
    }
    
    internal func getPortal(for ptr: UnsafeMutableRawPointer) -> Portal {
        return activePortals.getPortal(for: ptr, mgr: self)
    }
    
    internal func unsubscribe(portal: Portal) {
        activePortals.decrementRefcountAndRemoveOnZero(for: portal)
    }
    
    internal func portalChange(oldBaseAddres: UnsafeMutableRawPointer, newBaseAddress: UnsafeMutableRawPointer) {
        let offset = oldBaseAddres.distance(to: newBaseAddress)
        activePortals.forEachPortal() { $0.updatePointers(by: offset) }
    }
    
    internal func portalUpdate(atOrAboveThisPtr refPtr: UnsafeMutableRawPointer, offset: Int) {
        activePortals.forEachPortal() { $0.update(atOrAboveThisPtr: refPtr, by: offset) }
    }
    
    internal func portalInvalidate(atOrAboveThisPtr startPtr: UnsafeMutableRawPointer, belowThisPtr endPtr: UnsafeMutableRawPointer) {
        activePortals.forEachPortal() { $0.invalidate(atOrAboveThisPtr: startPtr, belowThisPtr: endPtr) }
    }
}

extension ItemManager: BufferManagerProtocol {
    
    internal var unusedByteCount: Int { return buffer.count - rootItem.byteCount }
    
    internal func increaseBufferSize(by bytes: Int) -> Bool {
        
        guard bufferIncrements > 0 else { return false }
        
        let increase = Int(max(bytes, bufferIncrements))
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(count: buffer.count + increase)
        
        _ = Darwin.memmove(newBuffer.baseAddress!, buffer.baseAddress!, buffer.count)
        
        buffer = newBuffer
        basePtr = newBuffer.baseAddress!
        
        return true
    }
    
    internal func moveBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer, _ length: Int) {
        _ = Darwin.memmove(dstPtr, srcPtr, length)
    }
    
    internal func moveEndBlock(_ dstPtr: UnsafeMutableRawPointer, _ srcPtr: UnsafeMutableRawPointer) {
        let length = srcPtr.distance(to: basePtr.advanced(by: count))
        moveBlock(dstPtr, srcPtr, length)
    }
}
