# BRBON
An Binary Object Notation by Balancing Rock.

Current status: The BRBON specification is considered stable, no changes are planned or expected. Extensions are planned but will be compatible to the current definitions.

The API passes all tests. But is still missing a lot of conveniance operators and even some core operations. However it is usable and future development is expected to be largely backwards compatible at the specification level.

## Description
BRBON is a binary storage format specification. It started out as a binary version for JSON but the requirement for speed has rendered some JSON aspects obsolete. Still, the JSON origins can be recognised in the object oriented approach.

The major design driver for BRBON is speed. Speed in access and speed in loading & storage.

Strictly speaking BRBON only refers to the format specification, not an implementation. However a reference API is offered for free under the same name.

Talking points:

- Vectored access: The format includes vectors that can be used to quickly traverse the entire structure (in both directions).
- Named objects: Objects may be named for identification, a hash value is included for faster name recognition.
- Aligned to 8 byte boundaries: Most of the elements in the structure are aligned to 8 byte boundaries. This ensures alignment for al types.
- All standard types are supported: Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Float32, Float64, String, Binary.
- Collection types: Array, Dictionary, Sequence, Table.
- Special types: Null, Font, RGB(A), UUID, CrcString, CrcBinary
- Array’s are packed for optimal storage density.
- The maximum Item capacity is 2GB (Int32.max). (The unfinished Block specification will include the capability for larger structures)

At this point in time BRBON is considered incomplete. The ‘Item’ specification has been completed but the ‘Block’ specification is still open.

The Item specification can be used for local storage needs and is useful on its own. The reference API has been prepared for the Block extension by taking the endianness of the data into account. Endianness will be part of the block specification. 

Two alternatives for BRBON have been considered: BSON and BinSON. However both were found lacking with respect to the capabilities for high speed (memory mapped) access.

## Usage

### Overview

BRBON is best viewed as a memory area that is formatted according to the BRBON specification. The reference API can be used to read-from and write-to this area. The API keeps the area formatted conform the BRBON specification.

Since all work (access) is done in real-time, there is no parsing, decoding or encoding. Saving, loading, transferring or receiving are as fast as the OS and HW can handle.

BRBON can be used ad-hoc, i.e.create the data structure as needed when needed. However using it ad-hoc can cause some slowdowns when writing data to the BRBON area. This is because increasing the size of an item may cause an expansion in the data structure necessitating a renewed memory allocation and (worst case) a memory-to-memory copy of the complete BRBON area. While it is true that with today's HW performance this is usually not a big deal, it is better to specify a data structure completely before filling it. In this aspect BRBON is similar to a database.

The API uses an Item Manager to create the BRBON memory area and initialize the root item. The root item will usually be a container type: array, dictionary, sequence or table. From there on the API can be used to create and access items in the containers.

BRBON needs to convert Swift Strings to byte sequences before they can be used. For this reason a NameField type is present. It is recommened to use NameFields where possible for optimum speed. Though the API also allows the use of Strings it needs to convert these strings to a NameField before they can be used internally. It is therefore more efficient to use externally created (and stored) NameField's where names are repeatedly used.

### Typical use

First create a BRBON item of the desired type, usually a container type like a dictionary, array, sequence or table. Then start reading writing or inspecting items using the new manager. An example:

    let dict = ItemManager.createDictionary()
    dict.root["User"] = "John"
    dict.root["Cars"] = parkingSpots
    let a = dict.root["Cars"].uint16 // Assume that parkingSpots was an UInt16
    
The root is a Portal that refers to the first item in the memory area. Every access of an item is routed through a Portal, and hence the Portal API is the most used API. It is also the most extensive.

### Available types

#### Null

A Null has little application in the reference API. It has no associated values but can have a name. As such it is only good for memory reservations and for presence/no-presence checks.

Portal operations:

    var isNull: Bool {get}

The Null struct conforms to tge Coder protocol.

#### Integers

All sized integers are present: UInt8, UInt16, UInt32, UInt64, Int8, Int16, Int32 and Int64. Only the unsized Int is not available.

Portal operations:

    var isUInt8: Bool {get}
    var isUInt16: Bool {get}
    var isUInt32: Bool {get}
    var isUint64: Bool {get}
    var isInt8: Bool {get}
    var isInt16: Bool {get}
    var isInt32: Bool {get}
    var isInt64: Bool {get}
    
The above operations return 'true' if the portal refers to the corresponding type.
    
    var uint8: UInt8? {get set}
    var uint16: UInt16? {get set}
    var uint32: UInt32? {get set}
    var uint64: UInt64? {get set}
    var int8: Int8? {get set}
    var int16: Int16? {get set}
    var int32: Int32? {get set}
    var int64: Int64? {get set}

The above operation get or set the value of a portal, but only if the portal refers to that type. Setting a nil is without effect.

