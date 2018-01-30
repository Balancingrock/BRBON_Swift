//
//  Item-Children.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 22/01/18.
//
//

import Foundation
import BRUtils


extension Item {
    
    
    /// The closure is called for each child item or until the closure returns true.
    ///
    /// - Parameter closure: The closure that is called for each item in the dictionary. If the closure returns true then the processing of further items is aborted.
    
    internal func forEachAbortOnTrue(_ closure: (Item) -> Bool) {
        if isArray {
            let elementPtr = valuePtr.advanced(by: 8)
            let nofChildren = Int(count)
            var index = 0
            let ebc = Int(elementByteCount)
            while index < nofChildren {
                let item = Item(basePtr: elementPtr.advanced(by: index * ebc), parentPtr: basePtr, endianness: endianness)
                if closure(item) { return }
                index += 1
            }
            return
        }
        if isDictionary {
            var itemPtr = valuePtr
            var remainder = count
            while remainder > 0 {
                let item = Item(basePtr: itemPtr, parentPtr: basePtr, endianness: endianness)
                if closure(item) { return }
                itemPtr = itemPtr.advanced(by: Int(item.byteCount))
                remainder -= 1
            }
        }
    }

}
