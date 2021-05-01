local cls = require('uuclass')

local function getBufferByName(bufname)
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_get_name(buf) == bufname then
            return buf
        end
    end
    return nil
end

local function isValidBuffer(buf)
    local bufs = vim.api.nvim_list_bufs()
    for _, b in ipairs(bufs) do
        if buf == b then return true end
    end
    return false
end

local bufmap = {}

---@class OutputBuffer: Object
---@field private buf number
---@field private win number
local OutputBuffer = cls.Extend()

---@return OutputBuffer
function OutputBuffer.new(ftype, ...)
    local obj = {}
    OutputBuffer.construct(obj)
    obj:init(ftype or 'lua', ...)
    return obj
end

function OutputBuffer:init(ftype)
    self.filetype = ftype
end

function OutputBuffer:_ensure_buffer()
    self.buf = bufmap[self.filetype]
    if not isValidBuffer(self.buf) then
        self.buf = nil
    end

    if self.buf == nil then
        local bufname = '/nvim-repl/[' .. self.filetype .. ']'
        self.buf = getBufferByName(bufname)
        if self.buf == nil then
            self.buf = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_buf_set_name(self.buf, bufname)
        end
        bufmap[self.filetype] = self.buf
    end
end

function OutputBuffer:_ensure_win()
    local wins = vim.api.nvim_tabpage_list_wins(0)
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if buf == self.buf then
            self.win = win
            return
        end
    end

    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_command("new")
    self.win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(current_win)
    vim.api.nvim_win_set_buf(self.win, self.buf)
end

function OutputBuffer:_attach_current_tab()
    self:_ensure_buffer()
    self:_ensure_win()
end

function OutputBuffer:_append_output(lines)
    self:_attach_current_tab()

    if type(lines) == type('') then
        lines = vim.split(lines or "", '\n', true)
    end

    local l0 = vim.api.nvim_buf_line_count(self.buf)
    vim.api.nvim_buf_set_lines(self.buf, l0, l0, true, lines)
    vim.api.nvim_win_set_cursor(self.win, { l0 + #lines, 1})
end

function OutputBuffer:stdout(text)
    self:_append_output(text)
end

function OutputBuffer:stderr(text)
    self:_append_output(text)
end

function OutputBuffer:closeWin()
    if self.win and vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_close(self.win, true)
        self.win = nil
    end
end


return OutputBuffer

