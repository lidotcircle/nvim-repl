local cls = require('uuclass')
local buffer = require('nvimRepl.output_buffer')
local ExecutionSession = require('nvimRepl.execution_session')

---@class InternalLuaExecutionSession: Object
---@field private buffer OutputBuffer
local InternalLuaExecutionSession = cls.Extend(ExecutionSession)

---@param ftype string filetype
---@param cmdpath string interpreter path
---@param config table configuration
---@return ExecutionSession
function InternalLuaExecutionSession.new(ftype, cmdpath, config)
    local obj = {}
    InternalLuaExecutionSession.construct(obj)
    obj.buffer = buffer.new(ftype)
    return obj
end

function InternalLuaExecutionSession:close()
end

---@param codes string
function InternalLuaExecutionSession:send(codes)
    self.buffer:code(codes)
    local chunk, err = load(codes)
    if err or not chunk then
        self.buffer:stderr("compilation failure\n".. err)
        return
    end
    local function plprint(...)
        local strs = {}
        local argv = { ... }
        for _, arg in ipairs(argv) do
            strs[#strs + 1] = tostring(arg)
        end
        self.buffer:stdout(table.concat(strs, ""))
    end
    local old_print = _G.print
    _G.print = plprint
    local cor = coroutine.create(chunk)
    local res = { coroutine.resume(cor) }
    if not res[1] then
        self.buffer:stderr(res[2])
    elseif #res > 1 then
        table.remove(res, 1)
        old_print(vim.inspect(res))
    end
    _G.print = old_print
end

return InternalLuaExecutionSession

