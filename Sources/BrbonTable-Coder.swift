//
//  Table-Coder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 03/03/18.
//
//

import Foundation
import BRUtils


internal let tableRowCountOffset = 0
internal let tableColumnCountOffset = 4
internal let tableRowsOffsetOffset = 8
internal let tableRowByteCountOffset = 12
internal let columnDescriptorBaseOffset = 16

internal let columnDescriptorByteCount = 16

internal let columnNameCrc16Offset = 0
internal let columnNameByteCountOffset = 2
internal let columnValueTypeOffset = 3
internal let columnNameUtf8OffsetOffset = 4
internal let columnValueOffsetOffset = 8
internal let columnValueByteCountOffset = 12


/// The specification of a single column in the table.

public struct ColumnSpecification {

    
    /// The type of item to be stored in the associated column.
    
    internal let valueType: ItemType
    
    
    /// The byte count for the value in the column. If absent, it will be set to the default value (as defined for the type), rounded up to the nearest multiple of 8.
    
    internal let valueByteCount: Int
    
    
    /// The name field descriptor for this column.
    
    internal var nfd: NameFieldDescriptor
    
    
    /// The offset for the name in the value field, will be computed when storing to memory
    
    internal var nameOffset: Int = 0
    
    
    /// The offset for the column value in a row, will be computed when storingto memory
    
    internal var valueOffset: Int = 0
    
    
    /// Creates a new column descriptor.
    ///
    /// - Parameters:
    ///   - name: The column name, should be no more than 245 UTF8 byte code units.
    ///   - initialNameFieldByteCount: The byte count to use for the name field, should be no more than 248 bytes and will always be rounded up to a multiple of 8. Default = (3 + UTF8-code-units) rounded up to first multiple of 8.
    ///   - valueType: The type of value that will be stored in this column.
    ///   - initialValueByteCount: The initial byte count reserved for items in this column. Maximum byte count is Int32.max, minimum is the minimum byte count possible for the type. Will always be rounded up to a multiple of 8 bytes. If not specified, the assumed byte count as specified for that type will be used. (Note that 8 bytes is the minimum possible, even for booleans)
    
    public init?(
        name: String,
        initialNameFieldByteCount: Int? = nil,
        valueType: ItemType,
        initialValueByteCount: Int? = nil) {
        
        guard let temp = NameFieldDescriptor(name, fixedLength: initialNameFieldByteCount) else { return nil }
        
        self.nfd = temp
        self.valueType = valueType
        self.valueByteCount = (initialValueByteCount ?? valueType.assumedValueByteCount).roundUpToNearestMultipleOf8()
    }
    
    internal init?(valueAreaPtr: UnsafeMutableRawPointer, forColumn column: Int, _ endianness: Endianness) {
        
        // Start of the column descriptor
        let ptr = valueAreaPtr.advanced(by: 16 + column * 16)
        
        // Get value type
        guard let type = ItemType(atPtr: ptr.advanced(by: columnValueTypeOffset)) else { return nil }
        self.valueType = type
        
        // Get value byte count
        self.valueByteCount = Int(UInt32(valuePtr: ptr.advanced(by: columnValueByteCountOffset), endianness))
        
        // Get nfd
        let nameCrc = UInt16(valuePtr: ptr.advanced(by: columnNameCrc16Offset), endianness)
        let nameByteCount = Int(UInt8(valuePtr: ptr.advanced(by: columnNameByteCountOffset), endianness))
        let nameUtf8Offset = Int(UInt32(valuePtr: ptr.advanced(by: columnNameUtf8OffsetOffset), endianness))
        let nameDataCount = Int(Int8(valuePtr: valueAreaPtr.advanced(by: nameUtf8Offset), endianness))
        let nameData = Data(valuePtr: valueAreaPtr.advanced(by: nameUtf8Offset + 1), count: nameDataCount, endianness)
        self.nfd = NameFieldDescriptor(data: nameData, crc: nameCrc, byteCount: nameByteCount)
    }
}


public class BrbonTable: Coder {

    
    public init(columnSpecifications: Array<ColumnSpecification>) {
        self.columns = columnSpecifications
    }
    
    internal var columns: Array<ColumnSpecification>
    
    public var brbonType: ItemType { return ItemType.table }
    
    public var valueByteCount: Int {
        
        // Start with the first 4 table parameters, each 4 bytes long
        
        var total = 16

        
        // Exit if there are no columns
        
        if columns.count == 0 { return total }
        
        
        // Add the column descriptor, 16 bytes for each column
        
        total += columns.count * 16
        
        
        // Add the name field byte counts
        
        columns.forEach() {
            total += $0.nfd.byteCount
        }
        
        
        return total
    }
    
