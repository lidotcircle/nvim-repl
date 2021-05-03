local cls = require('uuclass')
local utils = require('nvimRepl.utils')
---@type ExternalExecutionSession
local ExternalExecutionSession = require('nvimRepl.external_execution_session')
local InternalVimExecutionSession = require('nvimRepl.internal_vim_execution_session')
local InternalLuaExecutionSession = require('nvimRepl.internal_lua_execution_session')

---@class MixedExecutionSession: ExecutionSession
local MixedExecutionSession = cls.Extend()

---@param ftype string filetype
---@param config table configuration
---@return ExecutionSession
function MixedExecutionSession.new(ftype, config)
    ---@type MixedExecutionSession
    local obj = {}

    if config.internal then
        if ftype == 'vim' then
            obj = InternalVimExecutionSession.new(ftype, config)
        elseif ftype == 'lua' then
            obj = InternalLuaExecutionSession.new(ftype, config)
        else
            assert(false, "bad configuraion")
        end
    else
        obj = ExternalExecutionSession.new(ftype, config)
    end

    return utils.proxyObject(obj)
end

return MixedExecutionSession

