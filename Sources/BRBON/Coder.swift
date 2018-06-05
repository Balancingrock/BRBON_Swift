// =====================================================================================================================
//
//  File:       Coder.swift
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
// 0.7.0 - Code restructuring & simplification
// 0.4.2 - Updates due to new structure & API organization
// 0.1.0 - Initial version
// =====================================================================================================================
 
import Foundation
import BRUtils


/// This protocol is used to encode types to a series of bytes.
///
/// It should be adopted for leaf types, i.e. types that does not contain other BRBON types.

public protocol Coder {

    
    /// The BRBON type of the item this value can be saved as.
    
    var itemType: ItemType { get }
    
    
    /// The number of bytes needed to encode the raw value of self.

    var valueByteCount: Int { get }
    
    
    /// The minimum number of bytes of a value field necessary to encode self into.
    ///
    /// If the bytes are stored in the small-value field, 0 is returned. If not the first multiple of 8 above 'valueByteCount' is returned if 'valueByteCount' is not a multiple of 8.
    ///
    /// A default implementation is present that should be sufficient for all purposes.
    
    var minimumValueFieldByteCount: Int { get }
    
    
    /// Encodes self at the designated address such that self be be reconstitued from these bytes.
    ///
    /// - Parameters:
    ///   - to: The address where the first byte must be stored.
    ///   - endianness: Specifies the endian ordering of the bytes. Only used when storing values > 1 bytes.
    
    func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness)
}


// Default implementations

extension Coder {
    
    public var minimumValueFieldByteCount: Int {
        return itemType.usesSmallValue ? 0 : valueByteCount.roundUpToNearestMultipleOf8()
    }
}