All integers conform to the Coder protocol.

#### Floats

Both Float32 and Float64 are present. Double is not available (though Swift bridges this to a Float64)

Portal operations:

    var isFloat32: Bool {get}
    var isFloat64: Bool {get}
    var float32: Float32 {get set}
    var float64: Float64 {get set}

The above operations work like the integer operations.

All floats conform to the Coder protocol.

#### String

Strings are stored as UTF8 code sequences, and hence must be convertible into and from UTF8.

Portal operations:

    var isString: Bool {get}
    var string: String {get set}

The String conforms to the Coder protocol

#### Binary

The Data struct is implemented as a binary.

Portal operations:

    var isBinary: Bool {get}
    var binary: Data {get set}

The Data conforms to the Coder protocol

#### BRCrcString

The CRC string is a string with associated CRC32, the CRC32 is stored first.

    var isCrcString: Bool {get}
    var crcString: BRCrcString {get set}
    var string: String {get set}
    var crc: UInt32 {get}

The CRC String can be read and written as String as well as a CrcString. Note that BRCrcString is a struct provided by the reference API.

The BRCrcString conforms to the Coder protocol

#### BRCrcBinary

The CrcBinary is a binary with associated CRC32. The CRC32 is stored first.

    var isCrcBinary: Bool {get}
    var crcBinary: BRCrcBinary {get set}
    var binary: Data {get set}
    var crc: UInt32 {get}

The CRC Binary can be read and written as a binary (Data) as well as a CrcBinary. Note that BRCrcBinary is a struct provided by the reference API.

The BRCrcBinary conforms to the Coder protocol

#### UUID

Portal operations:

    var isUuid: Bool {get}
    var uuid: UUID {get set}

The UUID conforms to the Coder protocol

#### Font

The font is wrapped in a BRFont struct provided by the API.

Portal operations:

    var isFont: Bool {get}
    var font: BRFont {get set}

The BRFont conforms to the Coder protocol

#### Color

The color is wrapped in a BRColor struct provided by the API.

Portal operations:

    var isColor: Bool {get}
    var color: BRColor {get set}

The BRColor conforms to the Coder protocol

#### Array

The array type is a container type that contains elements. The element type must be specified when the array is created, as should the size of each element in bytes. The elements are access through their index. A portal to an element is tied to the index, not the content of the element unless the element contains a container type, then the portal is bound to that container.

Portal operations:

    var isArray: Bool {get}
    
    subscript(index: Int) -> Portal
    subscript(index: Int) -> Bool?
    subscript(index: Int) -> Int8?
    subscript(index: Int) -> Int16?
    subscript(index: Int) -> Int32?
    subscript(index: Int) -> Int64?
    subscript(index: Int) -> UInt8?
    subscript(index: Int) -> UInt16?
    subscript(index: Int) -> UInt32?
    subscript(index: Int) -> UInt64?
    subscript(index: Int) -> Float32?
    subscript(index: Int) -> Float64?
    subscript(index: Int) -> UUID?
    subscript(index: Int) -> String?
    subscript(index: Int) -> BRCrcString?
    subscript(index: Int) -> Data?
    subscript(index: Int) -> BRCRCBinary?
    subscript(index: Int) -> BRFont?
    subscript(index: Int) -> BRColor?
    
    appendElement(_: Coder?) -> Result
    removeElement(atIndex: Int) -> Result
    insertElement(_: Coder?) -> atIndex: Int) -> Result
    createNewElements(amount: Int = 1, value: Coder = nil) -> Result
    appendElement(_: ItemManager?) -> Result
    appendElements(_: Array<ItemManager>) -> Result
    insertElement(_: ItemManager?, atIndex: Int) -> Result

#### Sequence

The sequence type is a container that contains items, the type of item and the length of each item are indepent of each other. The items are accessed through an index. Portal into a sequence are tied to their item, not the index.

