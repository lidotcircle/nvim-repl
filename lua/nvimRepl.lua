package.path = package.path .. ';./lua/?.lua'; --TODO DEV

local Execution = require('nvimRepl.mixed_execution_session')

---@type ExecutionSession
local session = Execution.new("vim", nil, { vim = {
    internal = true
}})
session:send("echo 'yes' | echomsg 'nope'")
session:close()

