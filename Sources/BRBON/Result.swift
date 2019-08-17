// =====================================================================================================================
//
//  File:       Results.swift
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


/// Results for some of the operations provided by the API

public enum ErrorCode: Int, CustomStringConvertible {

    case nameFieldError = 1
    case outOfStorage = 2
    case dataInconsistency = 3
    case indexBelowLowerBound = 5
    case indexAboveHigherBound = 6
    case itemNotFound = 8
    case missingValue = 9
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
    case itemByteCountOutOfRange = 28
    case illegalTypeFieldValue = 29
    case missingIndex = 30
    case missingColumn = 31
    
    public var description: String {
        switch self {
        case .nameFieldError: return "Name field error"
        case .outOfStorage: return "Out of storage"
        case .dataInconsistency: return "Data inconsistency"
        case .indexBelowLowerBound: return "Index below lower bound"
        case .indexAboveHigherBound: return "Index above higher bound"
        case .itemNotFound: return "Item not found"
        case .missingValue: return "Missing Value"
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
        case .itemByteCountOutOfRange: return "Item byte count out of range"
        case .illegalTypeFieldValue: return "Illegal type field value"
        case .missingIndex: return "Missing index"
        case .missingColumn: return "MIssing column"
        }
    }
}

public enum Result: CustomStringConvertible, Equatable {
    
    case success
    case noAction
    case error(ErrorCode)
    
    public var description: String {
        switch self {
        case .success: return "Succesful execution"
        case .noAction: return "There was no error, but nothing was done either"
        case .error(let code): return "En error occured, code = \(code)"
        }
    }
    
    public static func == (lhs: Result, rhs: Result) -> Bool {
        switch lhs {
        case .success:
            switch rhs {
            case .success: return true
            default: return false
            }
        case .noAction:
            switch rhs {
            case .noAction: return true
            default: return false
            }
        case .error(let lcode):
            if case let .error(rcode) = rhs { return lcode == rcode }
            return false
        }
    }
}

