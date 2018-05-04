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
import Cocoa


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

public extension Portal {
    
    
    /// - Returns: True if the value accessable through this portal is a RGBA.
    
    public var isRgba: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.rgba }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.rgba.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.rgba.rawValue
    }
    

    /// - Returns: The value of the red component in the RGBA accessable through this portal
    
    public var redComponent: CGFloat? {
        get {
            guard isValid else { return nil }
            guard isRgba else { return nil }
            return CGFloat(_rgbaRed)
        }
        set {
            guard isValid else { return }
            guard isRgba else { return }
            if let newValue = newValue {
                _rgbaRed = Float32(newValue)
            } else {
                _rgbaRed = 0.0
            }
        }
    }
    
    
    /// - Returns: The value of the green component in the RGBA accessable through this portal

    public var greenComponent: CGFloat? {
        get {
            guard isValid else { return nil }
            guard isRgba else { return nil }
            return CGFloat(_rgbaGreen)
        }
        set {
            guard isValid else { return }
            guard isRgba else { return }
            if let newValue = newValue {
                _rgbaGreen = Float32(newValue)
            } else {
                _rgbaGreen = 0.0
            }
        }
    }
    

    /// - Returns: The value of the blue component in the RGBA accessable through this portal

    public var blueComponent: CGFloat? {
        get {
            guard isValid else { return nil }
            guard isRgba else { return nil }
            return CGFloat(_rgbaBlue)
        }
        set {
            guard isValid else { return }
            guard isRgba else { return }
            if let newValue = newValue {
                _rgbaBlue = Float32(newValue)
            } else {
                _rgbaBlue = 0.0
            }
        }
    }


    /// - Returns: The value of the alpha component in the RGBA accessable through this portal

    public var alphaComponent: CGFloat? {
        get {
            guard isValid else { return nil }
            guard isRgba else { return nil }
            return CGFloat(_rgbaAlpha)
        }
        set {
            guard isValid else { return }
            guard isRgba else { return }
            if let newValue = newValue {
                _rgbaAlpha = Float32(newValue)
            } else {
                _rgbaAlpha = 0.0
            }
        }
    }
    

    /// Access the value through the portal as a RBGA
    
    public var rgba: Rgba? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isRgba else { fatalOrNull("Attempt to access \(String(describing: itemType)) as a String"); return nil }
            return Rgba(fromPtr: valueFieldPtr, endianness)
        }
        set { assistValueFieldAssignment(newValue) }
    }

    
    /// Access the value through this portal as a NSColor
    
    public var nsColor: NSColor? {
        get {
            guard isValid else { return nil }
            guard isRgba else { return nil }
            return NSColor(red: CGFloat(_rgbaRed), green: CGFloat(_rgbaGreen), blue: CGFloat(_rgbaBlue), alpha: CGFloat(_rgbaAlpha))
        }
        set {
            guard isValid else { return }
            guard isRgba else { return }
            if let newValue = newValue {
                _rgbaRed = Float32(newValue.redComponent)
                _rgbaGreen = Float32(newValue.greenComponent)
                _rgbaBlue = Float32(newValue.blueComponent)
                _rgbaAlpha = Float32(newValue.alphaComponent)
            } else {
                _rgbaRed = 0.0
                _rgbaGreen = 0.0
                _rgbaBlue = 0.0
                _rgbaAlpha = 0.0
            }
        }
    }
}
