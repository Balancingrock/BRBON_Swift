// =====================================================================================================================
//
//  File:       Name-Access.swift
//  Project:    BRBON
//
//  Version:    0.5.0
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
// 0.5.0 - Migration to Swift 4
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation


public extension Portal {
    
    public subscript(name: String) -> Portal {
        get {
            guard isDictionary else { return Portal.nullPortal }
            return findPortalForItem(withName: NameField(name)) ?? Portal.nullPortal
        }
    }
    
    public subscript(name: String) -> Bool? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.bool
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> Int8? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.int8
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> Int16? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.int16
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> Int32? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.int32
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> Int64? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.int64
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> UInt8? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.uint8
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> UInt16? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.uint16
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> UInt32? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.uint32
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> UInt64? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.uint64
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> Float32? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.float32
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> Float64? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.float64
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> String? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.string
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(BRString(newValue) ?? Null(), withName: NameField(name))
        }
    }
    
    public subscript(name: String) -> Data? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.binary
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }

    public subscript(name: String) -> UUID? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.uuid
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }

    public subscript(name: String) -> BRColor? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.color
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }

    public subscript(name: String) -> BRFont? {
        get {
            guard isDictionary else { return nil }
            return findPortalForItem(withName: NameField(name))?.font
        }
        set {
            guard isDictionary else { return }
            _ = _dictionaryUpdateItem(newValue ?? Null(), withName: NameField(name))
        }
    }
}
