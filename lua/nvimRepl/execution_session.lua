local cls = require('uuclass')

---@class ExecutionSession: Object
local ExecutionSession = cls.Extend()

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

return ExecutionSession
