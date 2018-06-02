// =====================================================================================================================
//
//  File:       Binary.swift
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


// Offset definitions

fileprivate let binaryByteCountOffset = 0
internal let binaryDataOffset = binaryByteCountOffset + 4


// Pointer manipulations

fileprivate extension UnsafeMutableRawPointer {
    
    
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

    fileprivate func binaryData(_ endianness: Endianness) -> Data {
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
    
    internal var _binaryData: Data {
        
        get { return _valuePtr.binaryData(endianness) }
        
        set {
            let result = ensureValueFieldByteCount(of: binaryDataOffset + newValue.count)
            guard result == .success else { return }
            
            _valuePtr.setBinaryData(to: newValue, endianness)
        }
    }
    
    internal var _binaryValueFieldUsedByteCount: Int { return binaryDataOffset + Int(itemPtr.binaryByteCount(endianness)) }
}


// Public portal accessors for binary

public extension Portal {
    
    
    /// Returns true if the value accessable through this portal is a Binary.
    
    public var isBinary: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.binary }
        if index != nil { return itemPtr.itemValueFieldPtr.arrayElementType == ItemType.binary.rawValue }
        return itemPtr.itemType == ItemType.binary.rawValue
    }
    
    
    /// Access the value through the portal as a Binary.
    ///
    /// - Note: Assigning a nil has no effect.
    
    public var binary: Data? {
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


// Create a typealias for orthogonality

public typealias BRBinary = Data


// Adds the Coder protocol to Data

extension Data: Coder {
    
    public var itemType: ItemType { return ItemType.binary }

    public var valueByteCount: Int { return binaryDataOffset + self.count }
    
    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        UInt32(self.count).copyBytes(to: ptr.advanced(by: binaryByteCountOffset), endianness)
        self.copyBytes(to: ptr.advanced(by: binaryDataOffset).assumingMemoryBound(to: UInt8.self), count: self.count)
    }    
}


/// Add a decoder

extension Data {
    internal init(fromPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        let byteCount = Int(UInt32(fromPtr: fromPtr.advanced(by: binaryByteCountOffset), endianness))
        self.init(Data(bytes: fromPtr.advanced(by: binaryDataOffset), count: byteCount))
    }
}

