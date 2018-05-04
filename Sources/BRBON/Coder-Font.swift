// =====================================================================================================================
//
//  File:       Coder-Font.swift
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

public final class Font: Coder, Equatable {
    
    
    /// Equatable protocol
    
    static public func == (lhs: Font, rhs: Font) -> Bool {
        if lhs === rhs { return true }
        if lhs.font === rhs.font { return true }
        if lhs.font.pointSize != rhs.font.pointSize { return false }
        if lhs.font.familyName != rhs.font.familyName { return false }
        if lhs.font.fontName != rhs.font.fontName { return false }
        return true
    }
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    public var itemType: ItemType { return ItemType.rgba }
    
    
    /// Create a new BrbonArray
    
    public init(_ font: NSFont) { self.font = font }
    
    
    // The content
    
    public let font: NSFont
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream.
    
    internal var valueByteCount: Int {
        guard let family = (font.familyName ?? "").data(using: .utf8), family.count < 256 else { return 0 }
        guard let name = font.fontName.data(using: .utf8), name.count < 256 else { return 0 }
        return 4 + 2 + family.count + name.count
    }
    
    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        guard let family = (font.familyName ?? "").data(using: .utf8), family.count < 256 else { return }
        guard let name = font.fontName.data(using: .utf8), name.count < 256 else { return }
        
        if endianness == machineEndianness {
            atPtr.storeBytes(of: Float32(font.pointSize).bitPattern, as: UInt32.self)
        } else {
            atPtr.storeBytes(of: Float32(font.pointSize).bitPattern.byteSwapped, as: UInt32.self)
        }
        atPtr.advanced(by: 4).storeBytes(of: UInt8(family.count), as: UInt8.self)
        atPtr.advanced(by: 5).storeBytes(of: UInt8(name.count), as: UInt8.self)
        family.copyBytes(to: atPtr.advanced(by: 6).assumingMemoryBound(to: UInt8.self), count: family.count)
        name.copyBytes(to: atPtr.advanced(by: 6 + family.count).assumingMemoryBound(to: UInt8.self), count: name.count)
    }
    
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        
        let size: CGFloat
        let family: String
        let name: String
        
        if endianness == machineEndianness {
            size = CGFloat(Float32.init(bitPattern: fromPtr.assumingMemoryBound(to: UInt32.self).pointee))
        } else {
            size = CGFloat(Float32.init(bitPattern: fromPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped))
        }
        let familyByteCount = Int(UInt8(fromPtr: fromPtr.advanced(by: 4), endianness))
        let nameByteCount = Int(UInt8(fromPtr: fromPtr.advanced(by: 5), endianness))
        let familyBytes = Data(bytes: fromPtr.advanced(by: 6), count: familyByteCount)
        let nameBytes = Data(bytes: fromPtr.advanced(by: 6 + familyByteCount), count: nameByteCount)
        family = String(data: familyBytes, encoding: .utf8) ?? ""
        name = String(data: nameBytes, encoding: .utf8) ?? ""
        
        font = NSFont(name: name, size: size) ?? NSFont(name: family, size: size) ?? NSFont.systemFont(ofSize: size)
    }
}
