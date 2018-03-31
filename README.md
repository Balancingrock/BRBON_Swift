# BRBON
An Binary Object Notation by Balancing Rock.

Current status: The BRBON specification is considered stable, no changes are planned or expected. Extensions are planned but will be compatible to the current definitions.

The API passes all tests. But is still missing a lot of conveniance operators and even some core operations. However it is usable and future development is expected to be largely backwards compatible.

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
- Special type: Null.
- Array’s are packed for optimal storage density.
- The maximum Item capacity is 2GB (Int32.max). (The unfinished Block specification will include the capability for larger structures)

At this point in time BRBON is considered incomplete. The ‘Item’ specification has been completed but the ‘Block’ specification is still open.

The Item specification can be used for local storage needs and is useful on its own. The reference API has been prepared for the Block extension by taking the endianness of the data into account. Endianness will be part of the block specification. 

Two alternatives for BRBON have been considered: BSON and BinSON. However both were found lacking with respect to the capabilities for high speed (memory mapped) access.

# Version history

Note: Planned releases are for information only and subject to change without notice.

#### 0.5.0 (Planned)

- Bugfixes and API upgrades.

#### 0.4.0 (Current)

- The BRBON specification has been changed to allow fatser API implementations.
- The API has been completely re-implemented.

#### 0.3.0

- Complete reworking of the API and some changes in the data structure. Only partly complete.

#### 0.2.0

- Bugfixes and some changes.

#### 0.1.0

- Initial release.