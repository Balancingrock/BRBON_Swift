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
        get { return self[NameFieldDescriptor(column)] }
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
    
    internal var tableColumnDescriptorsBasePtr: UnsafeMutableRawPointer {
        return itemPtr.brbonItemValuePtr.advanced(by: columnDescriptorBaseOffset)
    }
    
    internal func columnDescriptorPtr(for column: Int) -> UnsafeMutableRawPointer {
        return tableColumnDescriptorsBasePtr.advanced(by: column * 16)
    }
    
    internal var tableRowCount: Int {
        get {
            return Int(UInt32(valuePtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowCountOffset), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowCountOffset), endianness)
        }
    }

    internal var tableColumnCount: Int {
        get {
            return Int(UInt32(valuePtr: itemPtr.brbonItemValuePtr.advanced(by: tableColumnCountOffset), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemValuePtr.advanced(by: tableColumnCountOffset), endianness)
        }
    }

    internal var tableRowsOffset: Int {
        get {
            return Int(UInt32(valuePtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowsOffsetOffset), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowsOffsetOffset), endianness)
        }
    }

    internal var tableRowByteCount: Int {
        get {
            return Int(UInt32(valuePtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowByteCountOffset), endianness))
        }
        set {
            UInt32(newValue).storeValue(atPtr: itemPtr.brbonItemValuePtr.advanced(by: tableRowByteCountOffset), endianness)
        }
    }
    
    internal func tableGetColumnName(for column: Int) -> String {
        let nameCount = tableGetColumnNameByteCount(for: column)
        let nameUtf8Ptr = itemPtr.brbonItemValuePtr.advanced(by: tableGetColumnNameUtf8Offset(for: column))
        return String(valuePtr: nameUtf8Ptr, count: nameCount, endianness)
    }
    
    internal func tableSetColumnName(_ value: String, for column: Int) -> Result {
        guard let nfd = NameFieldDescriptor(value) else { return .nameFieldError }
        if (nfd.data.count + 1) > tableGetColumnNameByteCount(for: column) {
            let result = increaseColumnNameByteCount(to: (nfd.data.count + 1), for: column)
            guard result == .success else { return result }
        }
        let nameUtf8Ptr = itemPtr.brbonItemValuePtr.advanced(by: tableGetColumnNameUtf8Offset(for: column))
        UInt8(nfd.data.count).storeValue(atPtr: nameUtf8Ptr, endianness)
        nfd.data.storeValue(atPtr: nameUtf8Ptr.advanced(by: 1), endianness)
        return .success
    }

    internal func tableGetColumnNameCrc(for column: Int) -> UInt16 {
        return UInt16(valuePtr: columnDescriptorPtr(for: column), endianness)
    }
    
    internal func tableSetColumnNameCrc(_ value: UInt16, for column: Int) {
        value.storeValue(atPtr: columnDescriptorPtr(for: column), endianness)
    }
    
    internal func tableGetColumnNameByteCount(for column: Int) -> Int {
        return Int(UInt16(valuePtr: columnDescriptorPtr(for: column).advanced(by: columnNameByteCountOffset), endianness))
    }
    
    internal func tableSetColumnNameByteCount(_ value: UInt16, for column: Int) {
        value.storeValue(atPtr: columnDescriptorPtr(for: column).advanced(by: columnNameByteCountOffset), endianness)
    }

    internal func tableGetColumnNameUtf8Offset(for column: Int) -> Int {
        return Int(UInt32(valuePtr: columnDescriptorPtr(for: column).advanced(by: columnNameUtf8OffsetOffset), endianness))
    }
    
    internal func tableSetColumnNameUtf8Offset(_ value: Int, for column: Int) {
        UInt32(value).storeValue(atPtr: columnDescriptorPtr(for: column).advanced(by: columnNameUtf8OffsetOffset), endianness)
    }
    
    internal func tableGetColumnType(for column: Int) -> ItemType? {
        return ItemType(atPtr: columnDescriptorPtr(for: column).advanced(by: columnValueTypeOffset))
    }
    
    internal func tableSetColumnType(_ value: ItemType, for column: Int) {
        value.storeValue(atPtr: columnDescriptorPtr(for: column).advanced(by: columnValueTypeOffset))
    }

    internal func tableGetColumnValueOffset(for column: Int) -> Int {
        return Int(UInt32(valuePtr: columnDescriptorPtr(for: column).advanced(by: columnValueOffsetOffset), endianness))
    }
    
    internal func tableSetColumnValueOffset(_ value: Int, for column: Int) {
        UInt32(value).storeValue(atPtr: columnDescriptorPtr(for: column).advanced(by: columnValueOffsetOffset), endianness)
    }

    internal func tableGetColumnValueByteCount(for column: Int) -> Int {
        return Int(UInt32(valuePtr: columnDescriptorPtr(for: column).advanced(by: columnValueByteCountOffset), endianness))
    }
    
    internal func tableSetColumnValueByteCount(_ value: Int, for column: Int) {
        UInt32(value).storeValue(atPtr: columnDescriptorPtr(for: column).advanced(by: columnValueByteCountOffset), endianness)
    }

    internal func tableFieldValuePtr(row: Int, column: Int) -> UnsafeMutableRawPointer {
        let rowOffset = row * tableRowByteCount
        let columnOffset = tableGetColumnValueOffset(for: column)
        return itemPtr.brbonItemValuePtr.advanced(by: tableRowsOffset + rowOffset + columnOffset)
    }
    
    internal func tableColumnNameFieldDescriptor(_ column: Int) -> NameFieldDescriptor {
        let crc = tableGetColumnNameCrc(for: column)
        let byteCount = tableGetColumnNameByteCount(for: column)
        let dataOffset = tableGetColumnNameUtf8Offset(for: column)
        let dataPtr = itemPtr.brbonItemValuePtr.advanced(by: dataOffset)
        let dataCount = Int(UInt8(valuePtr: dataPtr, endianness))
        let data = Data(valuePtr: dataPtr.advanced(by: 1), count: dataCount, endianness)
        return NameFieldDescriptor(data: data, crc: crc, byteCount: byteCount)
    }
    
    internal func tableWriteSpecification(_ arr: inout Array<ColumnSpecification>) {


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
        
        
        // Row Count
        UInt32(0).storeValue(atPtr: ptr, endianness)
        
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
    
    internal func increaseColumnNameByteCount(to bytes: Int, for column: Int) -> Result {
        
        let delta = bytes - tableGetColumnNameByteCount(for: column)
        let srcPtr = itemPtr.brbonItemValuePtr.advanced(by: tableRowsOffset)
        let dstPtr = srcPtr.advanced(by: delta)
        let len = tableContentByteCount

        let bytesNeeded = len + delta
        if (itemByteCount - 16) < bytesNeeded {
            let result = ensureValueByteCount(for: bytesNeeded)
            guard result == .success else { return result }
        }
        
        // Move the table values up
        moveBlock(dstPtr, srcPtr, len)
        
        // Rebuild the table and column description area
        var cols: Array<ColumnSpecification> = []
        for i in 0 ..< tableColumnCount {
            guard let colSpec = ColumnSpecification(valueAreaPtr: itemPtr.brbonItemValuePtr, forColumn: i, endianness) else {
                // Move the table back to its original place
                moveBlock(srcPtr, dstPtr, len)
                return .invalidTableColumnType
            }
            cols.append(colSpec)
        }
        let nfd = NameFieldDescriptor(data: cols[column].nfd.data, crc: cols[column].nfd.crc, byteCount: bytes)
        cols[column].nfd = nfd
        tableWriteSpecification(&cols)

        // Update the portals (only needed for the containers in the table content)
        manager.activePortals.updatePointers(atAndAbove: srcPtr, below: srcPtr.advanced(by: len), toNewBase: dstPtr)

        return .success
    }
    
    internal func ensureColumnValueByteCount(for value: Coder, in column: Int) -> Result {

        guard let cspec = ColumnSpecification(valueAreaPtr: itemPtr.brbonItemValuePtr, forColumn: column, endianness) else { return .invalidTableColumnType }

        if value.elementByteCount > cspec.valueByteCount {
            let result = increaseColumnValueByteCount(to: value.elementByteCount.roundUpToNearestMultipleOf8(), for: column)
            guard result == .success else { return result }
        }
        
        return .success
    }
    
    internal func increaseColumnValueByteCount(to bytes: Int, for column: Int) -> Result {
        
        let valueAreaPtr = itemPtr.brbonItemValuePtr
        let contentAreaPtr = valueAreaPtr.advanced(by: tableRowsOffset)
        
        // Calculate the needed bytes for the entire table content
        
        let cspec = ColumnSpecification(valueAreaPtr: valueAreaPtr, forColumn: column, endianness)!
        
        let columnValueByteCountIncrease = bytes - cspec.valueByteCount
        let oldRowByteCount = tableRowByteCount
        let newRowByteCount = oldRowByteCount + columnValueByteCountIncrease
        let newTableContentByteCount = tableRowCount * newRowByteCount
        let necessaryItemByteCount = minimumItemByteCount + tableRowsOffset + newTableContentByteCount
        
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
        
        for ri in (0 ..< tableRowCount).reversed() {
            
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
        tableSetColumnValueByteCount(colValueByteCount + columnValueByteCountIncrease, for: column)
        
        // Update the row byte count
        tableRowByteCount = newRowByteCount
        
        return .success
    }
    
    
    internal var tableContentByteCount: Int {
        if tableColumnCount == 0 { return 8 }
        return tableRowsOffset + (tableRowCount * tableRowByteCount)
    }
    
    public subscript(row: Int) -> TableRow {
        get {
            return TableRow(portal: Portal.nullPortal)
        }
    }
    
    public subscript(row: Int, column: NameFieldDescriptor?) -> Portal {
        get { return Portal.nullPortal }
        set {}
    }
    
    public func add(row: Dictionary<NameFieldDescriptor, IsBrbon>) -> Result {
        return .success
    }
    
    public func add(row: Dictionary<String, IsBrbon>) -> Result {
        let dict: Dictionary<NameFieldDescriptor, IsBrbon> = [:]
        for field in row {
            guard let nfd = NameFieldDescriptor(field.key) else { return Result.nameFieldError }
        }
        return add(row: dict)
    }

}
