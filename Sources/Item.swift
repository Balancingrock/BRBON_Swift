// =====================================================================================================================
//
//  File:       Item.swift
//  Project:    BRBON
//
//  Version:    0.1.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2017 Marinus van der Lugt, All rights reserved.
//
//  License:    Use or redistribute this code any way you like with the following two provision:
//
//  1) You ACCEPT this source code AS IS without any guarantees that it will work as intended. Any liability from its
//  use is YOURS.
//
//  2) You WILL NOT seek damages from the author or balancingrock.nl.
//
//  I also ask you to please leave this header with the source code.
//
//  I strongly believe that voluntarism is the way for societies to function optimally. Thus I have choosen to leave it
//  up to you to determine the price for this code. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  wishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to check the website http://www.balancingrock.nl before payment)
//
//  For private and non-profit use the suggested price is the price of 1 good cup of coffee, say $4.
//  For commercial use the suggested price is the price of 1 good meal, say $20.
//
//  You are however encouraged to pay more ;-)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// History
//
// 0.1.0  - Initial version
// =====================================================================================================================

import Foundation
import BRUtils


public final class Item: EndianBytes {
    
    
    /// The header of the item containing the type, options and name field length.
    
    internal var header: ItemHeader
    
    
    /// The name of this item, can be nil.
    
    internal var _name: ItemName? {
        didSet {
            if !header.options.fixedNameByteCount {
                header.nameLength = UInt8(nameByteCount)
            } else {
                assert(UInt8(nameByteCount) == header.nameLength)
            }
        }
    }
    
    
    /// The value of this item, may be nil even though it is force-unwrapped.
    
    internal var _value: ItemValue!

    
    /// The type of the Item
    
    public var type: ItemType { return _value.type }
    
    
    /// The parent of this item
    
    public internal(set) weak var parent: Item?
    
    
    /// The number of bytes needed to represent this item
    
    public var byteCount: UInt32 {
        if fixedItemByteCount != nil {
            return fixedItemByteCount!
        } else {
            var ctr: UInt32 = 8 // For header and nvrLength
            ctr += nameByteCount // Adding the name
            ctr += valueByteCount // Adding the value
            return ctr
        }
    }
    
    
    /// The number of bytes the name field will occupy
    
    public var nameByteCount: UInt32 {
        var usedBytes = _name?.byteCount ?? 0
        if (usedBytes & 0b0000_0111) != 0 { usedBytes = (usedBytes & 0b1111_1000) + 0b0000_1000 }
        if let fixedNameByteCount = fixedNameByteCount {
            return (usedBytes > fixedNameByteCount) ? UInt32(usedBytes) : UInt32(fixedNameByteCount)
        } else {
            return UInt32(usedBytes)
        }
    }
    
    
    /// The number of bytes the value field will occupy excluding reserved bytes, including filler bytes.
    
    public var valueByteCount: UInt32 {
        var usedBytes: UInt32 = _value?.byteCount ?? 0
        if (usedBytes & 0x0000_0007) != 0 { usedBytes = (usedBytes & 0xFFFF_FFF8) + 0x0000_0008 }
        return usedBytes
    }
    
    
    /// The number of unused bytes (value filler & reserved bytes) in the byte stream representation of this object.
    
    public var unusedByteCount: UInt32? {
        if let fixedItemByteCount = fixedItemByteCount {
            return fixedItemByteCount - 8 - nameByteCount - (_value?.byteCount ?? 0)
        } else {
            return nil
        }
    }
    
    
    /// The fixed byte count for the name of this item. This accessor cannot be used to reduce the size of an existing name. Make sure the name (plus 3 overhead bytes) fits the new size otherwise the write-accessor will fail.
    ///
    /// If this value is set, then the name field will have the exact size as specified. (Including hash and byte count = 3 bytes)
    ///
    /// The value must always be a multiple of 8. The valid range is 0 ... 248.
    ///
    /// Writing this value may fail, always use read-after-write to confirm that a new value was accepted. Causes for rejecting a new value may be: not a multiple of 8, the new value would truncate the existing name or the Item is contained in an array. (Array Items cannot have names)
    
