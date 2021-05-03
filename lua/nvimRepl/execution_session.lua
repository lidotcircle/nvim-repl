local cls = require('uuclass')
local buffer = require('nvimRepl.output_buffer')

---@class ExecutionSession: Object
---@field protected buffer OutputBuffer
local ExecutionSession = cls.Extend()

function ExecutionSession.init(self, ftype, config)
    self.buffer = buffer.new(ftype, config)
end

--[[
   config: {
     [filetype]: {
       cmdpath?: string,
       args?: {}  // lua and vim
       internal?: boolean  // lua
     }
   }
--]]

---@param ftype string filetype
---@param config table configuration
---@return ExecutionSession
function ExecutionSession.new(ftype, config)
    local obj = {}
    ExecutionSession.construct(obj)
    assert(false, "not implemented")
    return obj
end

function ExecutionSession:close()
    assert(false, "not implemented")
end

---@return boolean
function ExecutionSession:isValid()
    assert(false, "not implemented")
end

---@param codes string | string[]
function ExecutionSession:send(codes)
    assert(false, "not implemented")
end

function ExecutionSession:winOpen()
    self.buffer:winOpen()
end
function ExecutionSession:winToggle()
    self.buffer:winToggle()
end
function ExecutionSession:winClose()
    self.buffer:winClose()
end
function ExecutionSession:bufferClear()
    self.buffer:bufferClear()
end
function ExecutionSession:bufferClose()
    self.buffer:bufferClose()
end

return ExecutionSession
