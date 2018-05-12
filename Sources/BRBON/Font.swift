// =====================================================================================================================
//
//  File:       Font.swift
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
// 0.7.0  - Initial version
// =====================================================================================================================

import Foundation
import Cocoa

import BRUtils


// Offset definitions

fileprivate let fontPointSizeOffset = 0
fileprivate let fontFamilyNameByteCountOffset = fontPointSizeOffset + 4
fileprivate let fontFontNameByteCountOffset = fontFamilyNameByteCountOffset + 1
internal let fontFamilyNameUtf8CodeOffset = fontFontNameByteCountOffset + 1


// Internal portal helpers

extension Portal {
    
    
    internal var _fontPointSizePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontPointSizeOffset) }
    internal var _fontFamilyNameByteCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontFamilyNameByteCountOffset) }
    internal var _fontFontNameByteCountPtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontFontNameByteCountOffset) }
    internal var _fontFamilyNameUtf8CodePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontFamilyNameUtf8CodeOffset) }
    internal var _fontFontNameUtf8CodePtr: UnsafeMutableRawPointer { return itemValueFieldPtr.advanced(by: fontFamilyNameUtf8CodeOffset + Int(_fontFamilyNameByteCount)) }
    
    
    internal var _fontPointSize: Float32 {
        get { return Float32(fromPtr: _fontPointSizePtr, endianness) }
        set { Float32(newValue).copyBytes(to: _fontPointSizePtr, endianness) }
    }
    
    internal var _fontFamilyNameByteCount: UInt8 {
        get { return UInt8(fromPtr: _fontFamilyNameByteCountPtr, endianness) }
        set { UInt8(newValue).copyBytes(to: _fontFamilyNameByteCountPtr, endianness) }
    }
    
    internal var _fontFontNameByteCount: UInt8 {
        get { return UInt8(fromPtr: _fontFontNameByteCountPtr, endianness) }
        set { UInt8(newValue).copyBytes(to: _fontFontNameByteCountPtr, endianness) }
    }
    
    internal var _fontFamilyNameUtf8Code: Data {
        get {
            if _fontFamilyNameByteCount == 0 { return Data() }
            return Data(bytes: _fontFamilyNameUtf8CodePtr, count: Int(_fontFamilyNameByteCount))
        }
        set {
            guard newValue.count < 256 else { return }
            // ensure that the item size is large enough
            let newValueByteCount = fontFamilyNameUtf8CodeOffset + newValue.count + Int(_fontFontNameByteCount)
            let result = ensureValueFieldByteCount(of: newValueByteCount)
            guard result == .success else { return }
            // shift the name into its new place
            let sourceFontNamePtr = _fontFontNameUtf8CodePtr
            _fontFamilyNameByteCount = UInt8(newValue.count)
            let destinationNamePtr = _fontFontNameUtf8CodePtr
            Darwin.memmove(destinationNamePtr, sourceFontNamePtr, Int(_fontFontNameByteCount))
            // store the new family name
            newValue.copyBytes(to: _fontFamilyNameUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: newValue.count)
        }
    }
    
    internal var _fontFontNameUtf8Code: Data {
        get {
            if _fontFontNameByteCount == 0 { return Data() }
            return Data(bytes: _fontFontNameUtf8CodePtr, count: Int(_fontFontNameByteCount))
        }
        set {
            guard newValue.count < 256 else { return }
            // ensure that the item size is large enough
            let newValueByteCount = fontFamilyNameUtf8CodeOffset + Int(_fontFamilyNameByteCount) + newValue.count
            let result = ensureValueFieldByteCount(of: newValueByteCount)
            guard result == .success else { return }
            // Copy the name to its place
            _fontFontNameByteCount = UInt8(newValue.count)
            newValue.copyBytes(to: _fontFontNameUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: newValue.count)
        }
    }
    
    internal var _fontValueFieldUsedByteCount: Int {
        return fontFamilyNameUtf8CodeOffset + Int(_fontFamilyNameByteCount) + Int(_fontFontNameByteCount)
    }
}


