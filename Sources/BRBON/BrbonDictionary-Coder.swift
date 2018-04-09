// =====================================================================================================================
//
//  File:       BrbonDictionary-Coder.swift
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


/// Defines the BRBON Dictionary class and conforms it to the Coder protocol.

public final class BrbonDictionary: Coder {

    
    /// The BRBON Item type of the item this value will be stored into.
    
    public var itemType: ItemType { return ItemType.dictionary }

    
    /// Create a new BrbonDictionary.
    
    public init?(content: Dictionary<String, IsBrbon>? = nil) {
        if let content = content {
            for i in content {
                guard NameField(i.key) != nil else { return nil }
            }
            self.content = content as! Dictionary<String, Coder>
        } else {
            self.content = [:]
        }
    }

    
    /// The content of this dictionary
    
    internal let content: Dictionary<String, Coder>
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream
    
    internal var valueByteCount: Int {
        return content.reduce(dictionaryItemBaseOffset) { $0 + $1.value.itemByteCount(NameField($1.key)!) }
    }
    
    
    /// The parent offset for the items contained in the dictionary. I.e. the offset of the .dictionary item type itself. This must be set before 'storeValue' is called if the dictionary is not the top level (root) item in the buffer.
    
    internal var parentOffset: Int = 0
    
    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Note: Before calling, first set the parentOffset!
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        // Reserved
        UInt32(0).storeValue(atPtr: atPtr.advanced(by: dictionaryReservedOffset), endianness)
        
        // Count
        UInt32(content.count).storeValue(atPtr: atPtr.advanced(by: dictionaryItemCountOffset), endianness)
        
        // The items
        var offset = dictionaryItemBaseOffset
        for i in content {
            let name = NameField(i.key)!
            i.value.storeAsItem(atPtr: atPtr.advanced(by: offset), name: name, parentOffset: parentOffset, endianness)
            offset += i.value.itemByteCount(name)
        }
    }
}
