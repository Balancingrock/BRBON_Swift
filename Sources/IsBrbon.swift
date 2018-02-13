//
//  IsBrbon.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 13/02/18.
//
//

import Foundation

public protocol IsBrbon {
    var brbonType: ItemType { get }
}

extension Bool: IsBrbon {
    public var brbonType: ItemType { return ItemType.bool }
}

extension UInt8: IsBrbon {
    public var brbonType: ItemType { return ItemType.uint8 }
}

extension UInt16: IsBrbon {
    public var brbonType: ItemType { return ItemType.uint16 }
}

extension UInt32: IsBrbon {
    public var brbonType: ItemType { return ItemType.uint32 }
}

extension UInt64: IsBrbon {
    public var brbonType: ItemType { return ItemType.uint64 }
}

extension Int8: IsBrbon {
    public var brbonType: ItemType { return ItemType.int8 }
}

extension Int16: IsBrbon {
    public var brbonType: ItemType { return ItemType.int16 }
}

extension Int32: IsBrbon {
    public var brbonType: ItemType { return ItemType.int32 }
}

extension Int64: IsBrbon {
    public var brbonType: ItemType { return ItemType.int64 }
}

extension Float32: IsBrbon {
    public var brbonType: ItemType { return ItemType.float32 }
}

extension Float64: IsBrbon {
    public var brbonType: ItemType { return ItemType.float64 }
}

extension String: IsBrbon {
    public var brbonType: ItemType { return ItemType.string }
}

extension Data: IsBrbon {
    public var brbonType: ItemType { return ItemType.binary }
}
