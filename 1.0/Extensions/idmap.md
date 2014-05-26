Identifier Map Version 1.0 Specification
========================================
This document describes the `idmap` extension for MapCode 1.0.

Extension name
==============
The name for the extension described here is `idmap`.

Extension metadata
==================
This extension helps provide portability between MapCode applications by adding name-to-id mappings for nodes and items.

The names and their IDs are stored on a string->number static dictionary which can be found on the key "ids" of the extension's dictionary.

Example:

```
Extension Metadata Root
|-- 0
|   |-- "name" => "idmap"
|   |-- "version" => "1.0"
|   |-- "ids"
|   |   |-- "default:dirt" => 1
|   |   |   "default:stone" => 2
...
```