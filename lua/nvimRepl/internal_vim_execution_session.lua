local cls = require('uuclass')
local ExecutionSession = require('nvimRepl.execution_session')

---@class InternalVimExecutionSession: Object
local InternalVimExecutionSession = cls.Extend(ExecutionSession)

---@param ftype string filetype
---@param cmdpath string interpreter path
---@param config table configuration
---@return ExecutionSession
function InternalVimExecutionSession.new(ftype, cmdpath, config)
    assert(false, "not implemented")
end

function InternalVimExecutionSession:close()
    assert(false, "not implemented")
end

---@param codes string[]
function InternalVimExecutionSession:send(codes)
    assert(false, "not implemented")
end

return InternalVimExecutionSession

