//
//  ItemPtrLibrary.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 06/01/18.
//
//

import Foundation


internal let itemTypeOffset = 0
internal let itemNameFieldLengthOffset = 3
internal let itemLengthOffset = 4
internal let itemParentOffsetOffset = 8
internal let itemValueCountOffset = 12

internal let itemNvrOffset = 16

internal let itemNameFieldOffset = itemNvrOffset
internal let nameHashOffset = itemNameFieldOffset + 0
internal let nameCountOffset = itemNameFieldOffset + 2
internal let nameDataOffset = itemNameFieldOffset + 3

internal let lengthOfFixedItemPart: UInt32 = 16
