// =====================================================================================================================
//
//  File:       Item.swift
//  Project:    BRBON
//
//  Version:    0.8.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Git:        https://github.com/Balancingrock/BRBON
//
//  Copyright:  (c) 2018-2019 Marinus van der Lugt, All rights reserved.
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
//  I strongly believe that voluntarism is the way for societies to function optimally. So you can pay whatever you
//  think our code is worth to you.
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
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// History
//
// 0.8.0 - Migrated to Swift 5
// 0.7.9 - Minor comments updates
// 0.7.0 - Code restructuring & simplification
// 0.5.0 - Migration to Swift 4
// 0.4.2 - Added header & general review of access levels
// =====================================================================================================================

import Foundation
import BRUtils


internal let itemTypeOffset = 0
internal let itemOptionsOffset = 1
internal let itemFlagsOffset = 2
internal let itemNameFieldByteCountOffset = 3
internal let itemByteCountOffset = 4
internal let itemParentOffsetOffset = 8
internal let itemSmallValueOffset = 12

internal let itemHeaderByteCount = 16

internal let itemNameCrcOffset = itemHeaderByteCount + 0
internal let itemNameUtf8ByteCountOffset = itemHeaderByteCount + 2
internal let itemNameUtf8CodeOffset = itemHeaderByteCount + 3


// MARK: - Adding Item Header accessors

internal extension UnsafeMutableRawPointer {
    
    
    /// Returns a pointer to the item type assuming self points to the first byte of an item.
    