    public var fixedNameByteCount: UInt8? {
        get {
            return header.options.fixedNameByteCount ? header.nameLength : nil
        }
        set {
            if let newValue = newValue {
                guard newValue >= (_name?.byteCount ?? 0) else { return }
                guard (newValue & 0b0000_0111) == 0 else { return }
                header.options.fixedNameByteCount = true
                header.nameLength = newValue
            } else {
                header.options.fixedNameByteCount = false
            }
        }
    }
    
    
    /// The fixed byte count for the entire Item. This accessor cannot be used to reduce the size of this item. If a new value is lower than the current byte count the value that is set is the byte count. The fixed byte count must always be a multiple of 8 bytes. Attempts to specify other values will fail silently. To ensure that a new value was accepted, always use read-after-write for verification.
    ///
    /// If this value is set and the byte count of this item is smaller, then the difference will be added as zero bytes to the end of this item.
    
    public var fixedItemByteCount: UInt32? {
        get {
            return header.options.fixedItemByteCount ? _fixedItemByteCount : nil
        }
        set {
            if let newValue = newValue {
                header.options.fixedItemByteCount = false // Temporary
                if (newValue & 0x0000_0007) != 0 { return }
                if newValue < byteCount {
                    _fixedItemByteCount = byteCount
                } else {
                    _fixedItemByteCount = newValue
                }
                header.options.fixedItemByteCount = true
            } else {
                _fixedItemByteCount = 0
                header.options.fixedItemByteCount = false
            }
        }
    }
    
    
    // Storage for the fixedItemByteCount
    
    internal var _fixedItemByteCount: UInt32
    
    
    /// Create a duplicate of this item.
    
    public var duplicate: Item { return Item(other: self) }
    
    
    /// Accessor for the name of this item.
    ///
    /// When setting a new name, the name will be truncated to either 245 bytes (in UTF8 code) or the fixedNameByteCount whichever is smaller. Note that while the name will be truncated the of UTF8 byte code will always be valid.
    
