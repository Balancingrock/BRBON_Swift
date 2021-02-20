# BRBON - Swift

An API for the Binary Object Notation file/memory format by Balancing Rock.

This Swift API was created for BRBON specification v0.4. Form more on the BRBON specification see: [BRBON](https://github.com/Balancingrock/BRBON)

Status: Frozen. (We have switched to Linux/Ada from our Mac/Swift environment. A new ADA API is under construction)

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

#### 1.3.4 (Frozen)

- Limited Cocoa dependency to macOS only


#### 1.3.2, 1.3.3

- Added swift version, platforms and a LICENSE file.

#### 1.3.1

- Linux compatibility

#### 1.3.0

- Changed Result to ResultCode to avoid confusion with Swift.Result
- Simplified the usage of ResultCode

#### 1.2.4

- Updated BRUtils version.

#### 1.2.3

- Wrapped all ptest var/functions in conditional compilation

#### 1.2.2

- Bugfix for item size updates that failed in container items in table fileds when their size was increased
- Bugfix in an assert statement (no runtime relevance)
- Added PTEST compiler condition to add runtime pointer tests before/after use/update/access. Aid in debugging, not recommended for release.
- A few tests were updated

#### 1.2.1

- Bugfix for table output

#### 1.2.0

- Added CustomStringConvertible and CustomDebugStringConvertible to Portal

#### 1.1.0

- Bugfix: increasing the size of a table caused failures for named tables
- Added test to invoke bug and show that it is resolved

#### 1.0.1

- Documentation updates

#### 1.0.0

- Upped to 1.0.0 for Swiftfire