Portal operations:

    var isSequence: Bool {get}
    
    subscript(index: Int) -> Portal
    subscript(index: Int) -> Bool?
    subscript(index: Int) -> Int8?
    subscript(index: Int) -> Int16?
    subscript(index: Int) -> Int32?
    subscript(index: Int) -> Int64?
    subscript(index: Int) -> UInt8?
    subscript(index: Int) -> UInt16?
    subscript(index: Int) -> UInt32?
    subscript(index: Int) -> UInt64?
    subscript(index: Int) -> Float32?
    subscript(index: Int) -> Float64?
    subscript(index: Int) -> UUID?
    subscript(index: Int) -> String?
    subscript(index: Int) -> BRCrcString?
    subscript(index: Int) -> Data?
    subscript(index: Int) -> BRCRCBinary?
    subscript(index: Int) -> BRFont?
    subscript(index: Int) -> BRColor?
    
    func insertItem(atIndex: Int, withValue: Coder) -> Result
    func insertItem(atIndex: Int, withValue: Coder, withName: String) -> Result
    func insertItem(atIndex: Int, withValue: Coder, withNameField: NameField?) -> Result
    func insertItem(atIndex: Int, withValue: ItemManager) -> Result
    func insertItem(atIndex: Int, withValue: ItemManager, withName name: String) -> Result
    func insertItem(atIndex: Int, withValue: ItemManager, withNameField nameField: NameField?) -> Result
    func updateItem(atIndex: Int, withValue: Coder) -> Result
    func updateItem(atIndex: Int, withValue: ItemManager) -> Result
    func replaceItem(atIndex: Int, withValue: Coder, withNameField: NameField? = nil) -> Result
    func replaceItem(atIndex: Int, withValue: ItemManager, withNameField: NameField? = nil) -> Result
    func removeItem(atIndex: Int) -> Result
    func appendItem(_: Coder) -> Result
    func appendItem(_: Coder, withName: String) -> Result
    func appendItem(_: Coder, withNameField: NameField?) -> Result
    func appendItem(_: ItemManager) -> Result
    func appendItem(_: ItemManager, withName: String) -> Result
    func appendItem(_: ItemManager, withNameField: NameField?) -> Result

#### Dictionary

A dictionary contains other items, where all items have a unique name. The items are referenced by their name.

Portal operations:

    var isDictionary: Bool {get}
    
    subscript(name: String) -> Portal
    subscript(nameField: NameField) -> Portal
    subscript(name: String) -> Bool?
    subscript(nameField: NameField) -> Bool?
    subscript(name: String) -> Int8?
    subscript(nameField: NameField) -> Int8?
    subscript(name: String) -> Int16?
    subscript(nameField: NameField) -> Int16?
    subscript(name: String) -> Int32?
    subscript(nameField: NameField) -> Int32?
    subscript(name: String) -> Int64?
    subscript(nameField: NameField) -> Int64?
    subscript(name: String) -> UInt8?
    subscript(nameField: NameField) -> UInt8?
    subscript(name: String) -> UInt16?
    subscript(nameField: NameField) -> UInt16?
    subscript(name: String) -> UInt32?
    subscript(nameField: NameField) -> UInt32?
    subscript(name: String) -> UInt64?
    subscript(nameField: NameField) -> UInt64?
    subscript(name: String) -> Float32?
    subscript(nameField: NameField) -> Float32?
    subscript(name: String) -> Float64?
    subscript(nameField: NameField) -> Float64?
    subscript(name: String) -> String?
    subscript(nameField: NameField) -> String?
    subscript(name: String) -> BRCrcString?
    subscript(nameField: NameField) -> BRCrcString?
    subscript(name: String) -> Data?
    subscript(nameField: NameField) -> Data?
    subscript(name: String) -> BRCrcBinary?
    subscript(nameField: NameField) -> BRCrcBinary?
    subscript(name: String) -> UUID?
    subscript(nameField: NameField) -> UUID?
    subscript(name: String) -> BRColor?
    subscript(nameField: NameField) -> BRColor?
    subscript(name: String) -> BRFont?
    subscript(nameField: NameField) -> BRFont?
    
    func updateItem(_: Coder?, withNameField: NameField?) -> Result
    func updateItem(_: Coder?, withName: String) -> Result
    func updateItem(_: ItemManager?, withNameField: NameField?) -> Result
    func updateItem(_: ItemManager?, withName: String) -> Result
    func replaceItem(_: Coder?, withNameField: NameField?) -> Result
    func replaceItem(_: Coder?, withName: String) -> Result
    func replaceItem(_: ItemManager?, withNameField: NameField?) -> Result
    func replaceItem(_: ItemManager?, withName: String) -> Result
    func removeItem(withNameField: NameField?) -> Result
    func removeItem(withName: String) -> Result

#### Table

