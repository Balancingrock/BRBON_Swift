// =====================================================================================================================
//
//  File:       Portal-Rgba.swift
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
// 0.7.0 - Initial version
// =====================================================================================================================

import Foundation


fileprivate let rgbaRedOffset = 0
fileprivate let rgbaGreenOffset = rgbaRedOffset + 4
fileprivate let rgbaBlueOffset = rgbaGreenOffset + 4
fileprivate let rgbaAlphaOffset = rgbaBlueOffset + 4


extension Portal {
    
    
    internal var _rbgaRedPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: rgbaRedOffset) }
    internal var _rbgaGreenPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: rgbaGreenOffset) }
    internal var _rbgaBluePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: rgbaBlueOffset) }
    internal var _rbgaAlphaPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: rgbaAlphaOffset) }
    
    
    internal var _rgbaRed: Float32 {
        get { return Float32(fromPtr: _rbgaRedPtr, endianness) }
        set { Float32(newValue).storeValue(atPtr: _rbgaRedPtr, endianness) }
    }
    
    internal var _rgbaGreen: Float32 {
        get { return Float32(fromPtr: _rbgaGreenPtr, endianness) }
        set { Float32(newValue).storeValue(atPtr: _rbgaGreenPtr, endianness) }
    }

    internal var _rgbaBlue: Float32 {
        get { return Float32(fromPtr: _rbgaBluePtr, endianness) }
        set { Float32(newValue).storeValue(atPtr: _rbgaBluePtr, endianness) }
    }

    internal var _rgbaAlpha: Float32 {
        get { return Float32(fromPtr: _rbgaAlphaPtr, endianness) }
        set { Float32(newValue).storeValue(atPtr: _rbgaAlphaPtr, endianness) }
    }
}