    var itemTypePtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemTypeOffset)
    }

    
    /// Returns a pointer to the item options assuming self points to the first byte of an item.

    var itemOptionsPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemOptionsOffset)
    }
    
    
    /// Returns a pointer to the item flags assuming self points to the first byte of an item.

    var itemFlagsPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemFlagsOffset)
    }
    

    /// Returns a pointer to the item name field count assuming self points to the first byte of an item.

    var itemNameFieldByteCountPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemNameFieldByteCountOffset)
    }
    
    
    /// Returns a pointer to the item byte count assuming self points to the first byte of an item.

    var itemByteCountPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemByteCountOffset)
    }
    
    
    /// Returns a pointer to the item parent offset assuming self points to the first byte of an item.

    var itemParentOffsetPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemParentOffsetOffset)
    }
    
    
    /// Returns a pointer to the item small value assuming self points to the first byte of an item.

    var itemSmallValuePtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemSmallValueOffset)
    }
    
    
    /// The raw value of the item type, assuming self points to the first byte of an item.
    
    var itemType: UInt8 {
        get {
            return self.itemTypePtr.assumingMemoryBound(to: UInt8.self).pointee
        }
        set {
            self.itemTypePtr.storeBytes(of: newValue, as: UInt8.self)
        }
    }
    
    
    /// The raw value of the item options, assuming self points to the first byte of an item.

    var itemOptions: UInt8 {
        get {
            return self.itemOptionsPtr.assumingMemoryBound(to: UInt8.self).pointee
        }
        set {
            self.itemOptionsPtr.storeBytes(of: newValue, as: UInt8.self)
        }
    }

    
    /// The raw value of the item flags, assuming self points to the first byte of an item.

    var itemFlags: UInt8 {
        get {
            return self.itemFlagsPtr.assumingMemoryBound(to: UInt8.self).pointee
        }
        set {
            self.itemFlagsPtr.storeBytes(of: newValue, as: UInt8.self)
        }
    }
    
    
    /// The name field byte count of an item, assuming self points to the first byte of an item.

    var itemNameFieldByteCount: UInt8 {
        get {
            return self.itemNameFieldByteCountPtr.assumingMemoryBound(to: UInt8.self).pointee
        }
        set {
            self.itemNameFieldByteCountPtr.storeBytes(of: UInt8(newValue), as: UInt8.self)
        }
    }
    
    
    /// Returns the byte count of an item, assuming self points to the first byte of an item.

    func itemByteCount(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return self.itemByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return self.itemByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }

    
    /// Sets the byte count of an item, assuming self points to the first byte of an item.

    func setItemByteCount(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.itemByteCountPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            self.itemByteCountPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }
    
    
    /// Increment the bytecount with the given value (may be negative)
    
    func incrementItemByteCount(by value: Int, _ endianness: Endianness) {
        if endianness == machineEndianness {
            let c = Int(self.itemByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee) + value
            self.itemByteCountPtr.storeBytes(of: UInt32(c), as: UInt32.self)
        } else {
            let c = Int(self.itemByteCountPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped) + value
            self.itemByteCountPtr.storeBytes(of: UInt32(c).byteSwapped, as: UInt32.self)
        }
    }
    

    /// Returns the parent offset of an item, assuming self points to the first byte of an item.

    func itemParentOffset(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return self.itemParentOffsetPtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return self.itemParentOffsetPtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the parent offset of an item, assuming self points to the first byte of an item.

    func setItemParentOffset(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.itemParentOffsetPtr.storeBytes(of: value, as: UInt32.self)
        } else {
            self.itemParentOffsetPtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }

    
    /// Returns the small value of an item, assuming self points to the first byte of an item.

    func itemSmallValue(_ endianness: Endianness) -> UInt32 {
        if endianness == machineEndianness {
            return self.itemSmallValuePtr.assumingMemoryBound(to: UInt32.self).pointee
        } else {
            return self.itemSmallValuePtr.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the small value of an item, assuming self points to the first byte of an item.

    func setItemSmallValue(to value: UInt32, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.itemSmallValuePtr.storeBytes(of: value, as: UInt32.self)
        } else {
            self.itemSmallValuePtr.storeBytes(of: value.byteSwapped, as: UInt32.self)
        }
    }

    
    /// Returns the small value of an item, assuming self points to the first byte of an item.

    func itemSmallValue(_ endianness: Endianness) -> UInt16 {
        if endianness == machineEndianness {
            return self.itemSmallValuePtr.assumingMemoryBound(to: UInt16.self).pointee
        } else {
            return self.itemSmallValuePtr.assumingMemoryBound(to: UInt16.self).pointee.byteSwapped
        }
    }

    
    /// Sets the small value of an item, assuming self points to the first byte of an item.

    func setItemSmallValue(to value: UInt16, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.itemSmallValuePtr.storeBytes(of: value, as: UInt16.self)
        } else {
            self.itemSmallValuePtr.storeBytes(of: value.byteSwapped, as: UInt16.self)
        }
    }

    
    /// Returns the small value of an item, assuming self points to the first byte of an item.

    func itemSmallValue() -> UInt8 {
        return self.itemSmallValuePtr.assumingMemoryBound(to: UInt8.self).pointee
    }

    
    /// Sets the small value of an item, assuming self points to the first byte of an item.

    func setItemSmallValue(to value: UInt8) {
        self.itemSmallValuePtr.storeBytes(of: value, as: UInt8.self)
    }
}


// MARK: - Adding Item Name accessors

internal extension UnsafeMutableRawPointer {

    
    /// Returns a pointer to the name field of an item assuming self points to the first byte of an item.

    var itemNameFieldPtr: UnsafeMutableRawPointer { return self.advanced(by: itemHeaderByteCount) }

    
    /// Returns a pointer to the CRC field in the name of an item assuming self points to the first byte of an item.

    var itemNameCrcPtr: UnsafeMutableRawPointer { return self.advanced(by: itemNameCrcOffset) }
    
    
    /// Returns a pointer to the UTF8 Byte Count in the name field of an item assuming self points to the first byte of an item.

    var itemNameUtf8ByteCountPtr: UnsafeMutableRawPointer { return self.advanced(by: itemNameUtf8ByteCountOffset) }

    
    /// Returns a pointer to the start of the UTF8 Byte Code in the name field of an item assuming self points to the first byte of an item.

