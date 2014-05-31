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

local decoder = require('mapcode_decoder')

local ipairs, strfmt = ipairs, string.format;

local function _E(s,...)
    return nil, strfmt(s,...)
end

local M = {}

local function parseTheWholeThing(file, nodetypes, itemtypes, instructions)
    local t, err = decoder.decodeTheWholeThing(file)
    if not t then return nil, err end
    local state = {}
    local world = {}
    state.np = 1
    state.modulus = t.header.modulus
    state.i = 1
    while state.i <= #t.rawData do
        local v = t.rawData[state.i]
        if v < 0x10000 then
            if not nodetypes[v] then
                return _E("Unknown nodetype %d", v)
            end
            world[np] = v
            state.np = (state.np + 1) % state.modulus
        elseif v < 0x200000 then
            return _E("Attempt to use itemtype as node")
        else
            if instructions[v] then
                instructions[v](t, world, state, nodetypes, itemtypes, instructions)
            else
                return _E("Unknown instruction %d", v)
            end
        end
        state.i = state.i + 1
    end
    return t, state
end

return M