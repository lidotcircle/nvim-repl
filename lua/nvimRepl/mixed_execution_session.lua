local cls = require('uuclass')
---@type ExternalExecutionSession
local ExternalExecutionSession = require('nvimRepl.external_execution_session')
local InternalVimExecutionSession = require('nvimRepl.internal_vim_execution_session')
local InternalLuaExecutionSession = require('nvimRepl.internal_lua_execution_session')

---@class MixedExecutionSession: Object
---@field private proxyObj ExecutionSession
local MixedExecutionSession = cls.Extend()

---@param ftype string filetype
---@param cmdpath string interpreter path
---@param config table configuration
---@return ExecutionSession
function MixedExecutionSession.new(ftype, cmdpath, config)
    ---@type MixedExecutionSession
    local obj = {}
    config = config or {}
    MixedExecutionSession.construct(obj)

    if config[ftype] and config[ftype].internal then
        if ftype == 'vim' then
            obj.proxyObj = InternalVimExecutionSession.new(ftype, cmdpath, config)
        elseif ftype == 'lua' then
            obj.proxyObj = InternalLuaExecutionSession.new(ftype, cmdpath, config)
        else
            assert(false, "bad configuraion")
        end
    else
        obj.proxyObj = ExternalExecutionSession.new(ftype, cmdpath, config)
    end

    return obj
end

function MixedExecutionSession:close()
    self.proxyObj:close()
end

---@param codes string[]
function MixedExecutionSession:send(codes)
    self.proxyObj:send(codes)
end

return MixedExecutionSession

