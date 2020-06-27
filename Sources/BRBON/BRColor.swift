// =====================================================================================================================
//
//  File:       BRColor.swift
//  Project:    BRBON
//
//  Version:    1.3.1
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2020 Marinus van der Lugt, All rights reserved.
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
// 1.3.1 - Linux compatibility
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
#if os(macOS) || os(iOS) || os(tvOS)
import Cocoa
#endif
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


/// The BRColor structure

public struct BRColor {
    
    
    /// The value of the red component
    
    public let redComponent: UInt8
    
    
    /// The value of the green component
    
    public let greenComponent: UInt8
    
    
    /// The value of the blue component
    
    public let blueComponent: UInt8
    
    
    /// The value of the alpha component
    
    public let alphaComponent: UInt8
    
    
    /// The structure as an NSColor
    #if os(macOS) || os(iOS) || os(tvOS)
    public var color: NSColor { return NSColor(red: CGFloat(redComponent)/255, green: CGFloat(greenComponent)/255, blue: CGFloat(blueComponent)/255, alpha: CGFloat(alphaComponent)/255)}
    #endif
    
    /// Create a new structure, the color will be assumed to be in the generic RGB colorspace.
    ///
    /// In other words: If the colorspace is not generic RGB, this information will be lost as upon extracting the color information the generic RGB colorspace will be used.
    #if os(macOS) || os(iOS) || os(tvOS)
    public init(_ color: NSColor) {
        let genericRgbColor = color.usingColorSpace(NSColorSpace.genericRGB) ?? NSColor(genericGamma22White: 0, alpha: 1)
        redComponent = UInt8(genericRgbColor.redComponent * 255)
        greenComponent = UInt8(genericRgbColor.greenComponent * 255)
        blueComponent = UInt8(genericRgbColor.blueComponent * 255)
        alphaComponent = UInt8(genericRgbColor.alphaComponent * 255)
    }
    #endif
    
    
    /// Creates a new structure from the component values
    
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        redComponent = red
        greenComponent = green
        blueComponent = blue
        alphaComponent = alpha
    }
}


// Add equatable

extension BRColor: Equatable {
    
    
    /// Implementation of the equatable protocol
    
    public static func == (lhs: BRColor, rhs: BRColor) -> Bool {
        if lhs.redComponent != rhs.redComponent { return false }
        if lhs.greenComponent != rhs.greenComponent { return false }
        if lhs.blueComponent != rhs.blueComponent { return false }
        return lhs.alphaComponent == rhs.alphaComponent
    }
}


// Add the Coder protocol

extension BRColor: Coder {
    
    
    /// Implementation of the `Coder` protocol
    
    public var itemType: ItemType { return ItemType.color }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return colorValueByteCount }

    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        var ptr = ptr
        ptr.colorRed = redComponent
        ptr.colorGreen = greenComponent
        ptr.colorBlue = blueComponent
        ptr.colorAlpha = alphaComponent
    }
}



