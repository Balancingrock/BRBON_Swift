// =====================================================================================================================
//
//  File:       Table.swift
//  Project:    BRBON
//
//  Version:    1.2.2
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
// 1.2.2 - Removed unneeded comment lines
//       - Renamed a variable for better code readability
// 1.2.0 - Added ColumnSpecificationItterator and itterateColumnSpecifications
// 1.1.0 - Bugfix for cases where a table name was not taken into account when increasing the size of a table
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


/// This is the signature of a closure that can be used to provide default values for table fields.

public typealias SetTableFieldDefaultValue = (Portal) -> ()


/// Rewrites the complete table specification with the exception of the row count.
///
/// - Parameters:
///   - valueFieldPtr: A pointer to the value field of a table item.
///   - columns: An array with table column specifications.
///   - endianness: The endianness to be used for the values.

internal func tableWriteSpecification(valueFieldPtr ptr: UnsafeMutableRawPointer, _ arr: inout Array<ColumnSpecification>, _ endianness: Endianness) {
    
    // Calculate the name and value offsets
    var nameOffset = tableColumnDescriptorBaseOffset + tableColumnDescriptorByteCount * arr.count
    var fieldOffset = 0
    for i in 0 ..< arr.count {
        arr[i].nameOffset = nameOffset
        nameOffset += arr[i].nameField.byteCount
        arr[i].fieldOffset = fieldOffset
        fieldOffset += arr[i].fieldByteCount
    }
    let rowsOffset = nameOffset
    let rowByteCount = fieldOffset
    
    // Column Count
    UInt32(arr.count).copyBytes(to: ptr.advanced(by: tableColumnCountOffset), endianness)
    
    // Rows Offset
    UInt32(rowsOffset).copyBytes(to: ptr.advanced(by: tableRowsOffsetOffset), endianness)
    
    // Row Byte Count
    UInt32(rowByteCount).copyBytes(to: ptr.advanced(by: tableRowByteCountOffset), endianness)
    
    // Column Descriptors
    let columnDescriptorsPtr = ptr.advanced(by: tableColumnDescriptorBaseOffset)
    for (index, column) in arr.enumerated() {
        let descriptorPtr = columnDescriptorsPtr.advanced(by: index * tableColumnDescriptorByteCount)
        column.nameField.crc.copyBytes(to: descriptorPtr, endianness)
        UInt8(column.nameField.byteCount).copyBytes(to: descriptorPtr.advanced(by: tableColumnNameByteCountOffset), endianness)
        column.fieldType.copyBytes(to: descriptorPtr.advanced(by: tableColumnFieldTypeOffset))
        UInt32(column.nameOffset).copyBytes(to: descriptorPtr.advanced(by: tableColumnNameUtf8CodeOffsetOffset), endianness)
        UInt32(column.fieldOffset).copyBytes(to: descriptorPtr.advanced(by: tableColumnFieldOffsetOffset), endianness)
        UInt32(column.fieldByteCount).copyBytes(to: descriptorPtr.advanced(by: tableColumnFieldByteCountOffset), endianness)
    }
    
    // Column names
    for column in arr {
        UInt8(column.nameField.data.count).copyBytes(to: ptr.advanced(by: column.nameOffset), endianness)
        column.nameField.data.copyBytes(to: ptr.advanced(by: column.nameOffset + 1).assumingMemoryBound(to: UInt8.self), count: column.nameField.data.count)
    }
}


internal let tableRowCountOffset = 0
internal let tableColumnCountOffset = tableRowCountOffset + 4
internal let tableRowsOffsetOffset = tableColumnCountOffset + 4
internal let tableRowByteCountOffset = tableRowsOffsetOffset + 4
internal let tableColumnDescriptorBaseOffset = tableRowByteCountOffset + 4

internal let tableColumnNameCrcOffset = 0
internal let tableColumnNameByteCountOffset = tableColumnNameCrcOffset + 2
internal let tableColumnFieldTypeOffset = tableColumnNameByteCountOffset + 1
internal let tableColumnNameUtf8CodeOffsetOffset = tableColumnFieldTypeOffset + 1
internal let tableColumnFieldOffsetOffset = tableColumnNameUtf8CodeOffsetOffset + 4
internal let tableColumnFieldByteCountOffset = tableColumnFieldOffsetOffset + 4

internal let tableColumnDescriptorByteCount = tableColumnFieldByteCountOffset + 4


// Table item pointer manipulations

extension UnsafeMutableRawPointer {
    
    
    /// A pointer to the row count assuming self points to the first byte of the value.
    
    internal var tableRowCountPtr: UnsafeMutableRawPointer { return self.advanced(by: tableRowCountOffset) }
    
    
    /// A pointer to the column count assuming self points to the first byte of the value.
    
    internal var tableColumnCountPtr: UnsafeMutableRawPointer { return self.advanced(by: tableColumnCountOffset) }
    
    
    /// A pointer to the rows offset assuming self points to the first byte of the value.
    
    internal var tableRowsOffsetPtr: UnsafeMutableRawPointer { return self.advanced(by: tableRowsOffsetOffset) }
    
    
    /// A pointer to the row byte count assuming self points to the first byte of the value.
    
