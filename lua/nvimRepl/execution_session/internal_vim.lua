local cls = require('uuclass')
local ExecutionSession = require('nvimRepl.execution_session')

---@class InternalVimExecutionSession: ExecutionSession
local InternalVimExecutionSession = cls.Extend(ExecutionSession)

---@param config table configuration
---@return ExecutionSession
function InternalVimExecutionSession.new(ftype, config)
    assert(ftype == 'vim')
    assert(config and config.internal)
    local obj = {}
    InternalVimExecutionSession.construct(obj)
    ExecutionSession.init(obj, ftype, config)
    return obj
end

function InternalVimExecutionSession:close()
end

---@return boolean
function ExecutionSession:isValid()
    return true
end

---@param codes string | string[]
function InternalVimExecutionSession:send(codes)
    self.buffer:code(codes)
    if type(codes) == 'table' then
        codes = table.concat(codes, '\n')
    end

    local lua_wrap = coroutine.create(function ()
        return vim.api.nvim_exec(codes, true)
    end)
    local success, text = coroutine.resume(lua_wrap)
    if success then
        self.buffer:stdout(text)
    else
        self.buffer:stderr(text)
    end
end

return InternalVimExecutionSession

