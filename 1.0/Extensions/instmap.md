Instruction Map Version 1.0 Specification
=========================================
This document describes the `instmap` extension for MapCode 1.0.

Extension name
==============
The name for the extension described here is `instmap`.

Extension metadata
==================
This extension helps provide portability between MapCode applications and compatiblity between MapCode extensions by adding name-to-id mappings for instructions.

The names and their IDs are stored on a string->number static dictionary which can be found on the key "ids" of the extension's dictionary.

Example:

```
Extension Metadata Root
|-- 0
|   |-- "name" => "instmap"
|   |-- "version" => "1.0"
|   |-- "ids"
|   |   |-- "default:skip" => 0x100000
|   |   |-- "default:repeat" => 0x100001
...
```