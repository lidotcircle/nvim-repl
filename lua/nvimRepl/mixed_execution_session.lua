local cls = require('uuclass')
---@type ExternalExecutionSession
local ExternalExecutionSession = require('nvimRepl.external_execution_session')
local InternalVimExecutionSession = require('nvimRepl.internal_vim_execution_session')
local InternalLuaExecutionSession = require('nvimRepl.internal_lua_execution_session')

---@class MixedExecutionSession: Object
---@field private proxyObj ExecutionSession
local MixedExecutionSession = cls.Extend()

---@param ftype string filetype
---@param config table configuration
---@return ExecutionSession
function MixedExecutionSession.new(ftype, config)
    ---@type MixedExecutionSession
    local obj = {}
    MixedExecutionSession.construct(obj)

    if config.internal then
        if ftype == 'vim' then
            obj.proxyObj = InternalVimExecutionSession.new(ftype, config)
        elseif ftype == 'lua' then
            obj.proxyObj = InternalLuaExecutionSession.new(ftype, config)
        else
            assert(false, "bad configuraion")
        end
    else
        obj.proxyObj = ExternalExecutionSession.new(ftype, config)
    end

    return obj
end

function MixedExecutionSession:close()
    self.proxyObj:close()
end

---@return boolean
function MixedExecutionSession:isValid()
    return self.proxyObj:isValid()
end

---@param codes string | string[]
function MixedExecutionSession:send(codes)
    self.proxyObj:send(codes)
end

return MixedExecutionSession

