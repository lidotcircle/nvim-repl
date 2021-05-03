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

local bufmap = {}

---@class OutputBuffer: Object
---@field private buf      number
---@field private win      number
---@field private filetype string
---@field private config   table
local OutputBuffer = cls.Extend()

---@return OutputBuffer
function OutputBuffer.new(ftype, config, ...) --<
    local obj = {}
    OutputBuffer.construct(obj)
    obj:init(ftype or 'lua', config, ...)
    return obj
end -->

function OutputBuffer:init(ftype, config) --<
    self.filetype = ftype
    self.config = config
    self.buf = nil
    self.win = nil
end -->

function OutputBuffer:_syntax() --<
    vim.api.nvim_buf_call(self.buf, function()
        local cmd = "syntax include @Syntax syntax/"..self.filetype..".vim"
        vim.api.nvim_command(cmd)

        cmd = "syntax region ReplRegion start=+"..self:_start_tag().."+ keepend end=+"..self:_end_tag().."+  contains=@Syntax"
        vim.api.nvim_command(cmd)

        vim.api.nvim_command("syntax match Special +^*>+ ")
        vim.api.nvim_command("syntax match ErrorMsg +^-> .*$+")
        vim.api.nvim_command("syntax match Error +-> + containedin=ErrorMsg contained")

        vim.api.nvim_command("syntax match Comment /++++.*++++/")
        vim.api.nvim_command("syntax match Comment +"..self:_start_tag()..".*$+ containedin=ReplRegion contained")
        vim.api.nvim_command("syntax match Comment +"..self:_end_tag().."+ containedin=ReplRegion contained")
    end)
end -->

function OutputBuffer:_ensure_buffer() --<
    self.buf = bufmap[self.filetype]
    if self.buf and not vim.api.nvim_buf_is_valid(self.buf) then
        self.buf = nil
    end

    if self.buf == nil then
        local bufname = '/nvim-repl/[' .. self.filetype .. ']'
        self.buf = getBufferByName(bufname)
        if self.buf == nil then
            self.buf = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_buf_set_name(self.buf, bufname)
            vim.api.nvim_buf_set_lines(self.buf, 0, 2, false, {"++++ REPL " .. os.date() .. " ++++", ""})
            self:_syntax()
        end
        bufmap[self.filetype] = self.buf
    end
end -->

function OutputBuffer:_ensure_win() --<
    assert(vim.api.nvim_buf_is_valid(self.buf))

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
end -->

function OutputBuffer:_attach_current_tab() --<
    self:_ensure_buffer()
    self:_ensure_win()
end -->

---@param lines string[]
---@param setcursor boolean
function OutputBuffer:_append_output(lines, setcursor) --<
    local line_count = vim.api.nvim_buf_line_count(self.buf)
    vim.api.nvim_buf_set_lines(self.buf, line_count, line_count, true, lines)
    if setcursor and self.win and vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_set_cursor(self.win, { line_count + #lines, 1})
    end
end -->

function OutputBuffer:_start_tag() --<
    return "<"..self.filetype..">"
end -->

function OutputBuffer:_end_tag() --<
    return "</"..self.filetype..">"
end -->

---@param text string | string[]
function OutputBuffer:code(text) --<
    self:_attach_current_tab()

    if not text then return end
    local lines = text
    if type(text) == 'string' then
        lines = vim.split(text, '\n', true)
    else
        lines = vim.deepcopy(text)
    end
    local cur_len = vim.api.nvim_buf_line_count(self.buf)
    local last_lines = vim.api.nvim_buf_get_lines(self.buf, math.max(cur_len-3, 0), cur_len, true)

    local function trim(_text)
        local ans = string.gsub(string.gsub(_text, "^%s+", ""), "%s+$", "")
        return ans
    end


    local match = 0
    for idx, line in ipairs(last_lines) do
        if trim(line) == self:_end_tag() then
            match = idx
            break
        end
    end

    if match > 0 then
        local nlen = cur_len - (#last_lines - match + 1)
        vim.api.nvim_buf_set_lines(self.buf, nlen, cur_len, true, {})
        cur_len = nlen
    else
        table.insert(lines, 1, "")
        table.insert(lines, 2, self:_start_tag() .. "  " .. os.date())
    end
    table.insert(lines, self:_end_tag())

    self:_append_output(lines, true)
end -->

---@param text   string
---@param prefix string
function OutputBuffer:_append_prefixed_lines(text, prefix) --<
    self:_ensure_buffer()

    local lines = vim.split(text or "", '\n', true)

    for idx, line in ipairs(lines) do
        line = prefix .. line
        lines[idx] = line
    end

    self:_append_output(lines)
end -->

---@param text string
function OutputBuffer:stdout(text) self:_append_prefixed_lines(text, "*> ") end

---@param text string
function OutputBuffer:stderr(text) self:_append_prefixed_lines(text, "-> ") end

---@param text string
---@param err  boolean
function OutputBuffer:hint(text, err) self:_append_prefixed_lines(text, err and "--> " or "==> ") end

function OutputBuffer:winClose() --<
    if self.win and vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_close(self.win, true)
        self.win = nil
    end
end -->

function OutputBuffer:winOpen() --<
    self:_attach_current_tab()
end -->

function OutputBuffer:winToggle() --<
    if self.win and vim.api.nvim_win_is_valid(self.win) then
        self:winClose()
    else
        self:winOpen()
    end
end -->

function OutputBuffer:bufferClear() --<
    self:_ensure_buffer()
    local len = vim.api.nvim_buf_line_count(self.buf)
    vim.api.nvim_buf_set_lines(self.buf, 0, len, true, {})
end -->

function OutputBuffer:bufferClose() --<
    if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
        vim.api.nvim_buf_delete(self.buf, {force = true})
    end
end -->

return OutputBuffer

