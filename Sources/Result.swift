//
//  Result.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 18/01/18.
//
//

import Foundation


public enum Result: Int {

    case success = 0
//    case wrongType = 1
    case outOfStorage = 2
    case dataInconsistency = 3
    case onlySupportedOnArray = 4
    case indexBelowLowerBound = 5
    case indexAboveHigherBound = 6
    case onlySupportedOnDictionary = 7
    case itemNotFound = 8
    case noManager = 9
    case increaseFailed = 10
    case illegalNameField = 11
    case typeConflict = 12
    
    public var description: String {
        switch self {
        case .success: return "Succesful execution"
//        case .wrongType: return "Wrong type"
        case .outOfStorage: return "Out of storage"
        case .dataInconsistency: return "Data inconsistency"
        case .onlySupportedOnArray: return "Operation only supported on arrays"
        case .indexBelowLowerBound: return "Index below lower bound"
        case .indexAboveHigherBound: return "Index above higher bound"
        case .onlySupportedOnDictionary: return "Operation only supported on dictionaries"
        case .itemNotFound: return "Item not found"
        case .noManager: return "No manager available"
        case .increaseFailed: return "Memory increase failed"
        case .illegalNameField: return "Illegal name field values"
        case .typeConflict: return "Type conflict"
        }
    }
}