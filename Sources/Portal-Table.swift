//
//  Portal-Table.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 05/03/18.
//
//

import Foundation

public struct TableRow {
    
    internal let table: Portal
    
    init(portal: Portal) {
        self.table = portal
    }
    
    public subscript(column: NameFieldDescriptor?) -> Portal {
        get {
            // Guarding against failure
            guard table.isValid else { fatalOrNull("Portal is no longer valid"); return Portal.nullPortal }
            guard let nfd = column else { fatalOrNull("Name descriptor failure"); return Portal.nullPortal }
            
            // Get pointer to column descriptor
            guard let cIndex = columnIndex(for: nfd) else { return Portal.nullPortal }
            
            // Create and return portal
            return Portal(itemPtr: table.itemPtr, index: table.index, column: cIndex, manager: table.manager, endianness: table.endianness)
        }
    }
    
    public subscript(column: String) -> Portal {
        get {
            
            return self[NameFieldDescriptor(column)]
        }
        set {}
    }
    
    internal func columnIndex(for nfd: NameFieldDescriptor) -> Int? {
        var columnIndex = columnCount
        let tableValuePtr = table.itemPtr.brbonItemValuePtr
        let columnDescriptorPtr = tableValuePtr.advanced(by: columnDescriptorBaseOffset)
        while columnIndex > 0 {
            let ptr = columnDescriptorPtr.advanced(by: 16 * (columnIndex - 1))
            if nfd.crc != UInt16(valuePtr: ptr.advanced(by: columnNameCrc16Offset), table.endianness) { continue }
            let nameByteCount = Int(UInt16(valuePtr: ptr.advanced(by: columnNameByteCountOffset), table.endianness))
            if nfd.data.count != nameByteCount { continue }
            let nameDataOffset = Int(UInt32(valuePtr: ptr.advanced(by: columnNameUtf8OffsetOffset), table.endianness))
            let nameData = Data(valuePtr: tableValuePtr.advanced(by: nameDataOffset), count: nameByteCount, table.endianness)
            if nfd.data == nameData { return columnIndex }
            columnIndex -= 1
        }
        return nil
    }
    
    var columnCount: Int {
        return Int(UInt32(valuePtr: table.itemPtr.brbonItemValuePtr.advanced(by: tableColumnCountOffset), table.endianness))
    }
}


