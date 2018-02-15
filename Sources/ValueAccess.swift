//
//  ValueAccess.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 14/02/18.
//
//

import Foundation

public protocol ValueAccess {
    
    var isNull: Bool { get }
    
    var isBool: Bool { get }
    
    var isUInt8: Bool { get }
    
    var isUInt16: Bool { get }
    
    var isUInt32: Bool { get }
    
    var isUInt64: Bool { get }
    
    var isInt8: Bool { get }
    
    var isInt16: Bool { get }
    
    var isInt32: Bool { get }
    
    var isInt64: Bool { get }
    
    var isFloat32: Bool { get }
    
    var isFloat64: Bool { get }
    
    var isString: Bool { get }
    
    var isBinary: Bool { get }
    
    var isArray: Bool { get }
    
    var isDictionary: Bool { get }
    
    var isSequence: Bool { get }

    
    var null: Bool? { get set }
    
    var bool: Bool? { get set }
    
    var uint8: UInt8? { get set }
    
    var uint16: UInt16? { get set }
    
    var uint32: UInt32? { get set }
    
    var uint64: UInt64? { get set }
    
    var int8: Int8? { get set }
    
    var int16: Int16? { get set }
    
    var int32: Int32? { get set }
    
    var int64: Int64? { get set }
    
    var float32: Float32? { get set }
    
    var float64: Float64? { get set }
    
    var string: String? { get set }
    
    var binary: Data? { get set }
}
