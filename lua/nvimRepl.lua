package.path = package.path .. ';./lua/?.lua'; --TODO DEV

local Execution = require('nvimRepl.mixed_execution_session')

---@type ExecutionSession
local session = Execution.new("lua", nil, nil)
session:send("print(\"hello\")\n m = 0")
session:send("print(\"hello\")\n m = 0")
session:close()

