local cls = require('uuclass')
local ExecutionSession = require('nvimRepl.execution_session')

---@class InternalLuaExecutionSession: Object
local InternalLuaExecutionSession = cls.Extend(ExecutionSession)

---@param ftype string filetype
---@param cmdpath string interpreter path
---@param config table configuration
---@return ExecutionSession
function InternalLuaExecutionSession.new(ftype, cmdpath, config)
    assert(false, "not implemented")
end

function InternalLuaExecutionSession:close()
    assert(false, "not implemented")
end

---@param codes string[]
function InternalLuaExecutionSession:send(codes)
    assert(false, "not implemented")
end

return InternalLuaExecutionSession