    public var name: String? {
        get { return _name?.string }
        set {
            if let newValue = newValue {
                guard let itemName = ItemName.init(newValue, fixedByteCount: header.fixedNameByteCount) else { return }
                _name = itemName
                header.nameLength = ItemName.normalizedByteCount(itemName.byteCount)
            } else {
                _name = nil
                header.nameLength = 0
            }
        }
    }
    
    
    // Returns the byte stream representing this item. (Encoding)
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        
        var data = header.endianBytes(endianness)
        data.append((byteCount - 8).endianBytes(endianness))
        if let _name = _name {
            data.append(_name.endianBytes(endianness))
            data.increaseSizeToLowestMultipleOfEight()
        }
        if let fnbc = fixedNameByteCount {
            data.increaseSize(to: (UInt32(fnbc) + 8))
        }
        if let _value = _value {
            data.append(_value.endianBytes(endianness))
            data.increaseSizeToLowestMultipleOfEight()
        }
        data.increaseSize(to: fixedItemByteCount)
        return data
    }
    
    
    // Creates a new item from the bytestream. (Decoding)
    
    public required init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness) {
        
        
        // First read the header
        
        guard let h = ItemHeader(&bytePtr, count: &count, endianness: endianness) else { return nil }
        self.header = h

        
        // Read the NVR length
        
        guard let nvrLength = UInt32(&bytePtr, count: &count, endianness: endianness) else { return nil }
        guard (nvrLength & 0x0000_0007) == 0 else { return nil }
        guard (count >= nvrLength) else { return nil }
        
        self._fixedItemByteCount = header.options.fixedItemByteCount ? nvrLength + 8 : 0
        
        
        // Prepare to skip filler and reserved bytes after the name and value field
        
        let afterNamePtr = bytePtr.advanced(by: Int(header.nameLength))
        let afterNvrPtr = bytePtr.advanced(by: Int(nvrLength))
        
        let afterNameCount = count - UInt32(header.nameLength)
        let afterNvrCount = count - nvrLength
        
        
        // Read name
        
        if header.nameLength > 0 {
            guard count >= UInt32(header.nameLength) else { return nil }
            guard let n = ItemName(&bytePtr, count: &count, endianness: endianness) else { return nil }
            if n.utf8bytes.count != 0 { _name = n }
        }
        
        
        // Skip name filller and reserved bytes
        
        bytePtr = afterNamePtr
        count = afterNameCount
        
        
        // Read value
        
        guard count >= (nvrLength - UInt32(header.nameLength)) else { return nil }
        
        if header.type != .null {
            guard let v = ItemValue(&bytePtr, count: &count, endianness: endianness, type: header.type) else { return nil }
            _value = v
        }
        
        
        // Skip filler and reserved bytes
        
        bytePtr = afterNvrPtr
        count = afterNvrCount
        
        
        // Create the child -> arent links
        
        createChildParentLinks()
    }
    
    
    /// Create a new item. Note that the ItemValue is not duplicated but referenced directly.
    ///
    /// - Parameters:
    ///   - value: The new item value, if nil then a .null Item is created.
    ///   - name: The name for this item, if any. Note that if the string cannot be converted to a UTF8 sequence the name component for the new item will not be set. Also, the length of the name that is actually used will be truncated to 248 bytes when converted to UTF8 code. (It is guaranteed however that the UTF8 code will be valid)
    ///   - fixedByteCount: When specified, this will be the size of this item when encoded in a byte stream. If it is specified but too small for the item created, then the size of the item as created will be used instead. It will be rounded up to the next multiple of 8
    
    public init(_ value: ItemValue?, name: ItemName? = nil, fixedByteCount: UInt32? = nil) {
        header = ItemHeader(value?.type ?? .null)
        if let name = name {
            header.nameLength = ItemName.normalizedByteCount(name.byteCount)
            _name = name
        }
        _value = value ?? ItemValue(null: true)
        _fixedItemByteCount = 0
        if let fixedByteCount = fixedByteCount {
            _fixedItemByteCount = (fixedByteCount >= byteCount) ? fixedByteCount : byteCount
            if (_fixedItemByteCount & 0x0000_0007) != 0 {
                _fixedItemByteCount = (_fixedItemByteCount & 0xFFFF_FFF8) + 0x0000_0008
            }
            header.options.fixedItemByteCount = true
        }
        createChildParentLinks()
    }
    
    
    /// For the duplicate operation.
    
    private init(other: Item) {
        header = other.header
        _fixedItemByteCount = other._fixedItemByteCount
        _name = other._name
        _value = other._value.duplicate
        createChildParentLinks()
    }
    
    
    /// Create child to parent links
    
    private func createChildParentLinks() {
        if let array = _value.array {
            for item in array {
                item.parent = self
                if item._value.array != nil {
                    item.createChildParentLinks()
                }
            }
        }
    }
}


/// A wrapper for the different kinds of value that can be stored in an Item.

public final class ItemValue {
    
    
    /// The type of data stored in this wrapper.
    
    public let type: ItemType
    
    
    // The stored data, note that for a .null type this member will in fact be nil.
    
    internal var any: Any!
    
    
    // The stored data for a composite type
    
    internal var array: Array<Item>!
    
    
    /// The type of element that is allowed in an array
    
    internal var elementType: ItemType!      // Only used for array's
    
    
    /// The fixed bytecount for each array element.
    
    internal var elementByteCount: UInt32!   // Only used for array's
    
    
    /// The number of bytes needed to represent the value. Excluding filler or reserved bytes.
    
