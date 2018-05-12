// =====================================================================================================================
//
//  File:       RGBA.swift
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

fileprivate let rgbaRedOffset = 0
fileprivate let rgbaGreenOffset = rgbaRedOffset + 4
fileprivate let rgbaBlueOffset = rgbaGreenOffset + 4
fileprivate let rgbaAlphaOffset = rgbaBlueOffset + 4
internal let rgbaValueByteCount = rgbaAlphaOffset + 4


// Internal portal helpers

extension Portal {
    
    
    internal var _rbgaRedPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: rgbaRedOffset) }
    internal var _rbgaGreenPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: rgbaGreenOffset) }
    internal var _rbgaBluePtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: rgbaBlueOffset) }
    internal var _rbgaAlphaPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: rgbaAlphaOffset) }
    
    
    internal var _rgbaRed: Float32 {
        get { return Float32(fromPtr: _rbgaRedPtr, endianness) }
        set { Float32(newValue).copyBytes(to: _rbgaRedPtr, endianness) }
    }
    
    internal var _rgbaGreen: Float32 {
        get { return Float32(fromPtr: _rbgaGreenPtr, endianness) }
        set { Float32(newValue).copyBytes(to: _rbgaGreenPtr, endianness) }
    }
    
    internal var _rgbaBlue: Float32 {
        get { return Float32(fromPtr: _rbgaBluePtr, endianness) }
        set { Float32(newValue).copyBytes(to: _rbgaBluePtr, endianness) }
    }
    
    internal var _rgbaAlpha: Float32 {
        get { return Float32(fromPtr: _rbgaAlphaPtr, endianness) }
        set { Float32(newValue).copyBytes(to: _rbgaAlphaPtr, endianness) }
    }
}


// Public portal access

public extension Portal {
    
    
    /// Assess if the portal is valid and refers to a RBGA.
    ///
    /// - Returns: True if the value accessable through this portal is an RBGA. False if the portal is invalid or the value is not an RBGA.

    public var isRgba: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.rgba }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.rgba.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.rgba.rawValue
    }
    
    
    /// Access the value through this portal as a NSColor
    
    public var rgba: RGBA? {
        get {
            guard isRgba else { return nil }
            return RGBA(red: _rgbaRed, green: _rgbaGreen, blue: _rgbaBlue, alpha: _rgbaAlpha)
        }
        set {
            guard isRgba else { return }
            guard let newValue = newValue else { return }
            
            _rgbaRed = newValue.redComponent
            _rgbaGreen = newValue.greenComponent
            _rgbaBlue = newValue.blueComponent
            _rgbaAlpha = newValue.alphaComponent
        }
    }
    
    
    /// Add an RGBA to an Array.
    ///
    /// - Returns: .success or one of .portalInvalid, .operationNotSupported, .typeConflict
    
    @discardableResult
    public func append(_ value: NSColor) -> Result {
        let rgba = RGBA(value)
        return appendClosure(for: rgba.itemType, with: rgba.valueByteCount) { rgba.copyBytes(to: _arrayElementPtr(for: _arrayElementCount), endianness) }
    }
}


// The RGBA class and the Coder protocol

public struct RGBA {
    
    public let redComponent: Float32
    public let greenComponent: Float32
    public let blueComponent: Float32
    public let alphaComponent: Float32
    
    public var color: NSColor { return NSColor(calibratedRed: CGFloat(redComponent), green: CGFloat(greenComponent), blue: CGFloat(blueComponent), alpha: CGFloat(alphaComponent)) }
        
    public init(_ color: NSColor) {
        redComponent = Float32(color.redComponent)
        greenComponent = Float32(color.greenComponent)
        blueComponent = Float32(color.blueComponent)
        alphaComponent = Float32(color.alphaComponent)
    }
    
    public init(red: Float32, green: Float32, blue: Float32, alpha: Float32) {
        redComponent = red
        greenComponent = green
        blueComponent = blue
        alphaComponent = alpha
    }
}


// Add equatable

extension RGBA: Equatable {
    
    public static func == (lhs: RGBA, rhs: RGBA) -> Bool {
        if lhs.redComponent != rhs.redComponent { return false }
        if lhs.greenComponent != rhs.greenComponent { return false }
        if lhs.blueComponent != rhs.blueComponent { return false }
        return lhs.alphaComponent == rhs.alphaComponent
    }
}


// Add the Coder protocol

extension RGBA {
    
    public var itemType: ItemType { return ItemType.rgba }
    
    public var valueByteCount: Int { return rgbaValueByteCount }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        if endianness == machineEndianness {
            ptr.storeBytes(of: Float32(color.redComponent).bitPattern, as: UInt32.self)
            ptr.advanced(by: 4).storeBytes(of: Float32(color.greenComponent).bitPattern, as: UInt32.self)
            ptr.advanced(by: 8).storeBytes(of: Float32(color.blueComponent).bitPattern, as: UInt32.self)
            ptr.advanced(by: 12).storeBytes(of: Float32(color.alphaComponent).bitPattern, as: UInt32.self)
        } else {
            ptr.storeBytes(of: Float32(color.redComponent).bitPattern.byteSwapped, as: UInt32.self)
            ptr.advanced(by: 4).storeBytes(of: Float32(color.greenComponent).bitPattern.byteSwapped, as: UInt32.self)
            ptr.advanced(by: 8).storeBytes(of: Float32(color.blueComponent).bitPattern.byteSwapped, as: UInt32.self)
            ptr.advanced(by: 12).storeBytes(of: Float32(color.alphaComponent).bitPattern.byteSwapped, as: UInt32.self)
        }
    }
}



