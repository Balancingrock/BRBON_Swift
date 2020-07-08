// =====================================================================================================================
//
//  File:       BRCrcBinary.swift
//  Project:    BRBON
//
//  Version:    1.3.2
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2020 Marinus van der Lugt, All rights reserved.
//
//  License:    MIT, see LICENSE file
//
//  And because I need to make a living:
//
//   - You can send payment (you choose the amount) via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
// PLEASE let me know about bugs, improvements and feature requests. (rien@balancingrock.nl)
// =====================================================================================================================
//
// History
//
// 1.3.2 - Updated LICENSE
// 1.2.2 - Comment line removed
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


fileprivate let crcBinaryCrcOffset = 0
fileprivate let crcBinaryByteCountOffset = crcBinaryCrcOffset + 4
fileprivate let crcBinaryDataOffset = crcBinaryByteCountOffset + 4


// Add crcBinary access

internal extension UnsafeMutableRawPointer {

    
    /// Returns a pointer to the CRC value of a crcBinary item assuming self points at the first byte of the value.
    
    fileprivate var crcBinaryCrcPtr: UnsafeMutableRawPointer { return self.advanced(by: crcBinaryCrcOffset) }


    /// Returns a pointer to the Byte Count value of a crcBinary item assuming self points at the first byte of the value.

    fileprivate var crcBinaryByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: crcBinaryByteCountOffset) }


    /// Returns a pointer to the Data area of a crcBinary item assuming self points at the first byte of the value.

    fileprivate var crcBinaryDataPtr: UnsafeMutableRawPointer { return self.advanced(by: crcBinaryDataOffset) }

    
    /// Returns the CRC value of a crcBinary item assuming self points at the first byte of the value.
    
    func crcBinaryCrc(_ endianness: Endianness) -> UInt32 {
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
    
    
    /// Returns a BRCrcBinary assuming self points to the first byte of the value
    
    func crcBinary(_ endianness: Endianness) -> BRCrcBinary {
        return BRCrcBinary.init(data: crcBinaryData(endianness), crc: crcBinaryCrc(endianness))
    }
}


// Item access

internal extension Portal {
    
    
    /// Access to the crcBinary value as Data.
    
    var _crcBinaryData: Data {
        get {
            return _valuePtr.crcBinaryData(endianness)
        }
        set {
            let result = ensureStorageAtValuePtr(of: crcBinaryDataOffset + newValue.count)
            guard result == .success else { return }
            
            _valuePtr.setCrcBinaryData(to: newValue, endianness)
            _valuePtr.setCrcBinaryCrc(to: newValue.crc32(), endianness)
        }
    }

    
    /// Access to the crcBinary value as a BRCrcBinary.
    
    var _crcBinary: BRCrcBinary {
        get {
            return BRCrcBinary(data: _valuePtr.crcBinaryData(endianness), crc: _valuePtr.crcBinaryCrc(endianness))
        }
        set {
            let result = ensureStorageAtValuePtr(of: crcBinaryDataOffset + newValue.data.count)
            guard result == .success else { return }
            
            _valuePtr.setCrcBinaryData(to: newValue.data, endianness)
            _valuePtr.setCrcBinaryCrc(to: newValue.crc, endianness)
        }
    }
    
    
    /// Returns the number of bytes actually used of the value field.
    
    var _crcBinaryValueFieldUsedByteCount: Int {
        return crcBinaryDataOffset + Int(_valuePtr.crcBinaryByteCount(endianness))
    }
}


// Item utils

public extension Portal {
    
    
    /// Returns true if the value accessable through this portal is a CrcBinary.
    
    var isCrcBinary: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.crcBinary }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.crcBinary.rawValue }
        return itemPtr.itemType == ItemType.crcBinary.rawValue
    }
    
    
    /// Access the value through the portal as a BRCrcBinary
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to a crcBinary, writing will be ineffective and reading will always return nil.
    ///
    /// __On Read:__ It will interpret the data at the associated memory location as a BRCrcBinary specification and return it. Otherwise it will return nil. Note that if the BRCrcBinary specification was written as nil, it will read as 'empty'.
    ///
    /// __On Write:__ Writes the specification of the BRCrcBinary to the associated memory area. Writing a nil will result in erasure of existing  data (by setting the size and crc zero).

    var crcBinary: BRCrcBinary? {
        get {
            guard isCrcBinary else { return nil }
            return _crcBinary
        }
        set {
            guard isCrcBinary else { return }
            if let newValue = newValue {
                _crcBinary = newValue
            } else {
                _valuePtr.setCrcBinaryCrc(to: 0, endianness)
                _valuePtr.setCrcBinaryByteCount(to: 0, endianness)
            }
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
    
    
    /// Implementation of the Equatable protocol

    public static func == (lhs: BRCrcBinary, rhs: BRCrcBinary) -> Bool {
        if lhs.crc != rhs.crc { return false }
        return lhs.data == rhs.data
    }
}


/// Add the coder protocol

extension BRCrcBinary: Coder {
    
    
    /// Implementation of the `Coder` protocol

    public var itemType: ItemType { return ItemType.crcBinary }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return crcBinaryDataOffset + data.count }

    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        ptr.setCrcBinaryCrc(to: crc, endianness)
        ptr.setCrcBinaryData(to: data, endianness)
    }
}


