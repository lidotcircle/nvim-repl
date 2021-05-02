local cls = require('uuclass')

---@class ExecutionSession: Object
local ExecutionSession = cls.Extend()

--[[
   config: {
     [filetype]: {
       cmdpath?: string,
       internal?: boolean  // lua and vim
     }
   }
--]]

---@param ftype string filetype
---@param cmdpath string interpreter path
---@param config table configuration
---@return ExecutionSession
function ExecutionSession.new(ftype, cmdpath, config)
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
