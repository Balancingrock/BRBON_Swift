// =====================================================================================================================
//
//  File:       Portal-Equatable.swift
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
// 0.7.0 - Added type .color and .font
//         Type change is no longer possible
// 0.5.0 - Migration to Swift 4
// 0.4.3 - Changed access levels for index and column
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation


// The active portals management needs the Equatable and Hashable

extension Portal: Equatable {
    
    /// Compares the content pointed at by two portals and returns true if they are the same, regardless of endianness.
    ///
    /// Note that this opration only compares used bytes and excluding the flag bits and parent-offsets. A bit by bit compare would probably find differences even when this operation returns equality. Invalid item types will always be considered unequal.
    
    public static func ==(lhs: Portal, rhs: Portal) -> Bool {
        
        // Test if the portals are still valid
        guard lhs.isValid, rhs.isValid else { return false }
        
        // Check indicies
        if lhs.index != rhs.index { return false }
        
        // Check columns
        if lhs.column != rhs.column { return false }
        
        if lhs.index == nil {
            
            // Compare items
            
            // Test type
            guard let lType = lhs.itemType else { return false }
            guard let rType = rhs.itemType else { return false }
            guard lType == rType else { return false }
            
            // Test options
            guard let lOptions = lhs.itemOptions else { return false }
            guard let rOptions = rhs.itemOptions else { return false }
            guard lOptions == rOptions else { return false }
            
            // Do not test flags
            
            // Do not test length of name field
            
            // Do not test the byte count
            
            // Do not test parent offset
            
            // Test count/value field (note that unused bytes must be zero!
            guard UInt32(fromPtr: lhs.itemSmallValuePtr, lhs.endianness) == UInt32(fromPtr: rhs.itemSmallValuePtr, rhs.endianness) else { return false }
            
            // Test name field (if present)
            if lhs._itemNameFieldByteCount != 0 {
                guard let lnfd = lhs.nameField else { return false }
                guard let rnfd = rhs.nameField else { return false }
                guard lnfd == rnfd else { return false }
            }
            
            // Test value field
            switch lhs.itemType! {
                
            case .null, .bool, .int8, .int16, .int32, .uint8, .uint16, .uint32, .float32:
                
                return true // Was already tested in the count/value field
                
                
            case .int64, .uint64, .float64:
                
                return lhs.uint64 == rhs.uint64
                
                
            case .uuid:
                
                return lhs.uuid == rhs.uuid
                
                
            case .string:
                
                return lhs.string == rhs.string
                
                
            case .crcString:
                
                return lhs.string == rhs.string
                
                
            case .binary:
                
                return lhs.binary == rhs.binary
                
                
            case .crcBinary:
                
                return lhs.crcBinary == rhs.crcBinary
                
                
            case .color:
                
                return lhs.color == rhs.color
                
                
            case .font:
                
                return lhs.font == rhs.font
                
                
            case .array:
                
                // Test element type
                guard lhs._arrayElementType != nil else { return false }
                guard rhs._arrayElementType != nil else { return false }
                guard lhs._arrayElementType == rhs._arrayElementType else { return false }
                
                // Do not test the element byte count
                
                // Test the elements
                for index in 0 ..< lhs._arrayElementCount {
                    let lPortal = Portal(itemPtr: lhs.itemPtr, index: index, manager: lhs.manager, endianness: lhs.endianness)
                    let rPortal = Portal(itemPtr: rhs.itemPtr, index: index, manager: rhs.manager, endianness: rhs.endianness)
                    if lPortal != rPortal { return false }
                }
                
                return true
                
                
            case .dictionary:
                
                var result = true
                
                lhs.forEachAbortOnTrue(){
                    (lportal: Portal) -> Bool in
                    let rportal = rhs[lportal.itemName!].portal
                    result = (lportal == rportal)
                    return !result
                }
                
                return result
                
                
            case .sequence:
                
                for index in 0 ..< lhs._sequenceItemCount {
                    let lPortal = lhs[index].portal
                    let rPortal = rhs[index].portal
                    if lPortal != rPortal { return false }
                }
                return true
                
                
            case .table:
                
                if lhs._tableColumnCount != rhs._tableColumnCount { return false }
                if lhs._tableRowCount != rhs._tableRowCount { return false }
                
                for ci in 0 ..< lhs._tableColumnCount {
                    
                    let lnamecrc = lhs._tableGetColumnNameCrc(for: ci)
                    let rnamecrc = rhs._tableGetColumnNameCrc(for: ci)
                    if lnamecrc != rnamecrc { return false }
                    
                    let lname = lhs._tableGetColumnName(for: ci)
                    let rname = rhs._tableGetColumnName(for: ci)
                    if lname != rname { return false }
                    
                    guard let lType = lhs._tableGetColumnType(for: ci) else { return false }
                    guard let rType = rhs._tableGetColumnType(for: ci) else { return false }
                    if lType != rType { return false }
                    
                    for ri in 0 ..< lhs._tableRowCount {
                        
                        switch lType {
                            
                        case .null: break
                            
                        case .bool:
                            let lbool = Bool(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rbool = Bool(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lbool != rbool { return false }
                            
                        case .int8, .uint8:
                            if lhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt8.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt8.self).pointee { return false }
                            
                        case .int16, .uint16:
                            if lhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt16.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt16.self).pointee { return false }
                            
                        case .int32, .uint32, .float32:
                            if lhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt32.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt32.self).pointee { return false }
                            
                        case .int64, .uint64, .float64:
                            if lhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt64.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt64.self).pointee { return false }
                            
                        case .uuid:
                            if lhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt64.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).assumingMemoryBound(to: UInt64.self).pointee { return false }
                            if lhs._tableFieldPtr(row: ri, column: ci).advanced(by: 8).assumingMemoryBound(to: UInt64.self).pointee
                                != rhs._tableFieldPtr(row: ri, column: ci).advanced(by: 8).assumingMemoryBound(to: UInt64.self).pointee { return false }
                            
                        case .color:
                            if lhs.color != rhs.color { return false }
                            
                        case .font:
                            if lhs.font != rhs.font { return false }
                            
                        case .string:
                            let lstr = BRString(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rstr = BRString(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .crcString:
                            let lstr = BRCrcString(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rstr = BRCrcString(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .binary:
                            let lstr = Data(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rstr = Data(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .crcBinary:
                            let lstr = BRCrcBinary(fromPtr: lhs._tableFieldPtr(row: ri, column: ci), lhs.endianness)
                            let rstr = BRCrcBinary(fromPtr: rhs._tableFieldPtr(row: ri, column: ci), rhs.endianness)
                            if lstr != rstr { return false }
                            
                        case .array, .sequence, .dictionary, .table:
                            let lportal = Portal(itemPtr: lhs._tableFieldPtr(row: ri, column: ci), manager: lhs.manager, endianness: lhs.endianness)
                            let rportal = Portal(itemPtr: rhs._tableFieldPtr(row: ri, column: ci), manager: rhs.manager, endianness: rhs.endianness)
                            if lportal != rportal { return false }
                        }
                    }
                }
                
                return true
            }
            
            
        } else {
            
            // The lhs and rhs are an array element or a table field.
            
            // Test a single value
            switch lhs.valueType! {
                
            case .null: return true
            case .bool: return lhs.bool == rhs.bool
            case .int8: return lhs.int8 == rhs.int8
            case .int16: return lhs.int16 == rhs.int16
            case .int32: return lhs.int32 == rhs.int32
            case .int64: return lhs.int64 == rhs.int64
            case .uint8: return lhs.uint8 == rhs.uint8
            case .uint16: return lhs.uint16 == rhs.uint16
            case .uint32: return lhs.uint32 == rhs.uint32
            case .uint64: return lhs.uint64 == rhs.uint64
            case .float32: return lhs.float32 == rhs.float32
            case .float64: return lhs.float64 == rhs.float64
            case .uuid: return lhs.uuid == rhs.uuid
            case .color: return lhs.color == rhs.color
            case .font: return lhs.font == rhs.font
            case .string: return lhs.string == rhs.string
            case .crcString: return lhs.string == rhs.string
            case .binary: return lhs.binary == rhs.binary
            case .crcBinary: return lhs.crcBinary == rhs.crcBinary
            case .array, .dictionary, .sequence, .table:
                let lPortal = Portal(itemPtr: lhs._arrayElementPtr(for: lhs.index!), index: nil, manager: lhs.manager, endianness: lhs.endianness)
                let rPortal = Portal(itemPtr: rhs._arrayElementPtr(for: rhs.index!), index: nil, manager: rhs.manager, endianness: rhs.endianness)
                return lPortal == rPortal
            }
        }
    }
}
