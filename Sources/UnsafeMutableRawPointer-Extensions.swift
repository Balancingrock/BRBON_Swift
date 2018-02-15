//
//  UnsafeMutableRawPointer-Extensions.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 15/02/18.
//
//

import Foundation


// Offsets in the item data structure

internal let itemTypeOffset = 0
internal let itemOptionsOffset = 1
internal let itemFlagsOffset = 2
internal let itemNameFieldByteCountOffset = 3
internal let itemByteCountOffset = 4
internal let itemParentOffsetOffset = 8
internal let itemCountValueOffset = 12
internal let itemNvrFieldOffset = 16

// Offsets in the NVR field data structure

internal let nameFieldOffset = itemNvrFieldOffset
internal let nameHashOffset = nameFieldOffset + 0
internal let nameCountOffset = nameFieldOffset + 2
internal let nameDataOffset = nameFieldOffset + 3


extension UnsafeMutableRawPointer {
    
    
    /// Returns a pointer to the ItemType byte of an item.
    ///
    /// - Note: Self must point to the first byte of an item.
    
    var brbonItemTypePtr: UnsafeMutableRawPointer {
        return self
    }
    
    
    /// Returns a pointer to the ItemOptions byte of an item.
    ///
    /// - Note: Self must point to the first byte of an item.
    
    var brbonItemOptionsPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemOptionsOffset)
    }
    
    
    /// Returns a pointer to the ItemFlags byte of an item.
    ///
    /// - Note: Self must point to the first byte of an item.
    
    var brbonItemFlagsPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemFlagsOffset)
    }
    
    
    /// Returns a pointer to the byte count of the name field of an item.
    ///
    /// - Note: Self must point to the first byte of an item.
    
    var brbonItemNameFieldByteCountPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemNameFieldByteCountOffset)
    }
    
    
    /// Returns a pointer to the byte count of the item.
    ///
    /// - Note: Self must point to the first byte of an item.
    
    var brbonItemByteCountPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemByteCountOffset)
    }

    
    /// Returns a pointer to the parent offset in the item.
    ///
    /// - Note: Self must point to the first byte of an item.

    var brbonItemParentOffsetPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemParentOffsetOffset)
    }
    
    
    /// Returns a pointer to the count/value in/of the item.
    ///
    /// - Note: Self must point to the first byte of an item.

    var brbonItemCountValuePtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemCountValueOffset)
    }
    
    
    /// Returns a pointer to the namefield in the item.
    ///
    /// - Note: Self must point to the first byte of an item.

    var brbonItemNameFieldPtr: UnsafeMutableRawPointer {
        return self.advanced(by: nameFieldOffset)
    }
    
    
    /// Returns a pointer to the hash value in the namefield of the item.
    ///
    /// - Note: Self must point to the first byte of an item.

    var brbonItemNameHashPtr: UnsafeMutableRawPointer {
        return self.advanced(by: nameHashOffset)
    }
    
    
    /// Returns a pointer to the count in the namefield for the number of bytes in the name of the item.
    ///
    /// - Note: Self must point to the first byte of an item.
    
    var brbonItemNameCountPtr: UnsafeMutableRawPointer {
        return self.advanced(by: nameCountOffset)
    }
    
    
    /// Returns a pointer to the first byte of the UTF8 byte codes of the name of the item.
    ///
    /// - Note: Self must point to the first byte of an item.

    var brbonItemNameDataPtr: UnsafeMutableRawPointer {
        return self.advanced(by: nameDataOffset)
    }
    
    
    /// Returns a pointer to the first byte of the value of the item.
    ///
    /// - Note: Self must point to the first byte of an item.

    var brbonItemValuePtr: UnsafeMutableRawPointer {
        let t = self.assumingMemoryBound(to: UInt8.self).pointee
        if (t & useCountValueAsValueMask) != 0 {
            return self.advanced(by: itemCountValueOffset)
        } else {
            let nameFieldByteCount = self.advanced(by: itemNameFieldByteCountOffset).assumingMemoryBound(to: UInt8.self).pointee
            return self.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount))
        }
    }

    
    /// Returns a pointer to the byte count of the elements in an array.
    ///
    /// - Note: Self must point to the first byte of an array item.

    var brbonArrayElementByteCountPtr: UnsafeMutableRawPointer {
        let nameFieldByteCount = self.advanced(by: itemNameFieldByteCountOffset).assumingMemoryBound(to: UInt8.self).pointee
        return self.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount) + 4)
    }
    
    
    /// Returns a pointer to the ItemType byte that identifies the type of elements in the array.
    ///
    /// - Note: Self must point to the first byte of an array item.
    
    var brbonArrayElementTypePtr: UnsafeMutableRawPointer {
        let nameFieldByteCount = self.advanced(by: itemNameFieldByteCountOffset).assumingMemoryBound(to: UInt8.self).pointee
        return self.advanced(by: itemNvrFieldOffset + Int(nameFieldByteCount))
    }
}
