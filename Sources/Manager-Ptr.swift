//
//  ItemPtr.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 28/12/17.
//
//

import Foundation
import BRUtils


// *************************************************************************
// **                                                                     **
// ** NONE OF THE OPERATIONS IN HERE ARE PROTECTED AGAINST ILLEGAL VALUES **
// **                                                                     **
// *************************************************************************
//
// Any operation that uses a current item pointer (cip) or designated item pointers (dip) is not protected against
// illegal values.
// I.e. the operation will always assume that the pointed at area's will indeed support the purported operations.
//
// A CIP (Current Item Pointer) is a pointer at a guaranteed contigious item.
// A DIP (Designated Item Pointers) are two pointer values, the first pointing at the Item-Header & Item-NVR-Length
// area and the second at the NVR area. These two areas do not need to be adjacent. If they are adjacent, no
// conclusions can be drawn from that!)
//
// 'Current Item' (CI) is used to talk about the information stored at the current item pointer. Sometimes CI and CIP
// can be used interchangeably.
// 'Designated Item' (DI) is used to talk about the information stored at the designated item pointers. Sometimes DI
// and DIP can be used interchangeably.
//
// All pointers names end in 'Ptr' with exception of the CIP and DIP.


/// The CIP points to the first byte of a contigious item.

internal typealias CurrentItemPointer = UnsafeMutableRawPointer


/// Returns the length of the name area in the current item.
///
/// - Parameter cip: Points at the current item.
//
/// - Returns: The number of bytes of the name area (may be zero)

internal func nameAreaLength(_ cip: CurrentItemPointer) -> UInt8 {
    return cip.advanced(by: nameAreaLengthOffset).assumingMemoryBound(to: UInt8.self).pointee
}


/// Tests if the current item is of the required type.
///
/// - Parameters:
///   - cip: Must point to the first byte of an item.
///   - type: The type to test the item for.
/// - Returns: True if the type of the item pointed at equals the given type.

internal func isType(_ cip: CurrentItemPointer, _ type: ItemType) -> Bool {
    return cip.assumingMemoryBound(to: UInt8.self).pointee == type.rawValue
}


/// Returns a pointer to the value area of the designated item.
///
/// - Parameter dip: The designated item.
///
/// - Returns: A pointer to the start of the value area.

internal func valuePtr(_ dip: DesignatedItemPointers) -> UnsafeMutableRawPointer {
    return dip.nvrPtr.advanced(by: Int(nameAreaLength(dip.itemPtr)))
}


/// Extends the manager with pointer manipulation operations.

extension ItemManager {
    

    /// The number of items contained in the designated item.
    ///
    /// - Parameter dip: The designated item.
    /// - Returns: The number of child items.

    internal func itemCount(_ dip: DesignatedItemPointers) -> UInt32 {
        return UInt32(valuePtr(dip), endianness: endianness)
    }

    
    /// Returns true if the name in the designated item equals the given information.
    ///
    /// - Parameters:
    ///   - dip: The designated item.
    ///   - hash: The CRC16 has of the name.
    ///   - name: A data struct that contains the UTF8 bytes in the name to compare against the name in the item.
    /// - Returns: True if the names match, false otherwise.

    internal func nameEquals(_ dip: DesignatedItemPointers, hash: UInt16, name: Data) -> Bool {
        if nameAreaLength(dip.itemPtr) == 0 { return false }
        if hash != UInt16(dip.nvrPtr, endianness: endianness) { return false }
        if name.count != Int(UInt8(dip.nvrPtr.advanced(by: 1), endianness: endianness)) { return false }
        let nameData = Data(dip.nvrPtr.advanced(by: 2), endianness: endianness, count: UInt32(name.count))
        return name == nameData
    }


    /// Returns a pointer to the item after the current item.
    ///
    /// - Parameter cip: A pointer to the current item. (The current item must be a member of a .dictionary or .sequence)
    /// - Returns: A pointer to the first byte after the item.

    internal func nextItem(_ cip: CurrentItemPointer) -> UnsafeMutableRawPointer {
        let nvrSize = UInt32(cip.advanced(by: nvrLengthOffset), endianness: endianness)
        return cip.advanced(by: Int(nvrSize) + 8)
    }

    
    /// Returns a pointer to the item after the designated item.
    ///
    /// - Parameter dip: The designated item. (The designated item must be a member of a .dictionary or .sequence)
    /// - Returns: A pointer to the next designated item.
    
