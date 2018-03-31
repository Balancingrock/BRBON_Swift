// =====================================================================================================================
//
//  File:       NameField.swift
//  Project:    BRBON
//
//  Version:    0.4.2
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
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


/// The NameField structure contains the name field information for an item name or column name.

public struct NameField: Equatable, Hashable {
    
    public static func ==(lhs: NameField, rhs: NameField) -> Bool {
        guard lhs.crc == rhs.crc else { return false }
        guard lhs.byteCount == rhs.byteCount else { return false }
        guard lhs.data == rhs.data else { return false }
        return true
    }

    
    internal let data: Data
    internal let crc: UInt16
    internal let byteCount: Int
    
    public internal(set) var hashValue: Int
    
    public var string: String { return String(data: data, encoding: .utf8)! }
    
    public init?(_ name: String?, fixedLength: Int? = nil) {
        
        guard let name = name else { return nil }
        
        var length: Int = 0
        
        
        // Create a data object from the name with maximal 245 bytes
        
        guard let (nameData, charRemoved) = name.utf8CodeMaxBytes(245) else { return nil }
        guard !charRemoved else { return nil }
        self.data = nameData
        
        
        // If a fixed length is specified, determine if it can be used
        
        if let fixedLength = fixedLength {
            guard fixedLength <= 245 else { return nil }
            if fixedLength < data.count { return nil }
            length = Int(fixedLength)
        } else {
            length = self.data.count
        }
        
        
        // If there is a field, then add 3 bytes for the hash and length indicator
        
        self.byteCount = (length == 0) ? 0 : (length + 3).roundUpToNearestMultipleOf8()
        
        
        // Create the crc
        
        self.crc = data.crc16()
        
        
        // And the hash
        
        self.hashValue = data.hashValue
    }
    
    internal init(data: Data, crc: UInt16, byteCount: Int) {
        self.data = data
        self.crc = crc
        self.byteCount = byteCount
        self.hashValue = data.hashValue
    }
    
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc.storeValue(atPtr: atPtr, endianness)
        UInt8(data.count).storeValue(atPtr: atPtr.advanced(by: 2), endianness)
        let dataPtr = atPtr.advanced(by: 3).assumingMemoryBound(to: UInt8.self)
        data.copyBytes(to: dataPtr, count: data.count)
        let remainder = byteCount - 3 - data.count
        if remainder > 0 {
            let remainderPtr = atPtr.advanced(by: Int(byteCount) - remainder).assumingMemoryBound(to: UInt8.self)
            Data(count: remainder).copyBytes(to: remainderPtr, count: remainder)
        }
    }

    internal static func readValue(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> NameField {
        let crc = UInt16(fromPtr: fromPtr, endianness)
        let count = Int(UInt8(fromPtr: fromPtr.advanced(by: 2), endianness))
        let byteCount = 3 + count
        let data = Data(bytes: fromPtr.advanced(by: 3), count: count)
        return NameField(data: data, crc: crc, byteCount: byteCount)
    }
}
