// =====================================================================================================================
//
//  File:       BRColor.swift
//  Project:    BRBON
//
//  Version:    0.8.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
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
//  I strongly believe that voluntarism is the way for societies to function optimally. So you can pay whatever you
//  think our code is worth to you.
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
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// History
//
// 0.8.0 - Migrated to Swift 5
// 0.7.12 - Added conversion to Generic RGB when creating a BRColor with a NSColor.
// 0.7.9 - Changed handling of writing nil to color (will now set all fields to zero)
// 0.7.8 - Made colorValueByteCount internal
// 0.7.5 - Added color to the pointer operations.
// 0.7.0 - Initial version
// =====================================================================================================================

import Foundation
import Cocoa
import BRUtils


// Offset definitions

fileprivate let colorRedOffset = 0
fileprivate let colorGreenOffset = colorRedOffset + 1
fileprivate let colorBlueOffset = colorGreenOffset + 1
fileprivate let colorAlphaOffset = colorBlueOffset + 1
internal let colorValueByteCount = colorAlphaOffset + 1


// Internal portal helpers

internal extension UnsafeMutableRawPointer {

    
    /// A pointer to the value for the red color assuming self points to the first byte of the value field
    
    fileprivate var colorRedPtr: UnsafeMutableRawPointer { return self.advanced(by: colorRedOffset) }


    /// A pointer to the value for the green color assuming self points to the first byte of the value field

    fileprivate var colorGreenPtr: UnsafeMutableRawPointer { return self.advanced(by: colorGreenOffset) }


    /// A pointer to the value for the blue color assuming self points to the first byte of the value field

    fileprivate var colorBluePtr: UnsafeMutableRawPointer { return self.advanced(by: colorBlueOffset) }


    /// A pointer to the value for the alpha value assuming self points to the first byte of the value field

    fileprivate var colorAlphaPtr: UnsafeMutableRawPointer { return self.advanced(by: colorAlphaOffset) }
    
    
    /// The red color weight assuming self points to the first byte of the value field
    
    fileprivate var colorRed: UInt8 {
        get { return colorRedPtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { colorRedPtr.storeBytes(of: newValue, as: UInt8.self) }
    }
    
    
    /// The green color weight assuming self points to the first byte of the value field
    
    fileprivate var colorGreen: UInt8 {
        get { return colorGreenPtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { colorGreenPtr.storeBytes(of: newValue, as: UInt8.self) }
    }
    
    
    /// The blue color weight assuming self points to the first byte of the value field
    
    fileprivate var colorBlue: UInt8 {
        get { return colorBluePtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { colorBluePtr.storeBytes(of: newValue, as: UInt8.self) }
    }
    
    
    /// The alpha weight assuming self points to the first byte of the value field
    
    fileprivate var colorAlpha: UInt8 {
        get { return colorAlphaPtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { colorAlphaPtr.storeBytes(of: newValue, as: UInt8.self) }
    }
    
    
    /// Returns the BRColor assuming self points to the first byte of the value field
    
    var color: BRColor {
        return BRColor.init(red: colorRed, green: colorGreen, blue: colorBlue, alpha: colorAlpha)
    }
}


internal extension Portal {
    
    
    /// The weight of the red color.
    
    var _colorRed: UInt8 {
        get { return _valuePtr.colorRed }
        set { _valuePtr.colorRed = newValue }
    }

    
    /// The weight of the green color.

    var _colorGreen: UInt8 {
        get { return _valuePtr.colorGreen }
        set { _valuePtr.colorGreen = newValue }
    }

    
    /// The weight of the blue color.

    var _colorBlue: UInt8 {
        get { return _valuePtr.colorBlue }
        set { _valuePtr.colorBlue = newValue }
    }

    
    /// The weight of the alpha component.

    var _colorAlpha: UInt8 {
        get { return _valuePtr.colorAlpha }
        set { _valuePtr.colorAlpha = newValue }
    }
}


// Public portal access

public extension Portal {
    
    
    /// Returns true if the portal is valid and the value accessable through this portal is a color.

    var isColor: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.color }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.color.rawValue }
        return itemPtr.itemType == ItemType.color.rawValue
    }
    
    
    /// Access the value through the portal as a NSColor in the generic RGB colorspace.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to an color, writing will be ineffective and reading will always return nil.
    ///
    /// __On read:__ Returns the BRColor specification read from the memory location associated with this portal.
    ///
    /// __On write:__ Stores the BRColor specification at the memory location associated with this portal. If a nil is written the data at the location will be set to 0, 0, 0, 0.

    var color: BRColor? {
        get {
            guard isColor else { return nil }
            return BRColor(red: _valuePtr.colorRed, green: _valuePtr.colorGreen, blue: _valuePtr.colorBlue, alpha: _valuePtr.colorAlpha)
        }
        set {
            guard isColor else { return }
            if let newValue = newValue {
                _valuePtr.colorRed = newValue.redComponent
                _valuePtr.colorGreen = newValue.greenComponent
                _valuePtr.colorBlue = newValue.blueComponent
                _valuePtr.colorAlpha = newValue.alphaComponent
            } else {
                _valuePtr.colorRed = 0
                _valuePtr.colorGreen = 0
                _valuePtr.colorBlue = 0
                _valuePtr.colorAlpha = 0
            }
        }
    }
}


// The BRColor class and the Coder protocol

public struct BRColor {
    
    public let redComponent: UInt8
    public let greenComponent: UInt8
    public let blueComponent: UInt8
    public let alphaComponent: UInt8
    
    public var color: NSColor { return NSColor(red: CGFloat(redComponent)/255, green: CGFloat(greenComponent)/255, blue: CGFloat(blueComponent)/255, alpha: CGFloat(alphaComponent)/255)}
    
    
    /// Create a new BRColor, the color will be assumed to be in the generic RGB colorspace.
    ///
    /// In other words: If the colorspace is not generic RGB, this information will be lost as upon extracting the color information the generic RGB colorspace will be used.
    
    public init(_ color: NSColor) {
        let genericRgbColor = color.usingColorSpace(NSColorSpace.genericRGB) ?? NSColor(genericGamma22White: 0, alpha: 1)
        redComponent = UInt8(genericRgbColor.redComponent * 255)
        greenComponent = UInt8(genericRgbColor.greenComponent * 255)
        blueComponent = UInt8(genericRgbColor.blueComponent * 255)
        alphaComponent = UInt8(genericRgbColor.alphaComponent * 255)
    }
    
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        redComponent = red
        greenComponent = green
        blueComponent = blue
        alphaComponent = alpha
    }
}


// Add equatable

extension BRColor: Equatable {
    
    public static func == (lhs: BRColor, rhs: BRColor) -> Bool {
        if lhs.redComponent != rhs.redComponent { return false }
        if lhs.greenComponent != rhs.greenComponent { return false }
        if lhs.blueComponent != rhs.blueComponent { return false }
        return lhs.alphaComponent == rhs.alphaComponent
    }
}


// Add the Coder protocol

extension BRColor: Coder {
    
    public var itemType: ItemType { return ItemType.color }
    
    public var valueByteCount: Int { return colorValueByteCount }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        var ptr = ptr
        ptr.colorRed = redComponent
        ptr.colorGreen = greenComponent
        ptr.colorBlue = blueComponent
        ptr.colorAlpha = alphaComponent
    }
}