    public var byteCount: UInt32 {
        switch type {
        case .null: return 0
        case .bool, .int8, .uint8: return 1
        case .int16, .uint16: return 2
        case .int32, .uint32, .float32: return 4
        case .int64, .uint64, .float64: return 8
        case .binary: return 4 + UInt32((any as! Data).count)
        case .array:
            return 8 + UInt32(array.count) * elementByteCount
        case .string:
            if let data = (any as! String).data(using: .utf8) {
                return 4 + UInt32(data.count)
            } else {
                return 4
            }
        case .dictionary, .sequence:
            var ctr: UInt32 = 8
            array.forEach() { ctr += $0.byteCount }
            return ctr
        }
    }
    
    
    /// Returns an in-depth duplicate of this item. Note that the content of a composite type is also duplicated, not just referenced.
    
    public var duplicate: ItemValue { return ItemValue(self) }
    
    
    // Encode this object
    
    public func endianBytes(_ endianness: Endianness) -> Data {
        
        var data: Data
        
        
        switch type {
        
        case .null:
            
            data = Data()
        
            
        case .bool:
            
            if let b = any as? Bool {
                data = b.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as Bool")
                data = Data()
            }
            
            
        case .int8:
            
            if let i = any as? Int8 {
                data = i.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as Int8")
                data = Data()
            }

            
        case .uint8:
            
            if let u = any as? UInt8 {
                data = u.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as UInt8")
                data = Data()
            }

            
        case .int16:
            
            if let i = any as? Int16 {
                data = i.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as Int16")
                data = Data()
            }
            
            
        case .uint16:
            
            if let u = any as? UInt16 {
                data = u.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as UInt16")
                data = Data()
            }
            
            
        case .int32:
            
            if let i = any as? Int32 {
                data = i.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as Int32")
                data = Data()
            }
            
            
        case .uint32:
            
            if let u = any as? UInt32 {
                data = u.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as UInt32")
                data = Data()
            }
            
            
        case .int64:
            
            if let i = any as? Int64 {
                data = i.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as Int64")
                data = Data()
            }
            
            
        case .uint64:
            
            if let u = any as? UInt64 {
                data = u.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as UInt64")
                data = Data()
            }
            
            
        case .float32:
            
            if let f = any as? Float32 {
                data = f.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as Float32")
                data = Data()
            }
            

        case .float64:
            
            if let f = any as? Float64 {
                data = f.endianBytes(endianness)
            } else {
                assertionFailure("Cannot interpret value as Float64")
                data = Data()
            }
            

        case .string:
            
            if let s = any as? String {
                if let strdata = s.data(using: .utf8) {
                    data = UInt32(strdata.count).endianBytes(endianness)
                    data.append(strdata)
                } else {
                    assertionFailure("Cannot convert string to utf8")
                    data = Data()
                }
            } else {
                assertionFailure("Cannot interpret value as String")
                data = Data()
            }
            

        case .array:
            
            // Add the element spec
            
            let eType = UInt32(elementType.rawValue) << 24
            let eCount = UInt32(elementByteCount) & 0x00FF_FFFF
            let elementSpec = eType | eCount
            data = elementSpec.endianBytes(endianness)
            
            
            // Add the element count
            
            data.append(UInt32(array.count).endianBytes(endianness))
            
            
            // Add the array elements value's
            
            array.forEach() {
                var elementData = $0._value.endianBytes(endianness)
                let remainder = Int(elementByteCount) - elementData.count
                if remainder > 0 {
                    elementData.append(Data(count: remainder))
                }
                data.append(elementData)
            }
            
            
        case .dictionary, .sequence:
            
            
            // Add the element count
            
            data = UInt32(array.count).endianBytes(endianness)
            data.append(UInt32(0).endianBytes(endianness))
            
            // Add the array elements value's
            
            array.forEach() {
                data.append($0.endianBytes(endianness))
            }

            
        case .binary:
            
            if let d = any as? Data {
                
                data = Data()
                
                
                // Add nof bytes
                
                data.append(UInt32(d.count).endianBytes(endianness))
                
                
                // Add the bytes
                
                data.append(d)
                
            } else {
                assertionFailure("Cannot interpret value as Array<Item>")
                data = Data()
            }
        }
        
        
        // Make sure its a multiple of 8
        
        // let c = UInt32(data.count) & 0x0000_0007
        // if c != 0 { data.append(Data(count: Int(8 - c))) }
        
        return data
    }

    
    // Decode an object
    
