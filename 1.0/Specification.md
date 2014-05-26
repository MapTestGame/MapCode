MapCode Version 1.0 Specification
=================================

MapCode is based on UTF-8, and so it uses **codepoints**. All numbers are encoded as codepoints, including (but not limited to): version numbers (major, minor, patch), string lengths, dimension sizes.

Codepoints
==========
A MapCode codepoint looks just like an UTF-8 codepoint, with only a minor difference: codepoints can be up to 8 bytes long. This means codepoints can store up to 42 bits of data.

Basic types
===========
There are 6 basic types.

| Type Name          | Type Code |
| ------------------ | :-------: |
| Number             |     0     |
| String             |     1     |
| Static List        |     2     |
| Dynamic List       |     3     |
| Static dictionary  |     4     |
| Dynamic dictionary |     5     |

Lists are 0-indexed.

String
------
A string is a length (in number of characters/codepoints, not bytes), followed by the string data. All strings must be UTF-8 encoded. Strings may contain embed NULs.

Example:

| Length |  S  |  o  |  n  |  i  |  E  |  x  |  2  |
| :----: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
|   07   |  53 |  6F |  6E |  69 |  45 |  78 |  32 |

Static list
-----------
A static list comprises a length (in number of entries), followed by a type number (as defined above), followed by <length> entries. Decoders must ignore type number when decoding empty lists. Encoders should save proper type number on empty lists.

Example of empty static list:

| Length | Type number |
| :----: | :---------: |
|    0   |      0      |

Example of static list of strings:

| Length | Type number | String 0 length | String 0 data | String 1 length |   String 1 data    |
| :----: | :---------: | :-------------: | :-----------: | :-------------: | :----------------: |
|    2   |      1      |        7        |    SoniEx2    |        18       | MapCode Is Awesome |

Dynamic list
------------
A dynamic list comprises a length (in number of entries), followed by <length> entries.

Example of empty dynamic list:

| Length |
| :----: |
|    0   |

Example of non-empty dynamic list:

| Length | Type number | String length | String data | Type number | String length |    String data     |
| :----: | :---------: | :-----------: | :---------: | :---------: | :-----------: | :----------------: |
|    2   |      1      |       7       |   SoniEx2   |      1      |       18      | MapCode Is Awesome |

Static dictionary
-----------------
A static dictionary comprises a length (in number of entries), followed by a type number (as defined above), followed by <length> entries.

A static dictionary entry comprises a string, followed by a <type>.

Example of empty static dictionary:

| Length | Type number |
| :----: | :---------: |
|    0   |      0      |

Example of string -> string static dictionary:

| Length | Type number | Key length | Key data | String length |    String data     |
| :----: | :---------: | :--------: | :------: | :-----------: | :----------------: |
|    1   |      1      |     7      | SoniEx2  |       18      | MapCode Is Awesome |

Example of string -> number static dictionary:

| Length | Type number | Key length | Key data | Number | Key length | Key data | Number |
| :----: | :---------: | :--------: | :------: | :----: | :--------: | :------: | :----: |
|    1   |      0      |     6      |  Conway  | 196883 |     7      | SoniEx2  |   16   |

Dynamic dictionary
------------------
A dynamic dictionary comprises a length (in number of entries), followed by a type number (as defined above), followed by <length> entries.

A dynamic dictionary entry comprises a string, followed by a <type>.

Example of empty dynamic dictionary:

| Length |
| :----: |
|    0   |

Example of dynamic dictionary:

| Length | Type number | Key length | Key data | Number | Type number | Key length | Key data | Number |
| :----: | :---------: | :--------: | :------: | :----: | :---------: | :--------: | :------: | :----: |
|    1   |      0      |     6      |  Conway  | 196883 |      0      |     7      | SoniEx2  |   16   |

MapCode Files
=============
A MapCode file is a header, followed by extension metadata (if any), followed by the map itself.

Header
------
The header comprises a major version, a minor version, a patch version, dimension information, and an extension list.

### Dimensions
The dimension header comprises 3 codepoints, indicating the length of the X dimension, the length of the Y dimension, and the length of the Z dimension, respectively. Dimensions can have a length of zero.

Dimensions work just like real life dimensions.

A 0-dimensional map is a dot, a point. It's when all dimensions have length 0. It can hold a single node.  
A 1-dimensional map is a line. It's when all dimensions but one have length 0. It can hold X+1 nodes.  
A 2-dimensional map is a rectangle. It's when only one dimension has length 0. It can hold (X+1)\*(Y+1) or X\*Y + X + Y + 1 nodes.  
A 3-dimensional map is a cuboid. It's when all dimensions have a non-0 length. It can hold (X+1)\*(Y+1)\*(Z+1) or X\*Y\*Z + X\*Y + Y\*Z + X\*Z + X + Y + Z + 1 nodes.

### The extension list
The extension list is a static list of strings, where an even index contains an extension name, and the following odd index contains the extension's version.

Extension metadata
------------------
TODO

The map
-------
The map can contain nodes (0x00 - 0xFFFFF) or instructions (TODO).