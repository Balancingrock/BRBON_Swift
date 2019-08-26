# Available types

## Null

A Null has little application in the reference API. It has no associated values but can have a name. As such it is only good for memory reservations and for presence/no-presence checks.

Portal operations:

````swift
var isNull: Bool {get}
````

The Null struct conforms to the Coder protocol.

## Integers

All sized integers are present: UInt8, UInt16, UInt32, UInt64, Int8, Int16, Int32 and Int64. Only the unsized Int is not available.

Portal operations:

````swift
var isUInt8: Bool {get}
var isUInt16: Bool {get}
var isUInt32: Bool {get}
var isUint64: Bool {get}
var isInt8: Bool {get}
var isInt16: Bool {get}
var isInt32: Bool {get}
var isInt64: Bool {get}
````
The above operations return 'true' if the portal refers to the corresponding type.

````swift
var uint8: UInt8? {get set}
var uint16: UInt16? {get set}
var uint32: UInt32? {get set}
var uint64: UInt64? {get set}
var int8: Int8? {get set}
var int16: Int16? {get set}
var int32: Int32? {get set}
var int64: Int64? {get set}
````

The above operation get or set the value of a portal, but only if the portal refers to that type. Setting a nil is without effect.

All integers conform to the Coder protocol.

## Floats

Both Float32 and Float64 are present. Double is not available (though Swift bridges this to a Float64)

Portal operations:

````swift
var isFloat32: Bool {get}
var isFloat64: Bool {get}
var float32: Float32 {get set}
var float64: Float64 {get set}
````

The above operations work like the integer operations.

All floats conform to the Coder protocol.

## String

Strings are stored as UTF8 code sequences, and hence must be convertible into and from UTF8.

Portal operations:

````swift
var isString: Bool {get}
var string: String {get set}
````

The String conforms to the Coder protocol

## Binary

The Data struct is implemented as a binary.

Portal operations:

````swift
var isBinary: Bool {get}
var binary: Data {get set}
````

The Data conforms to the Coder protocol

## BRCrcString

The CRC string is a string with associated CRC32, the CRC32 is stored first.

````swift
var isCrcString: Bool {get}
var crcString: BRCrcString {get set}
var string: String {get set}
var crc: UInt32 {get}
````

The CRC String can be read and written as String as well as a CrcString. Note that BRCrcString is a struct provided by the reference API.

The BRCrcString conforms to the Coder protocol

## BRCrcBinary

The CrcBinary is a binary with associated CRC32. The CRC32 is stored first.

````swift
var isCrcBinary: Bool {get}
var crcBinary: BRCrcBinary {get set}
var binary: Data {get set}
var crc: UInt32 {get}
````

The CRC Binary can be read and written as a binary (Data) as well as a CrcBinary. Note that BRCrcBinary is a struct provided by the reference API.

The BRCrcBinary conforms to the Coder protocol

## UUID

Portal operations:

````swift
var isUuid: Bool {get}
var uuid: UUID {get set}
````

The UUID conforms to the Coder protocol

## Font

The font is wrapped in a BRFont struct provided by the API.

Portal operations:

````swift
var isFont: Bool {get}
var font: BRFont {get set}
````

The BRFont conforms to the Coder protocol

## Color

The color is wrapped in a BRColor struct provided by the API.

Portal operations:

````swift
var isColor: Bool {get}
var color: BRColor {get set}
````

The BRColor conforms to the Coder protocol

## Array

The array type is a container type that contains elements. The element type must be specified when the array is created, as should the size of each element in bytes. The elements are access through their index. A portal to an element is tied to the index, not the content of the element unless the element contains a container type, then the portal is bound to that container.

Portal operations:

````swift
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
````

## Sequence

The sequence type is a container that contains items, the type of item and the length of each item are indepent of each other. The items are accessed through an index. Portal into a sequence are tied to their item, not the index.

Portal operations:

````swift
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
````

## Dictionary

A dictionary contains other items, where all items have a unique name. The items are referenced by their name.

Portal operations:

````swift
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
````

## Table

A table consists of table fields arranged in columns and rows. Each field can contain a value, or a container. Each column contains the same kind of type and has the same byte count.

````swift
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
````

_Document end_
