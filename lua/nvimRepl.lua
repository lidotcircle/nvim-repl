local Execution = require('nvimRepl.mixed_execution_session')
local Sanitizer = require('nvimRepl.sanitizer')

local M = {}

local registeredBuffers = {}
local sessions = {}
local globalConfig = {
    vim = {
        internal = true;
    };
    lua = {
        stdoutSanitizer = Sanitizer.lua_stdout;
        stderrSanitizer = Sanitizer.lua_stderr;
    };
}

local function softAssign(target, source) --<
    assert(type(source) == type({}) and type(target) == type({}))
    for key,val in pairs(source) do
        if target[key] == nil or type(val) ~= type({}) then
            target[key] = vim.deepcopy(val)
        else
            softAssign(target[key], val)
        end
    end
end -->

---@param config table
function M.setup(config) --<
    assert(type(config) == type({}))
    softAssign(globalConfig, config)
end -->

---@return number
local function getCurrentBuffer() --<
    local buffer = vim.api.nvim_get_current_buf()
    if not buffer then
        local msg = "NvimRepl: can't get current buffer"
        vim.api.nvim_win_writeln(msg)
        assert(false, msg)
    end

    return buffer
end -->

---@return string
local function getFiletype() --<
    local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
    if not filetype then
        local msg = "NvimRepl: detect filetype fail"
        vim.api.nvim_err_writeln(msg)
        assert(false, msg)
    end

    return filetype
end -->

---@return ExecutionSession | nil
local function getCurrentExecutionSession() --<
    local buffer = getCurrentBuffer()
    return sessions[buffer]
end -->

---@return table
local function iter2array(iter) --<
    local ans = {}
    local res = iter()
    while res do
        ans[#ans + 1] = res
        res = iter()
    end

    return ans
end -->

local function registerBufferDelete(buffer) --<
    if registeredBuffers[buffer] ~= nil then return end

    vim.api.nvim_buf_call(buffer, function()
        vim.api.nvim_command(string.format("autocmd BufDelete <buffer> lua require('nvimRepl').beforeBufferDeleteCallback(%d)", buffer))
    end)
    registeredBuffers[buffer] = true
end -->

local function cleanSessionOfBuffer(buffer) --<
    ---@type ExecutionSession
    local session = sessions[buffer]
    if session then
        if session:isValid() then session:close() end
        sessions[buffer] = nil
    end
end -->

function M.beforeBufferDeleteCallback(buffer) --<
    assert(registeredBuffers[buffer] ~= nil)
    registeredBuffers[buffer] = nil
    cleanSessionOfBuffer(buffer)
end -->

---@return ExecutionSession
local function ensureCurrentExecutionSession() --<
    local filetype = getFiletype()
    local buffer = getCurrentBuffer()

    ---@type ExecutionSession
    local session = sessions[buffer]
    if session and not session:isValid() then
        sessions[buffer] = nil
        session = nil
    end

    if session == nil then
        local config = vim.deepcopy(globalConfig[filetype] or {})
        if vim.api.nvim_exec("echo exists('b:cmdpath')", true) == '1' then
            config.cmdpath = vim.api.nvim_buf_get_var(0, "cmdpath")
        end
        if vim.api.nvim_exec("echo exists('b:internal')", true) == '1' then
            config.internal = vim.api.nvim_buf_get_var(0, "internal") ~= 0
        end

        if filetype == 'vim' then
            config.internal = true
        end

        session = Execution.new(filetype, config)
        sessions[buffer] = session
        registerBufferDelete(buffer)
    end

    return session
end -->

---@param codes string | string[]
local function exec(codes) --<
    local session = ensureCurrentExecutionSession()
    session:send(codes)
end -->

function M.cleanCurrentSession() --<
    local buffer = getCurrentBuffer()
    cleanSessionOfBuffer(buffer)
end -->

function M.winClose() --<
    local session = ensureCurrentExecutionSession()
    session:winClose()
end -->

function M.winOpen() --<
    local session = ensureCurrentExecutionSession()
    session:winOpen()
end -->

function M.winToggle() --<
    local session = ensureCurrentExecutionSession()
    session:winToggle()
end -->

function M.bufferClear() --<
    local session = getCurrentExecutionSession()
    if session then session:bufferClear() end
end -->

function M.bufferClose() --<
    local session = getCurrentExecutionSession()
    if session then session:bufferClose() end
end -->

function M.execFile() --<
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    exec(lines)
end -->

function M.execCurrentLine() --<
    local line = vim.api.nvim_get_current_line()
    exec(line)
end -->

---@return string[]
local function selectionText() --<
    local _startPos = vim.api.nvim_exec("echo getpos(\"'<\")", true)
    local _endPos   = vim.api.nvim_exec("echo getpos(\"'>\")", true)
    local startPos = iter2array(string.gmatch(_startPos, "%d+"))
    local endPos = iter2array(string.gmatch(_endPos, "%d+"))
    local startRow = tonumber(startPos[2])
    local startCol = tonumber(startPos[3])
    local endRow = tonumber(endPos[2])
    local endCol = tonumber(endPos[3])

    local lines = vim.api.nvim_buf_get_lines(0, startRow - 1, endRow, true)
    if #lines > 0 then
        lines[#lines] = string.sub(lines[#lines], 1, endCol)
        lines[1] = string.sub(lines[1], startCol)
    end
    return lines
end -->

function M.execSelection() --<
    local lines = selectionText()
    exec(lines)
end -->

return M

