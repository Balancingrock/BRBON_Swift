//
//  Manager.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 26/12/17.
//
//

import Foundation
import BRUtils


// ******************************************************************
// **                                                              **
// ** INTERNAL OPERATIONS ARE NOT PROTECTED AGAINST ILLEGAL VALUES **
// **                                                              **
// ******************************************************************


/// The manager of a BRBON data area

public class DictionaryManager {
    
    
    /// The buffer containing the root item with all child items.
    
    internal var buffer: UnsafeMutableRawBufferPointer
    
    
    /// The entry point for new items.
    
    internal var entryPtr: UnsafeMutableRawPointer
    
    
    /// A pointer to the root item
    
    internal var rootItem: DictionaryItem!
    
    
    /// The number of bytes not yet used in the buffer
    
    public var availbleBytes: UInt32 { return UInt32(buffer.count - buffer.baseAddress!.distance(to: entryPtr)) }
    
    
    /// The endianness of the root item and all child items
    
    public let endianness: Endianness
    
    
    /// The number of bytes with which to increment the buffer size if there is insufficient free space available.
    
    public let bufferIncrements: UInt32
    
    
    /// Returns the buffer as a Data object. The buffer will not be copied, but wrapped in a data object.
    
    public var asData: Data {
        let count = buffer.baseAddress!.distance(to: entryPtr)
        return Data(bytesNoCopy: buffer.baseAddress!, count: count, deallocator: Data.Deallocator.none)
    }
    
    
    /// Create a new DictionaryManager.
    ///
    /// - Parameters:
    ///   - initialBufferSize: The size of the buffer area used for the initial allocation.
    ///   - bufferIncrements: The number of bytes with which to increment the buffer if it is too small.
    ///   - endianness: The endianness to be used in this dictionary manager.
    
    public init?(
        name: String? = nil,
        fixedNameFieldLength: UInt8? = nil,
        fixedItemLength: UInt32? = nil,
        initialBufferSize: UInt32 = 1024,
        bufferIncrements: UInt32 = 1024,
        endianness: Endianness) {
        
        var bufferSize = initialBufferSize
        var increments = bufferIncrements

        if let fixedItemByteCount = fixedItemLength, initialBufferSize > fixedItemByteCount {
            bufferSize = initialBufferSize
            increments = 0
        }
        self.bufferIncrements = increments
        
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: Int(bufferSize))
        
        guard let dictbuf = DictionaryItem.createInBuffer(name, fixedNameFieldLength: fixedNameFieldLength, fixedItemLength: fixedItemLength, endianness: endianness) else { return nil }
        
        _ = Darwin.memmove(self.buffer.baseAddress!, dictbuf.baseAddress!, dictbuf.count)
        
        dictbuf.deallocate()
        
        self.entryPtr = self.buffer.baseAddress!
        self.endianness = endianness
    }
    
    
    /// Cleanup.
    
    deinit { self.buffer.deallocate() }
    
    
    internal func add(_ value: BrbonBytes, name: String? = nil, fixedNameFieldByteCount: UInt8? = nil, fixedItemLength: UInt32? = nil) -> Bool {
        
    }

    
    
    /// Adds a value to a dictionary or sequence.
    ///
    /// - Parameters:
    ///   - value: The value to be added.
    ///   - path: The path to the parent to which to add the value. The path must consist of an array of Strings and Integers. The last path component must be a String, and that string will be used as the name for the value. The preceding path component must select a dictionary or sequence for the operation to succeed.
    ///
    /// - Returns: True if the operation was succesfull. False otherwise.
    /*
    public func add(_ value: EndianBytes, at path: [Any]) -> Bool {

        guard path.count > 0 else { return false }
        
        guard let name = path.last as? String else { return false }
        
        guard let parent = rootItem.item(at: Array(path.dropLast())) else { return false }
        
        guard parent.isDictionary || parent.isSequence else { return false }
        
        
        // Create the byte representation for the new item
        
        guard let itemBuffer = createValueItemByteBuffer(value, parentOffset: UInt32(buffer.baseAddress!.distance(to: parent.headerPtr))) else { return false }
        defer { itemBuffer.deallocate() }
        
        
        // Remove a previous item with the same name if the parent is a dictionary
        
        if parent.isDictionary {
            if let itemToRemove = parent.item(at: [name]) {
                remove(itemToRemove, parent: parent)
            }
        }

        
        // Make sure the buffer is large enough
        
        while availableBytes() < UInt32(itemBuffer.count) {
            guard incrementBufferSize() else { return false }
        }
        
        
        // Insert the buffer at the end of the dictionary or sequence
        
        append(itemBuffer, toDictionary: parent)
        
        
        // Increase the number of items in the parent
        
        parent.incrementCount()
        
        
        return true
    }
    
    */
    
}
