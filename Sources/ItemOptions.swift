// =====================================================================================================================
//
//  File:       ItemOptions.swift
//  Project:    BRBON
//
//  Version:    0.1.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2017 Marinus van der Lugt, All rights reserved.
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
// 0.1.0  - Initial version
// =====================================================================================================================

import Foundation
import BRUtils


private let itemOptionNil: UInt8 = 0b1000_0000

private let itemOptionFixedItemByteCount: UInt8 = 0b0100_0000

private let itemOptionFixedNameByteCount: UInt8 = 0b0010_0000

private let itemOptionReservedMask: UInt8 = 0b0001_1111


public struct ItemOptions {

    fileprivate var value: UInt8 = 0
    
    
    /// When 'true' the associated value should be considered 'nil'.
    
    public var isNil: Bool {
        set {
            if newValue {
                value |= itemOptionNil
            } else {
                value &= ~itemOptionNil
            }
        }
        get {
            return (value & itemOptionNil) != 0
        }
    }
    

    /// When 'true' then the byte count for this item is fixed.
    
    public var fixedItemByteCount: Bool {
        set {
            if newValue {
                value |= itemOptionFixedItemByteCount
            } else {
                value &= ~itemOptionFixedItemByteCount
            }
        }
        get {
            return (value & itemOptionFixedItemByteCount) != 0
        }
    }
    
    
    /// When 'true' then the byte count for the name of this item is fixed.
    
    public var fixedNameByteCount: Bool {
        set {
            if newValue {
                value |= itemOptionFixedNameByteCount
            } else {
                value &= ~itemOptionFixedNameByteCount
            }
        }
        get {
            return (value & itemOptionFixedNameByteCount) != 0
        }
    }

    
    public init?(_ val: UInt8) {
        guard (val & itemOptionReservedMask) == 0 else { return nil }
        value = val
    }
    
    public init() {
        value = 0
    }
}


extension ItemOptions: EndianBytes {

    public func endianBytes(_ endianness: Endianness) -> Data {
        return Data(bytes: [value])
    }

    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        guard count > 0 else { return nil }
        let byte = bytePtr.advanceUInt8()
        count -= 1
        self.init(byte)
    }
}


extension ItemOptions: Equatable {
    
    public static func == (l: ItemOptions, r: ItemOptions) -> Bool {
        return l.value == r.value
    }
}


internal extension UnsafeRawPointer {
    
    internal mutating func advanceItemOptions() -> ItemOptions? {
        let val = self.advanceUInt8()
        return ItemOptions(val)
    }
}

