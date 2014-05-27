MapCode
=======

MapCode is a standard for saving, loading, compressing and building maps. It aims to provide compression by using a UTF-8-like codepoint system, [modular arithmetic](http://en.wikipedia.org/wiki/Modular%20arithmetic) and extensions.

Let's say you have a 10x10x10 world. That's 1000 blocks. Your usual game would store such world in an array with capacity for 1000 elements, and save them sequentially on disk. With MapCode, the array index would "wrap around" after reaching 1000, so you could save your world as "layers". Extensions may let you repeat a single operation over and over again, like set a block to (for example) stone, and skip a block, allowing you to save a "layer" of stone, then a "layer" of ore generation, then a "layer" of tree generation, then a "layer" of player-built structures.