    internal var tableRowByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: tableRowByteCountOffset) }
    

    /// A pointer to the base of the column descriptors assuming self points to the first byte of the value.
    
    internal var tableColumnDescriptorBasePtr: UnsafeMutableRawPointer { return self.advanced(by: tableColumnDescriptorBaseOffset) }
    
    
    /// A pointer to the column descriptor for a column assuming self points to the first byte of the value.
    
    internal func tableColumnDescriptorPtr(for column: Int) -> UnsafeMutableRawPointer {
        return tableColumnDescriptorBasePtr.advanced(by: column * tableColumnDescriptorByteCount)
    }
    

    /// Returns the CRC for the given column.
    
    internal func tableColumnNameCrc(for column: Int, _ endianness: Endianness) -> UInt16 {
        if endianness == machineEndianness {
            return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameCrcOffset).assumingMemoryBound(to: UInt16.self).pointee
        } else {
            return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameCrcOffset).assumingMemoryBound(to: UInt16.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the CRC of the column name to a new value.
    
    internal func setTableColumnNameCrc(_ value: UInt16, for column: Int, _ endianness: Endianness) {
        if endianness == machineEndianness {
            tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameCrcOffset).storeBytes(of: value, as: UInt16.self)
        } else {
            tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameCrcOffset).storeBytes(of: value.byteSwapped, as: UInt16.self)
        }
    }

    
    /// Returns the offset for the column name UTF8 field relative to the first byte of the item value field assuming self points to the first byte of the value field.
    
    internal func tableColumnNameUtf8Offset(for column: Int, _ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameUtf8CodeOffsetOffset).assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameUtf8CodeOffsetOffset).assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets a new offset for column name UTF8 field relative to the first byte of the item value field.
    
    internal func setTableColumnNameUtf8Offset(_ value: UInt32, for column: Int, _ endianness: Endianness) {
        if endianness == machineEndianness {
            tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameUtf8CodeOffsetOffset).storeBytes(of: value, as: UInt32.self)
        } else {
            tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameUtf8CodeOffsetOffset).storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }

    
    /// Returns the byte count for the column name field.
    
    internal func tableColumnNameByteCount(for column: Int) -> UInt8 {
        return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameByteCountOffset).assumingMemoryBound(to: UInt8.self).pointee
    }
    
    
    /// Sets a new byte count for the column name field.
    
    internal func setTableColumnNameByteCount(_ value: UInt8, for column: Int) {
        tableColumnDescriptorPtr(for: column).advanced(by: tableColumnNameByteCountOffset).storeBytes(of: value, as: UInt8.self)
    }
    
    
    /// Returns the item type of the value stored in the column.
    
    internal func tableColumnType(for column: Int) -> UInt8 {
        return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldTypeOffset).assumingMemoryBound(to: UInt8.self).pointee
    }
    
    
    /// Sets a new item type for the value stored in the column.
    
    internal func setTableColumnType(_ value: UInt8, for column: Int) {
        tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldTypeOffset).storeBytes(of: value, as: UInt8.self)
    }

    
    /// Returns the offset of the first byte of the location where the value for the column is stored, relative to the first byte of the row.
    
    internal func tableColumnFieldOffset(for column: Int, _ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldOffsetOffset).assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldOffsetOffset).assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets a new value for the offset of the first byte of the column relative to the first byte of the row.
    
    internal func setTableColumnFieldOffset(_ value: UInt32, for column: Int, _ endianness: Endianness) {
        if endianness == machineEndianness {
            tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldOffsetOffset).storeBytes(of: value, as: UInt32.self)
        } else {
            tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldOffsetOffset).storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Returns the byte count that is reserved for the value in the column.
    
    internal func tableColumnFieldByteCount(for column: Int, _ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldByteCountOffset).assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldByteCountOffset).assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets a new value in the column descriptor table for the number of bytes that can be stored in the column.
    
    internal func setTableColumnFieldByteCount(_ value: UInt32, for column: Int, _ endianness: Endianness) {
        if endianness == machineEndianness {
            tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldByteCountOffset).storeBytes(of: value, as: UInt32.self)
        } else {
            tableColumnDescriptorPtr(for: column).advanced(by: tableColumnFieldByteCountOffset).storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }

    
    /// Returns the number of rows in a table item assuming self points to the first byte of the value.

    internal func tableRowCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return tableRowCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return tableRowCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the number of rows in a table item assuming self points to the first byte of the value.
    
    internal func setTableRowCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            tableRowCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            tableRowCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Increments the number of rows count by 1 assuming self points to the first byte of the value.
    
    internal func incrementTableRowCount(_ endianness: Endianness) {
        if endianness == machineEndianness {
            let value = tableRowCountPtr.assumingMemoryBound(to: UInt32.self).pointee + 1
            tableRowCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            let value = tableRowCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped + 1
            tableRowCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Increments the number of rows count by 1 assuming self points to the first byte of the value.
    
    internal func decrementTableRowCount(_ endianness: Endianness) {
        if endianness == machineEndianness {
            let value = tableRowCountPtr.assumingMemoryBound(to: UInt32.self).pointee - 1
            tableRowCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            let value = tableRowCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped - 1
            tableRowCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }

    
    /// Returns the number of columns in the table assuming self points to the first byte of the value.
    
    internal func tableColumnCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return tableColumnCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return tableColumnCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the number of columns in the table assuming self points to the first byte of the value.

    internal func setTableColumnCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            tableColumnCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            tableColumnCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// The offset from the start of the item value field to the first byte of the row content fields.
    
    internal func tableRowsOffset(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return tableRowsOffsetPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return tableRowsOffsetPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    internal func setTableRowsOffset(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            tableRowsOffsetPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            tableRowsOffsetPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// The number of bytes in a row. This is the raw number of bytes, including filler bytes.
    
    internal func tableRowByteCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return tableRowByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return tableRowByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    internal func setTableRowByteCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            tableRowByteCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            tableRowByteCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    

    internal func tableColumnNameUtf8Code(for column: Int, _ endianness: Endianness) -> Data {
        let nameUtf8Ptr = self.advanced(by: Int(tableColumnNameUtf8Offset(for: column, endianness)))
        let nameCount = Int(nameUtf8Ptr.assumingMemoryBound(to: UInt8.self).pointee)
        return Data(bytes: nameUtf8Ptr.advanced(by: 1), count: nameCount)
    }

    
    internal func setTableColumnNameUtf8Code(to value: Data, for column: Int, _ endianness: Endianness) {
        let nameUtf8Ptr = self.advanced(by: Int(tableColumnNameUtf8Offset(for: column, endianness)))
        nameUtf8Ptr.storeBytes(of: UInt8(value.count), as: UInt8.self)
        value.copyBytes(to: nameUtf8Ptr.advanced(by: 1).assumingMemoryBound(to: UInt8.self), count: value.count)
    }

    
    /// Returns a pointer to the first byte of the first item in a row
    
    internal func tableRowPtr(for row: Int, _ endianness: Endianness) -> UnsafeMutableRawPointer {
        let rowOffset = row * Int(tableRowByteCount(endianness))
        return self.advanced(by: Int(tableRowsOffset(endianness)) + rowOffset)
    }

    
    /// Returns a pointer to the first byte of the value in the row/column combination.
    
    internal func tableFieldPtr(row: Int, column: Int, _ endianness: Endianness) -> UnsafeMutableRawPointer {
        let rowPtr = tableRowPtr(for: row, endianness)
        let columnOffset = Int(tableColumnFieldOffset(for: column, endianness))
        return rowPtr.advanced(by: columnOffset)
    }
}


// Table item access

extension Portal {
    
    
    /// The number of rows in the table
    
    internal var _tableRowCount: Int {
        get { return Int(itemPtr.itemValueFieldPtr.tableRowCount(endianness)) }
        set { itemPtr.itemValueFieldPtr.setTableRowCount(to: UInt32(newValue), endianness) }
    }
    
    
    /// The number of columns in the table
    
    internal var _tableColumnCount: Int {
        get { return Int(itemPtr.itemValueFieldPtr.tableColumnCount(endianness)) }
        set { itemPtr.itemValueFieldPtr.setTableColumnCount(to: UInt32(newValue), endianness) }
    }
    
    
    /// The offset for the column field in a table row
    
    internal var _tableRowsOffset: Int {
        get { return Int(itemPtr.itemValueFieldPtr.tableRowsOffset(endianness)) }
        set { itemPtr.itemValueFieldPtr.setTableRowsOffset(to: UInt32(newValue), endianness) }
    }

    
    /// The byte count for a table row
    
    internal var _tableRowByteCount: Int {
        get { return Int(itemPtr.itemValueFieldPtr.tableRowByteCount(endianness)) }
        set { itemPtr.itemValueFieldPtr.setTableRowByteCount(to: UInt32(newValue), endianness) }
    }

    
    /// Returns the column name for a column.
    
    internal func _tableGetColumnName(for column: Int) -> String {
        let utf8Code = itemPtr.itemValueFieldPtr.tableColumnNameUtf8Code(for: column, endianness)
        return (String(data: utf8Code, encoding: .utf8) ?? "")
    }
    
    
    /// Sets the column name for a column.
    ///
    /// Updates the column descriptors as well as the column name fields. May shift the entire content area of the table if the new name is larger as the old name.
    
    internal func _tableSetColumnName(_ value: String, for column: Int) -> Result {
        
        // Convert the name into a NFD
        guard let nfd = NameField(value) else { return .error(.nameFieldError) }
        
        // Expand the name storage field when necessary
        if (nfd.data.count + 1) > itemPtr.itemValueFieldPtr.tableColumnNameByteCount(for: column) {
            let result = _tableIncreaseColumnNameByteCount(to: (nfd.data.count + 1), for: column)
            guard result == .success else { return result }
        }
        
        // Store the new name
        itemPtr.itemValueFieldPtr.setTableColumnNameUtf8Code(to: nfd.data, for: column, endianness)
        
        // Store the new crc
        itemPtr.itemValueFieldPtr.setTableColumnNameCrc(nfd.crc, for: column, endianness)
        
        return .success
    }
    
    
    /// The used area in the value field
    
    internal var _tableValueFieldUsedByteCount: Int {
        return _tableRowsOffset + _tableRowCount * _tableRowByteCount
    }
    
    
    /// Returns a NFD for the column.
    
    internal func _tableColumnNameField(_ column: Int) -> NameField {
        let crc = itemPtr.itemValueFieldPtr.tableColumnNameCrc(for: column, endianness)
        let byteCount = Int(itemPtr.itemValueFieldPtr.tableColumnNameCrc(for: column, endianness))
        let dataOffset = Int(itemPtr.itemValueFieldPtr.tableColumnNameUtf8Offset(for: column, endianness))
        let dataPtr = itemPtr.itemValueFieldPtr.advanced(by: dataOffset)
        let dataCount = Int(dataPtr.assumingMemoryBound(to: UInt8.self).pointee)
        let data = Data(bytes: dataPtr.advanced(by: 1), count: dataCount)
        return NameField(data: data, crc: crc, byteCount: byteCount)
    }
    
    
    /// Increases the space available for storage of the column's name utf8-byte-code sequence (and count byte).
    
    internal func _tableIncreaseColumnNameByteCount(to bytes: Int, for column: Int) -> Result {
        
        let delta = bytes - Int(itemPtr.itemValueFieldPtr.tableColumnNameByteCount(for: column))
        let srcPtr = itemPtr.itemValueFieldPtr.advanced(by: _tableRowsOffset)
        let dstPtr = srcPtr.advanced(by: delta)
        let len = _tableContentByteCount
        
        let bytesNeeded = len + delta
        if (_itemByteCount - itemHeaderByteCount) < bytesNeeded {
            let result = _tableEnsureColumnValueByteCount(of: bytesNeeded, in: column)
            guard result == .success else { return result }
        }
        
        // Move the table values up
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        // Rebuild the table and column description area
        var cols: Array<ColumnSpecification> = []
        for i in 0 ..< _tableColumnCount {
            guard let colSpec = ColumnSpecification(fromPtr: itemPtr.itemValueFieldPtr, forColumn: i, endianness) else {
                // Undo: Move the table back to its original place
                manager.moveBlock(to: srcPtr, from: dstPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
                return .error(.invalidTableColumnType)
            }
            cols.append(colSpec)
        }
        let nameField = NameField(data: cols[column].nameField.data, crc: cols[column].nameField.crc, byteCount: bytes)
        cols[column].nameField = nameField
        
        tableWriteSpecification(valueFieldPtr: itemPtr.itemValueFieldPtr, &cols, endianness)
        
        return .success
    }
    
    
    /// Makes sure the byte count for the column's value is sufficient to store the value.
    
    internal func _tableEnsureColumnValueByteCount(of bytes: Int, in column: Int) -> Result {
        
        guard let cspec = ColumnSpecification(fromPtr: itemPtr.itemValueFieldPtr, forColumn: column, endianness) else { return .error(.invalidTableColumnType) }
        
        if bytes > cspec.fieldByteCount {
            let result = _tableIncreaseColumnValueByteCount(to: bytes.roundUpToNearestMultipleOf8(), for: column)
            guard result == .success else { return result }
        }
        
        return .success
    }
    
    
    /// Increases the value byte count for the column.
    
    internal func _tableIncreaseColumnValueByteCount(to bytes: Int, for column: Int) -> Result {
        
        // Calculate the needed bytes for the entire table content
        
        let cspec = ColumnSpecification(fromPtr: _itemValueFieldPtr, forColumn: column, endianness)!
        
        let columnFieldByteCountIncrease = bytes - cspec.fieldByteCount
        let oldRowByteCount = _tableRowByteCount
        let newRowByteCount = oldRowByteCount + columnFieldByteCountIncrease
        let newTableContentByteCount = _tableRowCount * newRowByteCount
        let newTableItemByteCount = itemPtr.itemHeaderAndNameByteCount + _tableRowsOffset + newTableContentByteCount
        
        if _itemByteCount < newTableItemByteCount {
            let result = increaseItemByteCount(to: newTableItemByteCount)
            guard result == .success else { return result }
        }
        
        
        // Shift the column value fields to their new place
        
        let colOffset = Int(_itemValueFieldPtr.tableColumnFieldOffset(for: column, endianness))
        let colValueByteCount = Int(_itemValueFieldPtr.tableColumnFieldByteCount(for: column, endianness))
        let offsetOfFirstByteAfterIncreasedByteCount = colOffset + colValueByteCount
        let bytesAfterIncrease = oldRowByteCount - offsetOfFirstByteAfterIncreasedByteCount
        
        if bytesAfterIncrease > 0 {
            let lastRowPtr = _itemValueFieldPtr.tableRowPtr(for: (_tableRowCount - 1), endianness)
            let srcPtr = lastRowPtr.advanced(by: offsetOfFirstByteAfterIncreasedByteCount)
            let dstPtr = srcPtr.advanced(by: _tableRowCount * columnFieldByteCountIncrease)
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: bytesAfterIncrease, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        if _tableRowCount > 1 {
            for ri in (1 ..< _tableRowCount).reversed() {
                let rowPtr = _itemValueFieldPtr.tableRowPtr(for: ri, endianness)
                let srcPtr = rowPtr.advanced(by: offsetOfFirstByteAfterIncreasedByteCount - oldRowByteCount)
                let dstPtr = srcPtr.advanced(by: ri * columnFieldByteCountIncrease)
                manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: oldRowByteCount, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
            }
        }
        
        // Update the column value byte count to the new value
        _itemValueFieldPtr.setTableColumnFieldByteCount(UInt32(colValueByteCount + columnFieldByteCountIncrease), for: column, endianness)
        
        // Update column value offsets
        if (column + 1) < _tableColumnCount {
            for ci in (column + 1) ..< _tableColumnCount {
                let old = Int(_itemValueFieldPtr.tableColumnFieldOffset(for: ci, endianness))
                let new = old + columnFieldByteCountIncrease
                _itemValueFieldPtr.setTableColumnFieldOffset(UInt32(new), for: ci, endianness)
            }
        }
        
        // Update the row byte count
        _tableRowByteCount = newRowByteCount
        
        return .success
    }
    
    
    /// Returns the total amount of bytes stored in the table content area. Includes filler data in the value fields. Excludes filler data in the item.
    
    internal var _tableContentByteCount: Int {
        if _tableColumnCount == 0 { return tableColumnDescriptorBaseOffset }
        return _tableRowsOffset + (_tableRowCount * _tableRowByteCount)
    }
    
    
    /// Returns the column index
    
    internal func _tableColumnIndex(for nfd: NameField) -> Int? {
        
        let valuePtr = itemPtr.itemValueFieldPtr
        
        for i in 0 ..< _tableColumnCount {
            if nfd.crc != valuePtr.tableColumnNameCrc(for: i, endianness) { continue }
            let offset = Int(valuePtr.tableColumnNameUtf8Offset(for: i, endianness))
            if nfd.data.count != Int(valuePtr.advanced(by: offset).assumingMemoryBound(to: UInt8.self).pointee) { continue }
            let data = Data(bytesNoCopy: valuePtr.advanced(by: offset + 1), count: nfd.data.count, deallocator: Data.Deallocator.none)
            if data == nfd.data { return i }
        }
        
        return nil
    }
    
    
    /// Returns the column index
    
    internal func _tableColumnIndex(for name: String?) -> Int? {
        guard let nfd = NameField(name) else { return nil }
        return _tableColumnIndex(for: nfd)
    }
    
    
    /// Returns the column index.
    ///
    /// - Note: Using the column index is faster than using the column name. However the column index may change due to other operations. Make sure no table-operation is used of which it is documented that it may change the column index. This documentation will be backwards compatible, i.e. if it is not documented now, it is safe to assume that the operation will never change the column index.
    ///
    /// - Parameter for: The NameFieldDescriptor of the column to return the index for.
    ///
    /// - Returns: The requested index or nil if there is no matching column.
    
    public func tableColumnIndex(for nfd: NameField?) -> Int? {
        guard isTable else { return nil }
        guard let nfd = nfd else { return nil }
        return _tableColumnIndex(for: nfd)
    }
    
    
    /// Returns the column index.
    ///
    /// - Note: Using the column index is faster than using the column name. However the column index may change due to other operations. Make sure no table-operation is used of which it is documented that it may change the column index. This documentation will be backwards compatible, i.e. if it is not documented now, it is safe to assume that the operation will never change the column index.
    ///
    /// - Parameter for: The name of the column to return the index for.
    ///
    /// - Returns: The requested index or nil if there is no matching column.
    
    public func tableColumnIndex(for name: String) -> Int? {
        guard isTable else { return nil }
        return tableColumnIndex(for: name)
    }
    
    
    /// Execute the given closure on each column item at the requested row.
    ///
    /// - Parameters:
    ///   - atRow: The row for which to execute the closure.
    ///   - closure: The closure to execute for each column value. Note that the portal in the closure parameter is not registered with the active portals manager and thus should not be used/stored outside the closure. Also it is not allowed to make changes to the
    
    internal func forEachColumn(atRow index: Int, closure: (String, Portal) -> ()) {
        
        guard isTable else { return }
        guard index >= 0 && index < _tableRowCount else { return }
        
        for ci in 0 ..< _tableColumnCount {
            closure(_tableGetColumnName(for: ci), Portal(itemPtr: itemPtr, index: index, column: ci, manager: manager, endianness: endianness))
        }
    }
    
    
    /// Execute the given closure for each row value for the given column or until the closure returns 'true'.
    ///
    /// The closure is not executed if the column cannot be found.
    ///
    /// - Parameters:
    ///   - column: The name of the string that identifies the column value to be processed by the closure.
    ///   - closure: The closure to execute on each row value for the requested column. Aborts when the closure returns 'true'. Note that the portal in the closure parameter is not registered with the active portals manager and thus should not be used/stored outside the closure.
    
    internal func forEachRowAbortOnTrue(column: String, closure: (Portal) -> (Bool)) {
        
        guard isTable else { return }
        guard let ci = _tableColumnIndex(for: column) else { return }
        
        for ri in 0 ..< _tableRowCount {
            if closure(Portal(itemPtr: itemPtr, index: ri, column: ci, manager: manager, endianness: endianness)) { break }
        }
    }

    
    internal func _tableGetColumnType(for column: Int) -> ItemType {
        return ItemType(rawValue: itemPtr.itemValueFieldPtr.tableColumnType(for: column)) ?? ItemType.null
    }
}

extension Portal {
    
    
    /// Return a portal for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remain constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The column of the portal to retrieve.
    ///
    /// - Returns: The requested portal or the nullPortal if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField?) -> Portal {
        get {
            guard isTable else { return Portal.nullPortal }
            guard let column = column else { return Portal.nullPortal }
            guard row >= 0, row < _tableRowCount else { return Portal.nullPortal }
            guard let columnIndex = _tableColumnIndex(for: column) else { return Portal.nullPortal }
            if _tableGetColumnType(for: columnIndex).isContainer {
                return manager.getActivePortal(for: itemPtr.itemValueFieldPtr.tableFieldPtr(row: row, column: columnIndex, endianness), index: nil, column: nil)
            } else {
                return manager.getActivePortal(for: itemPtr, index: row, column: columnIndex)
            }
        }
    }
    
    
    /// Return a portal for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remain constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The column of the portal to retrieve.
    ///
    /// - Returns: The requested portal or the nullPortal if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> Portal {
        get {
            guard isTable else { return Portal.nullPortal }
            guard row >= 0, row < _tableRowCount else { return Portal.nullPortal }
            guard let columnIndex = _tableColumnIndex(for: column) else { return Portal.nullPortal }
            if _tableGetColumnType(for: columnIndex).isContainer {
                return manager.getActivePortal(for: itemPtr.itemValueFieldPtr.tableFieldPtr(row: row, column: columnIndex, endianness), index: nil, column: nil)
            } else {
                return manager.getActivePortal(for: itemPtr, index: row, column: columnIndex)
            }
        }
    }
    
    
    /// Return a portal for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The column of the portal to retrieve.
    ///
    /// - Returns: The requested portal or the nullPortal if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Portal {
        get {
            guard isTable else { return Portal.nullPortal }
            guard row >= 0, row < _tableRowCount else { return Portal.nullPortal }
            guard column >= 0, column < _tableColumnCount else { return Portal.nullPortal }
            if _tableGetColumnType(for: column).isContainer {
                return manager.getActivePortal(for: itemPtr.itemValueFieldPtr.tableFieldPtr(row: row, column: column, endianness), index: nil, column: nil)
            } else {
                return manager.getActivePortal(for: itemPtr, index: row, column: column)
            }
        }
    }
    
    
    /// Return a bool for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.

    public subscript(row: Int, column: NameField) -> Bool? {
        get { return self[row, column].bool }
        set { self[row, column].bool = newValue }
    }

    
    /// Return a bool for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.

    public subscript(row: Int, column: String) -> Bool? {
        get { return self[row, column].bool }
        set { self[row, column].bool = newValue }
    }

    
    /// Return a bool for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Bool? {
        get { return self[row, column].bool }
        set { self[row, column].bool = newValue }
    }

    
    
    
    /// Return a UInt8 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> UInt8? {
        get { return self[row, column].uint8 }
        set { self[row, column].uint8 = newValue }
    }
    
    
    /// Return a UInt8 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> UInt8? {
        get { return self[row, column].uint8 }
        set { self[row, column].uint8 = newValue }
    }
    
    
    /// Return a UInt8 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> UInt8? {
        get { return self[row, column].uint8 }
        set { self[row, column].uint8 = newValue }
    }

    
    
    
    /// Return a UInt16 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> UInt16? {
        get { return self[row, column].uint16 }
        set { self[row, column].uint16 = newValue }
    }
    
    
    /// Return a UInt16 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> UInt16? {
        get { return self[row, column].uint16 }
        set { self[row, column].uint16 = newValue }
    }
    
    
    /// Return a UInt16 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> UInt16? {
        get { return self[row, column].uint16 }
        set { self[row, column].uint16 = newValue }
    }

    
    
    
    /// Return a UInt32 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> UInt32? {
        get { return self[row, column].uint32 }
        set { self[row, column].uint32 = newValue }
    }

    
    /// Return a UInt32 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> UInt32? {
        get { return self[row, column].uint32 }
        set { self[row, column].uint32 = newValue }
    }

    
    /// Return a UInt32 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> UInt32? {
        get { return self[row, column].uint32 }
        set { self[row, column].uint32 = newValue }
    }

    
    
    
    /// Return a UInt64 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> UInt64? {
        get { return self[row, column].uint64 }
        set { self[row, column].uint64 = newValue }
    }
    
    
    /// Return a UInt64 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> UInt64? {
        get { return self[row, column].uint64 }
        set { self[row, column].uint64 = newValue }
    }
    
    
    /// Return a UInt64 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> UInt64? {
        get { return self[row, column].uint64 }
        set { self[row, column].uint64 = newValue }
    }

    
    
    
    /// Return a Int8 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> Int8? {
        get { return self[row, column].int8 }
        set { self[row, column].int8 = newValue }
    }
    
    
    /// Return a Int8 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> Int8? {
        get { return self[row, column].int8 }
        set { self[row, column].int8 = newValue }
    }
    
    
    /// Return a Int8 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Int8? {
        get { return self[row, column].int8 }
        set { self[row, column].int8 = newValue }
    }
    
    
    
    
    /// Return a Int16 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> Int16? {
        get { return self[row, column].int16 }
        set { self[row, column].int16 = newValue }
    }
    
    
    /// Return a Int16 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> Int16? {
        get { return self[row, column].int16 }
        set { self[row, column].int16 = newValue }
    }
    
    
    /// Return a Int16 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Int16? {
        get { return self[row, column].int16 }
        set { self[row, column].int16 = newValue }
    }
    
    
    
    
    /// Return a Int32 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> Int32? {
        get { return self[row, column].int32 }
        set { self[row, column].int32 = newValue }
    }
    
    
    /// Return a Int32 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> Int32? {
        get { return self[row, column].int32 }
        set { self[row, column].int32 = newValue }
    }
    
    
    /// Return a Int32 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Int32? {
        get { return self[row, column].int32 }
        set { self[row, column].int32 = newValue }
    }
    
    
    
    
    /// Return a Int64 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> Int64? {
        get { return self[row, column].int64 }
        set { self[row, column].int64 = newValue }
    }
    
    
    /// Return a Int64 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> Int64? {
        get { return self[row, column].int64 }
        set { self[row, column].int64 = newValue }
    }
    
    
    /// Return a Int64 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Int64? {
        get { return self[row, column].int64 }
        set { self[row, column].int64 = newValue }
    }
    

    
    
    /// Return a Float32 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> Float32? {
        get { return self[row, column].float32 }
        set { self[row, column].float32 = newValue }
    }
    
    
    /// Return a Float32 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> Float32? {
        get { return self[row, column].float32 }
        set { self[row, column].float32 = newValue }
    }
    
    
    /// Return a Float32 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Float32? {
        get { return self[row, column].float32 }
        set { self[row, column].float32 = newValue }
    }
    
    
    
    
    /// Return a Float64 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> Float64? {
        get { return self[row, column].float64 }
        set { self[row, column].float64 = newValue }
    }
    
    
    /// Return a Float64 for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> Float64? {
        get { return self[row, column].float64 }
        set { self[row, column].float64 = newValue }
    }
    
    
    /// Return a Float64 for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Float64? {
        get { return self[row, column].float64 }
        set { self[row, column].float64 = newValue }
    }

    
    
    
    /// Return a String for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> String? {
        get { return self[row, column].string }
        set { self[row, column].string = newValue }
    }
    
    
    /// Return a String for the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> String? {
        get { return self[row, column].string }
        set { self[row, column].string = newValue }
    }
    
    
    /// Return a String for the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> String? {
        get { return self[row, column].string }
        set { self[row, column].string = newValue }
    }

    
    
    
    /// Return the Data of the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The namefield for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: NameField) -> Data? {
        get {
            if isBinary { return self[row, column].binary }
            return self[row, column].crcBinary?.data
        }
        set {
            guard let newValue = newValue else { return }
            if isBinary {
                self[row, column].binary = newValue
            } else {
                self[row, column].crcBinary = BRCrcBinary(newValue)
            }
        }
    }
    
    
    /// Return the Data of the requested table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remains constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The name for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: String) -> Data? {
        get {
            if isBinary { return self[row, column].binary }
            return self[row, column].crcBinary?.data
        }
        set {
            guard let newValue = newValue else { return }
            if isBinary {
                self[row, column].binary = newValue
            } else {
                self[row, column].crcBinary = BRCrcBinary(newValue)
            }
        }
    }
    
    
    /// Return the Data of the requested table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The index for the column of the portal to retrieve.
    ///
    /// - Returns: The requested value or nil if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Data? {
        get {
            if isBinary { return self[row, column].binary }
            return self[row, column].crcBinary?.data
        }
        set {
            guard let newValue = newValue else { return }
            if isBinary {
                self[row, column].binary = newValue
            } else {
                self[row, column].crcBinary = BRCrcBinary(newValue)
            }
        }
    }
    
    
    /// The number of rows in the table
    
    public var rowCount: Int? {
        guard isValid else { return nil }
        guard isTable else { return nil }
        return _tableRowCount
    }
    
    
    /// The byte count for a single row
    
    internal var rowByteCount: Int? {
        guard isValid else { return nil }
        guard isTable else { return nil }
        return _tableRowByteCount
    }
    
    
    
    /// Reset the table to an empty state.
    ///
    /// - Parameter clear: If set to true, the cleared memory area is filled with zero's. If false the area will stay as is but the row count is reset to zero.
    
    public func tableReset(clear: Bool = false) {
        guard isValid, isTable else { return }
        if clear {
            _ = Darwin.memset(itemPtr.itemValueFieldPtr.tableRowPtr(for: 0, endianness), 0, _tableRowCount * _tableRowByteCount)
        }
        _tableRowCount = 0
    }
    

    /// Returns a dictionary with the columns at the given row.
    ///
    /// - Parameter index: The index of the row to retrieve.
    ///
    /// - Returns: A dictionary with the columns at the given row.
    
    public func getRow(_ index: Int) -> Dictionary<String, Portal> {
        
        guard isValid, isTable else { return [:] }

        var dict: Dictionary<String, Portal> = [:]
        
        for ci in 0 ..< _tableColumnCount {
            let name = _tableGetColumnName(for: ci)
            dict[name] = manager.getActivePortal(for: itemPtr, index: index, column: ci)
        }
        
        return dict
    }
    
    
    /// Signature of closure used to itterate over the column specifications. Itteration starts at column 0.
    ///
    /// - Parameters:
    ///   - index: The index of the column specification.
    ///   - cspec: The column specification corresponding to the index.

    public typealias ColumnSpecificationItterator = (_ index: Int, _ cspec: ColumnSpecification) -> Void
    
    
    /// Itterate over the columnspecifications for this table. Itteration starts at 0.
    ///
    /// - Parameters:
    ///   - closure: The closure is executed for each column specification. Itteration starts at column index 0.

    public func itterateColumnSpecifications(_ closure: ColumnSpecificationItterator) {
        var i = 0
        while i < _tableColumnCount {
            let cspec = ColumnSpecification(fromPtr: itemPtr.itemValueFieldPtr, forColumn: i, endianness)!
            closure(i, cspec)
            i += 1
        }
    }
    
    
    /// Signature of closure used to itterate over the fields of a table row column. Itteration starts at column 0. Itteration cab be aborted by returning 'false'.
    ///
    /// - Parameters:
    ///   - portal: The portal for the column field. Note that for container fields a portal to that item will be presented, while non-container fields will use the portal to the original table with properly initialized index and field members.
    ///   - column: The index of the column in the original table.
    ///
    /// - Returns: Return 'true' to keep itterating, return 'false' to stop itterating.
    
    public typealias ColumnItterator = (_ portal: Portal, _ column: Int) -> Bool
    
    
    /// Itterate over the column-fields in a row. Itteration continues as long as the closure returns 'true'.
    ///
    /// - Parameters:
    ///   - ofRow: The index of the row over which to itterate.
    ///   - closure: The closure is executed for each column. Check the column member of the portal to find out which column field is provided. Return 'true' to continue column field itteration, 'false' to stop itteration. Itteration starts at column index 0 and counts up to the last column.
    ///
    /// - Returns: Success on completion, or an error message when it was not possible to itterate.
    
    @discardableResult
    public func itterateFields(ofRow row: Int, closure: ColumnItterator) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isTable else { return .error(.operationNotSupported) }
        guard row >= 0 else { return .error(.indexBelowLowerBound) }
        guard row < _tableRowCount else { return .error(.indexAboveHigherBound) }
        guard _tableColumnCount > 0 else { return .error(.missingColumn) }
        
        for c in 0 ..< _tableColumnCount {
            if let p = self[row, c].portal {
                if !closure(p, c) { break }
            } else {
                assertionFailure("There should be a field portal")
            }
        }
        
        return .success
    }
    
    
    /// Signature of closure used to itterate over a column field of all table rows. Itteration starts at row 0. Itteration cab be aborted by returning 'false'.
    ///
    /// - Parameters:
    ///   - portal: The portal for the field. Note that for container fields a portal to that item will be presented, while non-container fields will use the portal to the original table with properly initialized index and field members.
    ///   - row: The index of the row in the original table.
    ///
    /// - Returns: Return 'true' to keep itterating, return 'false' to stop itterating.

    public typealias RowItterator = (_ portal: Portal, _ row: Int) -> Bool
    
    
    /// Itterate over all column-fields. Itteration continues as long as the closure returns 'true'.
    ///
    /// - Parameters:
    ///   - ofColumn: The index of the column over which to itterate.
    ///   - closure: The closure is executed for each column. Check the column member of the portal to find out which column field is provided. Return 'true' to continue column field itteration, 'false' to stop itteration. Itteration starts at column index 0 and counts up to the last column.
    ///
    /// - Returns: Success on completion, or an error message when it was not possible to itterate.
    
    @discardableResult
    public func itterateFields(ofColumn column: Int, closure: RowItterator) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isTable else { return .error(.operationNotSupported) }
        guard column >= 0 else { return .error(.indexBelowLowerBound) }
        guard column < _tableColumnCount else { return .error(.indexAboveHigherBound) }
        
        for r in 0 ..< _tableRowCount {
            if let p = self[r, column].portal {
                if !closure(p, r) { break }
            } else {
                assertionFailure("There should be a field portal")
            }
        }
        
        return .success
    }

    
    /// Adds new rows to the table.
    ///
    /// The fields of the new rows will be set to zero, after which the defaultValues closure is called.
    ///
    /// - Parameters:
    ///   - amount: The number of rows that must be added.
    ///   - values: A closure that provides the values for the new fields. Field will be set to zero's before the closure is activated.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func addRows(_ amount: Int, values closure: SetTableFieldDefaultValue? = nil) -> Result {
       
        guard isValid else { return .error(.portalInvalid) }
        guard isTable else { return .error(.operationNotSupported) }
        
        let necessaryValueFieldByteCount = _tableRowsOffset + ((_tableRowCount + amount) * _tableRowByteCount)
        
        if currentValueFieldByteCount < necessaryValueFieldByteCount {
            let result = increaseItemByteCount(to: itemHeaderByteCount + _itemNameFieldByteCount + necessaryValueFieldByteCount)
            guard result == .success else { return result }
        }
        

        // Init the new area to zero.
        
        let ptr = itemPtr.itemValueFieldPtr.tableFieldPtr(row: _tableRowCount, column: 0, endianness)
        
        _ = Darwin.memset(ptr, 0, amount * _tableRowByteCount)
        
        
        // Increase the row count
        
        _tableRowCount += amount

        
        // Let the API user fill in the default values
        
        if let closure = closure {
            for ri in (_tableRowCount - amount) ..< _tableRowCount {
                for ci in 0 ..< _tableColumnCount {
                    let portal = manager.getActivePortal(for: itemPtr, index: ri, column: ci)
                    closure(portal)
                }
            }
        }
        
        return .success
    }
    
    
    /// Removes the row from the table.
    ///
    /// - Parameter index: The index of the row to be removed.
    ///
    /// - Result: Success or an error indicator.
    
    @discardableResult
    public func removeRow(_ index: Int) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isTable else { return .error(.operationNotSupported) }
        
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < _tableRowCount else { return .error(.indexAboveHigherBound) }
        
        let dstPtr = itemPtr.itemValueFieldPtr.tableFieldPtr(row: index, column: 0, endianness)
        let srcPtr = dstPtr.advanced(by: _tableRowByteCount)
        let moveCount = (_tableRowCount - index - 1) * _tableRowByteCount
        let removeCount = _tableRowByteCount
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: moveCount, removeCount: removeCount, updateMovedPortals: true, updateRemovedPortals: true)
        
        _tableRowCount -= 1
        
        return .success
    }
    
    
    /// Removes the column with the given name from the table. The column-field is removed from the table rows, but not the table-item. Hence the itemByteCount will remain the same size as before, but the rowByteCount is reduced.
    ///
    /// - Note: If this operation is successful, then the existing __COLUMN INDEX__'s must be considered __INVALID__.
    ///
    /// - Parameter name: The name of the column to be removed.
    ///
    /// - Result: Success or an error indicator.
    
    @discardableResult
    public func removeColumn(_ name: String) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isTable else { return .error(.operationNotSupported) }
        
        
        // Get the index of the column to remove
        
        guard let column = _tableColumnIndex(for: name) else { return .error(.columnNotFound) }
        
        
        // Build an array of column descriptors to re-create the table descriptor without the removed column
        
        var cols: Array<ColumnSpecification> = []
        for i in 0 ..< _tableColumnCount {
            if i != column {
                guard let colSpec = ColumnSpecification(fromPtr: itemPtr.itemValueFieldPtr, forColumn: i, endianness) else {
                    return .error(.invalidTableColumnType)
                }
                cols.append(colSpec)
            }
        }
        
        
        // Cached variables (before they are changed by rebuilding the table descriptor)
        
        let valuePtr = itemPtr.itemValueFieldPtr
        let valueByteCount = Int(valuePtr.tableColumnFieldByteCount(for: column, endianness))
        
        let firstByteToBeRemovedOffset = Int(valuePtr.tableColumnFieldOffset(for: column, endianness))
        let bytesToBeRemoved = Int(valuePtr.tableColumnFieldByteCount(for: column, endianness))
        let firstByteNotToRemoveOffset = firstByteToBeRemovedOffset + bytesToBeRemoved

        let oldRowByteCount = _tableRowByteCount
        let newRowByteCount = oldRowByteCount - valueByteCount
        
        let oldRowsOffset = _tableRowsOffset
        
        
        // Remove active portals in the regions to be deleted
        
        for i in 0 ..< _tableRowCount {
            manager.removeActivePortal(Portal(itemPtr: itemPtr, index: i, column: column, manager: manager, endianness: endianness))
        }
        
        
        // Rewrite table specification
        
        tableWriteSpecification(valueFieldPtr: valuePtr, &cols, endianness)
        
        
        // Done if there is no data
        
        if _tableRowCount == 0 { return .success }
        
        
        // Shift the table data to the new locations.
        // This always moves data from higher addresses to lower addresses hence we start at the beginning of the table.
        
        var dstPtr = valuePtr.advanced(by: _tableRowsOffset)
        var srcPtr = valuePtr.advanced(by: oldRowsOffset)
        
        
        // Adjust the source pointer if the first column must be removed.
        
        if column == 0 { srcPtr = srcPtr.advanced(by: valueByteCount) }
        
        
        // The first block
        
        if firstByteToBeRemovedOffset > 0 {
            
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: firstByteToBeRemovedOffset, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
            
            srcPtr = srcPtr.advanced(by: firstByteNotToRemoveOffset)
            dstPtr = dstPtr.advanced(by: firstByteToBeRemovedOffset)
        }
        
        
        // Move blocks of memory (rowcount - 1) times
        
        for _ in 0 ..< (_tableRowCount - 1) {

            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: newRowByteCount, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
            
            dstPtr = dstPtr.advanced(by: newRowByteCount)
            srcPtr = srcPtr.advanced(by: oldRowByteCount)
        }
        
        
        // The last block
        
        if firstByteNotToRemoveOffset < oldRowByteCount {
            
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: (oldRowByteCount - firstByteNotToRemoveOffset), removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        
        // If there are no columns left, then set the rows count to zero
        
        if _tableColumnCount == 0 { _tableRowCount = 0 }
        
        
        return .success
    }
    
    
    /// Adds a new column to the table.
    ///
    /// - Note: If this operation is successful, then the existing __COLUMN INDEX__'s must be considered __INVALID__.
    ///
    /// - Parameters:
    ///   - type: The type stored in this column.
    ///   - nameField: A namefield descriptor for the column name.
    ///   - byteCount: The number of bytes reserved for the new column value.
    ///   - default: A closure that can be used to set the default value for each new field.
    ///
    /// - Returns: Success or an error indicator.

    @discardableResult
    public func addColumn(type: ItemType, nameField nfd: NameField, byteCount: Int, default closure: SetTableFieldDefaultValue? = nil) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isTable else { return .error(.operationNotSupported) }

        
        // Create a new column specification
        
        let newSpec = ColumnSpecification(type: type, nameField: nfd, byteCount: byteCount)

        
        // Add the new spec
        
        return addColumn(newSpec, defaultValues: closure)
    }
    
    
    /// Adds a series of columns to the table.
    ///
    /// The columns will be added at the end in the sequence given by the array.
    ///
    /// - Parameter specs: An array with column specifications.
    ///
    /// - Returns: Either .success or an error indicator. If an error indicator is returned some columns may still have been added.
    
    @discardableResult
    public func addColumns(_ specs: Array<ColumnSpecification>, defaultValues closure: SetTableFieldDefaultValue? = nil) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isTable else { return .error(.operationNotSupported) }

        for spec in specs {
            let result = addColumn(spec, defaultValues: closure)
            guard result == .success else { return result }
        }
        return .success
    }
    
    
    /// Adds a new column to the table.
    ///
    /// - Note: If this operation is successful, then the existing __COLUMN INDEX__'s must be considered __INVALID__.
    ///
    /// - Parameters:
    ///   - colSpec: The column specification for the new column.
    ///   - defaultValue: A default value that will be assigned to existing and new rows. When not specified, the bytes containing the value will be set to zero. Reserved bytes will also be set to zero. Note that the defaultValue must implement the Coder protocol.
    ///
    /// - Returns: Success or an error indicator.
    
    @discardableResult
    public func addColumn(_ colSpec: ColumnSpecification, defaultValues closure: SetTableFieldDefaultValue? = nil) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isTable else { return .error(.operationNotSupported) }

        
        // The name may not exist already
        
        guard _tableColumnIndex(for: colSpec.nameField) == nil else { return .error(.nameExists) }
        
        
        // Build an array of column descriptors to re-create the table descriptor
        
        var cols: Array<ColumnSpecification> = []
        for i in 0 ..< _tableColumnCount {
            guard let spec = ColumnSpecification(fromPtr: itemPtr.itemValueFieldPtr, forColumn: i, endianness) else {
                    return .error(.invalidTableColumnType)
            }
            cols.append(spec)
        }
        
        
        // Add the new colspec
        
        cols.append(colSpec)

        
        // Calculate some new values to move the data into the new locations
        
        let rows = _tableRowCount

        let oldRowsOffset = _tableRowsOffset
        let oldRowByteCount = _tableRowByteCount
        
        var newRowsOffset = tableColumnDescriptorBaseOffset + cols.count * tableColumnDescriptorByteCount
        for col in cols { newRowsOffset += col.nameField.byteCount }
        newRowsOffset = newRowsOffset.roundUpToNearestMultipleOf8()
        let newRowByteCount = oldRowByteCount + colSpec.fieldByteCount
        
        
        // Create necessary space
        
        let necessaryTableValueFieldByteCount = rows * newRowByteCount + newRowsOffset
        
        let result = increaseItemByteCount(to: itemHeaderByteCount + _itemNameFieldByteCount + necessaryTableValueFieldByteCount)
        guard result == .success else { return result }
        
        
        // Shift the data into its new space
        
        let valuePtr = itemPtr.itemValueFieldPtr
        
        for i in (0 ..< rows).reversed() {
            let dstPtr = valuePtr.advanced(by: newRowsOffset + (i * newRowByteCount))
            let srcPtr = valuePtr.advanced(by: oldRowsOffset + (i * oldRowByteCount))
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: oldRowByteCount, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        
        // Create the new table descriptor
        
        tableWriteSpecification(valueFieldPtr: valuePtr, &cols, endianness)
        
        
        // Set the default value
        
        if let closure = closure {
            
            let ci = _tableColumnCount - 1
            for ri in 0 ..< rows {
                let portal = manager.getActivePortal(for: itemPtr, index: ri, column: ci)
                closure(portal)
            }
            
        } else {

            let empty = Data(count: colSpec.fieldByteCount)
            let ci = _tableColumnCount - 1
            for i in 0 ..< rows {
                let ptr = valuePtr.tableFieldPtr(row: i, column: ci, endianness)
                empty.copyBytes(to: ptr, endianness)
            }
        }
        
        
        return .success
    }
    
    
    /// Inserts a new row into a table item.
    ///
    /// The content of the fields will be set to zero. After inserting the new row(s) a closure will be invoked for all new fields to allow a setup with default values.
    ///
    /// - Parameter atIndex: The index at which a new row will be inserted. The index must be an existing index otherwise an error is returned.
    ///
    /// - Returns: Success or an error indicator.
    
    public func insertRows(atIndex index: Int, amount: Int = 1, defaultValues closure: SetTableFieldDefaultValue? = nil) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard isTable else { return .error(.operationNotSupported) }
        
        guard index >= 0 else { return .error(.indexBelowLowerBound) }
        guard index < _tableRowCount else { return .error(.indexAboveHigherBound) }
        
        guard (amount > 0) && (amount < Int(Int32.max)) else { return .error(.illegalAmount) }
        
        let necessaryValueFieldByteCount = _tableRowsOffset + ((_tableRowCount + amount) * _tableRowByteCount)
        
        if currentValueFieldByteCount < necessaryValueFieldByteCount {
            let result = increaseItemByteCount(to: itemPtr.itemHeaderAndNameByteCount + necessaryValueFieldByteCount)
            guard result == .success else { return result }
        }
        
        let srcPtr = itemPtr.itemValueFieldPtr.tableFieldPtr(row: index, column: 0, endianness)
        let dstPtr = itemPtr.itemValueFieldPtr.tableFieldPtr(row: (index + amount), column: 0, endianness)
        let len = (_tableRowCount - index) * _tableRowByteCount
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)
        
        
        // Init the new area to zero.
        
        _ = Darwin.memset(srcPtr, 0, amount * _tableRowByteCount)
        
        
        // Increase the row count
        
        _tableRowCount += amount
        
        
        // Let the API user initialize the new fields
        
        if let closure = closure {
            for ri in index ..< (index + amount) {
                for ci in 0 ..< _tableColumnCount {
                    let portal = manager.getActivePortal(for: itemPtr, index: ri, column: ci)
                    closure(portal)
                }
            }
        }
        
        return .success
    }

    
    /// Copies the content of an ItemManager to a table field.
    ///
    /// The table field must be of the same type as the root type in the item manager. Also, the table field must be a container type (.array, .dictionary .sequence or .table)
    ///
    /// - Parameters:
    ///   - at: The row index of the table field.
    ///   - in: The column index of the table field.
    ///   - withManager: The manager with the root item to be copied.
    ///
    /// - Returns: Either .success or an error id.
    
    @discardableResult
    public func assignField(atRow row: Int, inColumn column: Int, fromManager source: ItemManager) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard itemType == .table else { return .error(.operationNotSupported) }

        
        // Prevent errors
        
        guard row >= 0 else { return .error(.indexBelowLowerBound) }
        guard row < _tableRowCount else { return .error(.indexAboveHigherBound) }
        
        guard (column >= 0) && (column < _tableColumnCount) else { return .error(.columnNotFound) }
        
        guard source.root.itemType?.isContainer ?? false else { return .error(.dataInconsistency) }
        
        guard _tableGetColumnType(for: column) == source.root.itemType else { return .error(.invalidTableColumnType) }
        
        
        // Ensure that there is sufficient space
        
        let result = _tableEnsureColumnValueByteCount(of: source.root._itemByteCount, in: column)
        
        guard result == .success else { return result }
        
        
        // Copy the container to the field
        
        let ptr = itemPtr.itemValueFieldPtr.tableFieldPtr(row: row, column: column, endianness)
        
        _ = Darwin.memmove(ptr, source.bufferPtr, source.root._itemByteCount)

        
        // Adjust the parent offset
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
                
        UInt32(pOffset).copyBytes(to: ptr.advanced(by: itemParentOffsetOffset), endianness)
        
        return .success
    }
    
    
    /// Copies the content of an ItemManager to this table field.
    ///
    /// The table column type must be of the same type as the type in the item manager.
    ///
    /// - Parameters:
    ///   - source: The manager with the root item to be copied.
    ///
    /// - Returns: Either .success or an error id.

    @discardableResult
    public func assignField(_ source: ItemManager) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard let index = index else { return .error(.missingIndex) }
        guard let column = column else { return .error(.missingColumn) }
        
        let table = manager.getActivePortal(for: itemPtr)
        
        return table.assignField(atRow: index, inColumn: column, fromManager: source)
    }
    
    
    /// Convenience method: Create an array in a table field.
    ///
    /// This operation uses assignField to create the requested table.
    ///
    /// - Parameters:
    ///   - atRow: The row index of the field.
    ///   - inColumn: The column index of the field.
    ///   - elementType: The type to be stored in the array.
    ///   - elementByteCount: The byte count for the array elements.
    ///   - valueByteCount: The initial byte count for the value field in the array.
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func createFieldArray(atRow row: Int, inColumn column: Int, elementType: ItemType, elementByteCount: Int? = nil, elementCount: Int) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard itemType == .table else { return .error(.operationNotSupported) }
        
        let im = ItemManager.createArrayManager(withNameField: nil, elementType: elementType, elementByteCount: elementByteCount ?? 0, elementCount: elementCount, endianness: endianness)
        
        return assignField(atRow: row, inColumn: column, fromManager: im)
    }
    
    
    /// Convenience method: Create a sequence in a table field.
    ///
    /// This operation uses assignField to create the requested table.
    ///
    /// - Parameters:
    ///   - at: The row index of the field.
    ///   - in: The column index of the field.
    ///   - valueByteCount: The initial byte count for the value field of the sequence.
    ///
    /// - Returns: Either .success or an error indicator.

    @discardableResult
    public func createFieldSequence(atRow row: Int, inColumn column: Int, valueByteCount: Int? = nil) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard itemType == .table else { return .error(.operationNotSupported) }

        let im = ItemManager.createSequenceManager(valueFieldByteCount: valueByteCount ?? 0, endianness: endianness)
        
        return assignField(atRow: row, inColumn: column, fromManager: im)
    }
    
    
    /// Convenience method: Create a dictionary in a table field.
    ///
    /// This operation uses assignField to create the requested table.
    ///
    /// - Parameters:
    ///   - at: The row index of the field.
    ///   - in: The column index of the field.
    ///   - valueByteCount: The initial byte count for the value field of the sequence.
    ///
    /// - Returns: Either .success or an error indicator.

    @discardableResult
    public func createFieldDictionary(atRow row: Int, inColumn column: Int, valueByteCount: Int? = nil) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard itemType == .table else { return .error(.operationNotSupported) }
        
        let im = ItemManager.createDictionaryManager(valueFieldByteCount: valueByteCount ?? 0, endianness: endianness)
        
        return assignField(atRow: row, inColumn: column, fromManager: im)
    }
    
    
    /// Convenience method: Create a table in a table field.
    ///
    /// This operation uses assignField to create the requested table.
    ///
    /// - Parameters:
    ///   - at: The row index of the field.
    ///   - in: The column index of the field.
    ///   - valueByteCount: The initial byte count for the value field of the sequence.
    ///
    /// - Returns: Either .success or an error indicator.

    @discardableResult
    public func createFieldTable(at row: Int, in column: Int, columnSpecifications: inout Array<ColumnSpecification>) -> Result {
        
        guard isValid else { return .error(.portalInvalid) }
        guard itemType == .table else { return .error(.operationNotSupported) }
        
        let im = ItemManager.createTableManager(columns: &columnSpecifications, endianness: endianness)
        
        return assignField(atRow: row, inColumn: column, fromManager: im)
    }
}


internal func buildTableItem(withNameField nameField: NameField?, columns: inout Array<ColumnSpecification>, initialRowsAllocated: Int, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
    
    let rowByteCount: Int = columns.reduce(0) { $0 + $1.fieldByteCount }

    let valueByteCount: Int = {
        
        // Start with the first 4 table parameters, each 4 bytes long
        
        var total = tableColumnDescriptorBaseOffset
        
        
        // Exit if there are no columns
        
        if columns.count == 0 { return total }
        
        
        // Add the column descriptor, 16 bytes for each column
        
        total += columns.count * 16
        
        
        // Add the name field byte counts
        
        columns.forEach() {
            total += $0.nameField.byteCount
        }
        
        
        // Add reserved space for the row fields.
        
        total += initialRowsAllocated * rowByteCount
        
        
        return total
    }()

    buildItem(ofType: .table, withNameField: nameField, atPtr: ptr, endianness)
    ptr.incrementItemByteCount(by: valueByteCount, endianness)

    ptr.itemValueFieldPtr.setTableRowCount(to: UInt32(0), endianness)
    tableWriteSpecification(valueFieldPtr: ptr.itemValueFieldPtr, &columns, endianness)
}
