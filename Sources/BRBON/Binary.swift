// =====================================================================================================================
//
//  File:       Binary.swift
//  Project:    BRBON
//
//  Version:    1.0.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//  Website:    http://swiftfire.nl/projects/brbon/brbon.html
//
//  Copyright:  (c) 2018-2019 Marinus van der Lugt, All rights reserved.
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
//  Like you, I need to make a living:
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
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


// Offset definitions

fileprivate let binaryByteCountOffset = 0
fileprivate let binaryDataOffset = binaryByteCountOffset + 4


// Pointer manipulations

internal extension UnsafeMutableRawPointer {
    
    
    /// The pointer to the binary byte count assuming self points to the first byte of the value.

    fileprivate var binaryByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: binaryByteCountOffset) }

    
    /// The pointer to the first byte assuming self points to the first byte of the value.

    fileprivate var binaryDataPtr: UnsafeMutableRawPointer { return self.advanced(by: binaryDataOffset) }

    
    /// Returns the binary byte count assuming self points to the first byte of the value.

    fileprivate func binaryByteCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return binaryByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return binaryByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }

    
    /// Sets the binary byte count assuming self points to the first byte of the value.

    fileprivate func setBinaryByteCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            binaryByteCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            binaryByteCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Returns the binary data assuming self points to the first byte of the value.
    ///
    /// Also reads from 'binaryByteCount'

    func binary(_ endianness: Endianness) -> Data {
        return Data(bytes: binaryDataPtr.assumingMemoryBound(to: UInt8.self), count: Int(binaryByteCount(endianness)))
    }
    
    
    /// Sets the binary data assuming self points to the first byte of the value.
    ///
    /// Also writes to 'setBinaryByteCount'

    fileprivate func setBinaryData(to value: Data, _ endianness: Endianness) {
        setBinaryByteCount(to: UInt32(value.count), endianness)
        value.copyBytes(to: binaryDataPtr.assumingMemoryBound(to: UInt8.self), count: value.count)
    }
}


internal extension Portal {
    
    
    /// The binary data referred to by this portal.
    
    var _binaryData: Data {
        
        get { return _valuePtr.binary(endianness) }
        
        set {
            let result = ensureStorageAtValuePtr(of: binaryDataOffset + newValue.count)
            guard result == .success else { return }
            
            _valuePtr.setBinaryData(to: newValue, endianness)
        }
    }
    
    
    /// The number of bytes actually used for the value referenced by the portal.
    
    var _binaryValueFieldUsedByteCount: Int { return binaryDataOffset + Int(itemPtr.binaryByteCount(endianness)) }
}


// Public portal accessors for binary

public extension Portal {
    
    
    /// Returns true if the portal is valid and refers to a Binary.
    
    var isBinary: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.binary }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.binary.rawValue }
        return itemPtr.itemType == ItemType.binary.rawValue
    }
    
    
    /// Access the value through the portal as a binary.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to a binary or CrcBinary, writing will be ineffective and reading will always return nil.
    ///
    /// __On Read:__ The data at the associated memory location will be interpreted as a binary or CrcBinary and the content returned.
    ///
    /// __On Write:__ Writes the binary or CrcBinary to the associated memory area. Writing a nil will result in erasure of existing binary data (by setting the size of the data to zero).

    var binary: Data? {
        get {
            if isBinary { return _binaryData }
            if isCrcBinary { return _crcBinaryData }
            return nil
        }
        set {
            guard let newValue = newValue else { return }
            if isBinary { _binaryData = newValue }
            if isCrcBinary { _crcBinaryData = newValue }
        }
    }
}


// Adds the Coder protocol to Data

extension Data: Coder {
    
    public var itemType: ItemType { return ItemType.binary }

    public var valueByteCount: Int { return binaryDataOffset + self.count }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        ptr.setBinaryData(to: self, endianness)
    }
}

