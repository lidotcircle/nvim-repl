package.path = package.path .. ';./lua/?.lua';

local buffer = require('nvimRepl.output_buffer')

---@type OutputBuffer
local buf = buffer.new("lua")

buf:stdout("hello world")