A table consists of table fields arranged in columns and rows. Each field can contain a value, or a container. Each column contains the same kind of type and has the same byte count.

    var isTable: Bool {get}
    
    subscript(row: Int, column: NameField?) -> Portal
    subscript(row: Int, column: String) -> Portal
    subscript(row: Int, column: Int?) -> Portal
    subscript(row: Int, column: NameField?) -> Int8?
    subscript(row: Int, column: String) -> Int8?
    subscript(row: Int, column: Int?) -> Int8?
    subscript(row: Int, column: NameField?) -> Int16?
    subscript(row: Int, column: String) -> Int16?
    subscript(row: Int, column: Int?) -> Int16?
    subscript(row: Int, column: NameField?) -> Int32?
    subscript(row: Int, column: String) -> Int32?
    subscript(row: Int, column: Int?) -> Int32?
    subscript(row: Int, column: NameField?) -> Int64?
    subscript(row: Int, column: String) -> Int64?
    subscript(row: Int, column: Int?) -> Int64?
    subscript(row: Int, column: NameField?) -> UInt8?
    subscript(row: Int, column: String) -> UInt8?
    subscript(row: Int, column: Int?) -> UInt8?
    subscript(row: Int, column: NameField?) -> UInt16?
    subscript(row: Int, column: String) -> UInt16?
    subscript(row: Int, column: Int?) -> UInt16?
    subscript(row: Int, column: NameField?) -> UInt32?
    subscript(row: Int, column: String) -> UInt32?
    subscript(row: Int, column: Int?) -> UInt32?
    subscript(row: Int, column: NameField?) -> UInt64?
    subscript(row: Int, column: String) -> UInt64?
    subscript(row: Int, column: Int?) -> UInt64?
    subscript(row: Int, column: NameField?) -> Float32?
    subscript(row: Int, column: String) -> Float32?
    subscript(row: Int, column: Int?) -> Float32?
    subscript(row: Int, column: NameField?) -> Float64?
    subscript(row: Int, column: String) -> Float64?
    subscript(row: Int, column: Int?) -> Float64?
    subscript(row: Int, column: NameField?) -> String?
    subscript(row: Int, column: String) -> String?
    subscript(row: Int, column: Int?) -> String?
    subscript(row: Int, column: NameField?) -> BRCrcString?
    subscript(row: Int, column: String) -> BRCrcString?
    subscript(row: Int, column: Int?) -> BRCrcString?
    subscript(row: Int, column: NameField?) -> Data?
    subscript(row: Int, column: String) -> Data?
    subscript(row: Int, column: Int?) -> Data?
    subscript(row: Int, column: NameField?) -> BRCrcBinary?
    subscript(row: Int, column: String) -> BRCrcBinary?
    subscript(row: Int, column: Int?) -> BRCrcBinary?
    subscript(row: Int, column: NameField?) -> UUID?
    subscript(row: Int, column: String) -> UUID?
    subscript(row: Int, column: Int?) -> UUID?
    subscript(row: Int, column: NameField?) -> BRColor?
    subscript(row: Int, column: String) -> BRColor?
    subscript(row: Int, column: Int?) -> BRColor?
    subscript(row: Int, column: NameField?) -> BRFont?
    subscript(row: Int, column: String) -> BRFont?
    subscript(row: Int, column: Int?) -> BRFont?
    
    func tableColumnIndex(for: NameField?) -> Int?
    func tableColumnIndex(for: String) -> Int?
    
    var rowCount: Int? {get}

    func tableReset(clear: Bool = false)
    func getRow(_: Int) -> Dictionary<String, Portal>
    func addRows(_: Int, values: SetTableFieldDefaultValue? = nil) -> Result
    func removeRow(_: Int) -> Result
    func removeColumn(_: String) -> Result
    func addColumn(type: ItemType, nameField: NameField, byteCount: Int, default: SetTableFieldDefaultValue? = nil) -> Result 
    func addColumns(_: Array<ColumnSpecification>, defaultValues: SetTableFieldDefaultValue? = nil) -> Result
    func addColumn(_: ColumnSpecification, defaultValues: SetTableFieldDefaultValue? = nil) -> Result
    func insertRows(atIndex: Int, amount: Int = 1, defaultValues: SetTableFieldDefaultValue? = nil) -> Result
    func assignField(atRow: Int, inColumn: Int, fromManager: ItemManager) -> Result
    func createFieldArray(atRow: Int, inColumn: Int, elementType: ItemType, elementByteCount: Int? = nil, elementCount: Int) -> Result
    func createFieldSequence(atRow: Int, inColumn: Int, valueByteCount: Int? = nil) -> Result
    func createFieldDictionary(atRow: Int, inColumn: Int, valueByteCount: Int? = nil) -> Result
    func createFieldTable(atRow: Int, inColumn: Int, columnSpecifications: inout Array<ColumnSpecification>) -> Result

# Version history

Note: Planned releases are for information only and subject to change without notice.

#### 0.9.0 (Planned)

- Bugfixes and API upgrades as they happen.

#### 0.8.0 (Current)

- Migrated to Swift 5

#### 0.7.0

- Redesign of API (mostly streamlining)
- Added new type RGBA and Font
- Renamed a number of coder files

#### 0.6.0

- Migrated to SPM 4

#### 0.5.0

- Migration to Swift 4

#### 0.4.2

- Added headers
- Fixed access levels

#### 0.4.1

- Added UUID type

#### 0.4.0

- The BRBON specification has been changed to allow fatser API implementations.
- The API has been completely re-implemented.

#### 0.3.0

- Complete reworking of the API and some changes in the data structure. Only partly complete.

#### 0.2.0

- Bugfixes and some changes.

#### 0.1.0

- Initial release.
