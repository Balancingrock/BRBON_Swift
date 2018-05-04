// =====================================================================================================================
//
//  File:       Portal-Font.swift
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


fileprivate let fontSizeOffset = 0
fileprivate let fontFamilySizeOffset = fontSizeOffset + 4
fileprivate let fontNameSizeOffset = fontFamilySizeOffset + 1
fileprivate let fontFamilyOffset = fontNameSizeOffset + 1


extension Portal {
    
    
    internal var _fontSizePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontSizeOffset) }
    internal var _fontFamilySizePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontFamilySizeOffset) }
    internal var _fontNameSizePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontNameSizeOffset) }
    internal var _fontFamilyPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontFamilyOffset) }
    internal var _fontNamePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontFamilyOffset + Int(_fontFamilySize)) }

    
    internal var _fontSize: Float32 {
        get { return Float32(fromPtr: _fontSizePtr, endianness) }
        set { Float32(newValue).storeValue(atPtr: _fontSizePtr, endianness) }
    }
    
    internal var _fontFamilySize: UInt8 {
        get { return UInt8(fromPtr: _fontFamilySizePtr, endianness) }
        set { UInt8(newValue).storeValue(atPtr: _fontFamilySizePtr, endianness) }
    }
    
    internal var _fontNameSize: UInt8 {
        get { return UInt8(fromPtr: _fontNameSizePtr, endianness) }
        set { UInt8(newValue).storeValue(atPtr: _fontNameSizePtr, endianness) }
    }
    
    internal var _fontFamily: String? {
        get {
            if _fontFamilySize == 0 { return nil }
            let data = Data(bytes: _fontFamilyPtr, count: Int(_fontFamilySize))
            return String(data: data, encoding: .utf8)
        }
        set {
            if let newValue = newValue {
                guard let data = newValue.data(using: .utf8), data.count < 256 else { return }
                // ensure that the item size is large enough
                let newValueByteCount = 4 + 2 + data.count + Int(_fontNameSize)
                let result = ensureValueFieldByteCount(of: newValueByteCount)
                guard result == .success else { return }
                // shift the name into its new place
                let sourceFontNamePtr = _fontNamePtr
                _fontFamilySize = UInt8(data.count)
                let destinationNamePtr = _fontNamePtr
                Darwin.memmove(destinationNamePtr, sourceFontNamePtr, Int(_fontNameSize))
                // store the new family name
                data.copyBytes(to: _fontFamilyPtr.assumingMemoryBound(to: UInt8.self), count: data.count)
            } else {
                let sourceFontNamePtr = _fontNamePtr
                _fontFamilySize = 0
                let destinationNamePtr = _fontNamePtr
                Darwin.memmove(destinationNamePtr, sourceFontNamePtr, Int(_fontNameSize))
            }
        }
    }
    
    internal var _fontName: String? {
        get {
            if _fontNameSize == 0 { return nil }
            let data = Data(bytes: _fontNamePtr, count: Int(_fontNameSize))
            return String(data: data, encoding: .utf8)
        }
        set {
            if let newValue = newValue {
                guard let data = newValue.data(using: .utf8), data.count < 256 else { return }
                // ensure that the item size is large enough
                let newValueByteCount = 4 + 2 + Int(_fontFamilySize) + data.count
                let result = ensureValueFieldByteCount(of: newValueByteCount)
                guard result == .success else { return }
                // Copy the name to its place
                _fontNameSize = UInt8(data.count)
                data.copyBytes(to: _fontNamePtr.assumingMemoryBound(to: UInt8.self), count: data.count)
            } else {
                _fontNameSize = 0
            }
        }
    }
    
    internal var _fontValueFieldUsedByteCount: Int {
        return 4 + 2 + Int(_fontFamilySize) + Int(_fontNameSize)
    }
}
