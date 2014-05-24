Specification
=============

MapCode is based on UTF-8, and so it uses **codepoints**.

Codepoints
----------
A MapCode codepoint looks just like an UTF-8 codepoint, with only a minor difference: codepoints can be up to 9 bytes long.

Header
------
The header comprises a version number codepoint, followed by dimension information, followed by (todo: stuff)...

### Dimensions
The dimension header comprises 3 codepoints, indicating the length of the X dimension, the length of the Y dimension, and the length of the Z dimension, respectively. Dimensions can have a length of zero.

Dimensions work just like real life dimensions.

A 0-dimensional map is a dot, a point. It's when all dimensions have length 0. It can hold a single node.  
A 1-dimensional map is a line. It's when all dimensions but one have length 0. It can hold X+1 nodes.  
A 2-dimensional map is a rectangle. It's when only one dimension has length 0. It can hold (X+1)*(Y+1) or X*Y + X + Y + 1 nodes.  
A 3-dimensional map is a cuboid. It's when all dimensions have a non-0 length. It can hold (X+1)*(Y+1)*(Z+1) or X*Y*Z + X*Y + Y*Z + X*Z + X + Y + Z + 1 nodes.

(TODO: stuff)