local cls = require('uuclass')
local buffer = require('nvimRepl.output_buffer')
local ExecutionSession = require('nvimRepl.execution_session')

---@class InternalVimExecutionSession: Object
---@field private buffer OutputBuffer
local InternalVimExecutionSession = cls.Extend(ExecutionSession)

---@param ftype string filetype
---@param cmdpath string interpreter path
---@param config table configuration
---@return ExecutionSession
function InternalVimExecutionSession.new(ftype, cmdpath, config)
    assert(ftype == 'vim')
    assert(config and config.vim and config.vim.internal)
    local obj = {}
    InternalVimExecutionSession.construct(obj)
    obj.buffer = buffer.new(ftype)
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

