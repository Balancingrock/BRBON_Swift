//
//  Item-Sequence.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 10/11/17.
//
//

import Foundation

extension Item {
    
    
    /// Creates a new Item of the sequence type.
    
    public static func sequence(_ name: String? = nil, fixedByteCount: UInt32? = nil) -> Item? {
        
        
        // Make sure the fixedByteCount is within limits
        
        if let fixedByteCount = fixedByteCount, fixedByteCount > UInt32(Int32.max) { return nil }
        
        
        // Create value wrapper
        
        let itemValue = ItemValue(sequence: [])
        
        
        // Create the item name (if any)
        
        var itemName: ItemName?
        
        if let name = name {
            guard let n = ItemName(name) else { return nil }
            itemName = n
        }
        
        
        // Create new Item referencing the created item value
        
        return self.init(itemValue, name: itemName, fixedByteCount: fixedByteCount)
    }


    /// Returns true if the Item is a sequence type
    
    public var isSequence: Bool { return type == .sequence }
}
