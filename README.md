# BRBON

An Binary Object Notation by Balancing Rock.

BRBON is an in-memory storage manager that has been optimized for speed. The result is a fast loading and fast access binary object manager. Loading is fast because the entire BRBON structure is loaded at once, and does not need conversion before use. Access is fast because all access is vectored and optimizations have been build in to speed up name comparisons. On top of that, static hierarchies can use an access mechanism (Portals) that allow near instantenious access of the underlying data.

The name BRBON appies to both the specification and the API presented in this project.

BRBON is used by the [Swiftfire webserver](http://swiftfire.nl) project.

The [API Reference manual](http://swiftfire.nl/projects/brbon/reference/index.html).

## Status

The BRBON Item specification is considered stable, no changes are planned or expected. Extensions are planned but will be compatible to the current definitions.

The API passes all tests. But is still missing a lot of conveniance operators and even some core operations. However it is usable and future development is expected to be backwards compatible.

The BRBON Block specification is not finished (and lacking from the provided documentation). Blocks are intended for communication and very large data structures. The (finished) Item specification deals with access of objects in a single file, on a single computer.

## Description

BRBON is a binary storage format specification. It started out as a binary version for JSON but the requirement for speed has rendered some JSON aspects obsolete. Still, the JSON origins can be recognised in the object oriented approach.

Talking points:

- Vectored access: The format includes vectors that can be used to quickly traverse the entire structure (in both directions).
- Named objects: Objects may be named for identification, a hash value is included for faster name recognition.
- Aligned to 8 byte boundaries: Most of the elements in the structure are aligned to 8 byte boundaries. This ensures alignment for al types.
- All standard types are supported: Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Float32, Float64, String, Binary.
- Collection types: Array, Dictionary, Sequence, Table.
- Special types: Null, Font, RGB(A), UUID, CrcString, CrcBinary
- Array’s are packed for optimal storage density.
- The maximum Item capacity is 2GB (Int32.max). (The unfinished Block specification will include the capability for larger structures)

Two alternatives for BRBON have been considered: BSON and BinSON. However both were found lacking with respect to the capabilities for high speed (memory mapped) access.

## Usage

### Overview

BRBON is best viewed as a memory area that is formatted according to the BRBON specification. The reference API can be used to read-from and write-to this area. The API keeps the area formatted conform the BRBON specification.

All objects in storage are wrapped in an Item. There is one top level item (a container type) that contains the entire hierarchy. The top level item needs a memory manager wich is called the ItemManager.

To start a BRBON hierarchy an ItemManager must be created containg a top level container item. This can be done using one of the factory methods of ItemManager. Once the item manager is created the hierarchy can be created using the root item of that manager.

BRBON can be used ad-hoc, i.e.create the data structure as needed when needed. However using it ad-hoc can cause some slowdowns when writing data to the BRBON area. This is because increasing the size of an item may cause an expansion in the data structure necessitating a renewed memory allocation and (worst case) a memory-to-memory copy of the complete BRBON area. While it is true that with today's HW performance this is usually not a big deal, it is better to specify a data structure completely before filling it. In this aspect BRBON is similar to a database.

BRBON is strongly typed. A type must be read as the type that was stored.

### Typical example

First create a BRBON ItemManager with a root item of a container type (dictionary, array, sequence or table). Then start reading writing or inspecting items using the root item in the manager. An example:

````swift
let dict = ItemManager.createDictionary()
dict.root["User"] = "John"
dict.root["Cars"] = parkingSpots
let a = dict.root["Cars"].uint16 // Assume that parkingSpots was an UInt16
````    

### Portals

Any item can be looked up by the path to that item. However every lookup requires traversing the hierarchy. Even though this is very quick, this can be made faster still by using Portals.

A Portal is a pointer to an item in the hierarchy. By using portals the need for traversing the hierarchy dissappears.

````swift
let dict = ItemManager.createDictionary()
dict.root["User"] = "John"
dict.root["Cars"] = parkingSpots
let a = dict.root["Cars"].portal // lookup
...
let oldParkingSpots = a.uint16 // no lookup
a = newParkingSpots // no lookup
````

The API will maintain the pointer -used by a portal- to stay in synch with mutations made to the hierarchy. I.e. the portal will always point to the correct memory location even when the hierarchy is mutated. Only when an item is removed (or one of its ancestors is removed) the portal will become invalid. Invalid portals return nil for most operations.

# Version history


#### 1.1.0

- Bugfix: increasing the size of a table caused failures for named tables
- Added test to invoke bug and show that it is resolved

#### 1.0.1

- Documentation updates

#### 1.0.0

- Upped to 1.0.0 for Swiftfire

