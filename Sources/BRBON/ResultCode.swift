// =====================================================================================================================
//
//  File:       Results.swift
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
// 1.3.0 - Renamed Result to ResultCode to avoid confusion due to Swift's Result type
//       - Symplified the ResultCode to make it easier to use.
// 1.0.1 - Documentation update
// 1.0.0 - Removed older history
//
// =====================================================================================================================

import Foundation


/// Results for some of the operations provided by the API

public enum ResultCode: CustomStringConvertible {

    
    /// The action concluded sucessfully
    
    case success
    
    
    /// No action was taken, no error occured
    
    case noAction
    
    
    /// Generated if a NameField could not be created
    
    case nameFieldError
    
    
    /// Generated if an attempt is made to increase the storage area of a non-container item
    
    case outOfStorage
    
    
    /// Generated if an attempt is made to add a non-container item manager to a table
    
    case dataInconsistency
    
    
    /// Generated if an index is lower than zero
    
    case indexBelowLowerBound
    
    
    /// Generated if an index is >= count
    
    case indexAboveHigherBound
    
    
    /// Generated if no item can be found with the given name
    
    case itemNotFound
    
    
    /// Generated if an optional input value should have had a value
    
    case missingValue
    
    
    /// Generated if it was necessary to increase a item's size, but this was not possible
    
    case increaseFailed
    
    
    /// Not used
    
    case illegalNameField
    
    
    /// Generated if an attempt is made to change the type in an item or element
    
    case typeConflict
    
    
    /// Generated if an operation is attemped on a type that does not support it
    
    case operationNotSupported
    
    
    /// Not used
    
    case arrayMustContainAnElement
    
    
    /// Not used
    
    case valueByteCountTooLarge
    
    
    /// Not used
    
    case valueByteCountTooSmall
    
    
    /// Not used
    
    case cannotConvertStringToUtf8
    
    
    /// Not used
    
    case notAnArray
    
    
    /// Not used
    
    case allDictionaryKeysMustBeString
    
    
    /// Not used
    
    case emptyKey
    
    
    /// Generated when an attempt is made to use an invalid portal
    
    case portalInvalid
    
    
    /// Generated if a table column descriptor could not be constructed from the memory contents
    
    case invalidTableColumnType
    
    
    /// Generated if a column was not present in the table
    
    case columnNotFound
    
    
    /// Generated if table does not contain a column with the given name
    
    case nameExists
    
    
    /// Generated if an amount specified cannot be valid (either nagative or < Int32'max)
    
    case illegalAmount
    
    
    /// Generated if a namefield could not be created
    
    case missingName
    
    
    /// Not used
    
    case noNameAllowed
    
    
    /// Generated if an amount is larger than Int32.max
    
    case itemByteCountOutOfRange
    
    
    /// Generated if a memory content cannot be converted to a type indicator
    
    case illegalTypeFieldValue
    
    
    /// Generated if the index is missing from a table field portal
    
    case missingIndex
    
    
    /// Generated if the column is missing from a table field portal
    
    case missingColumn
    
    
    /// Returns a string describing the enum
    
    public var description: String {
        switch self {
        case .success: return "Success"
        case .noAction: return "No action was taken"
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
        case .missingColumn: return "Missing column"
        }
    }
}
