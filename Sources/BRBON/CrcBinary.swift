// =====================================================================================================================
//
//  File:       Coder-CrcBinary.swift
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
// 0.7.0 - Renamed file from CrcBinary to Coder-CrcBinary
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


fileprivate let crcBinaryCrcOffset = 0
fileprivate let crcBinaryByteCountOffset = crcBinaryCrcOffset + 4
internal let crcBinaryDataOffset = crcBinaryByteCountOffset + 4


extension Portal {
    
    internal var _crcBinaryCrcPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: crcBinaryCrcOffset) }
    internal var _crcBinaryByteCountPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: crcBinaryByteCountOffset) }
    internal var _crcBinaryDataPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: crcBinaryDataOffset) }
    
    
    internal var _crcBinaryCrc: UInt32 {
        get { return UInt32(fromPtr: _crcBinaryCrcPtr, endianness) }
        set { newValue.copyBytes(to: _crcBinaryCrcPtr, endianness) }
    }
    
    internal var _crcBinaryByteCount: Int {
        get { return Int(UInt32(fromPtr: _crcBinaryByteCountPtr, endianness)) }
        set { UInt32(newValue).copyBytes(to: _crcBinaryByteCountPtr, endianness) }
    }
    
    internal var _crcBinaryData: Data {
        get { return Data(bytes: _crcBinaryDataPtr.assumingMemoryBound(to: UInt8.self), count: _crcBinaryByteCount) }
        set {
            let result = ensureValueFieldByteCount(of: crcBinaryDataOffset + newValue.count)
            guard result == .success else { return }
            _crcBinaryByteCount = newValue.count
            newValue.copyBytes(to: _crcBinaryDataPtr.assumingMemoryBound(to: UInt8.self), count: _crcBinaryByteCount)
        }
    }
    
    internal var _crcBinary: BRCrcBinary {
        get { return BRCrcBinary(data: _crcBinaryData, crc: _crcBinaryCrc) }
        set {
            _crcBinaryData = newValue.data
            _crcBinaryByteCount = newValue.data.count
            _crcBinaryCrc = newValue.crc
        }
    }
    
    internal var _crcBinaryValueFieldUsedByteCount: Int {
        return crcBinaryDataOffset + _crcBinaryByteCount
    }
}


public extension Portal {
    
    
    /// Returns true if the value accessable through this portal is a CrcBinary.
    
    public var isCrcBinary: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.crcBinary }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.crcBinary.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.crcBinary.rawValue
    }
    
    
    public var crcBinary: BRCrcBinary? {
        get {
            guard isCrcBinary else { return nil }
            return _crcBinary
        }
        set {
            guard let newValue = newValue else { return }
            guard isCrcBinary else { return }
            _crcBinary = newValue
        }
    }
}


/// Defines the BRCrcBinary.

public struct BRCrcBinary {
    
    public let data: Data
    public let crc: UInt32

    internal var crcIsValid: Bool { return data.crc32() == crc }

    public init(_ data: Data) {
        self.data = data
        self.crc = data.crc32()
    }
    
    public init(data: Data, crc: UInt32) {
        self.data = data
        self.crc = crc
    }
}


/// Add the equatable protocol

extension BRCrcBinary: Equatable {
    
    public static func == (lhs: BRCrcBinary, rhs: BRCrcBinary) -> Bool {
        if lhs.crc != rhs.crc { return false }
        return lhs.data == rhs.data
    }
}


/// Add the coder protocol

extension BRCrcBinary: Coder {
    
    public var itemType: ItemType { return ItemType.crcBinary }

    public var valueByteCount: Int { return crcBinaryDataOffset + data.count }

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc.copyBytes(to: ptr.advanced(by: crcBinaryCrcOffset), endianness)
        UInt32(data.count).copyBytes(to: ptr.advanced(by: crcBinaryByteCountOffset), endianness)
        data.copyBytes(to: ptr.advanced(by: crcBinaryDataOffset).assumingMemoryBound(to: UInt8.self), count: data.count)
    }
}


/// Add a decoder

extension BRCrcBinary {
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc = UInt32(fromPtr: fromPtr.advanced(by: crcBinaryCrcOffset), endianness)
        let byteCount = Int(UInt32(fromPtr: fromPtr.advanced(by: crcBinaryByteCountOffset), endianness))
        data = Data(bytes: fromPtr.advanced(by: crcBinaryDataOffset), count: byteCount)
    }
}

