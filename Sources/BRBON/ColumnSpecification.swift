// =====================================================================================================================
//
//  File:       ColumnSpecification.swift
//  Project:    BRBON
//
//  Version:    1.0.0
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
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


/// The specification for a single column in a table item.

public struct ColumnSpecification {

    
    /// The type of item to be stored in the associated column.
    
    internal let fieldType: ItemType
    
    
    /// The byte count for the value to be stored in the column.
    ///
    /// If absent, it will be set to the default value (as defined by the 'minimumElementByteCount' in ItemType.swift), rounded up to the nearest multiple of 8.
    
    internal let fieldByteCount: Int
    
    
    /// The name field for this column.
    
    internal var nameField: NameField
    
    
    /// The offset for the name in the value field, will be computed when creating a table.
    
    internal var nameOffset: Int = 0
    
    
    /// The offset for the column value in a row, will be computed when creating a table.
    
    internal var fieldOffset: Int = 0
    
    
    /// Create a new column descriptor.
    ///
    /// - Parameters:
    ///   - type: The type of value that will be stored in this column.
    ///   - nameField: The name field for the column.
    ///   - byteCount: The initial byte count reserved for the items in this column. Range 'minimumElementByteCount'...Int32.max. In the current implementation it will be rounded up -if necessary- to a multiple of 8, this may change in future versions.
    
    public init(
        type: ItemType,
        nameField: NameField,
        byteCount: Int) {
        
        self.nameField = nameField
        self.fieldType = type
        self.fieldByteCount = byteCount.roundUpToNearestMultipleOf8()
    }
    
    
    /// Create a new column descriptor from a byte stream in a table.
    ///
    /// - Parameters:
    ///   - fromPtr: A pointer to the base of the serialized column descriptor of a table structure.
    ///   - forColumn: The index of the column to read the descriptor for.
    ///   - endianness: The endianness used for the table.
    
    internal init?(fromPtr: UnsafeMutableRawPointer, forColumn column: Int, _ endianness: Endianness) {
        
        
        // Start of the descriptor for the requested column
        
        let ptr = fromPtr.advanced(by: tableColumnDescriptorBaseOffset + column * tableColumnDescriptorByteCount)
        
        
        // Read the type of the value field
        
        guard let type = ItemType(atPtr: ptr.advanced(by: tableColumnFieldTypeOffset)) else { return nil }
        self.fieldType = type
        
        
        if endianness == machineEndianness {
        
            // Read the byte count of the value field
            
            self.fieldByteCount = Int(ptr.advanced(by: tableColumnFieldByteCountOffset).assumingMemoryBound(to: UInt32.self).pointee)
            
            
            // Get the name field
            
            let nameCrc = ptr.advanced(by: tableColumnNameCrcOffset).assumingMemoryBound(to: UInt16.self).pointee
            let nameByteCount = Int(ptr.advanced(by: tableColumnNameByteCountOffset).assumingMemoryBound(to: UInt8.self).pointee)
            let nameUtf8Offset = Int(ptr.advanced(by: tableColumnNameUtf8CodeOffsetOffset).assumingMemoryBound(to: UInt32.self).pointee)
            
            let nameDataCount = Int(fromPtr.advanced(by: nameUtf8Offset).assumingMemoryBound(to: UInt8.self).pointee)
            let nameData = Data(bytes: fromPtr.advanced(by: nameUtf8Offset + 1), count: nameDataCount)
            self.nameField = NameField(data: nameData, crc: nameCrc, byteCount: nameByteCount)

        } else {

            // Read the byte count of the value field
            
            self.fieldByteCount = Int(ptr.advanced(by: tableColumnFieldByteCountOffset).assumingMemoryBound(to: UInt32.self).pointee.byteSwapped)

            
            // Get the name field
            
            let nameCrc = ptr.advanced(by: tableColumnNameCrcOffset).assumingMemoryBound(to: UInt16.self).pointee.byteSwapped
            let nameByteCount = Int(ptr.advanced(by: tableColumnNameByteCountOffset).assumingMemoryBound(to: UInt8.self).pointee)
            let nameUtf8Offset = Int(ptr.advanced(by: tableColumnNameUtf8CodeOffsetOffset).assumingMemoryBound(to: UInt32.self).pointee.byteSwapped)

            let nameDataCount = Int(fromPtr.advanced(by: nameUtf8Offset).assumingMemoryBound(to: UInt8.self).pointee)
            let nameData = Data(bytes: fromPtr.advanced(by: nameUtf8Offset + 1), count: nameDataCount)
            self.nameField = NameField(data: nameData, crc: nameCrc, byteCount: nameByteCount)
        }
    }
}

