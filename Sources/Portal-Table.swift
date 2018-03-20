//
//  Portal-Table.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 05/03/18.
//
//

import Foundation
import BRUtils


/// This is the signature of a closure that can be used to provide default values for table fields.
///
/// Note: The portal parameter is not managed by the active-portals manager.

public typealias SetTableFieldDefaultValue = (Portal) -> ()


extension Portal {
    
    
    /// Return a portal for the request table value field.
    ///
    /// - Note: The 'subscript[Int, Int]' is faster, consider using that version if the column remain constant over many subscript requests.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The column of the portal to retrieve.
    ///
    /// - Returns: The requested portal or the nullPortal if either column or row could not be matched.
    
    public subscript(row: Int, column: NameFieldDescriptor?) -> Portal {
        get {
            guard isTable else { return fatalOrNull("Self is not a table") }
            guard let column = column else { return fatalOrNull("No column specified") }
            guard row >= 0, row < _tableRowCount else { return fatalOrNull("Row must be >= 0 and < \(_tableRowCount)") }
            guard let columnIndex = _tableColumnIndex(for: column) else { return fatalOrNull("No column with this name (\(column.string))") }
            if _tableGetColumnType(for: columnIndex)!.isContainer {
                return manager.getActivePortal(for: _tableFieldValuePtr(row: row, column: columnIndex), index: row, column: columnIndex)
            } else {
                return manager.getActivePortal(for: itemPtr, index: row, column: columnIndex)
            }
        }
    }
    
    
    /// Return a portal for the request table value field.
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
            guard isTable else { return fatalOrNull("Self is not a table") }
            guard row >= 0, row < _tableRowCount else { return fatalOrNull("Row must be >= 0 and < \(_tableRowCount)") }
            guard let columnIndex = _tableColumnIndex(for: column) else { return fatalOrNull("No column with this name (\(column))") }
            if _tableGetColumnType(for: columnIndex)!.isContainer {
                return manager.getActivePortal(for: _tableFieldValuePtr(row: row, column: columnIndex), index: row, column: columnIndex)
            } else {
                return manager.getActivePortal(for: itemPtr, index: row, column: columnIndex)
            }
        }
    }
    
    
    /// Return a portal for the request table value field.
    ///
    /// - Parameters:
    ///   - row: The row for which to retrieve the portal.
    ///   - column: The column of the portal to retrieve.
    ///
    /// - Returns: The requested portal or the nullPortal if either column or row could not be matched.
    
    public subscript(row: Int, column: Int) -> Portal {
        get {
            guard isTable else { return fatalOrNull("Self is not a table") }
            guard row >= 0, row < _tableRowCount else { return fatalOrNull("Row must be >= 0 and < \(_tableRowCount)") }
            guard column >= 0, column < _tableColumnCount else { return fatalOrNull("Illegal column index") }
            if _tableGetColumnType(for: column)!.isContainer {
                return manager.getActivePortal(for: _tableFieldValuePtr(row: row, column: column), index: row, column: column)
            } else {
                return manager.getActivePortal(for: itemPtr, index: row, column: column)
            }
        }
    }
    
    
    public subscript(row: Int, column: NameFieldDescriptor) -> Bool? {
        get { return self[row, column].bool }
        set { self[row, column].bool = newValue }
    }
    public subscript(row: Int, column: String) -> Bool? {
        get { return self[row, column].bool }
        set { self[row, column].bool = newValue }
    }
    public subscript(row: Int, column: Int) -> Bool? {
        get { return self[row, column].bool }
        set { self[row, column].bool = newValue }
    }

    
    public subscript(row: Int, column: NameFieldDescriptor) -> UInt8? {
        get { return self[row, column].uint8 }
        set { self[row, column].uint8 = newValue }
    }
    public subscript(row: Int, column: String) -> UInt8? {
        get { return self[row, column].uint8 }
        set { self[row, column].uint8 = newValue }
    }
    public subscript(row: Int, column: Int) -> UInt8? {
        get { return self[row, column].uint8 }
        set { self[row, column].uint8 = newValue }
    }

    
    public subscript(row: Int, column: NameFieldDescriptor) -> UInt16? {
        get { return self[row, column].uint16 }
        set { self[row, column].uint16 = newValue }
    }
    public subscript(row: Int, column: String) -> UInt16? {
        get { return self[row, column].uint16 }
        set { self[row, column].uint16 = newValue }
    }
    public subscript(row: Int, column: Int) -> UInt16? {
        get { return self[row, column].uint16 }
        set { self[row, column].uint16 = newValue }
    }

    
    public subscript(row: Int, column: NameFieldDescriptor) -> UInt32? {
        get { return self[row, column].uint32 }
        set { self[row, column].uint32 = newValue }
    }
    public subscript(row: Int, column: String) -> UInt32? {
        get { return self[row, column].uint32 }
        set { self[row, column].uint32 = newValue }
    }
    public subscript(row: Int, column: Int) -> UInt32? {
        get { return self[row, column].uint32 }
        set { self[row, column].uint32 = newValue }
    }

    
    public subscript(row: Int, column: NameFieldDescriptor) -> UInt64? {
        get { return self[row, column].uint64 }
        set { self[row, column].uint64 = newValue }
    }
    public subscript(row: Int, column: String) -> UInt64? {
        get { return self[row, column].uint64 }
        set { self[row, column].uint64 = newValue }
    }
    public subscript(row: Int, column: Int) -> UInt64? {
        get { return self[row, column].uint64 }
        set { self[row, column].uint64 = newValue }
    }

    
    public subscript(row: Int, column: NameFieldDescriptor) -> Int8? {
        get { return self[row, column].int8 }
        set { self[row, column].int8 = newValue }
    }
    public subscript(row: Int, column: String) -> Int8? {
        get { return self[row, column].int8 }
        set { self[row, column].int8 = newValue }
    }
    public subscript(row: Int, column: Int) -> Int8? {
        get { return self[row, column].int8 }
        set { self[row, column].int8 = newValue }
    }
    
    
    public subscript(row: Int, column: NameFieldDescriptor) -> Int16? {
        get { return self[row, column].int16 }
        set { self[row, column].int16 = newValue }
    }
    public subscript(row: Int, column: String) -> Int16? {
        get { return self[row, column].int16 }
        set { self[row, column].int16 = newValue }
    }
    public subscript(row: Int, column: Int) -> Int16? {
        get { return self[row, column].int16 }
        set { self[row, column].int16 = newValue }
    }
    
    
    public subscript(row: Int, column: NameFieldDescriptor) -> Int32? {
        get { return self[row, column].int32 }
        set { self[row, column].int32 = newValue }
    }
    public subscript(row: Int, column: String) -> Int32? {
        get { return self[row, column].int32 }
        set { self[row, column].int32 = newValue }
    }
    public subscript(row: Int, column: Int) -> Int32? {
        get { return self[row, column].int32 }
        set { self[row, column].int32 = newValue }
    }
    
    
    public subscript(row: Int, column: NameFieldDescriptor) -> Int64? {
        get { return self[row, column].int64 }
        set { self[row, column].int64 = newValue }
    }
    public subscript(row: Int, column: String) -> Int64? {
        get { return self[row, column].int64 }
        set { self[row, column].int64 = newValue }
    }
    public subscript(row: Int, column: Int) -> Int64? {
        get { return self[row, column].int64 }
        set { self[row, column].int64 = newValue }
    }
    

    public subscript(row: Int, column: NameFieldDescriptor) -> Float32? {
        get { return self[row, column].float32 }
        set { self[row, column].float32 = newValue }
    }
    public subscript(row: Int, column: String) -> Float32? {
        get { return self[row, column].float32 }
        set { self[row, column].float32 = newValue }
    }
    public subscript(row: Int, column: Int) -> Float32? {
        get { return self[row, column].float32 }
        set { self[row, column].float32 = newValue }
    }
    
    
    public subscript(row: Int, column: NameFieldDescriptor) -> Float64? {
        get { return self[row, column].float64 }
        set { self[row, column].float64 = newValue }
    }
    public subscript(row: Int, column: String) -> Float64? {
        get { return self[row, column].float64 }
        set { self[row, column].float64 = newValue }
    }
    public subscript(row: Int, column: Int) -> Float64? {
        get { return self[row, column].float64 }
        set { self[row, column].float64 = newValue }
    }

    
    public subscript(row: Int, column: NameFieldDescriptor) -> String? {
        get { return self[row, column].string }
        set { self[row, column].string = newValue }
    }
    public subscript(row: Int, column: String) -> String? {
        get { return self[row, column].string }
        set { self[row, column].string = newValue }
    }
    public subscript(row: Int, column: Int) -> String? {
        get { return self[row, column].string }
        set { self[row, column].string = newValue }
    }

    
    public subscript(row: Int, column: NameFieldDescriptor) -> BrbonString? {
        get { return self[row, column].brbonString }
        set { self[row, column].brbonString = newValue }
    }
    public subscript(row: Int, column: String) -> BrbonString? {
        get { return self[row, column].brbonString }
        set { self[row, column].brbonString = newValue }
    }
    public subscript(row: Int, column: Int) -> BrbonString? {
        get { return self[row, column].brbonString }
        set { self[row, column].brbonString = newValue }
    }

    
    public subscript(row: Int, column: NameFieldDescriptor) -> Data? {
        get { return self[row, column].binary }
        set { self[row, column].binary = newValue }
    }
    public subscript(row: Int, column: String) -> Data? {
        get { return self[row, column].binary }
        set { self[row, column].binary = newValue }
    }
    public subscript(row: Int, column: Int) -> Data? {
        get { return self[row, column].binary }
        set { self[row, column].binary = newValue }
    }

    
    /// A pointer to the first byte of the column descriptors.
    
    internal var _tableColumnDescriptorsBasePtr: UnsafeMutableRawPointer {
        return itemPtr.brbonItemValuePtr.advanced(by: columnDescriptorBaseOffset)
    }
    
    
    /// A pointer to the column descriptor for a column.
    ///
    /// There is no check on the validity of the column index.
    
    internal func _tableColumnDescriptorPtr(for column: Int) -> UnsafeMutableRawPointer {
        return _tableColumnDescriptorsBasePtr.advanced(by: column * 16)
    }
    
    
    /// The number of rows in the table.
    
    internal var _tableRowCount: Int {
        get {
            return Int(UInt32(valuePtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowCountOffset), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowCountOffset), endianness)
        }
    }

    
    /// The number of column sin the table.
    
    internal var _tableColumnCount: Int {
        get {
            return Int(UInt32(valuePtr: itemPtr.brbonItemValuePtr.advanced(by: tableColumnCountOffset), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemValuePtr.advanced(by: tableColumnCountOffset), endianness)
        }
    }

    
    /// The offset from the start of the item value field to the first byte of the row content fields.
    
    internal var _tableRowsOffset: Int {
        get {
            return Int(UInt32(valuePtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowsOffsetOffset), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowsOffsetOffset), endianness)
        }
    }

    
    /// The number of bytes in a row. This is the raw number of bytes, including filler bytes.
    
    internal var _tableRowByteCount: Int {
        get {
            return Int(UInt32(valuePtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowByteCountOffset), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowByteCountOffset), endianness)
        }
    }
    
    
    /// Returns the column name for a column.
    
    internal func _tableGetColumnName(for column: Int) -> String {
        let nameUtf8Ptr = itemPtr.brbonItemValuePtr.advanced(by: _tableGetColumnNameUtf8Offset(for: column))
        let nameCount = Int(UInt8(valuePtr: nameUtf8Ptr, endianness))
        return String(valuePtr: nameUtf8Ptr.advanced(by: 1), count: nameCount, endianness)
    }
    
    
    /// Sets the column name for a column.
    ///
    /// Updates the column descriptors as well as the column name fields. May shift the entire content area of the table if the new name is larger as the old name.
    
    internal func _tableSetColumnName(_ value: String, for column: Int) -> Result {
        
        // Convert the name into a NFD
        guard let nfd = NameFieldDescriptor(value) else { return .nameFieldError }
        
        // Expand the name storage field when necessary
        if (nfd.data.count + 1) > _tableGetColumnNameByteCount(for: column) {
            let result = _tableIncreaseColumnNameByteCount(to: (nfd.data.count + 1), for: column)
            guard result == .success else { return result }
        }
        
        // Store the new name
        let nameUtf8Ptr = itemPtr.brbonItemValuePtr.advanced(by: _tableGetColumnNameUtf8Offset(for: column))
        UInt8(nfd.data.count).storeValue(atPtr: nameUtf8Ptr, endianness)
        nfd.data.storeValue(atPtr: nameUtf8Ptr.advanced(by: 1), endianness)
        
        // Store the new crc
        _tableSetColumnNameCrc(nfd.crc, for: column)
        
        return .success
    }

    
    /// Returns the CRC for the given column.
    
    internal func _tableGetColumnNameCrc(for column: Int) -> UInt16 {
        return UInt16(valuePtr: _tableColumnDescriptorPtr(for: column), endianness)
    }
    
    
    /// Sets the CRC of the column name to a new value.
    
    internal func _tableSetColumnNameCrc(_ value: UInt16, for column: Int) {
        value.storeValue(atPtr: _tableColumnDescriptorPtr(for: column), endianness)
    }
    
    
    /// Returns the byte count for the column name field.
    
    internal func _tableGetColumnNameByteCount(for column: Int) -> Int {
        return Int(UInt8(valuePtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnNameByteCountOffset), endianness))
    }
    
    
    /// Sets a new byte count for the column name field.
    
    internal func _tableSetColumnNameByteCount(_ value: UInt8, for column: Int) {
        value.storeValue(atPtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnNameByteCountOffset), endianness)
    }

    
    /// Returns the offset for the column name UTF8 field relative to the first byte of the item value field.
    
    internal func _tableGetColumnNameUtf8Offset(for column: Int) -> Int {
        return Int(UInt32(valuePtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnNameUtf8OffsetOffset), endianness))
    }

    
    /// Sets a new offset for column name UTF8 field relative to the first byte of the item value field.

    internal func _tableSetColumnNameUtf8Offset(_ value: Int, for column: Int) {
        UInt32(value).storeValue(atPtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnNameUtf8OffsetOffset), endianness)
    }
    
    
    /// Returns the item type of the value stored in the column.
    
    internal func _tableGetColumnType(for column: Int) -> ItemType? {
        return ItemType(atPtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnValueTypeOffset))
    }
    
    
    /// Sets a new item type for the value stored in the column.
    
    internal func _tableSetColumnType(_ value: ItemType, for column: Int) {
        value.storeValue(atPtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnValueTypeOffset))
    }

    
    /// Returns the offset of the first byte of the location where the value for the column is stored, relative to the first byte of the row.
    
    internal func _tableGetColumnValueOffset(for column: Int) -> Int {
        return Int(UInt32(valuePtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnValueOffsetOffset), endianness))
    }
    
    
    /// Sets a new value for the offset of the first byte of the column relative to the first byte of the row.
    
    internal func _tableSetColumnValueOffset(_ value: Int, for column: Int) {
        UInt32(value).storeValue(atPtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnValueOffsetOffset), endianness)
    }

    
    /// Returns the byte count that is reserved for the value in the column.
    
    internal func _tableGetColumnValueFieldByteCount(for column: Int) -> Int {
        return Int(UInt32(valuePtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnValueByteCountOffset), endianness))
    }
    
    
    /// Sets a new value in the column descriptor table for the number of bytes that can be stored in the column.
    
    internal func _tableSetColumnValueFieldByteCount(_ value: Int, for column: Int) {
        UInt32(value).storeValue(atPtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnValueByteCountOffset), endianness)
    }
    
    
    /// Returns a pointer to the first byte of the value in the row/column combination.
    
    internal func _tableFieldValuePtr(row: Int, column: Int) -> UnsafeMutableRawPointer {
        let rowOffset = row * _tableRowByteCount
        let columnOffset = _tableGetColumnValueOffset(for: column)
        return itemPtr.brbonItemValuePtr.advanced(by: _tableRowsOffset + rowOffset + columnOffset)
    }
    
    
    /// Returns a pointer to the first byte of the first item in a row
    
    internal func _tableGetRowPtr(row: Int) -> UnsafeMutableRawPointer {
        let rowOffset = row * _tableRowByteCount
        return itemPtr.brbonItemValuePtr.advanced(by: _tableRowsOffset + rowOffset)
    }
    
    
    /// Returns a NFD for the column.
    
    internal func _tableColumnNameFieldDescriptor(_ column: Int) -> NameFieldDescriptor {
        let crc = _tableGetColumnNameCrc(for: column)
        let byteCount = _tableGetColumnNameByteCount(for: column)
        let dataOffset = _tableGetColumnNameUtf8Offset(for: column)
        let dataPtr = itemPtr.brbonItemValuePtr.advanced(by: dataOffset)
        let dataCount = Int(UInt8(valuePtr: dataPtr, endianness))
        let data = Data(valuePtr: dataPtr.advanced(by: 1), count: dataCount, endianness)
        return NameFieldDescriptor(data: data, crc: crc, byteCount: byteCount)
    }
    
    
    /// Rewrites the complete table specification with the exception of the row count.
    
    internal func _tableWriteSpecification(_ arr: inout Array<ColumnSpecification>) {


        // Calculate the name and value offsets
        var nameOffset = 16 + 16 * arr.count
        var valueOffset = 0
        for i in 0 ..< arr.count {
            arr[i].nameOffset = nameOffset
            nameOffset += arr[i].nfd.byteCount
            arr[i].valueOffset = valueOffset
            valueOffset += arr[i].valueByteCount
        }
        let rowsOffset = nameOffset
        let rowByteCount = valueOffset
        
        let ptr = itemPtr.brbonItemValuePtr
        
        
        // Column Count
        UInt32(arr.count).storeValue(atPtr: ptr.advanced(by: tableColumnCountOffset), endianness)
        
        // Rows Offset
        UInt32(rowsOffset).storeValue(atPtr: ptr.advanced(by: tableRowsOffsetOffset), endianness)
        
        // Row Byte Count
        UInt32(rowByteCount).storeValue(atPtr: ptr.advanced(by: tableRowByteCountOffset), endianness)
        
        // Column Descriptors
        let columnDescriptorsPtr = ptr.advanced(by: columnDescriptorBaseOffset)
        for (index, column) in arr.enumerated() {
            let descriptorPtr = columnDescriptorsPtr.advanced(by: index * columnDescriptorByteCount)
            column.nfd.crc.storeValue(atPtr: descriptorPtr, endianness)
            UInt8(column.nfd.byteCount).storeValue(atPtr: descriptorPtr.advanced(by: columnNameByteCountOffset), endianness)
            column.valueType.storeValue(atPtr: descriptorPtr.advanced(by: columnValueTypeOffset))
            UInt32(column.nameOffset).storeValue(atPtr: descriptorPtr.advanced(by: columnNameUtf8OffsetOffset), endianness)
            UInt32(column.valueOffset).storeValue(atPtr: descriptorPtr.advanced(by: columnValueOffsetOffset), endianness)
            UInt32(column.valueByteCount).storeValue(atPtr: descriptorPtr.advanced(by: columnValueByteCountOffset), endianness)
        }
        
        // Column names
        for column in arr {
            UInt8(column.nfd.data.count).storeValue(atPtr: ptr.advanced(by: column.nameOffset), endianness)
            column.nfd.data.storeValue(atPtr: ptr.advanced(by: column.nameOffset + 1), endianness)
        }
    }
    
    
    /// Increases the space available for storage of the column's name utf8-byte-code sequence (and count byte).
    
    internal func _tableIncreaseColumnNameByteCount(to bytes: Int, for column: Int) -> Result {
        
        let delta = bytes - _tableGetColumnNameByteCount(for: column)
        let srcPtr = itemPtr.brbonItemValuePtr.advanced(by: _tableRowsOffset)
        let dstPtr = srcPtr.advanced(by: delta)
        let len = _tableContentByteCount

        let bytesNeeded = len + delta
        if (itemByteCount - 16) < bytesNeeded {
            let result = ensureValueFieldByteCount(of: bytesNeeded)
            guard result == .success else { return result }
        }
        
        // Move the table values up
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        
        // Rebuild the table and column description area
        var cols: Array<ColumnSpecification> = []
        for i in 0 ..< _tableColumnCount {
            guard let colSpec = ColumnSpecification(valueAreaPtr: itemPtr.brbonItemValuePtr, forColumn: i, endianness) else {
                // Undo: Move the table back to its original place
                manager.moveBlock(to: srcPtr, from: dstPtr, moveCount: len, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
                return .invalidTableColumnType
            }
            cols.append(colSpec)
        }
        let nfd = NameFieldDescriptor(data: cols[column].nfd.data, crc: cols[column].nfd.crc, byteCount: bytes)
        cols[column].nfd = nfd
        _tableWriteSpecification(&cols)


        return .success
    }
    
    
    /// Makes sure the byte count for the column's value is sufficient to store the value.
    
    internal func _tableEnsureColumnValueByteCount(of bytes: Int, in column: Int) -> Result {

        guard let cspec = ColumnSpecification(valueAreaPtr: itemPtr.brbonItemValuePtr, forColumn: column, endianness) else { return .invalidTableColumnType }

        if bytes > cspec.valueByteCount {
            let result = _tableIncreaseColumnValueByteCount(to: bytes.roundUpToNearestMultipleOf8(), for: column)
            guard result == .success else { return result }
        }
        
        return .success
    }
    
    
    /// Increases the value byte count for the column.
    
    internal func _tableIncreaseColumnValueByteCount(to bytes: Int, for column: Int) -> Result {
        
        let valueAreaPtr = itemPtr.brbonItemValuePtr
        let contentAreaPtr = valueAreaPtr.advanced(by: _tableRowsOffset)
        
        // Calculate the needed bytes for the entire table content
        
        let cspec = ColumnSpecification(valueAreaPtr: valueAreaPtr, forColumn: column, endianness)!
        
        let columnValueByteCountIncrease = bytes - cspec.valueByteCount
        let oldRowByteCount = _tableRowByteCount
        let newRowByteCount = oldRowByteCount + columnValueByteCountIncrease
        let newTableContentByteCount = _tableRowCount * newRowByteCount
        let necessaryItemByteCount = minimumItemByteCount + _tableRowsOffset + newTableContentByteCount
        
        if itemByteCount < necessaryItemByteCount {
            let result = increaseItemByteCount(to: necessaryItemByteCount)
            guard result == .success else { return result }
        }
        
        
        // Shift the column value fields to their new place
        
        let colOffsetPtr = itemPtr.brbonItemValuePtr.advanced(by: 16 + column * 16 + columnValueOffsetOffset)
        let colOffset = Int(UInt32(valuePtr: colOffsetPtr, endianness))
        let colValueByteCountPtr = itemPtr.brbonItemValuePtr.advanced(by: 16 + column * 16 + columnValueByteCountOffset)
        let colValueByteCount = Int(UInt32(valuePtr: colValueByteCountPtr, endianness))
        
        let offsetOfFirstByteAfterIncreasedByteCount = colOffset + colValueByteCount
        
        let bytesAfterIncrease = oldRowByteCount - offsetOfFirstByteAfterIncreasedByteCount
        let bytesBeforeIncrease = oldRowByteCount - bytesAfterIncrease
        
        for ri in (0 ..< _tableRowCount).reversed() {
            
            let oldRowStartPtr = contentAreaPtr.advanced(by: oldRowByteCount * ri)
            let newRowStartPtr = contentAreaPtr.advanced(by: newRowByteCount * ri)
            
            if bytesAfterIncrease > 0 {
                let srcPtr = oldRowStartPtr.advanced(by: offsetOfFirstByteAfterIncreasedByteCount)
                let dstPtr = newRowStartPtr.advanced(by: offsetOfFirstByteAfterIncreasedByteCount)
                manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: bytesAfterIncrease, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
            }
            
            // There are always bytes 'before'
            
            manager.moveBlock(to: newRowStartPtr, from: oldRowStartPtr, moveCount: bytesBeforeIncrease, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        // Update the column value byte count to the new value
        _tableSetColumnValueFieldByteCount(colValueByteCount + columnValueByteCountIncrease, for: column)
        
        // Update the row byte count
        _tableRowByteCount = newRowByteCount
        
        return .success
    }
    
    
    /// Returns the total amount of bytes stored in the table content area. Includes filler data in the value fields. Excludes filler data in the item.
    
    internal var _tableContentByteCount: Int {
        if _tableColumnCount == 0 { return 8 }
        return _tableRowsOffset + (_tableRowCount * _tableRowByteCount)
    }
    
    
    /// Returns the column index
    
    internal func _tableColumnIndex(for nfd: NameFieldDescriptor) -> Int? {
    
        let valuePtr = itemPtr.brbonItemValuePtr
        
        for i in 0 ..< _tableColumnCount {
            if nfd.crc != _tableGetColumnNameCrc(for: i) { continue }
            let offset = _tableGetColumnNameUtf8Offset(for: i)
            if nfd.data.count != Int(valuePtr.advanced(by: offset).assumingMemoryBound(to: UInt8.self).pointee) { continue }
            let data = Data(bytesNoCopy: valuePtr.advanced(by: offset + 1), count: nfd.data.count, deallocator: Data.Deallocator.none)
            if data == nfd.data { return i }
        }
        
        return nil
    }
    
    
    /// Returns the column index
    
    internal func _tableColumnIndex(for name: String?) -> Int? {
        guard let nfd = NameFieldDescriptor(name) else { return nil }
        return _tableColumnIndex(for: nfd)
    }
    
    
    /// Returns the column index.
    ///
    /// - Note: Using the column index is faster than using the column name. However the column index may change due to other operations. Make sure no table-operation is used of which it is documented that it may change the column index. This documentation will be backwards compatible, i.e. if it is not documented now, it is safe to assume that the operation will never change the column index.
    ///
    /// - Parameter for: The NameFieldDescriptor of the column to return the index for.
    ///
    /// - Returns: The requested index or nil if there is no matching column.
    
    public func tableColumnIndex(for nfd: NameFieldDescriptor?) -> Int? {
        guard isTable else { fatalOrNull("Self is not a table"); return nil }
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
        guard isTable else { fatalOrNull("Self is not a table"); return nil }
        return tableColumnIndex(for: name)
    }
    
    
    /// Execute the given closure on each column item at the requested row.
    ///
    /// - Parameters:
    ///   - atRow: The row for which to execute the closure.
    ///   - closure: The closure to eecte for each column value. Note that the portal in the closure parameter is not registered with the active portals manager and thus should not be used/stored outside the closure.
    
    public func forEachColumn(atRow index: Int, closure: (String, Portal) -> ()) {
        
        guard isTable else { fatalOrNull("Self is not a table"); return }
        guard index >= 0 && index < _tableRowCount else { fatalOrNull("No row at provided index (\(index))"); return }
        
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
    
    public func forEachRowAbortOnTrue(column: String, closure: (Portal) -> (Bool)) {
        
        guard isTable else { fatalOrNull("Self is not a table"); return }
        guard let ci = _tableColumnIndex(for: column) else { fatalOrNull("Cannot find column (\(column))"); return }
        
        for ri in 0 ..< _tableRowCount {
            if closure(Portal(itemPtr: itemPtr, index: ri, column: ci, manager: manager, endianness: endianness)) { break }
        }
    }
    

    /// Returns a dictionary with the columns at the given row.
    ///
    /// - Parameter index: The index of the row to retrieve.
    ///
    /// - Returns: A dictionary with the columns at the given row.
    
    public func getRow(_ index: Int) -> Dictionary<String, Portal> {
        
        guard isTable else { return [:] }

        var dict: Dictionary<String, Portal> = [:]
        
        for ci in 0 ..< _tableColumnCount {
            let name = _tableGetColumnName(for: ci)
            dict[name] = manager.getActivePortal(for: itemPtr, index: index, column: ci)
        }
        
        return dict
    }
    
    
    /// Adds new rows to the table.
    ///
    /// The fields of the new rows will be set to zero, after which the defaultValues closure is called.
    ///
    /// - Parameter amount: The number of rows that must be added.
    ///
    /// - Returns: 'success' or an error indicator.
    
    @discardableResult
    public func addRows(_ amount: Int, defaultValues closure: SetTableFieldDefaultValue? = nil) -> Result {
       
        guard isTable else { return .operationNotSupported }
        
        let necessaryValueByteCount = _tableRowsOffset + ((_tableRowCount + amount) * _tableRowByteCount)
        
        if valueFieldByteCount < necessaryValueByteCount {
            let result = increaseItemByteCount(to: minimumItemByteCount + necessaryValueByteCount)
            guard result == .success else { return result }
        }
        
        let data = Data(count: amount * _tableRowByteCount)
        
        let ptr = _tableFieldValuePtr(row: _tableRowCount, column: 0)
        
        data.storeValue(atPtr: ptr, endianness)
        
        _tableRowCount += amount

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
        
        guard isTable else { return .operationNotSupported }
        
        guard index >= 0 else { return .indexBelowLowerBound }
        guard index < _tableRowCount else { return .indexAboveHigherBound }
        
        let dstPtr = _tableFieldValuePtr(row: index, column: 0)
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
        
        guard isTable else { return .operationNotSupported }
        
        
        // Get the index of the column to remove
        
        guard let column = _tableColumnIndex(for: name) else { fatalOrNull("Column Not Found"); return .columnNotFound }
        
        
        // Build an array of column descriptors to re-create the table descriptor without the removed column
        
        var cols: Array<ColumnSpecification> = []
        for i in 0 ..< _tableColumnCount {
            if i != column {
                guard let colSpec = ColumnSpecification(valueAreaPtr: itemPtr.brbonItemValuePtr, forColumn: i, endianness) else {
                    return .invalidTableColumnType
                }
                cols.append(colSpec)
            }
        }
        
        
        // Cached variables (before they are changed by rebuilding the table descriptor)
        
        let valuePtr = itemPtr.brbonItemValuePtr
        let valueByteCount = _tableGetColumnValueFieldByteCount(for: column)
        
        let firstByteToBeRemovedOffset = _tableGetColumnValueOffset(for: column)
        let bytesToBeRemoved = _tableGetColumnValueFieldByteCount(for: column)
        let firstByteNotToRemoveOffset = firstByteToBeRemovedOffset + bytesToBeRemoved

        let oldRowByteCount = _tableRowByteCount
        let newRowByteCount = oldRowByteCount - valueByteCount
        
        let oldRowsOffset = _tableRowsOffset
        
        
        // Remove active portals in the regions to be deleted
        
        for i in 0 ..< _tableRowCount {
            manager.removeActivePortal(Portal(itemPtr: itemPtr, index: i, column: column, manager: manager, endianness: endianness))
        }
        
        
        // Rewrite table specification
        
        _tableWriteSpecification(&cols)
        
        
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
    ///   - withName: The name for the new column.
    ///   - nameFieldByteCount: A byte count for the name field (must be a multiple of 8 and <= 248, the name itself can use 1 byte less than specified)
    ///   - valueType: The type stored in this column.
    ///   - valueByteCount: The number of bytes reserved for the new column value.
    ///   - closure: A closure that can be used to set the default value for each new field.
    ///
    /// - Returns: Success or an error indicator.

    @discardableResult
    public func addColumn(withName name: String, nameFieldByteCount: Int? = nil, valueType: ItemType, valueByteCount vbc: Int? = nil, defaultValues closure: SetTableFieldDefaultValue? = nil) -> Result {
        
        
        // Create a new column specification
        
        guard let newSpec = ColumnSpecification(name: name, initialNameFieldByteCount: nameFieldByteCount, valueType: valueType, initialValueByteCount: vbc) else { return .nameFieldError }

        
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
        
        
        // The name may not exist already
        
        guard _tableColumnIndex(for: colSpec.nfd) == nil else { return .nameExists }
        
        
        // Build an array of column descriptors to re-create the table descriptor without the removed column
        
        var cols: Array<ColumnSpecification> = []
        for i in 0 ..< _tableColumnCount {
            guard let colSpec = ColumnSpecification(valueAreaPtr: itemPtr.brbonItemValuePtr, forColumn: i, endianness) else {
                    return .invalidTableColumnType
            }
            cols.append(colSpec)
        }
        
        
        // Add the new colspec
        
        cols.append(colSpec)

        
        // Calculate some new values to move the data into the new locations
        
        let rows = _tableRowCount

        let oldRowsOffset = _tableRowsOffset
        let oldRowByteCount = _tableRowByteCount
        
        var newRowsOffset = 16 + cols.count * 16
        for col in cols { newRowsOffset += col.nfd.byteCount }
        newRowsOffset = newRowsOffset.roundUpToNearestMultipleOf8()
        let newRowByteCount = oldRowByteCount + colSpec.valueByteCount
        
        
        // Create necessary space
        
        let necessaryTableValueByteCount = rows * newRowByteCount + newRowsOffset
        
        let result = ensureValueFieldByteCount(of: necessaryTableValueByteCount)
        guard result == .success else { return result }
        
        
        // Shift the data into its new space
        
        let valuePtr = itemPtr.brbonItemValuePtr
        
        for i in (0 ..< rows).reversed() {
            let dstPtr = valuePtr.advanced(by: newRowsOffset + (i * newRowByteCount))
            let srcPtr = valuePtr.advanced(by: oldRowsOffset + (i * oldRowByteCount))
            manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: oldRowByteCount, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
        }
        
        
        // Create the new table descriptor
        
        _tableWriteSpecification(&cols)
        
        
        // Set the default value
        
        if let closure = closure {
            
            let ci = _tableColumnCount - 1
            for ri in 0 ..< rows {
                let portal = manager.getActivePortal(for: itemPtr, index: ri, column: ci)
                closure(portal)
            }
            
        } else {

            let empty = Data(count: colSpec.valueByteCount)
            let ci = _tableColumnCount - 1
            for i in 0 ..< rows {
                let ptr = _tableFieldValuePtr(row: i, column: ci)
                empty.storeValue(atPtr: ptr, endianness)
            }
        }
        
        
        return .success
    }
    
    
    /// Inserts a new row into a table item.
    ///
    /// The content of the fields will be set to zero. After inserting the new row(s) a closure will be invoked for all new fields to allow a setup with default values.
    ///
    /// - Parameter at: The index at which a new row will be inserted. The index must be an existing index otherwise an error is returned.
    ///
    /// - Returns: Success or an error indicator.
    
    public func insertRows(at index: Int, amount: Int = 1, defaultValues closure: SetTableFieldDefaultValue? = nil) -> Result {
        
        guard isTable else { return .operationNotSupported }
        
        guard index >= 0 else { return .indexBelowLowerBound }
        guard index < _tableRowCount else { return .indexAboveHigherBound }
        
        guard (amount > 0) && (amount < Int(Int32.max)) else { return .illegalAmount }
        
        let necessaryValueByteCount = _tableRowsOffset + ((_tableRowCount + amount) * _tableRowByteCount)
        
        if valueFieldByteCount < necessaryValueByteCount {
            let result = increaseItemByteCount(to: minimumItemByteCount + necessaryValueByteCount)
            guard result == .success else { return result }
        }
        
        let data = Data(count: amount * _tableRowByteCount)
        
        let srcPtr = _tableFieldValuePtr(row: index, column: 0)
        let dstPtr = _tableFieldValuePtr(row: (index + amount), column: 0)
        let len = (_tableRowCount - index) * _tableRowByteCount
        
        manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: len, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)
        
        data.storeValue(atPtr: srcPtr, endianness)
        
        _tableRowCount += amount
        
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
    public func assignField(at row: Int, in column: Int, fromManager im: ItemManager) -> Result {
        
        
        // Prevent errors
        
        guard parentPtr.brbonItemTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.table.rawValue else { return Result.operationNotSupported }
        
        guard row >= 0 else { return Result.indexBelowLowerBound }
        guard row < _tableRowCount else { return Result.indexAboveHigherBound }
        
        guard (column >= 0) && (column < _tableColumnCount) else { return Result.columnNotFound }
        
        guard im.root.itemType?.isContainer ?? false else { return Result.dataInconsistency }
        
        guard _tableGetColumnType(for: column)?.isContainer ?? false else { return Result.invalidTableColumnType }
        
        
        // Ensure that there is sufficient space
        
        let result = _tableEnsureColumnValueByteCount(of: manager.count, in: column)
        
        guard result == .success else { return result }
        
        
        // Copy the container to the field
        
        let ptr = _tableFieldValuePtr(row: row, column: column)
        
        _ = Darwin.memmove(ptr, im.bufferPtr, manager.count)

        
        // Adjust the parent offset
        
        let pOffset = manager.bufferPtr.distance(to: itemPtr)
                
        UInt32(pOffset).storeValue(atPtr: ptr.brbonItemParentOffsetPtr, endianness)
        
        return .success
    }
    
    
    /// Convenience method: Create an array in a table field.
    ///
    /// This operation uses assignField to create the requested table.
    ///
    /// - Parameters:
    ///   - at: The row index of the field.
    ///   - in: The column index of the field.
    ///   - elementType: The type to be stored in the array.
    ///   - elementByteCount: The byte count for the array elements.
    ///   - valueByteCount: The initial byte count for the value field in the array.
    ///
    /// - Returns: Either .success or an error indicator.
    
    @discardableResult
    public func createFieldArray(at row: Int, in column: Int, elementType: ItemType, elementByteCount: Int? = nil, valueByteCount: Int? = nil) -> Result {
        
        let arr = BrbonArray(content: [], type: elementType, elementByteCount: elementByteCount)
        guard let im = ItemManager(value: arr, name: nil, itemValueByteCount: valueByteCount, endianness: endianness) else { return Result.dataInconsistency }
        
        return assignField(at: row, in: column, fromManager: im)
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
    public func createFieldSequence(at row: Int, in column: Int, valueByteCount: Int? = nil) -> Result {
        
        let seq = BrbonSequence()
        guard let im = ItemManager(value: seq, name: nil, itemValueByteCount: valueByteCount, endianness: endianness) else { return Result.dataInconsistency }
        
        return assignField(at: row, in: column, fromManager: im)
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
    public func createFieldDictionary(at row: Int, in column: Int, valueByteCount: Int? = nil) -> Result {
        
        let dict = BrbonDictionary()
        guard let im = ItemManager(value: dict, name: nil, itemValueByteCount: valueByteCount, endianness: endianness) else { return Result.dataInconsistency }
        
        return assignField(at: row, in: column, fromManager: im)
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
    public func createFieldTable(at row: Int, in column: Int, columnSpecifications: Array<ColumnSpecification>, valueByteCount: Int? = nil) -> Result {
        
        let tab = BrbonTable(columnSpecifications: columnSpecifications)
        guard let im = ItemManager(value: tab, name: nil, itemValueByteCount: valueByteCount, endianness: endianness) else { return Result.dataInconsistency }
        
        return assignField(at: row, in: column, fromManager: im)
    }
}
