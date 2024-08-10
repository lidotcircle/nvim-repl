local cls = require('uuclass')
local popup = require('plenary.popup') -- require 'nvim-lua/popup.nvim'


local objMap = {}
local promptPrefix = '> '

---@class Prompt: Object
---@field private session ExecutionSession
---@field private config  table
---@field private win_id  number
---@field private history string[]
---@field private history_pointer number
local Prompt = cls.Extend()

---@param execSession ExecutionSession
---@param config table
function Prompt.new(execSession, config) --<
    local obj = {}
    Prompt.construct(obj)
    obj.session = execSession
    obj.config = config
    obj.config.promptPrefix = obj.config.promptPrefix or promptPrefix
    obj.history = {}
    obj.history_pointer = 1
    return obj
end -->

---@return Prompt
local function getInstance(win_id) --<
    local ans = objMap[win_id]
    assert(ans ~= nil)
    return ans
end -->

function Prompt.next(win_id) --<
    local obj = getInstance(win_id)
    if obj.history_pointer > #obj.history then return end

    obj.history_pointer = obj.history_pointer + 1
    obj:_set_content()
end -->

function Prompt.prev(win_id) --<
    local obj = getInstance(win_id)
    if obj.history_pointer == 1 then return end

    obj.history_pointer = obj.history_pointer - 1
    obj:_set_content()
end -->

function Prompt.exit(win_id) --<
    local obj = getInstance(win_id)
    obj:_exit()
end -->

function Prompt.exit_stop_insert(win_id) --<
    Prompt.exit(win_id)
    vim.cmd [[stopinsert]]
end -->

function Prompt.backspace(win_id)
    local pos = vim.api.nvim_win_get_cursor(win_id)
    if pos[2] == 1 then return end

    local bufnr = vim.api.nvim_win_get_buf(win_id)
    local obj = getInstance(win_id)
    local prelen = string.len(obj.config.promptPrefix)

    local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, 1, true), '')
    content = string.sub(content, 1, pos[2] + prelen - 2) .. string.sub(content, pos[2] + prelen)

    vim.api.nvim_buf_set_lines(bufnr, 0, 1, true, { content })
    vim.cmd [[startinsert!]]
end

function Prompt.enter(win_id) --<
    local obj = getInstance(win_id)
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, 1, true), '')
    local history = obj.history
    if history[obj.history_pointer] == nil then
        history[obj.history_pointer] = content
    end
    obj.history_pointer = #history + 1
    obj:_set_content()
    content = string.sub(content, string.len(obj.config.promptPrefix) + 1)
    obj.session:send(content)
end -->

local function setkeymap(win_id, mode, lhs, funcname) --<
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    local prefix = '<Cmd>'
    if mode == 'i' then
        prefix = '<c-o>:'
    end
    local rhs = string.format("%slua require('nvimRepl.prompt').%s(%d)<cr>", prefix, funcname, win_id);
    if Prompt[funcname] == nil then
        rhs = funcname
    end
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { noremap = true; silent = true })
end -->

function Prompt:_setup_win() --<
    setkeymap(self.win_id, 'i', '<c-n>',   'next')
    setkeymap(self.win_id, 'i', '<c-p>',   'prev')
    setkeymap(self.win_id, 'i', '<up>',    'prev')
    setkeymap(self.win_id, 'i', '<down>',  'next')
    setkeymap(self.win_id, 'i', '<enter>', 'enter')
    setkeymap(self.win_id, 'i', '<esc>',   'exit_stop_insert')
    setkeymap(self.win_id, 'i', '<c-j>',   '<esc>')

    -- FIXING: backspace doesn't work after nvim_buf_set_lines,
    --         this should be removed after upstream bug be fixed
    -- TODO still buggy
    setkeymap(self.win_id, 'i', '<backspace>', 'backspace')

    setkeymap(self.win_id, 'i', '<c-f>', '<right>')
    setkeymap(self.win_id, 'i', '<c-b>', '<left>')
    setkeymap(self.win_id, 'i', '<c-a>', '<esc>:normal! 0<cr><Cmd>startinsert<cr>')
    setkeymap(self.win_id, 'i', '<c-e>', '<esc>:normal! $<cr><Cmd>startinsert<cr><right>')

    setkeymap(self.win_id, 'n', 'v', 'exit')
    setkeymap(self.win_id, 'n', 'r', 'exit')
    setkeymap(self.win_id, 'n', ':',     'exit')
    setkeymap(self.win_id, 'n', '<esc>', 'exit')

    vim.cmd [[startinsert!]]
end -->

function Prompt:show(title) --<
    if self.win_id then self:_exit() end

    local opts = {
        height  = 1,
        title   = self.config.title or 'Prompt',
        padding = {0, 1, 0, 1},
        border  = {1, 1, 1, 1},
    }
    local uis= vim.api.nvim_list_uis()[1];
    opts.width = math.floor(uis.width * (self.config.width or 0.7))
    opts.line  = math.floor(uis.height * 0.8)
    opts.col   = math.floor((uis.width - opts.width) / 2)

    self.win_id = popup.create('', opts)
    objMap[self.win_id] = self

    vim.api.nvim_win_set_option(self.win_id, 'winblend', self.config.winblend or 0)
    local bufnr = vim.api.nvim_win_get_buf(self.win_id)
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, true, { '' })
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'prompt')
    vim.fn.prompt_setprompt(bufnr, self.config.promptPrefix)
    self:_setup_win()
end -->

function Prompt:_exit() --<
    if vim.api.nvim_win_is_valid(self.win_id) then
        vim.api.nvim_win_close(self.win_id, true)
        self.win_id = nil
    end
end -->

function Prompt:_set_content() --<
    local bufnr = vim.api.nvim_win_get_buf(self.win_id)
    local content = self.history[self.history_pointer]
    vim.cmd [[stopinsert]]
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, true, content and { content } or { self.config.promptPrefix } )
    vim.cmd [[startinsert!]]
end -->

return Prompt

