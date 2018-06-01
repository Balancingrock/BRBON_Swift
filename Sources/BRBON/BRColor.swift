// =====================================================================================================================
//
//  File:       BRColor.swift
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

fileprivate let colorRedOffset = 0
fileprivate let colorGreenOffset = colorRedOffset + 1
fileprivate let colorBlueOffset = colorGreenOffset + 1
fileprivate let colorAlphaOffset = colorBlueOffset + 1
internal let colorValueByteCount = colorAlphaOffset + 1


// Internal portal helpers

fileprivate extension UnsafeMutableRawPointer {

    fileprivate var colorRedPtr: UnsafeMutableRawPointer { return self.advanced(by: colorRedOffset) }
    fileprivate var colorGreenPtr: UnsafeMutableRawPointer { return self.advanced(by: colorGreenOffset) }
    fileprivate var colorBluePtr: UnsafeMutableRawPointer { return self.advanced(by: colorBlueOffset) }
    fileprivate var colorAlphaPtr: UnsafeMutableRawPointer { return self.advanced(by: colorAlphaOffset) }
}


internal extension Portal {
    
    internal var _colorRed: UInt8 {
        get { return _valuePtr.colorRedPtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { _valuePtr.colorRedPtr.storeBytes(of: newValue, as: UInt8.self) }
    }
    
    internal var _colorGreen: UInt8 {
        get { return _valuePtr.colorGreenPtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { _valuePtr.colorGreenPtr.storeBytes(of: newValue, as: UInt8.self) }
    }

    internal var _colorBlue: UInt8 {
        get { return _valuePtr.colorBluePtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { _valuePtr.colorBluePtr.storeBytes(of: newValue, as: UInt8.self) }
    }

    internal var _colorAlpha: UInt8 {
        get { return _valuePtr.colorAlphaPtr.assumingMemoryBound(to: UInt8.self).pointee }
        set { _valuePtr.colorAlphaPtr.storeBytes(of: newValue, as: UInt8.self) }
    }
}


// Public portal access

public extension Portal {
    
    
    /// Assess if the portal is valid and refers to a Color.
    ///
    /// - Returns: True if the value accessable through this portal is an Color. False if the portal is invalid or the value is not an Color.

    public var isColor: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.color }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.color.rawValue }
        return itemPtr.itemType == ItemType.color.rawValue
    }
    
    
    /// Access the value through this portal as a NSColor in the generic RGB colorspace.
    
    public var color: BRColor? {
        get {
            guard isColor else { return nil }
            return BRColor(red: _colorRed, green: _colorGreen, blue: _colorBlue, alpha: _colorAlpha)
        }
        set {
            guard isColor else { return }
            guard let newValue = newValue else { return }
            
            _colorRed = newValue.redComponent
            _colorGreen = newValue.greenComponent
            _colorBlue = newValue.blueComponent
            _colorAlpha = newValue.alphaComponent
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
    /// In other words: If the colorspace is not generic RGB, this information will be lost as upon extracting the color (type: NSColor) the generic RGB colorspace will be used.
    
    public init(_ color: NSColor) {
        redComponent = UInt8(color.redComponent * 255)
        greenComponent = UInt8(color.greenComponent * 255)
        blueComponent = UInt8(color.blueComponent * 255)
        alphaComponent = UInt8(color.alphaComponent * 255)
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
        redComponent.copyBytes(to: ptr.advanced(by: colorRedOffset), endianness)
        greenComponent.copyBytes(to: ptr.advanced(by: colorGreenOffset), endianness)
        blueComponent.copyBytes(to: ptr.advanced(by: colorBlueOffset), endianness)
        alphaComponent.copyBytes(to: ptr.advanced(by: colorAlphaOffset), endianness)
    }
}



