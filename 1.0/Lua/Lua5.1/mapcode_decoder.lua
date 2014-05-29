--[[
    The MIT License (MIT)
    
    Copyright (c) 2014 SoniEx2

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]

local M;

local _shift6 = 2^6

local function _E(s,...)
    return nil, string.format(s,...)
end

local decoders = {}

local function _decodeNumber(file, stack, count)
    if count > 0 then
        local n = file:read("*n")
        if n < 0x80 or n > 0xBF then
            return _E("Incomplete MapCode sequence at position 0x%X", file:seek("cur",0) - 1)
        else
            return _decodeNumber(file, (stack * _shift6) + (n - 0x80), count - 1)
        end
    else
        return stack
    end
end

local function decodeNumber(file)
    local n = file:read("*n")
    if not n then -- EOF
        return _E("End of file")
    end
    if n < 0x80 then -- 7-bit
        return n
    elseif n < 0xC0 then -- continuation chars (0x80 - 0xBF aka 0b10xx_xxxx)
        return _E("Invalid MapCode byte 0x%.02X at position 0x%X", n, file:seek("cur",0) - 1)
    elseif n < 0xE0 then -- 2 byte sequences, 6+5=11 bits
        return _decodeNumber(file, (n - 0xC0), 1)
    elseif n < 0xF0 then -- 3 byte sequences, 6+6+4 = 16 bits
        return _decodeNumber(file, (n - 0xE0), 2)
    elseif n < 0xF8 then -- 4 byte sequences, 6+6+6+3 = 21 bits
        return _decodeNumber(file, (n - 0xF0), 3)
    elseif n < 0xFC then -- 5 byte sequences, 6+6+6+6+2 = 26 bits
        return _decodeNumber(file, (n - 0xF8), 4)
    elseif n < 0xFE then -- 6 byte sequences, 6+6+6+6+6+1 = 31 bits
        return _decodeNumber(file, (n - 0xFC), 5)
    elseif n < 0xFF then -- 7 byte sequences, 6+6+6+6+6+6+0 = 36 bits
        return _decodeNumber(file, 0, 6)
    elseif n == 0xFF then -- 8 byte sequences, 6+6+6+6+6+6+6+0 = 42 bits
        return _decodeNumber(file, 0, 7)
    end
end
decoders[0] = decodeNumber

local function _decodeUtf8(file, count, ...)
    if count > 0 then
        local n = file:read("*n")
        if n < 0x80 or n > 0xBF then
            return _E("Incomplete UTF-8 sequence at position 0x%X", file:seek("cur",0) - 1)
        else
            return _decodeUtf8(file, count - 1, string.char(n), ...)
        end
    else
        return {...}
    end
end
local function decodeUtf8(file)
    local n = file:read("*n")
    if not n then -- EOF
        return _E("End of file")
    end
    if n < 0x80 then -- 7-bit
        return {n}
    elseif n < 0xC0 then -- continuation chars (0x80 - 0xBF aka 0b10xx_xxxx)
        return _E("Invalid UTF-8 byte 0x%.02X at position 0x%X", n, file:seek("cur",0) - 1)
    elseif n < 0xE0 then -- 2 byte sequences, 6+5=11 bits
        return _decodeNumber(file, 1)
    elseif n < 0xF0 then -- 3 byte sequences, 6+6+4 = 16 bits
        return _decodeNumber(file, 2)
    elseif n < 0xF8 then -- 4 byte sequences, 6+6+6+3 = 21 bits
        -- TODO validate the thing
        return _decodeNumber(file, 3)
    else
        return _E("Invalid UTF-8 byte 0x%.02X at position 0x%X", n, file:seek("cur",0) - 1)
    end
end

local function decodeString(file)
    local l = decodeNumber(file)
    local _temp = {} -- faster than doing multiple concatenations
    local _i = 0
    while _i < l do
        local _utf8, _err = decodeUtf8(file)
        if not utf8 then return nil, _err end
        for pos = #_utf8, 1, -1 do
            table.insert(_temp, _utf8[pos])
        end
    end
    return table.concat(_temp, '')
end
decoders[1] = decodeString

local function decodeStaticList(file)
    -- length
    local l = decodeNumber(file)
    if l == 0 then
        return {}
    end
    -- type
    local t = decodeNumber(file)
    if decoders[t] then
        local list = {}
        local _i = 0 -- use 0-indexed arrays for easy porting and stuff
        local _decoder = decoders[t]
        while _i < l do
            local _data, _err = _decoder(file)
            if not _data then return nil, _err end
            list[_i] = _data
        end
        setmetatable(list, {__unm=function() return t end})
        return list
    else
        return nil, _E("Unknown type %d at position 0x%x", t, file:seek("cur",0) - 1)
    end
end
decoders[2] = decodeStaticList

local function decodeDynamicList(file)
    -- length
    local l = decodeNumber(file)
    if l == 0 then
        return {}
    end
    local _i = 0 -- use 0-indexed arrays for easy porting and stuff
    local list = {}
    while _i < l do
        -- type
        local t = decodeNumber(file)
        local _decoder = decoders[t]
        if not _decoder then
            return nil, _E("Unknown type %d at position 0x%x", t, file:seek("cur",0) - 1)
        end
        local _data, _err = _decoder(file)
        if not _data then return nil, _err end
        list[_i] = _data
    end
    return list
end
decoders[3] = decodeDynamicList

local function decodeStaticDictionary(file)
    -- length
    local l = decodeNumber(file)
    if l == 0 then
        return {}
    end
    -- type
    local t = decodeNumber(file)
    if decoders[t] then
        local list = {}
        local _i = 0
        local _decoder = decoders[t]
        while _i < l do
            local _data, _name, _err
            _name, _err = decodeString(file)
            if not _name then return nil, _err end
            _data, _err = _decoder(file)
            if not _data then return nil, _err end
            list[_name] = _data
        end
        setmetatable(list, {__unm=function() return t end})
        return list
    else
        return nil, _E("Unknown type %d at position 0x%x", t, file:seek("cur",0) - 1)
    end
end
decoders[4] = decodeStaticDictionary

local function decodeDynamicDictionary(file)
    -- length
    local l = decodeNumber(file)
    if l == 0 then
        return {}
    end
    local _i = 0 -- use 0-indexed arrays for easy porting and stuff
    local list = {}
    while _i < l do
        -- type
        local t = decodeNumber(file)
        local _decoder = decoders[t]
        if not _decoder then
            return nil, _E("Unknown type %d at position 0x%x", t, file:seek("cur",0) - 1)
        end
        local _data, _name, _err
        _name, _err = decodeString(file)
        if not _name then return nil, _err end
        _data, _err = _decoder(file)
        if not _data then return nil, _err end
        list[_name] = _data
    end
    return list
end
decoders[5] = decodeDynamicDictionary

local function decodeHeader(file)
    local VERSION, version, sizex, sizey, sizez, extensionList, err;
    -- MAJOR
    VERSION, err = decodeNumber(file)
    if not VERSION then return nil, err end
    -- minor
    version, err = decodeNumber(file)
    if not version then return nil, err end
    if VERSION ~= 1 and version ~= 0 then
        return _E("Incompatible version %d.%d", VERSION, version)
    end
    header = {version = ("%d.%d"):format(VERSION, version)}
    -- Decode sizes
    -- Use locals because Rio Lua isn't very good at optimizing things
    sizex, err = decodeNumber(file)
    if not sizex then return nil, err end
    sizey, err = decodeNumber(file)
    if not sizey then return nil, err end
    sizez, err = decodeNumber(file)
    if not sizez then return nil, err end
    local sizes = {x = sizex, y = sizey, z = sizez)
    header.sizes = sizes
    -- Modulus, aka when numbers "wrap around"
    local modulus = sizex * sizey * sizez
    header.modulus = modulus
    header.extensionList, err = decodeStaticList(file)
    if not header.extensionList then return nil, err end
    -- the negation operator works on static lists and dictionaries to
    -- get the type of the values.
    -- we use next because #table doesn't work with index 0 and hash.
    if next(header.extensionList) and -header.extensionList ~= 1 then return _E("Invalid extension list with value type %d", -header.extensionList) end
    return header
end

local function decodeTheWholeThing(file)
    local header, extensionMetadata, rawData, err;
    header, err = decodeHeader(file)
    if not header then return nil, err end
    extensionMetadata, err = decodeStaticList(file)
    if not extensionMetadata then return nil, err end
    -- the negation operator works on static lists and dictionaries to
    -- get the type of the values.
    -- we use next because #table doesn't work with index 0 and hash.
    if next(extensionMetadata) and -extensionMetadata ~= 1 then return _E("Invalid extension metadata list with value type %d", -extensionMetadata) end
    rawData = {}
    while true do
        local n, err = decodeNumber(file)
        if not n and err == "End of file" then break
        elseif not n then return nil, err end
        table.insert(rawData, n)
    end
    return {header = header, extensionMetadata = extensionMetadata, rawData = rawData}
end

M = {
    decodeNumber = decodeNumber;
    decodeString = decodeString;
    decodeStaticList = decodeStaticList;
    decodeDynamicList = decodeDynamicList;
    decodeStaticDictionary = decodeStaticDictionary;
    decodeDynamicDictionary = decodeDynamicDictionary;
    decodeHeader = decodeHeader;
    decodeTheWholeThing = decodeTheWholeThing;
}

return M