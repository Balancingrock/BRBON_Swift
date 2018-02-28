//
//  Portal-Sequence.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 28/02/18.
//
//

import Foundation
import BRUtils

extension Portal {
    
    
    /// Replaces the item at self.
    ///
    /// The item at self is replaced by the new value. The byte count will be preserved as is, or enlarged as necessary. If there is an existing name it will be preserved. If the new value is nil, the item will be converted into a null.
    
    internal func replaceWith(_ value: Coder?) -> Result {
        
        guard isValid else { return .portalInvalid }
        
        if let value = value {
            
            
            // Make sure the item byte count is big enough
            
            let necessaryItemByteCount = value.itemByteCount(nameFieldDescriptor)
            
            if itemByteCount < necessaryItemByteCount {
                let result = increaseItemByteCount(to: necessaryItemByteCount)
                guard result == .success else { return result }
            }
            
            
            // Create the new item, but remember the old size as it must be re-used
            
            let oldByteCount = itemByteCount
            
            
            // Write the new value as an item
            
            value.storeAsItem(atPtr: itemPtr, bufferPtr: manager.bufferPtr, parentPtr: parentPtr, nameField: nameFieldDescriptor, valueByteCount: nil, endianness)
            
            
            // Restore the old byte count
            
            itemByteCount = oldByteCount
            
            
            return .success
            
        } else {
            
            itemType = .null
            return .success
        }
    }
}
