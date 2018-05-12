// =====================================================================================================================
//
//  File:       ColumnSpecification.swift
//  Project:    BRBON
//
//  Version:    0.7.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2018 Marinus van der Lugt, All rights reserved.
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
//  I strongly believe that voluntarism is the way for societies to function optimally. Thus I have choosen to leave it
//  up to you to determine the price for this code. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  wishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to check the website http://www.balancingrock.nl before payment)
//
//  For private and non-profit use the suggested price is the price of 1 good cup of coffee, say $4.
//  For commercial use the suggested price is the price of 1 good meal, say $20.
//
//  You are however encouraged to pay more ;-)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// History
//
// 0.7.0 - File renamed from BrbonTable-Coder to Coder-BrbonTable
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

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
        let ptr = fromPtr.advanced(by: tableColumnDescriptorBaseOffset + column * tableColumnDescriptorByteCount)
        
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

