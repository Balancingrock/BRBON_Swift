// =====================================================================================================================
//
//  File:       BRString.swift
//  Project:    BRBON
//
//  Version:    1.0.1
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
// 1.0.1 - Documentation updates
// 1.0.0 - Removed older history
//
// =====================================================================================================================
//
// This is a wrapper for a swift String.
//
// When storing strings in a BRBON structure repeated conversions to a Data struct are made. Using a BRString wrapper
// limits the number of conversions to just one, thereby improving performance.
//
// =====================================================================================================================

import Foundation
import BRUtils


// Pointer manipulations

internal extension UnsafeMutableRawPointer {
    
    func brString(_ endianness: Endianness) -> BRString {
        return BRString(self.stringUtf8Code(endianness))
    }
}


// Public item access

extension Portal {
    
    
    /// Access the value through the portal as a BRString.
    ///
    /// __Preconditions:__ If the portal is invalid or does not refer to a BRString, writing will be ineffective and reading will always return nil.
    ///
    /// __On Read:__ The data at the associated memory location will be interpreted as a BRString and returned. Note that if the BRString specification is invalid the result is unpredictable.
    ///
    /// __On Write:__ Writes the specification of the BRString to the associated memory area. Writing a nil will result in erasure of existing string data (by setting the size of the string to zero).
    
    public var brString: BRString? {
        get {
            guard isString else { return nil }
            return BRString.init(_stringUtf8Code)
        }
        set {
            guard isString else { return }
            if let newValue = newValue {

                let result = ensureStorageAtValuePtr(of: stringUtf8CodeOffset + newValue.utf8Code.count)
                guard result == .success else { return }

                _stringUtf8Code = newValue.utf8Code
            } else {
                _valuePtr.setStringUtf8ByteCount(to: 0, endianness)
            }
        }
    }
}


/// A wrapper for a swift String that stores the UTF8 byte code of a string.

public struct BRString {
    
    
    /// The UTF8 code of a string.
    
    public let utf8Code: Data
    
    
    /// The string value of the UTF8 code.
    
    public var string: String? { return String(data: utf8Code, encoding: .utf8) }
    
    
    /// Create a new BRString if possible, only fails if the String cannot be converted into UTF8 code.
    
    public init?(_ str: String?) {
        guard let code = str?.data(using: .utf8) else { return nil }
        utf8Code = code
    }
    
    
    /// Create a new BRString from raw data.
    
    internal init(_ data: Data) {
        utf8Code = data
    }
}


/// Add the equatable protocol

extension BRString: Equatable {
    
    
    /// Implements the Equatable protocol

    public static func == (lhs: BRString, rhs: BRString) -> Bool {
        return lhs.utf8Code == rhs.utf8Code
    }
}


/// Adds the Coder protocol

extension BRString: Coder {
    

    /// Implementation of the `Coder` protocol

    public var itemType: ItemType { return ItemType.string }

    
    /// Implementation of the `Coder` protocol

    public var valueByteCount: Int { return stringUtf8CodeOffset + utf8Code.count }

    
    /// Implementation of the `Coder` protocol

    public func copyBytes(to ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {
        ptr.setStringUtf8Code(to: utf8Code, endianness)
    }
}
