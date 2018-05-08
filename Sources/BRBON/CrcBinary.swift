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
fileprivate let crcBinaryDataOffset = crcBinaryByteCountOffset + 4


extension Portal {
    
    internal var _crcBinaryCrcPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: crcBinaryCrcOffset) }
    internal var _crcBinaryByteCountPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: crcBinaryByteCountOffset) }
    internal var _crcBinaryDataPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: crcBinaryDataOffset) }
    
    
    internal var _crcBinaryCrc: UInt32 {
        get { return UInt32(fromPtr: _crcBinaryCrcPtr, endianness) }
        set { newValue.storeValue(atPtr: _crcBinaryCrcPtr, endianness) }
    }
    
    internal var _crcBinaryByteCount: Int {
        get { return Int(UInt32(fromPtr: _crcBinaryByteCountPtr, endianness)) }
        set { UInt32(newValue).storeValue(atPtr: _crcBinaryByteCountPtr, endianness) }
    }
    
    internal var _crcBinaryData: Data {
        get { return Data(bytes: _crcBinaryDataPtr.assumingMemoryBound(to: UInt8.self), count: _crcBinaryByteCount) }
        set {
            _crcBinaryCrc = newValue.crc32()
            _crcBinaryByteCount = newValue.count
            newValue.copyBytes(to: _crcBinaryDataPtr.assumingMemoryBound(to: UInt8.self), count: _crcBinaryByteCount)
        }
    }
    
    internal var _crcBinaryValueFieldUsedByteCount: Int {
        return crcBinaryDataOffset + _crcBinaryByteCount
    }
}


public extension Portal {
    
    
    /// Returns true if the value accessable through this portal is a CrcBinary.
    
    public var isCrcBinary: Bool {
        guard isValid else { fatalOrNull("Portal is no longer valid"); return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.crcBinary }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.crcBinary.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.crcBinary.rawValue
    }
    
    
    /// Access the value through the portal as a CrcBinary.
    ///
    /// - Note: Assigning a nil has no effect.
    
    public var crcBinary: Data? {
        get {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return nil }
            guard isCrcBinary else { fatalOrNull("Attempt to access \(String(describing: itemType)) as a CrcBinary"); return nil }
            return _crcBinaryData
        }
        set {
            guard isValid else { fatalOrNull("Portal is no longer valid"); return }
            guard isCrcBinary else { fatalOrNull("Attempt to access \(String(describing: itemType)) as a CrcBinary"); return }
            guard let newValue = newValue else { return }
            let newValueFieldByteCount = newValue.valueByteCount
            let result = newEnsureValueFieldByteCount(of: newValueFieldByteCount)
            guard result == .success else { return }
            _crcBinaryData = newValue
        }
    }


    /// Add a Data to an Array of CrcBinary is done in binary.swift
}

/// Defines the BRBON CrcBinary class and conforms it to the Coder protocol.

internal final class CrcBinary: Coder, Equatable {
    
    public static func ==(lhs: CrcBinary, rhs: CrcBinary) -> Bool {
        if lhs.crc != rhs.crc { return false }
        return lhs.data == rhs.data
    }

    public var itemType: ItemType { return ItemType.crcBinary }
    
    
    /// Creates a new CrcBinary
    
    public init(_ data: Data) {
        self.data = data
        self.crc = data.crc32()
    }

    
    /// The data structure stored in this class.
    
    public let data: Data
    
    
    /// The original CRC value read or calculated during 'init'.
    
    public let crc: UInt32
    
    
    internal var valueByteCount: Int { return 8 + data.count }
    
    internal func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc.storeValue(atPtr: atPtr, endianness)
        data.storeValue(atPtr: atPtr.advanced(by: 4), endianness)
    }
    
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        crc = UInt32(fromPtr: fromPtr, endianness)
        let byteCount = Int(UInt32(fromPtr: fromPtr.advanced(by: 4), endianness))
        data = Data(bytes: fromPtr, count: byteCount)
    }
    
    
    /// - Returns: True if a new CRC32 calculated over the data matches the stored CRC
    
    internal var isValid: Bool { return data.crc32() == crc }
}