    internal func nextItem(_ dip: DesignatedItemPointers) -> DesignatedItemPointers {
        let nvrSize = UInt32(dip.itemPtr.advanced(by: nvrLengthOffset), endianness: endianness)
        return DesignatedItemPointers(dip.nvrPtr.advanced(by: Int(nvrSize) + 8), endianness: endianness)
    }
    
    
    /// Returns a designated item for the given index.
    ///
    /// - Parameters:
    ///   - at: The index for which to get the designated item.
    ///   - dip: The designated item (must contain an array).
    ///
    /// - Returns: The designated item for the requested index.
    
    internal func designatedItem(at index: UInt32, dip: DesignatedItemPointers) -> DesignatedItemPointers {
        let elementSize = Int(UInt32(dip.nvrPtr.advanced(by: 12), endianness: endianness))
        let elementOffset = (Int64(index) * Int64(elementSize)) + 16
        return DesignatedItemPointers(itemPtr: dip.nvrPtr.advanced(by: 8), nvrPtr: dip.nvrPtr.advanced(by: Int(elementOffset)), endianness: endianness)
    }

    
    /// Decrements the counter for the number of child elements/items.
    ///
    /// - Parameter dip: The designated item (must be an array, dictionary or sequence)
    
    internal func decrementChildCount(_ dip: DesignatedItemPointers) {
        var cptr = valuePtr(dip)
        let c = UInt32(cptr, endianness: endianness)
        (c - 1).endianBytes(endianness, toPointer: &cptr)
    }
    
    


    /// Returns the designated item at the path starting from a designated item.
    ///
    /// The path consists of a sequence of String and Integers.
    ///
    /// - Parameters:
    ///   - dip: The designated item.
    ///   - path: An array of strings and integers used to select an item. Nil is returned if a path element is not an integer or string.
    ///   - pathIndex: The index into the path for which find the designated item.
    ///
    /// - Returns: The designated item, or nil if none could be found (either an error, or it does not exist)

    internal func itemAt(_ dip: DesignatedItemPointers, path: [Any], _ pathIndex: Int = 0) -> DesignatedItemPointers? {
        
        
        // Make sure the path and its index are usable
        
        if path.count == 0 || pathIndex >= path.count { return nil }
        
        
        // Perform the lookup for an integer index
        
        if path[pathIndex] is Int {
            
            var index = path[pathIndex] as! Int
            
            
            // Check if the index is within range
            
            let itemCount = Int(self.itemCount(dip))
            guard itemCount > 0 else { return nil }
            guard index < itemCount else { return nil }
            
            
            // Array lookup
            
            if isType(dip.itemPtr, .array) {
                
                // Get the designated item at the requeted index
                
                let designatedItem = self.designatedItem(at: UInt32(index), dip: dip)
                
                
                // If this was the last path element then return it as the result, otherwise go deeper.
                
                if path.count == (pathIndex + 1) {
                    return designatedItem
                } else {
                    return itemAt(designatedItem, path: path, pathIndex + 1)
                }
            }
            
            
            // Sequence lookup
            
            if isType(dip.itemPtr, .sequence) {
                
                
                // Start at the first item and keep going until the required index
                
                var cip = dip.nvrPtr.advanced(by: 8)
                while index != 0 {
                    cip = nextItem(cip)
                    index -= 1
                }
                
                let designatedItem = DesignatedItemPointers(cip, endianness: endianness)
                
                
                // If this was the last path element then return it as the result, otherwise go deeper.
                
                if path.count == (pathIndex + 1) {
                    return designatedItem
                } else {
                    return itemAt(designatedItem, path: path, pathIndex + 1)
                }
            }
            
            return nil
        }
        
        
        // Perform the lookup for a name
        
        if path.first! is String {
            
            
            // Get the name of the item to look for
            
            let lookupName = path.first! as! String
            
            
            // The designated item must be a .dictionary or .sequence
            
            guard isType(dip.itemPtr, .dictionary) || isType(dip.itemPtr, .sequence) else { return nil }
            
            
            // Get the number of items in the designated item
            
            var itemCount = UInt32(dip.nvrPtr, endianness: endianness)
            guard itemCount > 0 else { return nil }
            
            
            // The name check will in fact use the utf8 byte representation
            
            guard let lookupData = lookupName.data(using: .utf8) else { return nil }
            
            
            // To speed up the name test, first test a hash value
            
            let lookupHash = lookupData.crc16()
            
            
            // Get the first item to check
            
            var testCip = dip.nvrPtr.advanced(by: 8)
            
            
            // Keep on checking until all items have been checked or a match is found
            
            while itemCount > 0 {
                
                
                // If the name is found...
                
                let testDip = DesignatedItemPointers(testCip, endianness: endianness)
                if nameEquals(testDip, hash: lookupHash, name: lookupData) {


                    // If this was the last path element then return it as the result, otherwise go deeper.
                    
                    if path.count == (pathIndex + 1) {
                        return testDip
                    } else {
                        return itemAt(testDip, path: path, pathIndex + 1)
                    }
                }
                
                
                // This item is not it, go to next item
                
                itemCount -= 1
                if itemCount > 0 { testCip = nextItem(testCip) }
            }
            
            return nil
        }
        
        
        // Wrong type of lookup parameter
        
        return nil
    }
    
    
    /// Execute the given closure for each item until the last or until the closure returns 'false'.
    
