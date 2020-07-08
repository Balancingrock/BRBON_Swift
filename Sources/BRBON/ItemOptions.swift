// =====================================================================================================================
//
//  File:       ItemOptions
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
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation
import BRUtils


/// The options for an item.

public enum ItemOptions: UInt8 {
    
    
    /// Unused
    
    case none = 0
    

    /// Creates a new enum with the contents from the given memory location

    public init?(atPtr: UnsafeMutableRawPointer) {
        self.init(rawValue: atPtr.assumingMemoryBound(to: UInt8.self).pointee)
    }
    
    internal func copyBytes(to ptr: UnsafeMutableRawPointer) {
        self.rawValue.copyBytes(to: ptr, machineEndianness)
    }
    
    internal static func readValue(atPtr: UnsafeMutableRawPointer) -> ItemOptions? {
        return self.init(atPtr: atPtr)
    }
}