    public func itemByteCount(_ nfd: NameFieldDescriptor? = nil) -> Int {
        return minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount
    }
    
    public var elementByteCount: Int { return itemByteCount() }

    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        fatalError("Do not use storeValue, use storeAsItem instead")
    }
    
    @discardableResult
    func storeAsItem(atPtr: UnsafeMutableRawPointer, bufferPtr: UnsafeMutableRawPointer, parentPtr: UnsafeMutableRawPointer, nameField nfd: NameFieldDescriptor?, valueByteCount: Int?, _ endianness: Endianness) -> Result {
        
        var byteCount = itemByteCount(nfd)
        
        let nameFieldByteCount = nfd?.byteCount ?? 0
        
        if let valueByteCount = valueByteCount {
            let alternateByteCount = (minimumItemByteCount + nameFieldByteCount + 4 + valueByteCount).roundUpToNearestMultipleOf8()
            if alternateByteCount > byteCount { byteCount = alternateByteCount }
        }
        
        brbonType.storeValue(atPtr: atPtr.brbonItemTypePtr)
        
        ItemOptions.none.storeValue(atPtr: atPtr.brbonItemOptionsPtr)
        
        ItemFlags.none.storeValue(atPtr: atPtr.brbonItemFlagsPtr)
        
        UInt8(nameFieldByteCount).storeValue(atPtr: atPtr.brbonItemNameFieldByteCountPtr, endianness)
        
        UInt32(byteCount).storeValue(atPtr: atPtr.brbonItemByteCountPtr, endianness)
        
        UInt32(bufferPtr.distance(to: parentPtr)).storeValue(atPtr: atPtr.brbonItemParentOffsetPtr, endianness)
        
        UInt32(0).storeValue(atPtr: atPtr.brbonItemCountValuePtr, endianness)
        
        nfd?.storeValue(atPtr: atPtr.brbonItemNameFieldPtr, endianness)
        
        
        // Calculate the name and value offsets
        
        var nameOffset = 16 + 16 * columns.count
        var valueOffset = 0
        for i in 0 ..< columns.count {
            columns[i].nameOffset = nameOffset
            nameOffset += columns[i].nfd.byteCount
            columns[i].valueOffset = valueOffset
            valueOffset += columns[i].valueByteCount
        }
        let rowByteCount = valueOffset
        let rowsOffset = nameOffset


        let ptr = atPtr.brbonItemValuePtr

        
        // Row Count
        UInt32(0).storeValue(atPtr: ptr, endianness)
        
        // Column Count
        UInt32(columns.count).storeValue(atPtr: ptr.advanced(by: tableColumnCountOffset), endianness)
        
        // Rows Offset
        UInt32(rowsOffset).storeValue(atPtr: ptr.advanced(by: tableRowsOffsetOffset), endianness)
        
        // Row Byte Count
        UInt32(rowByteCount).storeValue(atPtr: ptr.advanced(by: tableRowByteCountOffset), endianness)

        
        if columns.count == 0 { return .success }

        
        // Column Descriptors
        let columnDescriptorsPtr = ptr.advanced(by: columnDescriptorBaseOffset)
        for (index, column) in columns.enumerated() {
            let descriptorPtr = columnDescriptorsPtr.advanced(by: index * columnDescriptorByteCount)
            column.nfd.crc.storeValue(atPtr: descriptorPtr, endianness)
            UInt8(column.nfd.byteCount).storeValue(atPtr: descriptorPtr.advanced(by: columnNameByteCountOffset), endianness)
            column.valueType.storeValue(atPtr: descriptorPtr.advanced(by: columnValueTypeOffset))
            UInt32(column.nameOffset).storeValue(atPtr: descriptorPtr.advanced(by: columnNameUtf8OffsetOffset), endianness)
            UInt32(column.valueOffset).storeValue(atPtr: descriptorPtr.advanced(by: columnValueOffsetOffset), endianness)
            UInt32(column.valueByteCount).storeValue(atPtr: descriptorPtr.advanced(by: columnValueByteCountOffset), endianness)
        }
        
        // Column names
        var columnNamePtr = columnDescriptorsPtr.advanced(by: columns.count * columnDescriptorByteCount)
        for column in columns {
            UInt8(column.nfd.data.count).storeValue(atPtr: columnNamePtr, endianness)
            column.nfd.data.storeValue(atPtr: columnNamePtr.advanced(by: 1), endianness)
            columnNamePtr = columnNamePtr.advanced(by: (column.nfd.byteCount))
        }
                
        return .success
    }
    
    func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        fatalError("Do not use storeAsElement, use storeAsItem instead")
    }
}
