//
//  Item-Subscript-Dictionary.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 21/01/18.
//
//

import Foundation

extension Item {
    
    subscript(name: String) -> ItemProtocol? { get }
    
    subscript(name: String) -> Bool { get set }
    subscript(name: String) -> UInt8 { get set }
    subscript(name: String) -> UInt16 { get set }
    subscript(name: String) -> UInt32 { get set }
    subscript(name: String) -> UInt64 { get set }
    subscript(name: String) -> Int8 { get set }
    subscript(name: String) -> Int16 { get set }
    subscript(name: String) -> Int32 { get set }
    subscript(name: String) -> Int64 { get set }
    subscript(name: String) -> Float32 { get set }
    subscript(name: String) -> Float64 { get set }
    subscript(name: String) -> String { get set }
    subscript(name: String) -> Data { get set }

}