    var itemNameUtf8CodePtr: UnsafeMutableRawPointer { return self.advanced(by: itemNameUtf8CodeOffset) }
    
    
    /// Returns the CRC of the name of an item assuming self points to the first byte of an item.
    
    func itemNameCrc(_ endianness: Endianness) -> UInt16 {
        if endianness == machineEndianness {
            return self.itemNameCrcPtr.assumingMemoryBound(to: UInt16.self).pointee
        } else {
            return self.itemNameCrcPtr.assumingMemoryBound(to: UInt16.self).pointee.byteSwapped
        }
    }
    
    
    /// Sets the CRC of the name of an item assuming self points to the first byte of the item.

    func setItemNameCrc(to value: UInt16, _ endianness: Endianness) {
        if endianness == machineEndianness {
            self.itemNameCrcPtr.storeBytes(of: value, as: UInt16.self)
        } else {
            self.itemNameCrcPtr.storeBytes(of: value.byteSwapped, as: UInt16.self)
        }
    }
    
    
    /// The UTF8 Byte Count of the name of an item assuming self points to the first byte of the item.

    var itemNameUtf8ByteCount: UInt8 {
        get {
            return self.itemNameUtf8ByteCountPtr.assumingMemoryBound(to: UInt8.self).pointee
        }
        set {
            self.itemNameUtf8ByteCountPtr.storeBytes(of: UInt8(newValue), as: UInt8.self)
        }
    }
    
    
    /// The UTF8 Byte Code of the name of an item assuming self points to the first byte of the item.
    ///
    /// Note that this will also read from or write to 'itemNameUtf8ByteCount'.

    var itemNameUtf8Code: Data {
        get {
            return Data(bytes: self.itemNameUtf8CodePtr, count: Int(self.itemNameUtf8ByteCount))
        }
        set {
            newValue.copyBytes(to: self.itemNameUtf8CodePtr.assumingMemoryBound(to: UInt8.self), count: newValue.count)
            self.itemNameUtf8ByteCount = UInt8(newValue.count)
        }
    }
}


// Adding item related utility functions

extension UnsafeMutableRawPointer {

    
    /// Returns the byte count for the item header and item name
    
    internal var itemHeaderAndNameByteCount: Int {
        return itemHeaderByteCount + Int(self.itemNameFieldByteCount)
    }

    
    /// Returns a pointer to the first byte of the value field assuming self points to the first byte of the item.
    
    internal var itemValueFieldPtr: UnsafeMutableRawPointer {
        return self.advanced(by: itemHeaderAndNameByteCount)
    }
    
    
    /// Returns a pointer to the first byte after this item assuming self points to the first byte of the item.
    
    internal func nextItemPtr(_ endianness: Endianness) -> UnsafeMutableRawPointer {
        return self.advanced(by: Int(self.itemByteCount(endianness)))
    }
}


// Item fields access

extension Portal {

    
    /// The type of item this portal refers to.
    
    internal var _itemType: ItemType? {
        get { return ItemType(rawValue: itemPtr.itemType) }
        set { itemPtr.itemType = newValue?.rawValue ?? 0 }
    }
    
    
    /// The options for the item this portal refers to.
    
    internal var _itemsOptions: ItemOptions? {
        get { return ItemOptions(rawValue: itemPtr.itemOptions) }
        set { itemPtr.itemOptions = newValue?.rawValue ?? 0 }
    }
    

    /// The flags for the item this portal refers to.
    
    internal var _itemFlags: ItemFlags? {
        get { return ItemFlags(rawValue: itemPtr.itemFlags) }
        set { itemPtr.itemFlags = newValue?.rawValue ?? 0 }
    }

    
    /// The byte count of the name field in the item this portal refers to.
    
