package.path = package.path .. ';./lua/?.lua'; --TODO DEV

local cls = require('uuclass')
local buffer = require('nvimRepl.output_buffer')

---@param cmd string
---@return string | nil
local function which(cmd)
    local proc = io.popen("which " .. cmd)
    local ans = vim.split(proc:read("*a") or "", "\n")[1]
    if #ans == 0 then ans = nil end
    return ans
end

---@class ExecutionSession: Object
---@field private buffer OutputBuffer
---@field private cmdpath string
---@field private config table
---@field private stdin any
---@field private handle any
---@field private closed boolean
local ExecutionSession = cls.Extend()

---@param ftype string filetype
---@param cmdpath string interpreter path
---@param config table configuration
---@return ExecutionSession
function ExecutionSession.new(ftype, cmdpath, config)
    local obj = {}
    ExecutionSession.construct(obj)
    obj.buffer = buffer.new(ftype)
    obj.config = config or {}
    obj.cmdpath = cmdpath

    if obj.cmdpath == nil then
        if obj.config.cmdpath and obj.config.cmdpath[ftype] then
            obj.cmdpath = obj.config.cmdpath[ftype]
        else
            obj.cmdpath = which(ftype)
        end
    end
    assert(obj.cmdpath ~= nil)

    obj:_start()
    return obj
end

function ExecutionSession:_start()
    local uv = vim.loop
    local stdin = uv.new_pipe(true)
    local stdout = uv.new_pipe(true)
    local stderr = uv.new_pipe(true)
    self.stdin = stdin

    local handle, _ = uv.spawn(self.cmdpath, {
        stdio = {stdin, stdout, stderr}
    }, vim.schedule_wrap(function(code, signal)
        -- TODO
        print(self.cmdpath .. " exit code: " .. code .. ", signal: " .. signal)
    end))
    self.handle = handle

    uv.read_start(stdout, vim.schedule_wrap(function(err, data)
        assert(not err, err)
        if data then
            self.buffer:stdout(data)
        else
            self:_close()
        end
    end))

    uv.read_start(stderr, vim.schedule_wrap(function(err, data)
        assert(not err, err)
        if data then
            self.buffer:stderr(data)
        else
            self:_close()
        end
    end))
end

function ExecutionSession:_close()
    if self.closed then return end
    self.closed = true

    local handle = self.handle
    vim.loop.shutdown(self.stdin, vim.schedule_wrap(function() vim.loop.close(handle) end))
    self.stdin = nil
    self.handle = nil
end

function ExecutionSession:close()
    self:_close()
end

---@param codes string[]
function ExecutionSession:send(codes)
    self.buffer:code(codes)
    vim.loop.write(self.stdin, codes)
end

return ExecutionSession

