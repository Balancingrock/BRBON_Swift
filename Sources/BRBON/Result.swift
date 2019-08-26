// =====================================================================================================================
//
//  File:       Results.swift
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
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation


/// Results for some of the operations provided by the API

public enum ErrorCode: Int, CustomStringConvertible {

    
    /// Generated if a NameField could not be created
    
    case nameFieldError = 1
    
    
    /// Generated if an attempt is made to increase the storage area of a non-container item
    
    case outOfStorage = 2
    
    
    /// Generated if an attempt is made to add a non-container item manager to a table
    
    case dataInconsistency = 3
    
    
    /// Generated if an index is lower than zero
    
    case indexBelowLowerBound = 5
    
    
    /// Generated if an index is >= count
    
    case indexAboveHigherBound = 6
    
    
    /// Generated if no item can be found with the given name
    
    case itemNotFound = 8
    
    
    /// Generated if an optional input value should have had a value
    
    case missingValue = 9
    
    
    /// Generated if it was necessary to increase a item's size, but this was not possible
    
    case increaseFailed = 10
    
    
    /// Not used
    
    case illegalNameField = 11
    
    
    /// Generated if an attempt is made to change the type in an item or element
    
    case typeConflict = 12
    
    
    /// Generated if an operation is attemped on a type that does not support it
    
    case operationNotSupported = 13
    
    
    /// Not used
    
    case arrayMustContainAnElement = 14
    
    
    /// Not used
    
    case valueByteCountTooLarge = 15
    
    
    /// Not used
    
    case valueByteCountTooSmall = 16
    
    
    /// Not used
    
    case cannotConvertStringToUtf8 = 17
    
    
    /// Not used
    
    case notAnArray = 18
    
    
    /// Not used
    
    case allDictionaryKeysMustBeString = 19
    
    
    /// Not used
    
    case emptyKey = 20
    
    
    /// Generated when an attempt is made to use an invalid portal
    
    case portalInvalid = 21
    
    
    /// Generated if a table column descriptor could not be constructed from the memory contents
    
    case invalidTableColumnType = 22
    
    
    /// Generated if a column was not present in the table
    
    case columnNotFound = 23
    
    
    /// Generated if table does not contain a column with the given name
    
    case nameExists = 24
    
    
    /// Generated if an amount specified cannot be valid (either nagative or < Int32'max)
    
    case illegalAmount = 25
    
    
    /// Generated if a namefield could not be created
    
    case missingName = 26
    
    
    /// Not used
    
    case noNameAllowed = 27
    
    
    /// Generated if an amount is larger than Int32.max
    
    case itemByteCountOutOfRange = 28
    
    
    /// Generated if a memory content cannot be converted to a type indicator
    
    case illegalTypeFieldValue = 29
    
    
    /// Generated if the index is missing from a table field portal
    
    case missingIndex = 30
    
    
    /// Generated if the column is missing from a table field portal
    
    case missingColumn = 31
    
    
    /// Returns a string describing the enum
    
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


/// The result from some BRBON functions

public enum Result: CustomStringConvertible, Equatable {

    
    /// The operation succeeded
    
    case success
    
    
    /// If no action could be taken or was taken
    
    case noAction
    
    
    /// An error condition occured
    
    case error(ErrorCode)
    
    
    /// The CustomStringConvertible protocol
    
    public var description: String {
        switch self {
        case .success: return "Succesful execution"
        case .noAction: return "There was no error, but nothing was done either"
        case .error(let code): return "En error occured, code = \(code)"
        }
    }
    
    
    /// The Equatable protocol
    
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

