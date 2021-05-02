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
---@field private config table
---@field private filetype string
---@field private stdin any
---@field private handle any
---@field private closed boolean
local ExternalExecutionSession = cls.Extend(ExecutionSession)

---@param ftype string filetype
---@param config table configuration
---@return ExternalExecutionSession
function ExternalExecutionSession.new(ftype, config)
    local obj = {}
    ExternalExecutionSession.construct(obj)
    obj.buffer = buffer.new(ftype, config)
    obj.filetype = ftype
    obj.config = config
    obj.config.cmdpath = obj.config.cmdpath or which(ftype)

    obj:_start()
    return obj
end

function ExternalExecutionSession:_start()
    local uv = vim.loop
    local stdin = uv.new_pipe(true)
    local stdout = uv.new_pipe(true)
    local stderr = uv.new_pipe(true)
    self.stdin = stdin

    local handle, _ = uv.spawn(self.config.cmdpath, {
        stdio = {stdin, stdout, stderr};
        args = self.config.args or { "-i" };
    }, vim.schedule_wrap(function(code, signal)
        -- TODO
        print(self.config.cmdpath .. " exit code: " .. code .. ", signal: " .. signal)
    end))
    self.handle = handle

    uv.read_start(stdout, vim.schedule_wrap(function(err, data)
        print(err, data)
        if data then
            self.buffer:stdout(data)
        else
            self:_close()
        end
    end))

    uv.read_start(stderr, vim.schedule_wrap(function(err, data)
        print(err, data)
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

function ExternalExecutionSession:isValid()
    return not self.closed
end

function ExternalExecutionSession:close()
    self:_close()
end

---@param codes string | string[]
function ExternalExecutionSession:send(codes)
    self.buffer:code(codes)
    if type(codes) == 'table' then
        codes = table.concat(codes, '\n')
    end
    vim.loop.write(self.stdin, codes)
end

return ExternalExecutionSession