    public init?(_ bytePtr: inout UnsafeRawPointer, count: inout UInt32, endianness: Endianness, type: ItemType) {
        
        self.type = type
        
        switch type {
        
        case .null:
            assertionFailure("Should never be called for null")
            break
            
        case .bool:
            
            guard count >= 1 else { return nil }
            let b = bytePtr.advanceBool()
            count -= 1
            any = b
            
            
        case .int8:
            
            guard count >= 1 else { return nil }
            let i = bytePtr.advanceInt8()
            count -= 1
            any = i
            
            
        case .uint8:
            
            guard count >= 1 else { return nil }
            let u = bytePtr.advanceUInt8()
            count -= 1
            any = u
            
            
        case .int16:
            
            guard count >= 2 else { return nil }
            let i = bytePtr.advanceInt16(endianness: endianness)
            count -= 2
            any = i
            
            
        case .uint16:
            
            guard count >= 2 else { return nil }
            let u = bytePtr.advanceUInt16(endianness: endianness)
            count -= 2
            any = u

            
        case .int32:
            
            guard count >= 4 else { return nil }
            let i = bytePtr.advanceInt32(endianness: endianness)
            count -= 4
            any = i
            
            
        case .uint32:
            
            guard count >= 4 else { return nil }
            let u = bytePtr.advanceUInt32(endianness: endianness)
            count -= 4
            any = u

            
        case .int64:
            
            guard count >= 8 else { return nil }
            let i = bytePtr.advanceInt64(endianness: endianness)
            count -= 8
            any = i
            
            
        case .uint64:
            
            guard count >= 8 else { return nil }
            let u = bytePtr.advanceUInt64(endianness: endianness)
            count -= 8
            any = u

            
        case .float32:
            
            guard count >= 4 else { return nil }
            let u = bytePtr.advanceFloat32(endianness: endianness)
            count -= 4
            any = u

            
        case .float64:
            
            guard count >= 8 else { return nil }
            let u = bytePtr.advanceFloat64(endianness: endianness)
            count -= 8
            any = u

            
        case .string:
            
            guard count >= 4 else { return nil }
            let c = bytePtr.advanceUInt32(endianness: endianness)
            count -= 4
            guard count >= c else { return nil }
            guard let s = bytePtr.advanceUtf8(count: Int(c)) else { return nil }
            count -= c
            any = s
            
            
        case .array:
            
            guard count >= 4 else { return nil }
            let elementSpec = bytePtr.advanceUInt32(endianness: endianness)
            count -= 4
            let eType = (elementSpec & 0xFF00_0000) >> 24
            let eByteCount = elementSpec & 0x00FF_FFFF
            elementType = ItemType(rawValue: UInt8(eType))
            elementByteCount = eByteCount
            
            guard count >= 4 else { return nil }
            let elementCount = bytePtr.advanceUInt32(endianness: endianness)
            count -= 4
            
            array = Array<Item>()
            
            if elementCount > 0 {
                for _ in 1 ... elementCount {
                    let afterElement = bytePtr.advanced(by: Int(elementByteCount))
                    guard let itemValue = ItemValue(&bytePtr, count: &count, endianness: endianness, type: elementType) else { return nil }
                    bytePtr = afterElement // Skip filler and reserved bytes
                    array.append(Item(itemValue))
                }
            }

            
        case .dictionary, .sequence:
            
            guard count >= 8 else { return nil }
            let elementCount = bytePtr.advanceUInt32(endianness: endianness)
            let zero = bytePtr.advanceUInt32(endianness: endianness)
            guard zero == 0 else { return nil }
            count -= 8
            
            array = Array<Item>()
            
            if elementCount > 0 {
                for _ in 1 ... elementCount {
                    guard let newItem = Item.init(&bytePtr, count: &count, endianness: endianness) else { return nil }
                    if type == .dictionary {
                        if newItem._name == nil { return nil }
                    }
                    array.append(newItem)
                }
            }
            
            
        case .binary:
            
            guard count >= 4 else { return nil }
            let elementCount = bytePtr.advanceUInt32(endianness: endianness)
            count -= 4

            any = Data.init(bytes: bytePtr, count: Int(elementCount))
        }
    }
    
    
    /// Create a value wrapper for a null
    
