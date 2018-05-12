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
// 0.7.0 - File renamed from Data-Coder to Coder-Data
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


// Offset definitions

fileprivate let binaryByteCountOffset = 0
internal let binaryDataOffset = binaryByteCountOffset + 4


// Internal portal helpers

internal extension Portal {
    
    internal var _binaryByteCountPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: binaryByteCountOffset) }
    internal var _binaryDataPtr: UnsafeMutableRawPointer { return valueFieldPtr.advanced(by: binaryDataOffset) }
    
    
    internal var _binaryByteCount: Int {
        get { return Int(UInt32(fromPtr: _binaryByteCountPtr, endianness)) }
        set { UInt32(newValue).copyBytes(to: _binaryByteCountPtr, endianness) }
    }
    
    internal var _binaryData: Data {
        get { return Data(bytes: _binaryDataPtr.assumingMemoryBound(to: UInt8.self), count: _binaryByteCount) }
        set {
            let result = ensureValueFieldByteCount(of: binaryDataOffset + newValue.count)
            guard result == .success else { return }
            _binaryByteCount = newValue.count
            newValue.copyBytes(to: _binaryDataPtr.assumingMemoryBound(to: UInt8.self), count: newValue.count)
        }
    }
    
    internal var _binaryValueFieldUsedByteCount: Int { return binaryDataOffset + _binaryByteCount }
}


// Public portal accessors for Font

public extension Portal {
    
    
    /// Returns true if the value accessable through this portal is a Binary.
    
    public var isBinary: Bool {
        guard isValid else { return false }
        if let column = column { return _tableGetColumnType(for: column) == ItemType.binary }
        if index != nil { return _arrayElementTypePtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue }
        return itemPtr.assumingMemoryBound(to: UInt8.self).pointee == ItemType.binary.rawValue
    }
    
    
    /// Access the value through the portal as a Binary.
    ///
    /// - Note: Assigning a nil has no effect.
    
    public var binary: Data? {
        get {
            guard isBinary else { return nil }
            return _binaryData
        }
        set {
            guard isBinary else { return }
            
            guard let newValue = newValue else { return }
                        
            _binaryData = newValue
        }
    }


    /// Add a Data to an Array of Binary or CrcBinary.
    ///
    /// - Returns: .success or one of .portalInvalid, .operationNotSupported, .typeConflict
    
    @discardableResult
    public func append(_ value: Data) -> Result {
        if _arrayElementType == .binary {
            return appendClosure(for: value.itemType, with: value.valueByteCount) { value.copyBytes(to: _arrayElementPtr(for: _arrayElementCount), endianness) }
        } else if _arrayElementType == .crcBinary {
            let crcBinary = BRCrcBinary(value)
            return appendClosure(for: crcBinary.itemType, with: crcBinary.valueByteCount) { crcBinary.copyBytes(to: _arrayElementPtr(for: _arrayElementCount), endianness) }
        } else {
            return .typeConflict
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

