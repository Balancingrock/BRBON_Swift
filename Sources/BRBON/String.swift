// =====================================================================================================================
//
//  File:       Coder-String.swift
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
// 0.7.0 - File renamed from String-Coder to Coder-String
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


// Offset definitions

fileprivate let stringByteCountOffset = 0
fileprivate let stringUtf8CodeOffset = stringByteCountOffset + 4


// Internal portal helpers for String items

internal extension Portal {
    
    internal var _stringItemCountPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: stringByteCountOffset) }
    internal var _stringUtf8CodePtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: stringUtf8CodeOffset) }
    
    
    internal var _stringByteCount: Int {
        get { return Int(UInt32(fromPtr: _stringItemCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _stringItemCountPtr, endianness) }
    }
    
    internal var _stringUtf8Code: Data {
        get {
            return Data(bytes: _stringUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: _stringByteCount)
        }
        set {
            _stringByteCount = newValue.count
            newValue.copyBytes(to: _stringUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: newValue.count)
        }
    }
    
    internal var _stringValueFieldUsedByteCount: Int { return 4 + _stringByteCount }
}


// Public portal access

extension Portal {
    
    
    /// - Returns: True if the value accessable through this portal is a String.
    
    public var isString: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.string }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.string.rawValue
    }
    
    
    /// Access the value through the portal as a String
    ///
    /// - Note: Assigning a null has no effect.
    
    public var string: String? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isString else { fatalOrNull("Attempt to access \(String(describing: itemType)) as a String"); return nil }
            return String(data: _stringUtf8Code, encoding: .utf8)
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isString else { fatalOrNull("Attempt to access \(String(describing: itemType)) as a String"); return }
            guard let newValue = newValue else { return }
            
            guard let utf8 = newValue.data(using: .utf8) else { return }
            let result = newEnsureValueFieldByteCount(of: 4 + utf8.count)
            guard result == .success else { return }
            _stringUtf8Code = utf8
        }
    }
}


/// Adds the Coder protocol

extension String: Coder {
    
    internal var valueByteCount: Int { return 4 + (self.data(using: .utf8)?.count ?? 0) }
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let data = self.data(using: .utf8) ?? Data()
        data.storeValue(atPtr: atPtr, endianness)
    }
    
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let data = Data(fromPtr: fromPtr, endianness)
        self.init(data: data, encoding: .utf8)!
    }
}
