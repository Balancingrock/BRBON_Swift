// =====================================================================================================================
//
//  File:       BrbonArray-Coder.swift
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


/// Defines the BRBON Array class and conforms it to the Coder protocol.

public final class BrbonArray: Coder {
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    public var itemType: ItemType { return ItemType.array }

    
    /// Create a new BrbonArray
    
    public init(content: Array<IsBrbon>, type: ItemType, elementByteCount: Int? = nil) {
        
        assert(type != .null)
        
        self.content = (content as? Array<Coder>)!
        
        self.elementType = type
        
        var ebc = elementByteCount ?? 0
        
        if type.hasFlexibleLength {
            ebc = self.content.reduce(ebc) { max($0, $1.valueByteCount.roundUpToNearestMultipleOf8()) }
        }

        if ebc == 0 {
            ebc = type.defaultElementByteCount
        }
        
        self.elementValueByteCount = ebc
    }
    
    
    // The content
    
    internal let content: Array<Coder>
    
    
    // The element type
    
    internal let elementType: ItemType
    
    
    // The byte count for each element
    
    internal let elementValueByteCount: Int
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream.
    
    internal var valueByteCount: Int { return arrayElementBaseOffset + content.count * elementValueByteCount }
    
    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        // Element type + zero's
        UInt64(0).storeValue(atPtr: atPtr, endianness)
        elementType.storeValue(atPtr: atPtr.advanced(by: arrayElementTypeOffset))

        // Element count
        UInt32(content.count).storeValue(atPtr: atPtr.advanced(by: arrayElementCountOffset), endianness)
        
        // Element byte count
        UInt32(elementValueByteCount).storeValue(atPtr: atPtr.advanced(by: arrayElementByteCountOffset), endianness)
        
        // Elements
        for i in 0 ..< content.count {
            content[i].storeValue(atPtr: atPtr.advanced(by: arrayElementBaseOffset + i * elementValueByteCount), endianness)
        }
    }
}