    public init(null: Bool?) { type = .null }
    
    
    /// Create a value wrapper for a boolean
    
    public init(_ bool: Bool) { type = .bool; any = bool }
    
    
    /// Create a value wrapper for an Int8
    
    public init(_ int8: Int8) { type = .int8; any = int8 }
    
    
    /// Create a value wrapper for an UInt8
    
    public init(_ uint8: UInt8) { type = .uint8; any = uint8 }
    
    
    /// Create a value wrapper for an Int16
    
    public init(_ int16: Int16) { type = .int16; any = int16 }
    
    
    /// Create a value wrapper for an UInt16
    
    public init(_ uint16: UInt16) { type = .uint16; any = uint16 }
    
    
    /// Create a value wrapper for an Int32
    
    public init(_ int32: Int32) { type = .int32; any = int32 }
    
    
    /// Create a value wrapper for an UInt32
    
    public init(_ uint32: UInt32) { type = .uint32; any = uint32 }
    
    
    /// Create a value wrapper for an Int64
    
    public init(_ int64: Int64) { type = .int64; any = int64 }
    
    
    /// Create a value wrapper for an UInt64
    
    public init(_ uint64: UInt64) { type = .uint64; any = uint64 }
    
    
    /// Create a value wrapper for a Float32
    
    public init(_ float32: Float32) { type = .float32; any = float32 }
    
    
    /// Create a value wrapper for a Float64
    
    public init(_ float64: Float64) { type = .float64; any = float64 }
    
    
    /// Create a value wrapper for a String
    
    public init(_ string: String) { type = .string; any = string }
    
    
    /// Create a value wrapper for an Array
    
    public init(array: Array<Item>, elementType: ItemType, elementByteCount: UInt32) {
        type = .array
        self.array = Array<Item>()
        array.forEach() { self.array.append($0.duplicate) }
        self.elementType = elementType
        self.elementByteCount = elementByteCount
    }
    
    
    /// Create a value wrapper for a dictionary
    
    public init(dictionary: Array<Item>) {
        type = .dictionary
        array = Array<Item>()
        dictionary.forEach() { array.append($0.duplicate) }
    }
    
    
    /// Create a value wrapper for a sequence
    
    public init(sequence: Array<Item>) {
        type = .sequence
        array = Array<Item>()
        sequence.forEach() { array.append($0.duplicate) }
    }
    
    
    /// Create a value wrapper for a binary
    
    public init(_ binary: Data) { type = .binary; any = binary }
    
    
    /// Create a new object with the same content (duplicated)
    
    public convenience init(_ other: ItemValue) {
        
        switch other.type {
        
        case .null: self.init(null: true)
        case .bool: self.init(other.any as! Bool)
        case .int8: self.init(other.any as! Int8)
        case .uint8: self.init(other.any as! UInt8)
        case .int16: self.init(other.any as! Int16)
        case .uint16: self.init(other.any as! UInt16)
        case .int32: self.init(other.any as! Int32)
        case .uint32: self.init(other.any as! UInt32)
        case .int64: self.init(other.any as! Int64)
        case .uint64: self.init(other.any as! UInt64)
        case .float32: self.init(other.any as! Float32)
        case .float64: self.init(other.any as! Float64)
        case .string:  self.init(other.any as! String)
        case .array: self.init(array: other.array, elementType: other.elementType, elementByteCount: other.elementByteCount)
        case .dictionary: self.init(dictionary: other.array)
        case .sequence: self.init(sequence: other.array)
        case .binary: self.init(other.any as! Data)
        }
    }
}
