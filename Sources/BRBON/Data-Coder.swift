// =====================================================================================================================
//
//  File:       Data-Coder.swift
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


/// Adds the Coder protocol

extension Data: Coder {
    
    var valueByteCount: Int { return 4 + self.count }
    
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        UInt32(self.count).storeValue(atPtr: atPtr, endianness)
        self.copyBytes(to: atPtr.advanced(by: 4).assumingMemoryBound(to: UInt8.self), count: self.count)
    }    
    
    init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let byteCount = Int(UInt32(fromPtr: fromPtr, endianness))
        self.init(Data(bytes: fromPtr.advanced(by: 4), count: byteCount))
    }
}