    internal var _itemNameFieldByteCount: Int {
        get { return Int(itemPtr.itemNameFieldByteCount) }
        set { itemPtr.itemNameFieldByteCount = UInt8(newValue) }
    }

    
    /// The byte count of the item this portal refers to.
    
    internal var _itemByteCount: Int {
        get { return Int(itemPtr.itemByteCount(endianness)) }
        set { itemPtr.setItemByteCount(to: UInt32(newValue), endianness) }
    }
    
    
    /// The parent offset for the item this portal refers to.
    
    internal var _itemParentOffset: Int {
        get { return Int(itemPtr.itemParentOffset(endianness)) }
        set { itemPtr.setItemParentOffset(to: UInt32(newValue), endianness) }
    }

    
    /// The small value field accessor as a UInt32
    
    internal func _itemSmallValue(_ endianness: Endianness) -> UInt32 {
        return itemPtr.itemSmallValue(endianness)
    }
    
    
    /// Set the small value field as a UInt32
    
    internal func _setItemSmallValue(to value: UInt32, _ endianness: Endianness) {
        itemPtr.setItemSmallValue(to: value, endianness)
    }
}

extension Portal {
    
    
    /// Returns a pointer to the value field of this portal.
    
    internal var _itemValueFieldPtr: UnsafeMutableRawPointer {
        return itemPtr.itemValueFieldPtr
    }
    
    
    /// Returns a pointer to the first byte after the item of this portal.
    
    internal var _nextItemPtr: UnsafeMutableRawPointer {
        return itemPtr.nextItemPtr(endianness)
    }
}


extension Portal {
    
    /// The crc16 of name of the item this portal refers to.
    
    internal var _itemNameCrc: UInt16 {
        get { return itemPtr.itemNameCrc(endianness) }
        set { itemPtr.setItemNameCrc(to: newValue, endianness) }
    }
    
    
    /// The number of used bytes in the data area of the name field of the item this portal refers to.
    
    internal var _itemNameUtf8CodeByteCount: Int {
        get { return Int(itemPtr.itemNameUtf8ByteCount) }
        set { itemPtr.itemNameUtf8ByteCount = UInt8(newValue) }
    }
    
    
    /// A data struc with the bytes of the UTF8 code sequence used in the name field of the item this portal refers to.
    
    internal var _itemNameUtf8Code: Data {
        get { return itemPtr.itemNameUtf8Code }
        set { itemPtr.itemNameUtf8Code = newValue }
    }
}


public extension Portal {
    
    
    /// The type of item this portal refers to.
    
    internal(set) var itemType: ItemType? {
        get { guard isValid else { return nil }; return _itemType }
        set { guard isValid else { return }; _itemType = newValue }
    }
    
        
    /// The options for the item this portal refers to.
    
    var itemOptions: ItemOptions? {
        get { guard isValid else { return nil }; return _itemsOptions }
        set { guard isValid else { return }; _itemsOptions = newValue }
    }
    
    
    /// The flags for the item this portal refers to.
    
    var itemFlags: ItemFlags? {
        get { guard isValid else { return nil }; return _itemFlags }
        set { guard isValid else { return }; _itemFlags = newValue }
    }
    
    
    /// Returns true if the portal is valid and the item referred to has a name
    
    var hasName: Bool {
        guard isValid else { return false }
        return _itemNameFieldByteCount > 0
    }
    
    
    /// A string with the name for the item this portal refers to.
    ///
    /// - Note: To change a name, use the function _updateNameField_ instead.
    ///
    /// Nil if the item does not have a name. Empty if the conversion of UTF8 code to a string failed.
    
    var itemName: String? {
        get {
            guard isValid else { return nil }
            if _itemNameFieldByteCount == 0 { return nil }
            return String(data: _itemNameUtf8Code, encoding: .utf8)
        }
    }
    
    
    /// Set or remove an item name.
    ///
    /// Setting the name to nil will remove the name and the name-field from the item. Setting a smaller name will not reduce the size of the name-field however.
    
