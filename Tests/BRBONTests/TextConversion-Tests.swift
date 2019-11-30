//
//  TextConversion-Tests.swift
//  BRBONTests
//
//  Created by Marinus van der Lugt on 29/11/2019.
//

import XCTest
@testable import BRBON

class TextConversion_Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNull() {
        let im = ItemManager.createManager(withValue: Null())
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = null
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x00000000
            itemName       = (none)
            value          = null
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
        
        let im1 = ItemManager.createManager(withValue: Null(), withNameField: NameField("Less8"))
        let exp1 =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = null
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 8
            itemByteCount  = 24
            itemValueField = 0x00000000
            itemName       = Less8
            value          = null
        """
        let descr1 = "\(im1.root!)"
        XCTAssertEqual(descr1, exp1)

    }
    
    func testBool() {
        let im = ItemManager.createManager(withValue: false)
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = bool
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x00000000
            itemName       = (none)
            value          = false
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
        
        let im1 = ItemManager.createManager(withValue: true, withNameField: NameField("longerName"))
        let exp1 =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = bool
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 16
            itemByteCount  = 32
            itemValueField = 0x00000001
            itemName       = longerName
            value          = true
        """
        let descr1 = "\(im1.root!)"
        XCTAssertEqual(descr1, exp1)
    }
    
    func testInt8() {
        let im = ItemManager.createManager(withValue: Int8(-3))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = int8
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x000000FD
            itemName       = (none)
            value          = -3
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
        
        let im1 = ItemManager.createManager(withValue: Int8(6), withNameField: NameField("aName", fixedByteCount: 32))
        let exp1 =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = int8
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 32
            itemByteCount  = 48
            itemValueField = 0x00000006
            itemName       = aName
            value          = 6
        """
        let descr1 = "\(im1.root!)"
        XCTAssertEqual(descr1, exp1)
    }

    func testInt16() {
        let im = ItemManager.createManager(withValue: Int16(333))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = int16
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x0000014D
            itemName       = (none)
            value          = 333
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }
    
    func testInt32() {
        let im = ItemManager.createManager(withValue: Int32(333333))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = int32
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x00051615
            itemName       = (none)
            value          = 333333
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testInt64() {
        let im = ItemManager.createManager(withValue: Int64(333333))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = int64
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 24
            itemValueField = 0x00000000
            itemName       = (none)
            value          = 333333
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testUInt8() {
        let im = ItemManager.createManager(withValue: UInt8(255))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = uint8
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x000000FF
            itemName       = (none)
            value          = 255
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testUInt16() {
        let im = ItemManager.createManager(withValue: UInt16(333))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = uint16
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x0000014D
            itemName       = (none)
            value          = 333
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }
    
    func testUInt32() {
        let im = ItemManager.createManager(withValue: UInt32(333333))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = uint32
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x00051615
            itemName       = (none)
            value          = 333333
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testUInt64() {
        let im = ItemManager.createManager(withValue: UInt64(333333))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = uint64
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 24
            itemValueField = 0x00000000
            itemName       = (none)
            value          = 333333
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }
    
    func testFloat32() {
        let im = ItemManager.createManager(withValue: Float32(12.34e5))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = float32
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x4996A280
            itemName       = (none)
            value          = 1234000.0
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testFloat64() {
        let im = ItemManager.createManager(withValue: Float64(56.33e-6))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = float64
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 24
            itemValueField = 0x00000000
            itemName       = (none)
            value          = 5.633e-05
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testUuid() {
        let im = ItemManager.createManager(withValue: UUID(uuidString: "6A3349FF-FCFF-4BDD-9631-CB16D636B4F1")!)
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = uuid
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 32
            itemValueField = 0x00000000
            itemName       = (none)
            value          = 6A3349FF-FCFF-4BDD-9631-CB16D636B4F1
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testString() {
        let im = ItemManager.createManager(withValue: "Blabla")
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = string
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 32
            itemValueField = 0x00000000
            itemName       = (none)
            value          = Blabla
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testCrcString() {
        let im = ItemManager.createManager(withValue: BRCrcString("BlaBla")!)
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = crcString
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 32
            itemValueField = 0x00000000
            itemName       = (none)
            value          = Crc: 2900962341, String: BlaBla
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testBinary() {
        let im = ItemManager.createManager(withValue: Data(bytes: [UInt8(0), UInt8(0x55), UInt8(0xAA), UInt8(0xFF), UInt8(0x80)]))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = binary
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 32
            itemValueField = 0x00000000
            itemName       = (none)
            value          = Bytes: 5
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testCrcBinary() {
        let im = ItemManager.createManager(withValue: BRCrcBinary(Data(bytes: [UInt8(0), UInt8(0x55), UInt8(0xAA), UInt8(0xFF), UInt8(0x80)])))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = crcBinary
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 32
            itemValueField = 0x00000000
            itemName       = (none)
            value          = Crc: 2424483433, Bytes: 5
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testColor() {
        let im = ItemManager.createManager(withValue: BRColor(red: 11, green: 22, blue: 33, alpha: 44))
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = color
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 16
            itemValueField = 0x2C21160B
            itemName       = (none)
            value          = Red: 11, Green: 22, Blue: 33, Alpha: 44
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testFont() {
        let font = BRFont(NSFont(name: "Times", size: CGFloat(12.0))!)!
        let im = ItemManager.createManager(withValue: font)
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = font
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 40
            itemValueField = 0x00000000
            itemName       = (none)
            value          = Family: Times, Font: Times-Roman, Size: 12.0
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }

    func testDictionary() {
        let im = ItemManager.createDictionaryManager()
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1

        Item:
            itemType       = dictionary
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 24
            itemValueField = 0x00000000
            itemName       = (none)
            value:
                Item count = 0
                Items:
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
        
        im.root.updateItem(Int8(44), withName: "one")
        let exp2 =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1

        Item:
            itemType       = dictionary
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 48
            itemValueField = 0x00000000
            itemName       = (none)
            value:
                Item count = 1
                Items:
                    itemType       = int8
                    itemOptions    = none
                    itemFlags      = none
                    nameByteCount  = 8
                    itemByteCount  = 24
                    itemValueField = 0x0000002C
                    itemName       = one
                    value          = 44
        """
        let descr2 = "\(im.root!)"
        XCTAssertEqual(descr2, exp2)
    }
    
    func testSequence() {
        let im = ItemManager.createSequenceManager()
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1

        Item:
            itemType       = sequence
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 24
            itemValueField = 0x00000000
            itemName       = (none)
            value:
                Item count = 0
                Items:
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
        
        im.root.appendItem(Int8(44))
        let exp2 =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1

        Item:
            itemType       = sequence
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 40
            itemValueField = 0x00000000
            itemName       = (none)
            value:
                Item count = 1
                Items:
                    0:
                        itemType       = int8
                        itemOptions    = none
                        itemFlags      = none
                        nameByteCount  = 0
                        itemByteCount  = 16
                        itemValueField = 0x0000002C
                        itemName       = (none)
                        value          = 44
        """
        let descr2 = "\(im.root!)"
        XCTAssertEqual(descr2, exp2)
    }

    func testArray() {
        let im = ItemManager.createArrayManager(elementType: .uint8, elementByteCount: 1, elementCount: 0, endianness: .little)
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1
        
        Item:
            itemType       = array
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 32
            itemValueField = 0x00000000
            itemName       = (none)
            value:
                Element type  = uint8
                Element bytes = 1
                Element count = 0
                Elements:
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
        
        im.root.appendElement(UInt8(44))
        let exp2 =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1

        Item:
            itemType       = array
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 40
            itemValueField = 0x00000000
            itemName       = (none)
            value:
                Element type  = uint8
                Element bytes = 1
                Element count = 1
                Elements:
                      0: 44
        """
        let descr2 = "\(im.root!)"
        XCTAssertEqual(descr2, exp2)
        
        im.root.appendElement(UInt8(31))
        im.root.appendElement(UInt8(32))
        im.root.appendElement(UInt8(33))
        im.root.appendElement(UInt8(34))
        im.root.appendElement(UInt8(35))
        im.root.appendElement(UInt8(36))
        im.root.appendElement(UInt8(37))
        im.root.appendElement(UInt8(38))
        im.root.appendElement(UInt8(39))
        im.root.appendElement(UInt8(40))
        let exp3 =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 1

        Item:
            itemType       = array
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 48
            itemValueField = 0x00000000
            itemName       = (none)
            value:
                Element type  = uint8
                Element bytes = 1
                Element count = 11
                Elements:
                      0: 44
                      1: 31
                      2: 32
                      3: 33
                      4: 34
                      5: 35
                      6: 36
                      7: 37
                      8: 38
                      9: 39
                     10: 40
        """
        let descr3 = "\(im.root!)"
        XCTAssertEqual(descr3, exp3)
    }
    
    func testDictSecArr() {
        let im = ItemManager.createDictionaryManager()
        im.root!.updateItem("test", withName: "one")
        let seq = ItemManager.createSequenceManager()
        let arr = ItemManager.createArrayManager(elementType: .uuid, elementCount: 2, endianness: .little)
        arr.root!.appendElement(UUID(uuidString: "4DF8BFED-B97F-4923-BB55-6159A58C21BC"))
        arr.root!.appendElement(UUID(uuidString: "8B454F16-F354-4F44-8861-6115137C01E8"))
        seq.root!.appendItem(arr)
        im.root!.updateItem(seq, withName: "two")
        let exp =
        """
        Portal:
            isValid        = true
            endianness     = little
            index          = nil
            column         = nil
            refCount       = 2

        Item:
            itemType       = dictionary
            itemOptions    = none
            itemFlags      = none
            nameByteCount  = 0
            itemByteCount  = 152
            itemValueField = 0x00000000
            itemName       = (none)
            value:
                Item count = 2
                Items:
                    one:
                        itemType       = string
                        itemOptions    = none
                        itemFlags      = none
                        nameByteCount  = 8
                        itemByteCount  = 32
                        itemValueField = 0x00000000
                        itemName       = one
                        value          = test
                    two:
                        itemType       = sequence
                        itemOptions    = none
                        itemFlags      = none
                        nameByteCount  = 8
                        itemByteCount  = 96
                        itemValueField = 0x00000000
                        itemName       = two
                        value:
                            Item count = 1
                            Items:
                                0:
                                    itemType       = array
                                    itemOptions    = none
                                    itemFlags      = none
                                    nameByteCount  = 0
                                    itemByteCount  = 64
                                    itemValueField = 0x00000000
                                    itemName       = (none)
                                    value:
                                        Element type  = uuid
                                        Element bytes = 16
                                        Element count = 2
                                        Elements:
                                              0: 4DF8BFED-B97F-4923-BB55-6159A58C21BC
                                              1: 8B454F16-F354-4F44-8861-6115137C01E8
        """
        let descr = "\(im.root!)"
        XCTAssertEqual(descr, exp)
    }
}
