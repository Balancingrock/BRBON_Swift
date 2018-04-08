// =====================================================================================================================
//
//  File:       Extensions.swift
//  Project:    BRBON
//
//  Version:    0.5.0
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
// 0.5.0  - Migration to Swift 4
// 0.4.2  - Cleanup
// 0.1.0  - Initial version
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
    
    internal func roundUpToNearestMultipleOf8() -> Int {
        var a = self
        while a % 8 > 0 { a += 1 }
        return a
    }
}
