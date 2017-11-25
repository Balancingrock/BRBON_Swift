// =====================================================================================================================
//
//  File:       Item-PipeOperator.swift
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


/// Interrogate an Item for the existence of a child item with the given name. Has no side effects
///
/// - Parameters:
///   - lhs: The Item to interrogate
///   - rhs: The name of the sought after item
///
/// - Returns: Either the sought after item or nil if it does not exist.

public func | (lhs: Item?, rhs: String?) -> Item? {
    guard let lhs = lhs else { return nil }
    guard let rhs = rhs else { return nil }
    if lhs.type == .dictionary {
        return lhs.item(for: rhs)
    } else {
        return nil
    }
}


/// Interrogate an Item object for the existence of a child item at the given index. Has no side effects
///
/// - Parameters:
///   - lhs: The Item to interrogate
///   - rhs: The index of the sought after item
///
/// - Returns: Either the sought after item or nil if it does not exist.

public func | (lhs: Item?, rhs: Int?) -> Item? {
    guard let lhs = lhs else { return nil }
    guard let rhs = rhs else { return nil }
    guard lhs.type == .array else { return nil }
    guard rhs < (lhs.count ?? 0) else { return nil }
    return lhs._value.array[rhs]
}
