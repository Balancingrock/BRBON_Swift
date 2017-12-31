//
//  Protocol.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 25/12/17.
//
//

import Foundation
import BRUtils

internal typealias BrbonData = UnsafeMutableRawBufferPointer

internal enum DoesItFit { case fits, nameDoesNotFit, payloadDoesNotFit, itemDoesNotFit }

internal extension EndianBytes {
    
    
    /// Returns the value of this type encoded as a BRBON-Item.
    ///
    /// - Parameters:
    ///   - endianness: The endianness to be used to encode the contents.
    ///   - name: If present, the name used in the Item. Otherwise the Item name is empty. Note that the Item name is supposed to be convertible to an UTF8 byte code sequence. If that is not possible a nil must be returned.
    ///   - nameBytes: The number of bytes to use/reserve for a name. The name area will always be a multiple of 8 bytes, hence the actually available size may be a little larger than specified here. The maximum size is 245 bytes. If the given name is larger than can be fitted, a nil will be returned.
    ///   - payloadBytes: The number of bytes to use/reserve for the amount of data that can be stored in this item. The actual size will always be a multiple of 8 and hence may be a little larger than specified here. If this is too smal for self, then nil will be returned.
    ///
    /// - Returns: Nil if the conversion could not be made. On succes: An UnsafeMutableRawBufferPointer with the encoded version of self. Note that the callee owns the buffer and is responsable for its deallocation.
    
    func brbonItem(_ endianness: Endianness, name: String?, nameBytes: UInt8?, payloadBytes: UInt32?) -> BrbonData? {
        
            
        // Determine the size of the memory area that is needed
        
        var memsize: UInt32 = 8 // Item header & NVR Length
        
        
        // Prepare the name for inclusion
        
        guard let itemName = itemNameData(name, nameBytes, endianness) else { return nil }
        
        memsize += UInt32(itemName.count)
        
        
        // Get the size for the payload
        
        guard let pSize = payloadSize(endianCount(), payloadBytes) else { return nil }
        
        memsize += pSize
        
        
        // Allocate the buffer
        
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: Int(memsize))
        var itemPtr = buffer.baseAddress!
        
        
        // Add the item header & NVR length
        
        addItemHeader(&itemPtr, endianness: endianness, type: .uint8, itemName: itemName, payloadSize: pSize)
        
        
        // Add payload
        
        endianBytes(endianness, toPointer: &itemPtr)
        
        
        // Add reserved area (if any)
        
        let reserved = Int(memsize) - buffer.baseAddress!.distance(to: itemPtr)
        if reserved > 0 {
            Data(count: reserved).endianBytes(endianness, toPointer: &itemPtr)
        }
        
        return buffer
    }
    
    
    func addBrbonItem(_ endianness: Endianness, name: String?, nameBytes: UInt8?, payloadBytes: UInt32?, destinationPtr: inout UnsafeMutableRawPointer, maxBytes: UInt32) -> DoesItFit {
        
        
        // Keep the original pointer value
        
        let originalPtr = destinationPtr
        
        
        // Determine the size of the memory area that is needed
        
        var memsize: UInt32 = 8 // Item header & NVR Length
        
        
        // Prepare the name for inclusion
        
        guard let itemName = itemNameData(name, nameBytes, endianness) else { return .nameDoesNotFit }
        
        memsize += UInt32(itemName.count)
        
        
        // Get the size for the payload
        
        guard let pSize = payloadSize(endianCount(), payloadBytes) else { return .payloadDoesNotFit }
        
        memsize += pSize
        
        
        // Allocate the buffer
        
        if memsize > maxBytes { return .itemDoesNotFit }

        
        // Add the item header & NVR length
        
        addItemHeader(&destinationPtr, endianness: endianness, type: .uint8, itemName: itemName, payloadSize: pSize)
        
        
        // Add payload
        
        endianBytes(endianness, toPointer: &destinationPtr)
        
        
        // Add reserved area (if any)
        
        let reserved = Int(memsize) - originalPtr.distance(to: destinationPtr)
        if reserved > 0 {
            Data(count: reserved).endianBytes(endianness, toPointer: &destinationPtr)
        }
        
        return .fits
    }
}


/// - Returns: The name data, or nil on failure.

internal func itemNameData(_ name: String?, _ nameBytes: UInt8?, _ endianness: Endianness) -> Data? {

    var data = Data()

    
    // Processing for when a name is present
    
    if let name = name {
        
        if let nameBytes = nameBytes { guard nameBytes <= 245 else { return nil } }
        guard let nameData = name.data(using: .utf8), nameData.count <= 245 else { return nil }
        if let nameBytes = nameBytes { guard nameBytes >= UInt8(nameData.count) else { return nil } }
            
        data.append(nameData.crc16().endianBytes(endianness))
        data.append(UInt8(nameData.count).endianBytes(endianness))
        data.append(nameData)
            
        if let nameBytes = nameBytes {
            data.append(Data(count: Int(nameBytes) - nameData.count))
        }
        
    } else {
    
        // Processing without name, but with a reserved namespace
    
        if let nameBytes = nameBytes {
            guard nameBytes <= 245 else { return nil }
            data = Data(count: Int(nameBytes) + 3) // crc16 and name size are set to zero
        }
    }
    
    // Round up to next multiple of 8
    
    let roundUp = data.count & 0xFFFF_FFF8
    if roundUp != 0 { data.append(Data(count: 8 - roundUp)) }
    
    return data
}


/// - Returns the size of the payload area, including the reserved are (if any)

internal func payloadSize(_ selfBytes: UInt32, _ requestedBytes: UInt32?) -> UInt32? {
    var pSize = selfBytes
    if let requestedBytes = requestedBytes {
        guard pSize <= requestedBytes else { return nil }
        pSize = requestedBytes
    }
    if pSize & 7 != 0 {
        pSize = (pSize & 0xFFFF_FFF8) + 8
    }
    return pSize
}

internal func addItemHeader(_ ptr: inout UnsafeMutableRawPointer, endianness: Endianness, type: ItemType, itemName: Data, payloadSize: UInt32) {
    type.rawValue.endianBytes(.little, toPointer: &ptr)
    UInt16(0).endianBytes(.little, toPointer: &ptr) // Options & Flags
    UInt8(itemName.count).endianBytes(.little, toPointer: &ptr)
    (UInt32(itemName.count) + payloadSize).endianBytes(endianness, toPointer: &ptr)
    if itemName.count > 0 { itemName.endianBytes(endianness, toPointer: &ptr) }
}
