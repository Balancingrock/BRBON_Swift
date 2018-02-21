//
//  Array-BrbonCoder.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 09/02/18.
//
//

import Foundation
import BRUtils


internal class BrbonArray: Coder, IsBrbon {

    init(content: Array<Coder>, type: ItemType, elementByteCount: Int? = nil) {
        self.content = content
        self.elementType = type
        self.elementValueByteCount = elementByteCount
    }
    
    let content: Array<Coder>
    
    
    /// The BRBON Item type of the item this value will be stored into.
    
    var brbonType: ItemType { return ItemType.array }
    
    let elementType: ItemType
    
    let elementValueByteCount: Int?
    
    
    /// The number of bytes needed to encode self into an BrbonBytes stream.
    
    var valueByteCount: Int {
        switch elementType {
        case .null: return 8
        case .bool, .int8, .uint8: return content.count + 8
        case .int16, .uint16: return content.count * 2 + 8
        case .int32, .uint32, .float32: return content.count * 4 + 8
        case .int64, .uint64, .float64: return content.count * 8 + 8
        case .string, .binary, .array, .dictionary, .sequence:
            var ebc = elementValueByteCount ?? 0
            content.forEach(){
                let bc = $0.elementByteCount
                if bc > ebc { ebc = bc }
            }
            return (content.count * ebc + 8)
        }
    }
    
    func itemByteCount(_ nfd: NameFieldDescriptor? = nil) -> Int {
        return minimumItemByteCount + (nfd?.byteCount ?? 0) + valueByteCount.roundUpToNearestMultipleOf8()
    }
    
    var elementByteCount: Int {
        return minimumItemByteCount + valueByteCount.roundUpToNearestMultipleOf8()
    }
    
    
    /// Stores the value without any other information in the memory area pointed at.
    ///
    /// - Parameters:
    ///   - atPtr: The pointer at which the first byte will be stored. On return the pointer will be incremented for the number of bytes stored.
    ///   - endianness: Specifies the endianness of the bytes.
    
    @discardableResult
    func storeValue(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        fatalError("Do not use 'storeValue', use 'storeAsItem' instead.")
    }
    
    
    /// Create an array item of the contents of this array.
    ///
    /// - Note: The array may not be empty!
    
    @discardableResult
    func storeAsItem(
        atPtr: UnsafeMutableRawPointer,
        bufferPtr: UnsafeMutableRawPointer,
        parentPtr: UnsafeMutableRawPointer,
        nameField nfd: NameFieldDescriptor? = nil,
        valueByteCount: Int? = nil,
        _ endianness: Endianness) -> Result {
        
        
        // Number of bytes of the complete item
        
        var itemBC = self.itemByteCount(nfd)
        

        // Number of bytes in the name field
        
        let nameFieldByteCount = nfd?.byteCount ?? 0
        

        // Number of bytes in the element
        
        var elemBC: Int

        switch elementType {
        case .null: elemBC = 0
        case .bool, .int8, .uint8: elemBC = 1
        case .int16, .uint16: elemBC = 2
        case .int32, .uint32, .float32: elemBC = 4
        case .int64, .uint64, .float64: elemBC = 8
        case .string, .binary, .array, .dictionary, .sequence:
            var ebc = elementValueByteCount ?? 0
            content.forEach(){
                let bc = $0.elementByteCount
                if bc > ebc { ebc = bc }
            }
            elemBC = ebc
        }

        if elemBC == 0 { elemBC = elementType.assumedValueByteCount }
        
        if let valueByteCount = valueByteCount {
            
            
            // Range limit
            
            guard valueByteCount <= Int(Int32.max) else { return .valueByteCountTooLarge }
            
            
            // If specified, the fixed item length must be large enough (add the 8 overhead bytes as that is unknown to the API user)
            
            guard (valueByteCount + 8) >= (itemBC - minimumItemByteCount - nameFieldByteCount) else { return .valueByteCountTooSmall }
            
            
            // Use the fixed value byte count, but ensure that it is a multiple of 8 bytes.
            
            itemBC = (minimumItemByteCount + (nfd?.byteCount ?? 0) + 8 + valueByteCount).roundUpToNearestMultipleOf8()
        }
        
        
        // Create the array structure
        
        ItemType.array.storeValue(atPtr: atPtr.brbonItemTypePtr)
        
        ItemOptions.none.storeValue(atPtr: atPtr.brbonItemOptionsPtr)
        
        ItemFlags.none.storeValue(atPtr: atPtr.brbonItemFlagsPtr)
        
        UInt8(nameFieldByteCount).storeValue(atPtr: atPtr.brbonItemNameFieldByteCountPtr, endianness)
        
        UInt32(itemBC).storeValue(atPtr: atPtr.brbonItemByteCountPtr, endianness)
        
        UInt32(bufferPtr.distance(to: parentPtr)).storeValue(atPtr: atPtr.brbonItemParentOffsetPtr, endianness)
        
        UInt32(content.count).storeValue(atPtr: atPtr.brbonItemCountValuePtr, endianness)
        
        nfd?.storeValue(atPtr: atPtr.brbonItemNameFieldPtr, endianness)
        
        
        // Element spec
        
        UInt32(0).storeValue(atPtr: atPtr.brbonArrayElementTypePtr, endianness)

        elementType.storeValue(atPtr: atPtr.brbonArrayElementTypePtr)
        
        
        // Element bytecount
        
        UInt32(elemBC).storeValue(atPtr: atPtr.brbonArrayElementByteCountPtr, endianness)
        
        
        // Elements
        
        var p = atPtr.brbonArrayElementsBasePtr
        
        content.forEach({
            
            switch $0.brbonType {
            case .null: break
            case .bool, .int8, .int16, .int32, .int64, .uint8, .uint16, .uint32, .uint64, .float32, .float64, .string, .binary:
                $0.storeAsElement(atPtr: p, endianness)
            case .array, .dictionary, .sequence:
                $0.storeAsItem(atPtr: p, bufferPtr: bufferPtr, parentPtr: atPtr, nameField: nil, valueByteCount: nil, endianness)
            }
            
            let remainder = elemBC - $0.elementByteCount
            if remainder > 0 {
                Data(count: remainder).storeValue(atPtr: p.advanced(by: $0.elementByteCount), endianness)
            }
            
            p = p.advanced(by: elemBC)
        })
        
        
        // Filler
        
        let remainder = itemBC - atPtr.distance(to: p)
        if remainder > 0 {
            Data(count: remainder).storeValue(atPtr: p, endianness)
        }
        
        
        // Success
        
        return .success
    }
    
    @discardableResult
    func storeAsElement(atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) -> Result {
        fatalError("Do not use 'storeAsElement', use 'storeAsItem' instead")
    }
}

