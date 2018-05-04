// =====================================================================================================================
//
//  File:       Rgba-Coder.swift
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



/// The RGBA class and the Coder protocol

public final class Rgba: Coder, Equatable {
    
    
    /// Equatable protocol
    
    static public func == (lhs: Rgba, rhs: Rgba) -> Bool {
        if lhs === rhs { return true }
        if lhs.color === rhs.color { return true }
        if lhs.color.redComponent != rhs.color.redComponent { return false }
        if lhs.color.greenComponent != rhs.color.greenComponent { return false }
        if lhs.color.blueComponent != rhs.color.blueComponent { return false }
        if lhs.color.alphaComponent != rhs.color.alphaComponent { return false }
        return true
    }
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    public var itemType: ItemType { return ItemType.rgba }
    
    
    /// Create a new item
    
    public init(_ color: NSColor) { self.color = color }
    
    
    // The content
    
    public let color: NSColor
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream.
    
    internal var valueByteCount: Int { return 16 }
    
    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        if endianness == machineEndianness {
            atPtr.storeBytes(of: Float32(color.redComponent).bitPattern, as: UInt32.self)
            atPtr.advanced(by: 4).storeBytes(of: Float32(color.greenComponent).bitPattern, as: UInt32.self)
            atPtr.advanced(by: 8).storeBytes(of: Float32(color.blueComponent).bitPattern, as: UInt32.self)
            atPtr.advanced(by: 12).storeBytes(of: Float32(color.alphaComponent).bitPattern, as: UInt32.self)
        } else {
            atPtr.storeBytes(of: Float32(color.redComponent).bitPattern.byteSwapped, as: UInt32.self)
            atPtr.advanced(by: 4).storeBytes(of: Float32(color.greenComponent).bitPattern.byteSwapped, as: UInt32.self)
            atPtr.advanced(by: 8).storeBytes(of: Float32(color.blueComponent).bitPattern.byteSwapped, as: UInt32.self)
            atPtr.advanced(by: 12).storeBytes(of: Float32(color.alphaComponent).bitPattern.byteSwapped, as: UInt32.self)
        }
    }
    
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
        
        if endianness == machineEndianness {
            red = CGFloat(Float32.init(bitPattern: fromPtr.assumingMemoryBound(to: UInt32.self).pointee))
            green = CGFloat(Float32.init(bitPattern: fromPtr.advanced(by: 4).assumingMemoryBound(to: UInt32.self).pointee))
            blue = CGFloat(Float32.init(bitPattern: fromPtr.advanced(by: 8).assumingMemoryBound(to: UInt32.self).pointee))
            alpha = CGFloat(Float32.init(bitPattern: fromPtr.advanced(by: 12).assumingMemoryBound(to: UInt32.self).pointee))
        } else {
            red = CGFloat(Float32.init(bitPattern: fromPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped))
            green = CGFloat(Float32.init(bitPattern: fromPtr.advanced(by: 4).assumingMemoryBound(to: UInt32.self).pointee.byteSwapped))
            blue = CGFloat(Float32.init(bitPattern: fromPtr.advanced(by: 8).assumingMemoryBound(to: UInt32.self).pointee.byteSwapped))
            alpha = CGFloat(Float32.init(bitPattern: fromPtr.advanced(by: 12).assumingMemoryBound(to: UInt32.self).pointee.byteSwapped))
        }
        
        self.color = NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
