// =====================================================================================================================
//
//  File:       Extensions.swift
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
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation


extension String {
    
    
    /// Returns a Data item with the UTF8 encoded bytes of self, limited to a maximum number of bytes. Excess characters are ignored.
    ///
    /// - Note: The returned bytes will always represent complete characters. I.e. no conclusions can be derived from the count of the returned Data item. The count can be smaller than 'maxBytes' and still the string may be cut-off.
    ///
    /// - Parameter maxBytes: The maximum number of bytes to be returned.
    ///
    /// - Returns: The requested bytes and a flag that is true when characters were discarded false when all characters are included. Nil if conversion to utf8 is not possible.
    
    internal func utf8CodeMaxBytes(_ maxBytes: Int) -> (Data, Bool)? {
        
        // Early exit if the string cannot be converted to UTF8
        guard var utf8Code = self.data(using: .utf8) else { return nil }
        
        // Need a mutable copy of self
        var str = self
        var charactersWereRemoved = false
        
        // Quick limit to 'byte' characters
        if (str.utf8.count > maxBytes) {
            str = String(str[..<str.index(str.startIndex, offsetBy: maxBytes)])
            utf8Code = str.data(using: .utf8)!
        }
        
        // Fine tune down to 'bytes' code units
        while utf8Code.count > maxBytes {
            _ = str.remove(at: str.index(before: str.endIndex))
            charactersWereRemoved = true
            utf8Code = str.data(using: .utf8)!
        }
        
        return (utf8Code, charactersWereRemoved)
    }
}

extension Int {
    
    
    /// If self is not a multiple of 8 then round up to the nearest multiple of 8 and return that value.
    
    internal func roundUpToNearestMultipleOf8() -> Int {
        var a = self
        while a % 8 > 0 { a += 1 }
        return a
    }
}
