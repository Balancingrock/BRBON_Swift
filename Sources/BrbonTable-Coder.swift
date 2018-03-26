//
//  Table-Coder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/03/18.
//
//

import Foundation
import BRUtils


/// The specification of a single column in the table.

public struct ColumnSpecification {

    
    /// The type of item to be stored in the associated column.
    
    internal let fieldType: ItemType
    
    
    /// The byte count for the value in the column. If absent, it will be set to the default value (as defined for the type), rounded up to the nearest multiple of 8.
    
    internal let fieldByteCount: Int
    
    
    /// The name field for this column.
    
    internal var name: NameField
    
    
    /// The offset for the name in the value field, will be computed when storing to memory
    
    internal var nameOffset: Int = 0
    
    
    /// The offset for the column value in a row, will be computed when storingto memory
    
    internal var fieldOffset: Int = 0
    
    
    /// Creates a new column descriptor.
    ///
    /// - Parameters:
    ///   - type: The type of value that will be stored in this column.
    ///   - name: The column name.
    ///   - byteCount: The initial byte count reserved for items in this column. Maximum byte count is Int32.max, minimum is the minimum byte count possible for the type. Will always be rounded up to a multiple of 8 bytes. (Note that 8 bytes is the minimum possible, even for booleans)
    
    public init(
        type: ItemType,
        name: NameField,
        byteCount: Int) {
        
        self.name = name
        self.fieldType = type
        self.fieldByteCount = byteCount.roundUpToNearestMultipleOf8()
    }
    
    internal init?(fromPtr: UnsafeMutableRawPointer, forColumn column: Int, _ endianness: Endianness) {
        
        // Start of the column descriptor
        let ptr = fromPtr.advanced(by: tableColumnDescriptorBaseOffset)
        
        // Get value type
        guard let type = ItemType(atPtr: ptr.advanced(by: tableColumnFieldTypeOffset)) else { return nil }
        self.fieldType = type
        
        // Get value byte count
        self.fieldByteCount = Int(UInt32(fromPtr: ptr.advanced(by: tableColumnFieldByteCountOffset), endianness))
        
        // Get nfd
        let nameCrc = UInt16(fromPtr: ptr.advanced(by: tableColumnNameCrcOffset), endianness)
        let nameByteCount = Int(UInt8(fromPtr: ptr.advanced(by: tableColumnNameByteCountOffset), endianness))
        let nameUtf8Offset = Int(UInt32(fromPtr: ptr.advanced(by: tableColumnNameUtf8CodeOffsetOffset), endianness))
        let nameDataCount = Int(Int8(fromPtr: fromPtr.advanced(by: nameUtf8Offset), endianness))
        let nameData = Data(bytes: fromPtr.advanced(by: nameUtf8Offset + 1), count: nameDataCount)
        self.name = NameField(data: nameData, crc: nameCrc, byteCount: nameByteCount)
    }
}


public class BrbonTable: Coder {

    
    public init(columnSpecifications: Array<ColumnSpecification>) {
        self.columns = columnSpecifications
    }
    
    internal var columns: Array<ColumnSpecification>
    
    public var itemType: ItemType { return ItemType.table }
    
    public var valueByteCount: Int {
        
        // Start with the first 4 table parameters, each 4 bytes long
        
        var total = 16

        
        // Exit if there are no columns
        
        if columns.count == 0 { return total }
        
        
        // Add the column descriptor, 16 bytes for each column
        
        total += columns.count * 16
        
        
        // Add the name field byte counts
        
        columns.forEach() {
            total += $0.name.byteCount
        }
        
        
        // There are not rows yet.
        
        return total
    }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        UInt32(0).storeValue(atPtr: atPtr, endianness)
        tableWriteSpecification(valueFieldPtr: atPtr, &columns, endianness)
    }
}
