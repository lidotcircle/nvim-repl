local cls = require('uuclass')
local buffer = require('nvimRepl.output_buffer')
local ExecutionSession = require('nvimRepl.execution_session')

local filetype2cmdMapping = {
    javascript = 'node';
    typescript = 'node';
}

---@param cmd string
---@return string | nil
local function which(cmd)
    if filetype2cmdMapping[cmd] then cmd = filetype2cmdMapping end
    local proc = io.popen("which " .. cmd)
    local ans = vim.split(proc:read("*a") or "", "\n")[1]
    if #ans == 0 then ans = nil end
    return ans
end

---@class ExternalExecutionSession: ExecutionSession
---@field private buffer OutputBuffer
---@field private cmdpath string
---@field private config table
---@field private stdin any
---@field private handle any
---@field private closed boolean
local ExternalExecutionSession = cls.Extend(ExecutionSession)

---@param ftype string filetype
---@param cmdpath string interpreter path
---@param config table configuration
---@return ExternalExecutionSession
function ExternalExecutionSession.new(ftype, cmdpath, config)
    local obj = {}
    ExternalExecutionSession.construct(obj)
    obj.buffer = buffer.new(ftype)
    obj.config = config or {}
    obj.cmdpath = cmdpath

    if obj.cmdpath == nil then
        if obj.config[ftype] and obj.config[ftype].cmdpath then
            obj.cmdpath = obj.config[ftype].cmdpath
        else
            obj.cmdpath = which(ftype)
        end
    end
    assert(obj.cmdpath ~= nil)

    obj:_start()
    return obj
end

function ExternalExecutionSession:_start()
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

function ExternalExecutionSession:_close()
    if self.closed then return end
    self.closed = true

    local handle = self.handle
    vim.loop.shutdown(self.stdin, vim.schedule_wrap(function() vim.loop.close(handle) end))
    self.stdin = nil
    self.handle = nil
end

function ExternalExecutionSession:close()
    self:_close()
end

---@param codes string
function ExternalExecutionSession:send(codes)
    self.buffer:code(codes)
    vim.loop.write(self.stdin, codes)
end

return ExternalExecutionSession