extension Portal {
    
    
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
        let nameCount = _tableGetColumnNameByteCount(for: column)
        let nameUtf8Ptr = itemPtr.brbonItemValuePtr.advanced(by: _tableGetColumnNameUtf8Offset(for: column))
        return String(valuePtr: nameUtf8Ptr, count: nameCount, endianness)
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
        return Int(UInt16(valuePtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnNameByteCountOffset), endianness))
    }
    
    
    /// Sets a new byte count for the column name field.
    
    internal func _tableSetColumnNameByteCount(_ value: UInt16, for column: Int) {
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
    
    internal func _tableGetColumnValueByteCount(for column: Int) -> Int {
        return Int(UInt32(valuePtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnValueByteCountOffset), endianness))
    }
    
    
    /// Sets a new value in the column descriptor table for the number of bytes that can be stored in the column.
    
    internal func _tableSetColumnValueByteCount(_ value: Int, for column: Int) {
        UInt32(value).storeValue(atPtr: _tableColumnDescriptorPtr(for: column).advanced(by: columnValueByteCountOffset), endianness)
    }

    
    /// Returns a pointer to the first byte of the value in the row/column combination.
    
    internal func _tableFieldValuePtr(row: Int, column: Int) -> UnsafeMutableRawPointer {
        let rowOffset = row * _tableRowByteCount
        let columnOffset = _tableGetColumnValueOffset(for: column)
        return itemPtr.brbonItemValuePtr.advanced(by: _tableRowsOffset + rowOffset + columnOffset)
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
        var columnNamePtr = columnDescriptorsPtr.advanced(by: arr.count * columnDescriptorByteCount)
        for column in arr {
            UInt8(column.nfd.data.count).storeValue(atPtr: columnNamePtr, endianness)
            column.nfd.data.storeValue(atPtr: columnNamePtr.advanced(by: 1), endianness)
            columnNamePtr = columnNamePtr.advanced(by: (column.nfd.data.count + 1))
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
            let result = ensureValueByteCount(for: bytesNeeded)
            guard result == .success else { return result }
        }
        
        // Move the table values up
        moveBlock(dstPtr, srcPtr, len)
        
        // Rebuild the table and column description area
        var cols: Array<ColumnSpecification> = []
        for i in 0 ..< _tableColumnCount {
            guard let colSpec = ColumnSpecification(valueAreaPtr: itemPtr.brbonItemValuePtr, forColumn: i, endianness) else {
                // Move the table back to its original place
                moveBlock(srcPtr, dstPtr, len)
                return .invalidTableColumnType
            }
            cols.append(colSpec)
        }
        let nfd = NameFieldDescriptor(data: cols[column].nfd.data, crc: cols[column].nfd.crc, byteCount: bytes)
        cols[column].nfd = nfd
        _tableWriteSpecification(&cols)

        // Update the portals (only needed for the containers in the table content)
        manager.activePortals.updatePointers(atAndAbove: srcPtr, below: srcPtr.advanced(by: len), toNewBase: dstPtr)

        return .success
    }
    
    
    /// Makes sure the byte count for the column's value is sufficient to store the value.
    
    internal func _tableEnsureColumnValueByteCount(for value: Coder, in column: Int) -> Result {

        guard let cspec = ColumnSpecification(valueAreaPtr: itemPtr.brbonItemValuePtr, forColumn: column, endianness) else { return .invalidTableColumnType }

        if value.elementByteCount > cspec.valueByteCount {
            let result = _tableIncreaseColumnValueByteCount(to: value.elementByteCount.roundUpToNearestMultipleOf8(), for: column)
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
                moveBlock(dstPtr, srcPtr, bytesAfterIncrease)
                manager.activePortals.updatePointers(atAndAbove: srcPtr, below: srcPtr.advanced(by: bytesAfterIncrease), toNewBase: dstPtr)
            }
            
            // There are always bytes 'before'
            
            moveBlock(newRowStartPtr, oldRowStartPtr, bytesBeforeIncrease)
            manager.activePortals.updatePointers(atAndAbove: oldRowStartPtr, below: oldRowStartPtr.advanced(by: bytesBeforeIncrease), toNewBase: newRowStartPtr)
        }
        
        // Update the column value byte count to the new value
        _tableSetColumnValueByteCount(colValueByteCount + columnValueByteCountIncrease, for: column)
        
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
            return Portal(itemPtr: itemPtr, index: row, column: columnIndex, manager: manager, endianness: endianness)
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
            return Portal(itemPtr: itemPtr, index: row, column: columnIndex, manager: manager, endianness: endianness)
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
            return Portal(itemPtr: itemPtr, index: row, column: column, manager: manager, endianness: endianness)
        }
    }


    /// Adds new rows with the given default content to the table.
    ///
    /// If the dictionary with default values specifies new column names, these columns will be added.
    ///
    ///
    /// - Note: If this operation is used to add rows, then the existing __COLUMN INDEX__'s must be considered __INVALID__.
    ///
    /// - Parameters:
    ///   - fields: An optional dictionary with default values for the fields. If a field has no default value it will be set to zero. If a field is specified that has no corresponding column in the table, an additional column will be added. If an out of memory occurs, some columns may still have been added.
    ///   - count: The number of rows that must be added. If an out of memory occurs, then the maximum possible number of rows will have been added.
    ///
    /// - Returns:
    @discardableResult
    public func addRows(_ fields: Dictionary<String, IsBrbon>?, count: Int = 1) -> Result {
        return .success
    }
    
    
    /// Removes the row from the table.
    ///
    /// - Parameter index: The index of the row to be removed.
    ///
    /// - Result: Success or an error indicator.
    
    @discardableResult
    public func removeRow(_ index: Int) -> Result {
        fatalError("Not yet implemented")
    }
    
    
    /// Removes the column with the given name from the table.
    ///
    /// - Note: If this operation is successful, then the existing __COLUMN INDEX__'s must be considered __INVALID__.
    ///
    /// - Parameter name: The name of the column to be removed.
    ///
    /// - Result: Success or an error indicator.
    
    @discardableResult
    public func removeColumn(_ name: String) -> Result {
        fatalError("Not yet implemented")
    }
    
    
    /// Adds a new column to the table.
    ///
    /// - Note: If this operation is successful, then the existing __COLUMN INDEX__'s must be considered __INVALID__.
    ///
    /// - Parameters:
    ///   - withName: The name for the new column.
    ///   - nameFieldByteCount: A byte count for the name field (must be a multiple of 8 and <= 248, the name itself can use 1 byte less than specified)
    ///   - valueType: The type stored in this column.
    ///   - defaultValue: A default value that will be assigned to existing and new rows. When not specified, the bytes containing the value will be set to zero.
    ///   - valueByteCount: The number of bytes reserved for value storage.
    ///
    /// - Returns: Success of an error indicator.
    
    @discardableResult
    public func addColumn(withName name: String, nameFieldByteCount: Int? = nil, valueType type: ItemType, defaultValue: IsBrbon? = nil, valueByteCount: Int? = nil) -> Result {
        fatalError("Not yet implemented")
    }
}
