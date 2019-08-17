// =====================================================================================================================
//
//  File:       BRFont.swift
//  Project:    BRBON
//
//  Version:    1.0.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2019 Marinus van der Lugt, All rights reserved.
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
//  Like you, I need to make a living:
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
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import Cocoa

import BRUtils


// Offset definitions

fileprivate let fontPointSizeOffset = 0
fileprivate let fontFamilyNameUtf8ByteCountOffset = fontPointSizeOffset + 4
fileprivate let fontFontNameUtf8ByteCountOffset = fontFamilyNameUtf8ByteCountOffset + 1
fileprivate let fontFamilyNameUtf8CodeOffset = fontFontNameUtf8ByteCountOffset + 1


// Internal portal helpers

internal extension UnsafeMutableRawPointer {
    
    
    /// Returns a pointer to the font point size of a font item assuming self points at the first byte of the value.
    
    fileprivate var fontPointSizePtr: UnsafeMutableRawPointer { return self.advanced(by: fontPointSizeOffset) }
    
    
    /// Returns a pointer to the font family name utf8 byte count of a font item assuming self points at the first byte of the value.
    
    fileprivate var fontFamilyNameUtf8ByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: fontFamilyNameUtf8ByteCountOffset) }
    
    
    /// Returns a pointer to the font name utf8 byte count of a font item assuming self points at the first byte of the value.
    
    fileprivate var fontFontNameUtf8ByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: fontFontNameUtf8ByteCountOffset) }
    
    
    /// Returns a pointer to the first byte of a font family name utf8 code of a font item assuming self points at the first byte of the value.
    
    fileprivate var fontFamilyNameUtf8CodePtr: UnsafeMutableRawPointer { return self.advanced(by: fontFamilyNameUtf8CodeOffset) }
    
    
    /// Returns a pointer to the first byte of a font name utf8 code of a font item assuming self points at the first byte of the value.
    
    fileprivate var fontFontNameUtf8CodePtr: UnsafeMutableRawPointer { return self.advanced(by: fontFamilyNameUtf8CodeOffset + Int(fontFamilyNameUtf8ByteCount)) }
    
    
    /// Returns the point size of a font item assuming self points at the first byte of the value.
    
    fileprivate func fontPointSize(_ endianness: Endianness) -> Float32 {
        if endianness == machineEndianness {
            return Float32(bitPattern: fontPointSizePtr.assumingMemoryBound(to: UInt32.self).pointee)
        } else {
            return Float32(bitPattern: fontPointSizePtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped)
        }
    }
    
    
    /// Sets the point size of a font item assuming self points at the first byte of the value.
    
    fileprivate func setFontPointSize(to value: Float32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            fontPointSizePtr.storeBytes(of: value.bitPattern, as: UInt32.self)
        } else {
            fontPointSizePtr.storeBytes(of: value.bitPattern.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// The byte count of the font family name of a font item assuming self points at the first byte of the value.
    
    fileprivate var fontFamilyNameUtf8ByteCount: UInt8 {
        get { return fontFamilyNameUtf8ByteCountPtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { fontFamilyNameUtf8ByteCountPtr.storeBytes(of: newValue, as: UInt8.self) }
    }
    
    
    /// The byte count of the font name of a font item assuming self points at the first byte of the value.
    
    fileprivate var fontFontNameUtf8ByteCount: UInt8 {
        get { return fontFontNameUtf8ByteCountPtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { fontFontNameUtf8ByteCountPtr.storeBytes(of: newValue, as: UInt8.self) }
    }
    
    
    /// The font family name UTF8 byte code of a font item assuming self points at the first byte of the value.
    ///
    /// Will also read cq write to the 'fontFamilyNameUtf8ByteCount'
    ///
    /// - Note: Can only be used if it is guaranteed that the UTF8 code field is large enough to contain the data.
    
    fileprivate var fontFamilyNameUtf8Code: Data {
        get {
            let bc = fontFamilyNameUtf8ByteCount
            if bc == 0 { return Data() }
            return Data(bytes: fontFamilyNameUtf8CodePtr, count: Int(bc))
        }
        set {
            newValue.copyBytes(to: fontFamilyNameUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: newValue.count)
            fontFamilyNameUtf8ByteCount = UInt8(newValue.count)
        }
    }
    
    
    /// The font name UTF8 byte code of a font item assuming self points at the first byte of the value.
    ///
    /// Will also read cq write to the 'fontFontNameUtf8ByteCount'
    ///
    /// - Note: Can only be used if it is guaranteed that the UTF8 code field is large enough to contain the data.
    
    fileprivate var fontFontNameUtf8Code: Data {
        get {
            let bc = fontFontNameUtf8ByteCount
            if bc == 0 { return Data() }
            return Data(bytes: fontFontNameUtf8CodePtr, count: Int(bc))
        }
        set {
            newValue.copyBytes(to: fontFontNameUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: newValue.count)
            fontFontNameUtf8ByteCount = UInt8(newValue.count)
        }
    }
    
    
    /// Returns the BRFont assuming self points at the first byte of the value.
    func font(_ endianness: Endianness) -> BRFont {
        return BRFont.init(familyNameUtf8Code: fontFontNameUtf8Code, fontNameUtf8Code: fontFontNameUtf8Code, pointSize: fontPointSize(endianness))
    }
}

extension Portal {
    
    
    /// The font family name UTF8 byte code of a font item assuming self points at the first byte of the value.
    ///
    /// Will also read cq write to the 'fontFamilyNameUtf8ByteCount'
    ///
    /// - Note: On write, it will increase the storage area -when necessary- to ensure proper storage of the family and font name. THis may include shifting of the font name UTF8 byte code.
    
    internal var _fontFamilyNameUtf8Code: Data {
        get { return _valuePtr.fontFamilyNameUtf8Code }
        set {
            guard newValue.count < 256 else { return }
            // ensure that the item size is large enough
            let newValueByteCount = fontFamilyNameUtf8CodeOffset + newValue.count + Int(_valuePtr.fontFontNameUtf8ByteCount)
            let result = ensureStorageAtValuePtr(of: newValueByteCount)
            //let result = ensureValueFieldByteCount(of: newValueByteCount)
            guard result == .success else { return }
            // shift the name into its new place
            let sourceFontNamePtr = _valuePtr.fontFontNameUtf8CodePtr
            _valuePtr.fontFamilyNameUtf8ByteCount = UInt8(newValue.count)
            let destinationNamePtr = _valuePtr.fontFontNameUtf8CodePtr
            Darwin.memmove(destinationNamePtr, sourceFontNamePtr, Int(_valuePtr.fontFontNameUtf8ByteCount))
            // store the new family name
            _valuePtr.fontFamilyNameUtf8Code = newValue
        }
    }
    
    
    /// The font name UTF8 byte code of a font item assuming self points at the first byte of the value.
    ///
    /// Will also read cq write to the 'fontFamilyNameUtf8ByteCount'
    ///
    /// - Note: On write, it will increase the storage area -when necessary- to ensure proper storage of the family and font name.
    
    internal var _fontFontNameUtf8Code: Data {
        get { return _valuePtr.fontFontNameUtf8Code }
        set {
            guard newValue.count < 256 else { return }
            // ensure that the item size is large enough
            let newValueByteCount = fontFamilyNameUtf8CodeOffset + Int(_valuePtr.fontFamilyNameUtf8ByteCount) + newValue.count
            let result = ensureStorageAtValuePtr(of: newValueByteCount)
            guard result == .success else { return }
            // Copy the name to its place
            _valuePtr.fontFontNameUtf8Code = newValue
        }
    }
    
    
    /// Returns the actual number of bytes used to represent the font value referenced by this portal.
    
    internal var _fontValueFieldUsedByteCount: Int {
        return fontFamilyNameUtf8CodeOffset + Int(_valuePtr.fontFamilyNameUtf8ByteCount) + Int(_valuePtr.fontFontNameUtf8ByteCount)
    }
}


// Public portal accessors for Font

public extension Portal {
    
    
    /// Assess if the portal is valid and refers to a Font.
    ///
    /// - Returns: True if the value accessable through this portal is an Font. False if the portal is invalid or the value is not a Font.
    
    var isFont: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.font }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.font.rawValue }
        return itemPtr.itemType == ItemType.font.rawValue
    }
    
    
    /// Access the value through the portal as a Font
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to a font, writing will be ineffective and reading will always return nil.
    ///
    /// __On Read:__ If the size of the font name is not zero, it will interpret the data at the associated memory location as a BRFont specification and return it. Otherwise it will return nil. Note that if the BRFont specification is invalid the result is unpredictable.
    ///
    /// __On Write:__ Writes the specification of the BRFont to the associated memory area. Writing a nil will result in erasure of existing font data (by setting the size of the font name to zero).
    
    var font: BRFont? {
        get {
            guard isFont else { return nil }
            let font = BRFont(familyNameUtf8Code: _valuePtr.fontFamilyNameUtf8Code, fontNameUtf8Code: _valuePtr.fontFontNameUtf8Code, pointSize: _valuePtr.fontPointSize(endianness))
            if font.fontNameUtf8Code.count == 0 { return nil }
            return font
        }
        set {
            guard isFont else { return }
            if let newValue = newValue {
                _valuePtr.setFontPointSize(to: newValue.pointSize, endianness)
                _valuePtr.fontFamilyNameUtf8Code = newValue.familyNameUtf8Code ?? Data()
                _valuePtr.fontFontNameUtf8Code = newValue.fontNameUtf8Code
            } else {
                _valuePtr.setFontPointSize(to: 0.0, endianness)
                _valuePtr.fontFamilyNameUtf8Code = Data()
                _valuePtr.fontFontNameUtf8Code = Data()
            }
        }
    }
}


/// The Font definition.

public struct BRFont {
    
    public let familyNameUtf8Code: Data?
    public let fontNameUtf8Code: Data
    public let pointSize: Float32
    
    public var nofValueBytesNecessary: Int {
        let familySize = familyNameUtf8Code?.count ?? 0
        let fontSize = fontNameUtf8Code.count
        return 4 + 1 + familySize + 1 + fontSize
    }
    
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
    
    public init?(_ font: NSFont?) {
        
        guard let font = font else { return nil }
        
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
    
    public var itemType: ItemType { return ItemType.font }
    
    public var valueByteCount: Int { return fontFamilyNameUtf8CodeOffset + (familyNameUtf8Code?.count ?? 0) + fontNameUtf8Code.count }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        var ptr = ptr
        ptr.setFontPointSize(to: pointSize, endianness)
        ptr.fontFamilyNameUtf8Code = familyNameUtf8Code ?? Data()
        ptr.fontFontNameUtf8Code = fontNameUtf8Code
    }
}