    func updateItemName(to nameField: NameField?) -> Result {
        
        if let nameField = nameField {
        
            // Set a new name
            
            // If the name is larger, increase the item size and move the value field
            
            if nameField.byteCount > _itemNameFieldByteCount {
                let ibc = itemHeaderByteCount + nameField.byteCount + usedValueFieldByteCount
                if ibc > _itemByteCount {
                    let result = increaseItemByteCount(to: ibc)
                    guard result == .success else { return result }
                }
                let srcPtr = _itemValueFieldPtr
                let dstPtr = _itemValueFieldPtr.advanced(by: (nameField.byteCount - _itemNameFieldByteCount))
                let shiftSize = usedValueFieldByteCount
                manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: shiftSize, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
                _itemNameFieldByteCount = nameField.byteCount
            }
            if ItemManager.startWithZeroedBuffers {
                _ = Darwin.memset(itemPtr.itemNameFieldPtr, 0, _itemNameFieldByteCount)
            }
            _itemNameCrc = nameField.crc
            _itemNameUtf8CodeByteCount = nameField.data.count
            _itemNameUtf8Code = nameField.data
            
        } else {
            
            // Remove the name field if present
            
            if _itemNameFieldByteCount > 0 {
                let srcPtr = _itemValueFieldPtr
                let dstPtr = itemPtr.itemNameFieldPtr
                let shiftSize = _itemValueFieldPtr.distance(to: itemPtr.advanced(by: _itemByteCount))
                manager.moveBlock(to: dstPtr, from: srcPtr, moveCount: shiftSize, removeCount: 0, updateMovedPortals: true, updateRemovedPortals: false)
                _itemNameFieldByteCount = 0
                
                if ItemManager.startWithZeroedBuffers {
                    let zerosize = dstPtr.distance(to: srcPtr)
                    let targetPtr = _itemValueFieldPtr.advanced(by: shiftSize)
                    _ = Darwin.memset(targetPtr, 0, zerosize)
                }
            }
        }
        return .success
    }
    
    
    /// Update the value in this item.
    ///
    /// The portal of self will not be affected. All portals referencing an item in self will be invalidated.
    ///
    /// - Parameter value: The new value.
    ///
    /// - Returns:
    ///   success: if the value was updated.
    ///
    ///   error(code): if something prevented the update, the code details the reason.
    
    internal func _updateItemValue(_ value: Coder) -> Result {
        
        
        // Update the proper region
        
        if value.itemType.usesSmallValue {
        
            value.copyBytes(to: itemPtr.itemSmallValuePtr, endianness)
        
        } else {
        
            
            // Make sure the value field is big enough
            let necessaryValueFieldByteCount = value.minimumValueFieldByteCount
            let necessaryItemByteCount = itemPtr.itemHeaderAndNameByteCount + necessaryValueFieldByteCount
            if necessaryItemByteCount > _itemByteCount {
                let result = increaseItemByteCount(to: necessaryItemByteCount)
                guard result == .success else { return result }
            }
            
            
            // Invalidate portals
            
            manager.removeActivePortals(atAndAbove: _itemValueFieldPtr, below: itemPtr.advanced(by: _itemByteCount))
            
            
            // Reset the value field to zero - when necessary
            
            if ItemManager.startWithZeroedBuffers {
                _ = Darwin.memset(_itemValueFieldPtr, 0, _itemValueFieldPtr.distance(to: itemPtr.advanced(by: _itemByteCount)))
            }
            
            
            // Set the new value
            
            value.copyBytes(to: _itemValueFieldPtr, endianness)
        }
        
        return .success
    }
    
    
    /// Update the value in this item.
    ///
    /// The portal of self will not be affected. All portals contained in self will be invalidated.
    ///
    /// - Parameter value: The item manager with the new value.
    ///
    /// - Returns:
    ///
    ///   success: if the value was updated.
    ///
    ///   error(code): if something prevented the update, the code details the reason.

