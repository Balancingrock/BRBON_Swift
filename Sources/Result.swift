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
    case typeConflict = 1
    case outOfStorageSpace = 2
    case brbonBytesToDataFailed = 3
    case indexOutOfHighLimit = 4
    case elementToLarge = 5
    case indexLessThanZero = 6
    
    public var description: String {
        switch self {
        case .success: return "Succesful execution"
        case .typeConflict: return "Type conflict"
        case .outOfStorageSpace: return "Out of storage space"
        case .brbonBytesToDataFailed: return "The conversion to data for the brbon item failed"
        case .indexOutOfHighLimit: return "The index is above the high limit"
        case .elementToLarge: return "The element is larger than its value field"
        case .indexLessThanZero: return "Index below zero"
        }
    }
}
