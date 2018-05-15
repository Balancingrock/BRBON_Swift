// =====================================================================================================================
//
//  File:       Results.swift
//  Project:    BRBON
//
//  Version:    0.4.2
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
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation


/// Results for some of the operations provided by the API

public enum Result: Int {

    case success = 0
    case nameFieldError = 1
    case outOfStorage = 2
    case dataInconsistency = 3
    case indexBelowLowerBound = 5
    case indexAboveHigherBound = 6
    case itemNotFound = 8
    case missingCoder = 9
    case increaseFailed = 10
    case illegalNameField = 11
    case typeConflict = 12
    case operationNotSupported = 13
    case arrayMustContainAnElement = 14
    case valueByteCountTooLarge = 15
    case valueByteCountTooSmall = 16
    case cannotConvertStringToUtf8 = 17
    case notAnArray = 18
    case allDictionaryKeysMustBeString = 19
    case emptyKey = 20
    case portalInvalid = 21
    case invalidTableColumnType = 22
    case columnNotFound = 23
    case nameExists = 24
    case illegalAmount = 25
    case missingName = 26
    case noNameAllowed = 27
    
    public var description: String {
        switch self {
        case .success: return "Succesful execution"
        case .nameFieldError: return "Name field error"
        case .outOfStorage: return "Out of storage"
        case .dataInconsistency: return "Data inconsistency"
        case .indexBelowLowerBound: return "Index below lower bound"
        case .indexAboveHigherBound: return "Index above higher bound"
        case .itemNotFound: return "Item not found"
        case .missingCoder: return "Missing Coder"
        case .increaseFailed: return "Memory increase failed"
        case .illegalNameField: return "Illegal name field values"
        case .typeConflict: return "Type conflict"
        case .operationNotSupported: return "Operation not supported"
        case .arrayMustContainAnElement: return "Array must contain an element"
        case .valueByteCountTooLarge: return "Value byte count too large"
        case .valueByteCountTooSmall: return "Value byte count to small"
        case .cannotConvertStringToUtf8: return "Cannot convert string to UTF8"
        case .notAnArray: return "Not an array"
        case .allDictionaryKeysMustBeString: return "All dictionary keys must be strings"
        case .emptyKey: return "Empty key"
        case .portalInvalid: return "Portal invalid"
        case .invalidTableColumnType: return "Invalid Table Column Type"
        case .columnNotFound: return "Column Not Found"
        case .nameExists: return "Name exists"
        case .illegalAmount: return "Illegal amount"
        case .missingName: return "Missing name"
        case .noNameAllowed: return "Name not allowed"
        }
    }
}
