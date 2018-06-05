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

BRBON is best viewed as a special memory area that is formatted accoring to the BRBON specification. The API can be used to read-from and write-to this area. The API keeps the area formatted conform the BRBON specification.
To speed up repeated access to data nested somewhere in the BRBON structure, Portals can be used. A Portal maintains a pointer to the item it references. A Portal is bound to a selected item in the data area and its pointer is kept up to date even when the data is shifted around.
The API uses an Item Manager to create and maintain the memory area.

### Typical use

First create a BRBON item of the desired type, usually a container type like a dictionary, array or table. Then start reading writing or inspecting items using the new manager. An example:

    let dict = ItemManager.createDictionary()
    dict.root["User"] = "John"
    dict.root["Cars"] = parkingSpots
    let a = dict.root["Cars"].uint16 // Assume that parkingSpots was an UInt16
    
As shown above the reference API does not implicitly change the type to match a requested type. The reader has to know the type of data to be read. Though inspection operations are present to inspect the type of an item.

The root is a Portal that refers to the first item in a buffer area. It can be used invisible or visible. In the example above only the root item is visible and two invisible portals were used to write the new data for "User" and "Cars". Since there is an overhead involved in creating portals, it is possible to retrieve a portal that can be used to repeatedly access data without incurring the overhead for creating a portal.

Example:

    let user23 = dict.root["Users"][23].portal
    let name = user23["Name"].string
    let age = user23["Age"].uint8"

In this example the user32 is a portal that permanently refers to element 23 in the array called "Users" in the dictionary contained in root.

Note that named portals are fixed to the item with that name, but indexed portals are fixed to the index (not the content).

### Quick reference

#### ItemManager







The top level of the BRBON structure is found in the root member of the ItemManager:

    dict.root

The root is a Portal that refers to the first item in a buffer area.

The following code print "Its a dictionary" because a dictionary was created:

    if dict.root.isDictionary {
        print("Its a dictionary")
    }

To store something in the dictionary use the operation 'updateItem' like this:

    dict.root.updateItem(UInt16(1234), withName: "first")

Alternatively use subscripts:

    dict.root["first"] = UInt16(1234)
    
The BRBON reference API is strongly typed. All value accesses must specify the type of the data to be stored or retrieved.

    let a = dict.root["first"]
    
will generate a compile error since the type to be returned is unknown.
Instead use:

    let a: UInt16? = dict.root["first"]

or:

    let a: = dict.root["first"].uint16

Attempting to read a different type than is contained will return a nil:

    guard let a = dict.root["first"].int16 else { print("Fail!") }

in this example will print "Fail!"

In addition to strong typing, the default type 'Int' is not supported. The size of an Int can change form platform to platform, and the BRBON reference API does not support implicit size conversions.

To obtain a portal for a specific path use:

    let p: Portal = dict.root["first"]

or

    let p = dict.root["first"].portal

Then access the value of a as if it were a fully specified path:

    let a = p.uint16 // reading
    p = UInt16(67) // storing

To save the BRBON structure to file, use the write:to operation of the item manager.

To load a BRBON structure from file, use the read:from operation of the item manager.

Note that no additional processing is done when reading or writing. There is no parsing or encoding/decoding done at file read or write. Reading and writing are as fast as the operating system can handle.

# Version history

Note: Planned releases are for information only and subject to change without notice.

#### 0.8.0 (Planned)

- Bugfixes and API upgrades.

#### 0.7.0 (Current)

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