    internal func _updateItemValue(_ value: ItemManager) -> Result {
        
        let newByteCount = value.root._itemByteCount
        let oldByteCount = _itemByteCount
        let pOffset = _itemParentOffset
        
        
        manager.removeActivePortals(atAndAbove: _itemValueFieldPtr, below: itemPtr.advanced(by: _itemByteCount))

        if oldByteCount > newByteCount {

            manager.moveBlock(to: itemPtr, from: value.bufferPtr, moveCount: value.root._itemByteCount, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)
            
            _itemByteCount = oldByteCount

            if ItemManager.startWithZeroedBuffers {
                _ = Darwin.memset(itemPtr.advanced(by: newByteCount), 0, (oldByteCount - newByteCount))
            }
            
        } else if oldByteCount == newByteCount {

            manager.moveBlock(to: itemPtr, from: value.bufferPtr, moveCount: value.root._itemByteCount, removeCount: 0, updateMovedPortals: false, updateRemovedPortals: false)

        } else {
            
            // Increase the size of item to the necessary size
            let result = increaseItemByteCount(to: newByteCount)
            guard result == .success else { return result }
            
            _ = Darwin.memmove(itemPtr, value.bufferPtr, newByteCount)
        }
        
        _itemParentOffset = pOffset
        
        return .success
    }
}


/// Build an item structure.
///
/// - Note: The parentOffset, smallValueField and valueField are not be initialised. The itemByteCount is set to the minimum item byte count regardless of type.
///
/// - Parameters:
///   - ofType: The type to put in the itemType field.
///   - withNameField: The namefield for the item. Optional.
///   - atPtr: The pointer at which to build the item structure.
///   - endianness: The endianness to be used while creating the item.

internal func buildItem(ofType type: ItemType, withNameField nameField: NameField? = nil, atPtr: UnsafeMutableRawPointer, _ endianness: Endianness) {
    
    var ptr = atPtr
    
    ptr.itemType = type.rawValue
    ptr.itemFlags = ItemFlags.none.rawValue
    ptr.itemOptions = ItemOptions.none.rawValue
    ptr.itemNameFieldByteCount = UInt8(nameField?.byteCount ?? 0)
    ptr.setItemByteCount(to: UInt32(itemHeaderByteCount + (nameField?.byteCount ?? 0)), endianness)
    ptr.setItemParentOffset(to: 0, endianness)
    ptr.setItemSmallValue(to: UInt32(0), endianness)
    
    if let nameField = nameField {
        ptr.setItemNameCrc(to: nameField.crc, endianness)
        ptr.itemNameUtf8ByteCount = UInt8(nameField.data.count)
        ptr.itemNameUtf8Code = nameField.data
    }
}


/// Build an item structure and set the initial value.
///
/// - Note: The parentOffset is not initialized. The itemByteCount is set to the smallest value possible.
///
/// - Parameters:
///   - withValue: The value to put in the item.
///   - withNameField: The namefield for the item. Optional.
///   - atPtr: The pointer at which to build the item structure.
///   - endianness: The endianness to be used while creating the item.

internal func buildItem(withValue value: Coder, withNameField nameField: NameField? = nil, atPtr ptr: UnsafeMutableRawPointer, _ endianness: Endianness) {

    buildItem(ofType: value.itemType, withNameField: nameField, atPtr: ptr, endianness)

    if value.itemType.usesSmallValue {
        value.copyBytes(to: ptr.itemSmallValuePtr, endianness)
    } else {
        value.copyBytes(to: ptr.itemValueFieldPtr, endianness)
        ptr.setItemByteCount(to: UInt32(itemHeaderByteCount + (nameField?.byteCount ?? 0) + value.valueByteCount.roundUpToNearestMultipleOf8()), endianness)
    }
}