// Public portal accessors for Font

public extension Portal {
    
    
    /// Assess if the portal is valid and refers to a Font.
    ///
    /// - Returns: True if the value accessable through this portal is an Font. False if the portal is invalid or the value is not a Font.

    public var isFont: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.font }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.font.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.font.rawValue
    }

    
    /// Access the value through the portal as a Font
    
    public var font: BRFont? {
        get {
            guard isFont else { return nil }
            return BRFont(familyNameUtf8Code: _fontFontNameUtf8Code, fontNameUtf8Code: _fontFontNameUtf8Code, pointSize: _fontPointSize)
        }
        set {
            guard isFont else { return }
            guard let newValue = newValue else { return }
            
            _fontPointSize = newValue.pointSize
            _fontFamilyNameUtf8Code = newValue.familyNameUtf8Code ?? Data()
            _fontFontNameUtf8Code = newValue.fontNameUtf8Code
        }
    }
}


/// The Font definition.

public struct BRFont {
    
    public let familyNameUtf8Code: Data?
    public let fontNameUtf8Code: Data
    public let pointSize: Float32
    
    public var font: NSFont? {
        guard let name = String(data: fontNameUtf8Code, encoding: .utf8) else { return nil }
        if let font = NSFont(name: name, size: CGFloat(pointSize)) {
            return font
        } else {
            if let familyUtf8Code = familyNameUtf8Code {
                if let familyName = String(data: familyUtf8Code, encoding: .utf8) {
                    return NSFont(name: familyName, size: CGFloat(pointSize))
                }
            }
        }
        return nil
    }
    
    public init?(_ font: NSFont) {
        
        let f = font.familyName?.data(using: .utf8)
        if let f = f { guard f.count < 256 else { return nil } }
        self.familyNameUtf8Code = f
        
        guard let n = font.fontName.data(using: .utf8), n.count < 256 else { return nil }
        self.fontNameUtf8Code = n
        
        self.pointSize = Float32(font.pointSize)
    }
    
    public init(familyNameUtf8Code: Data, fontNameUtf8Code: Data, pointSize: Float32) {
        self.familyNameUtf8Code = familyNameUtf8Code
        self.fontNameUtf8Code = fontNameUtf8Code
        self.pointSize = pointSize
    }
}


/// Add equatable

extension BRFont: Equatable {
    
    public static func == (lhs: BRFont, rhs: BRFont) -> Bool {
        if lhs.pointSize != rhs.pointSize { return false }
        if lhs.fontNameUtf8Code != rhs.fontNameUtf8Code { return false }
        return lhs.familyNameUtf8Code == rhs.familyNameUtf8Code
    }
}


/// Add the Coder protocol

extension BRFont: Coder {
    
    public var itemType: ItemType { return ItemType.rgba }

    public var valueByteCount: Int { return fontFamilyNameUtf8CodeOffset + (familyNameUtf8Code?.count ?? 0) + fontNameUtf8Code.count }

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
    
        pointSize.copyBytes(to: ptr.advanced(by: fontPointSizeOffset), endianness)
        UInt8(familyNameUtf8Code?.count ?? 0).copyBytes(to: ptr.advanced(by: fontFamilyNameByteCountOffset), endianness)
        UInt8(fontNameUtf8Code.count).copyBytes(to: ptr.advanced(by: fontFontNameByteCountOffset), endianness)
        familyNameUtf8Code?.copyBytes(to: ptr.advanced(by: fontFamilyNameUtf8CodeOffset).assumingMemoryBound(to: UInt8.self), count: (familyNameUtf8Code?.count ?? 0))
        fontNameUtf8Code.copyBytes(to: ptr.advanced(by: fontFamilyNameUtf8CodeOffset + (familyNameUtf8Code?.count ?? 0)).assumingMemoryBound(to: UInt8.self), count: fontNameUtf8Code.count)
    }
}