    internal func forEachDoWhileTrue(_ dip: DesignatedItemPointers, _ closure: (DesignatedItemPointers) -> (Bool)) {
        
        if isType(dip.itemPtr, .array) {
            
            let count = itemCount(dip)
            
            var index: UInt32 = 0
            
            while index < count {
                
                let item = designatedItem(at: index, dip: dip)
                
                if !closure(item) { return }
                
                index += 1
            }
            
            return
        }
        
        if isType(dip.itemPtr, .dictionary) || isType(dip.itemPtr, .sequence) {
            
            let count = itemCount(dip)
            
            var index: UInt32 = 0
            
            var item = DesignatedItemPointers(dip.nvrPtr.advanced(by: 8), endianness: endianness)

            while index < count {
                
                if !closure(item) { return }
                
                index += 1
                
                if index < count { item = nextItem(item) }
            }
        }
    }

    
    /// Removes a block of memory from the internal data structure.
    ///
    /// - Parameters:
    ///   - fromPtr: A pointer to the first byte to be removed.
    ///   - upToPtr: A pointer to the first byte NOT to be removed.
    
    internal func removeBlock(fromPtr: UnsafeMutableRawPointer, upToPtr: UnsafeMutableRawPointer) {
        let bytes = upToPtr.distance(to: entryPtr)
        _ = Darwin.memmove(fromPtr, upToPtr, bytes)
        let newCount = buffer.baseAddress!.distance(to: entryPtr) - bytes
        entryPtr = buffer.baseAddress!.advanced(by: newCount)
    }
    
    
    /// Remove a designated item from a parent designated item. The item count in the parent will be decremented.
    ///
    /// - Parameters:
    ///   - dip: The designated item to be removed.
    ///   - parentDip: The designated item from which the item is removed.
    
    @discardableResult
    internal func removeDip(_ dip: DesignatedItemPointers, from parentDip: DesignatedItemPointers) {
        
        var srcPtr: UnsafeMutableRawPointer!
        
        if isType(parentDip.itemPtr, .array) {
            
            
            // Get the source address for the removal
            
            let elementSize = UInt32(parentDip.nvrPtr.advanced(by: 12), endianness: endianness)
            srcPtr = dip.nvrPtr.advanced(by: Int(elementSize))
        }
        
        
        if isType(parentDip.itemPtr, .dictionary) || isType(parentDip.itemPtr, .sequence) {
            
            
            // Get the source address for the removal
            
            srcPtr = nextItem(dip.itemPtr)
        }
        
        
        // If the item is the last item
            
        if srcPtr == entryPtr {
            
                
            // Just move the entryPtr to the first byte to be removed
                
            entryPtr = dip.itemPtr

        } else {
            
            
            // Remove by shifting the data downward
            
            removeBlock(fromPtr: dip.itemPtr, upToPtr: srcPtr)
        }
        
        
        // Decrement the counter index in the parent
            
        decrementChildCount(parentDip)
    }
}










