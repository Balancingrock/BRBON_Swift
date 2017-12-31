//
//  Manager.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 26/12/17.
//
//

import Foundation
import BRUtils


internal let typeOffset = 0
internal let optionsOffset = 1
internal let flagsOffset = 2
internal let nameAreaLengthOffset = 3
internal let nvrLengthOffset = 4
internal let nvrOffset = 8




/// The manager of a BRBON data area

public class ItemManager {
    
    internal var buffer: UnsafeMutableRawBufferPointer
    internal var rootItem: DesignatedItemPointers!
    internal var entryPtr: UnsafeMutableRawPointer
    
    public var remaining: UInt32 { return UInt32(buffer.count - buffer.baseAddress!.distance(to: entryPtr)) }
    
    
    public let endianness: Endianness
    
    public let bufferIncrements: UInt32
    
    
    private init(initialBufferSize: UInt32 = 1024, bufferIncrements: UInt32 = 1024, endianness: Endianness) {
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: Int(initialBufferSize))
        self.entryPtr = self.buffer.baseAddress!
        self.bufferIncrements = bufferIncrements
        self.endianness = endianness
    }
    
    
    /// Returns a new manager for dictionary bases access.
    ///
    /// - Parameters:
    ///   - initialBufferSize: The size of the initial memory allocation for the internal data of the manager. Must be > 16. If this is not a multiple of 8, then the manager will use the next higher mutiple of 8.
    ///   - bufferIncrements: The size of the buffer increments when more is added than fits the present buffer. If this is not a multiple of 8, then the manager will use the next higher mutiple of 8. May be zero (i.e. no new allocations will be made).
    
    static func newDictionary(initialBufferSize: UInt32 = 1024, bufferIncrements: UInt32 = 1024, endianness: Endianness = machineEndianness) -> ItemManager? {
        
        guard initialBufferSize < UInt32(Int32.max) && initialBufferSize >= 16 else { return nil }
        guard bufferIncrements < UInt32(Int32.max) else { return nil }
        
        let manager = ItemManager(initialBufferSize: initialBufferSize.roundUpToNearestMultipleOf8(), bufferIncrements: bufferIncrements.roundUpToNearestMultipleOf8(), endianness: endianness)
        
        
        // Build the initial type
        
        ItemType.dictionary.rawValue.endianBytes(endianness, toPointer: &manager.entryPtr)
        UInt8(0).endianBytes(endianness, toPointer: &manager.entryPtr) // Options
        UInt8(0).endianBytes(endianness, toPointer: &manager.entryPtr) // Flags
        UInt8(0).endianBytes(endianness, toPointer: &manager.entryPtr) // Name size (top level has no name)
        UInt32(0).endianBytes(endianness, toPointer: &manager.entryPtr) // Size of initial name and value part
        UInt32(0).endianBytes(endianness, toPointer: &manager.entryPtr) // Count of the number of items
        UInt32(0).endianBytes(endianness, toPointer: &manager.entryPtr) // Must be zero
        
        manager.rootItem = DesignatedItemPointers(manager.buffer.baseAddress!, endianness: endianness)
        
        return manager
    }

    
    /// - Returns: The available space in the managed data area.
    
    internal func availableBytes() -> UInt32 {
        return UInt32(buffer.count - (buffer.baseAddress!.distance(to: entryPtr)))
    }
    
    
    /// Increments the buffer size by bufferIncrements bytes.
    ///
    /// Note that this involves a memory allocation, copy and deallocation operations which can be costly.
    ///
    /// - Returns: True on success, false on failure.
    
    internal func incrementBufferSize() -> Bool {
        if bufferIncrements == 0 { return false }
        let newSize = buffer.count + Int(bufferIncrements)
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(count: newSize)
        let byteCount = buffer.baseAddress!.distance(to: entryPtr)
        _ = Darwin.memcpy(newBuffer.baseAddress!, buffer.baseAddress!, byteCount)
        buffer.deallocate()
        buffer = newBuffer
        entryPtr = buffer.baseAddress!.advanced(by: byteCount)
        rootItem = DesignatedItemPointers(buffer.baseAddress!, endianness: endianness)
        return true
    }
    
    
    /// If an item with the given name exists, that item will be removed. The given value will be added at the end if enough space is available.
    ///
    /// - Parameters:
    ///   - value: The value to be included in an item with the given name.
    ///   - for: The name under which the value can be found.
    ///
    /// - Returns: True if the operation was succesfull. False otherwise.
    
    func add(_ value: EndianBytes, at path: [Any]) -> Bool {
        return false
    }
}
