local cls = require('uuclass')
local ExecutionSession = require('nvimRepl.execution_session')

local filetype2cmdMapping = {
    javascript = 'node';
    typescript = 'node';
}

---@param cmd string
---@return string | nil
local function which(cmd) --<
    if filetype2cmdMapping[cmd] then cmd = filetype2cmdMapping end
    local proc = io.popen("which " .. cmd)
    local ans = vim.split(proc:read("*a") or "", "\n")[1]
    if #ans == 0 then ans = nil end
    return ans
end -->

---@class ExternalExecutionSession: ExecutionSession
---@field private config table
---@field private filetype string
---@field private stdin any
---@field private handle any
---@field private pid any
---@field private closed boolean
local ExternalExecutionSession = cls.Extend(ExecutionSession)

---@param ftype string filetype
---@param config table configuration
---@return ExternalExecutionSession
function ExternalExecutionSession.new(ftype, config) --<
    local obj = {}
    ExternalExecutionSession.construct(obj)
    ExecutionSession.init(obj, ftype, config)
    obj.filetype = ftype
    obj.config = config
    obj.config.cmdpath = obj.config.cmdpath or which(ftype)

    if not obj.config.lazy then obj:_start() end
    return obj
end -->

function ExternalExecutionSession:_start() --<
    local uv = vim.loop
    local stdin = uv.new_pipe(true)
    local stdout = uv.new_pipe(true)
    local stderr = uv.new_pipe(true)
    self.stdin = stdin

    local handle,pid =  uv.spawn(self.config.cmdpath, {
        stdio = {stdin, stdout, stderr};
        args = self.config.args or { "-i" };
    }, vim.schedule_wrap(function(code, _)
        self.buffer:hint(string.format("(%s) process %d exit with %d", self.filetype, self.pid, code), code ~= 0)
    end))
    self.handle = handle
    self.pid = pid

    uv.read_start(stdout, vim.schedule_wrap(function(err, data)
        if err then
            self.buffer:stderr(err)
            self:_close()
            return
        end

        if data then
            if self.config.stdoutSanitizer then
                local sout, serr = self.config.stdoutSanitizer(data)
                if sout then self.buffer:stdout(sout) end
                if serr then self.buffer:stderr(serr) end
            else
                self.buffer:stdout(data)
            end
        else
            self:_close()
        end
    end))

    uv.read_start(stderr, vim.schedule_wrap(function(err, data)
        if err then
            self.buffer:stderr(err)
            self:_close()
            return
        end

        if data then
            if self.config.stderrSanitizer then
                local sout, serr = self.config.stderrSanitizer(data)
                if sout then self.buffer:stdout(sout) end
                if serr then self.buffer:stderr(serr) end
            else
                self.buffer:stderr(data)
            end
        else
            self:_close()
        end
    end))
end -->

function ExternalExecutionSession:_close() --<
    if self.closed then return end
    self.closed = true

    if not self.handle then return end

    local handle = self.handle
    vim.loop.shutdown(self.stdin, vim.schedule_wrap(function() vim.loop.close(handle) end))
    self.stdin = nil
    self.handle = nil
end -->

function ExternalExecutionSession:isValid() --<
    return not self.closed
end -->

function ExternalExecutionSession:close() --<
    self:_close()
end -->

---@param codes string | string[]
function ExternalExecutionSession:send(codes) --<
    self.buffer:code(codes)
    if not self.handle then self:_start() end

    if type(codes) == type({}) then
        codes = table.concat(codes, '\n')
    end
    if not string.match(codes, "^%s*\n") then
        codes = '\n' .. codes
    end
    if not string.match(codes, ".*\n%s*$") then
        codes = codes .. '\n'
    end
    vim.loop.write(self.stdin, codes)
end -->

return ExternalExecutionSession

