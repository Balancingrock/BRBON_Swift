# BRBON
An Binary Object Notation by Balancing Rock.
## Description
JSON is a convenient and very maintainable format for data storage and transfer. However the price paid for this convenience is speed. This is not always a problem, but JSON also invites developers to use it as a database replacement system. This works fine for small amounts of data and low intensity access. But as the database grows and is used more intensely a speedier approach will often become necessary.

BRBON was designed for speed, but tries to keep as much from the simplicity of JSON as possible.

For this reason a binary based JSON model was followed but enhanced with vectors, space reservation and 8-byte alignement to allow for maximum speed. There is no optimisation for space for two reasons: memory and storage space is cheap nowadays, and when transferring data there will usually be a compression mechanism available, possibly in hardware.

Strictly speaking BRBON refers to the format specification in this project, not to the implementation. Though an implementation with the same is provided. It should be noted that the current implementation with this name does not implement a (fast) memory map based access mechanism but a simpler memory structure (parsing) based approach.

The current specification is version 0.1 and is intended for storage and access only. It thus concerns itself only with the Item specification. In the future a block wrapper is envisioned that will contain the Items as defined in this document and that may be used to exchange data between applications.

The most glaring omission from this specification is a way to specify the endianness of the Items. This will in the future be included in the block wrapper. For now it is assumed that data is only stored on a single machine or transferred between machines with the same endianness.

The most glaring omission from the current implementation is multithreading support. The API should be accessed from within a single thread.

Two alternatives for BRBON have been considered: BSON and BinSON. However both were found lacking with respect to the capabilities for (vectored) high speed memory mapped access. Though BSON does come close

# Version history

Note: Planned releases are for information only and subject to change without notice.

#### 0.2.0 (Planned)

- Add more conveniance operators.

#### 0.1.0 (Current)

- Initial release.