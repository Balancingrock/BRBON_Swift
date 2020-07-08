// =====================================================================================================================
//
//  File:       Coder.swift
//  Project:    BRBON
//
//  Version:    1.3.2
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2020 Marinus van der Lugt, All rights reserved.
//
//  License:    MIT, see LICENSE file
//
//  And because I need to make a living:
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
// 1.3.2 - Updated LICENSE
// 1.0.1 - Documentation updates
// 1.0.0 - Removed older history
//
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
    
    
    /// Default implementation of minimumValueFieldByteCount of the Coder protocol
    
    public var minimumValueFieldByteCount: Int {
        return itemType.usesSmallValue ? 0 : valueByteCount.roundUpToNearestMultipleOf8()
    }
}
