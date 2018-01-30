//
//  NullItem.swift
//  BRBON
//
//  Created by Marinus van der Lugt on 27/01/18.
//
//

import Foundation


// This class is used for an immutable null-item singleton. By using this singleton as a return paremeter in subscript operations the force-unwrap can be avoided.

internal class NullItem: Item {
    
    override var manager: BufferManagerProtocol? {
        get { return nil }
        set { return }
    }
    
    override var bool: Bool? {
        get { return nil }
        set { return }
    }
    
    override var uint8: UInt8? {
        get { return nil }
        set { return }
    }
    
    override var uint16: UInt16? {
        get { return nil }
        set { return }
    }
    
    override var uint32: UInt32? {
        get { return nil }
        set { return }
    }
    
    override var uint64: UInt64? {
        get { return nil }
        set { return }
    }
    
    override var int8: Int8? {
        get { return nil }
        set { return }
    }
    
    override var int16: Int16? {
        get { return nil }
        set { return }
    }
    
    override var int32: Int32? {
        get { return nil }
        set { return }
    }
    
    override var int64: Int64? {
        get { return nil }
        set { return }
    }
    
    override var float32: Float32? {
        get { return nil }
        set { return }
    }
    
    override var float64: Float64? {
        get { return nil }
        set { return }
    }
    
    override var string: String? {
        get { return nil }
        set { return }
    }
    
    override var binary: Data? {
        get { return nil }
        set { return }
    }
}
