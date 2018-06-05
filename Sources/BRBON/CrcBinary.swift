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
// 0.7.0 - Code restructuring & simplification
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


fileprivate let crcBinaryCrcOffset = 0
fileprivate let crcBinaryByteCountOffset = crcBinaryCrcOffset + 4
fileprivate let crcBinaryDataOffset = crcBinaryByteCountOffset + 4


// Add crcBinary access

fileprivate extension UnsafeMutableRawPointer {

    
    /// Returns a pointer to the CRC value of a crcBinary item assuming self points at the first byte of the value.
    
    fileprivate var crcBinaryCrcPtr: UnsafeMutableRawPointer { return self.advanced(by: crcBinaryCrcOffset) }


    /// Returns a pointer to the Byte Count value of a crcBinary item assuming self points at the first byte of the value.

    fileprivate var crcBinaryByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: crcBinaryByteCountOffset) }


    /// Returns a pointer to the Data area of a crcBinary item assuming self points at the first byte of the value.

    fileprivate var crcBinaryDataPtr: UnsafeMutableRawPointer { return self.advanced(by: crcBinaryDataOffset) }

    
    /// Returns the CRC value of a crcBinary item assuming self points at the first byte of the value.
    
    fileprivate func crcBinaryCrc(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return crcBinaryCrcPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return crcBinaryCrcPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the CRC value of a crcBinary item assuming self points at the first byte of the value.

    fileprivate func setCrcBinaryCrc(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            crcBinaryCrcPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            crcBinaryCrcPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Returns the Byte Count of a crcBinary item assuming self points at the first byte of the value.

    fileprivate func crcBinaryByteCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return crcBinaryByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return crcBinaryByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the Byte Count of a crcBinary item assuming self points at the first byte of the value.

    fileprivate func setCrcBinaryByteCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            crcBinaryByteCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            crcBinaryByteCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Returns the binary data of a crcBinary item assuming self points to the first byte of the value.
    ///
    /// Note that this will also read the crcBinaryByteCount.
    
    fileprivate func crcBinaryData(_ endianness: Endianness) -> Data {
        return Data(bytes: self.crcBinaryDataPtr, count: Int(self.crcBinaryByteCount(endianness)))
    }

    
    /// Sets the binary data of a crcBinary item assuming self points to the first byte of the value.
    ///
    /// Note that this will also write the crcBinaryByteCount.

    fileprivate func setCrcBinaryData(to value: Data, _ endianness: Endianness) {
        value.copyBytes(to: self.crcBinaryDataPtr.assumingMemoryBound(to: UInt8.self), count: value.count)
        self.setCrcBinaryByteCount(to: UInt32(value.count), endianness)
    }
}


// Item access

internal extension Portal {
    
    
    /// Access to the crcBinary value as Data.
    
    internal var _crcBinaryData: Data {
        get {
            return _valuePtr.crcBinaryData(endianness)
        }
        set {
            //let result = ensureValueFieldByteCount(of: crcBinaryDataOffset + newValue.count)
            let result = ensureStorageAtValuePtr(of: crcBinaryDataOffset + newValue.count)
            guard result == .success else { return }
            
            _valuePtr.setCrcBinaryData(to: newValue, endianness)
            _valuePtr.setCrcBinaryCrc(to: newValue.crc32(), endianness)
        }
    }

    
    /// Access to the crcBinary value as a BRCrcBinary.
    
    internal var _crcBinary: BRCrcBinary {
        get {
            return BRCrcBinary(data: _valuePtr.crcBinaryData(endianness), crc: _valuePtr.crcBinaryCrc(endianness))
        }
        set {
            //let result = ensureValueFieldByteCount(of: crcBinaryDataOffset + newValue.data.count)
            let result = ensureStorageAtValuePtr(of: crcBinaryDataOffset + newValue.data.count)
            guard result == .success else { return }
            
            _valuePtr.setCrcBinaryData(to: newValue.data, endianness)
            _valuePtr.setCrcBinaryCrc(to: newValue.crc, endianness)
        }
    }
    
    
    /// Returns the number of bytes actually used of the value field.
    
    internal var _crcBinaryValueFieldUsedByteCount: Int {
        return crcBinaryDataOffset + Int(_valuePtr.crcBinaryByteCount(endianness))
    }
}


// Item utils

public extension Portal {
    
    
    /// Returns true if the value accessable through this portal is a CrcBinary.
    
    public var isCrcBinary: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.crcBinary }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.crcBinary.rawValue }
        return itemPtr.itemType == ItemType.crcBinary.rawValue
    }
    
    
    /// The BRCrcBinary referenced by this portal. Nil if the portal is invalid or does not refer to a CrcBinary.
    
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


/// Associates a CRC32 with a Data object.

public struct BRCrcBinary {
    
    
    /// The Data object for the CRC32
    
    public let data: Data
    
    
    /// The CRC32 for the data object
    
    public let crc: UInt32

    
    /// True if the curretn value of the CRC32 and the calculated CRC32 of the data object are the same, false otherwise.
    
    public var isValid: Bool { return data.crc32() == crc }

    
    /// Create a new CrcBinary that contains a valid CRC
    
    public init(_ data: Data) {
        self.data = data
        self.crc = data.crc32()
    }
    
    
    /// Create a new CrcBinary, but the CRC value may be invalid.
    
    internal init(data: Data, crc: UInt32) {
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
        ptr.setCrcBinaryCrc(to: crc, endianness)
        ptr.setCrcBinaryData(to: data, endianness)
    }
}


