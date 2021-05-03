## A REPL Client for Neovim

### Requirements

+ neovim >= 0.5


### Features

- [X] REPL Environment for external interpreter (python, lua, node ...), still require extra code to clean prompt output from interpreter
- [X] currently [ lua, vim, bash, javascript, python ] is working properly
- [X] Support lua and vimscript embeded in neovim
- [X] support prompt interactive input


### Binding

|Binding | Action |
|---|---|
| `<Plug>(nvim-repl-current-line)` | execute current line          |
| `<Plug>(nvim-repl-current-file)` | execute current file (buffer) |
| `<Plug>(nvim-repl-selection)`    | execute selection zone        |
| `<Plug>(nvim-repl-reset-interpreter)` | close active interpreter |
| `<Plug>(nvim-repl-win-open)`      | open REPL window in current tabpage |
| `<Plug>(nvim-repl-win-close)`     | close REPL window |
| `<Plug>(nvim-repl-win-toggle)`    | toggle REPL window |
| `<Plug>(nvim-repl-buffer-clear)`    | clear buffer |
| `<Plug>(nvim-repl-buffer-close)`    | close buffer (also close window) |
| `<Plug>(nvim-repl-toggle-internal-external-mode)`    | toggle between internal and external mode (only for lua) |
| `<Plug>(nvim-repl-show-prompt)`    | open interactive prompt input |


### Example Configuration

**HINT*: Don't use `noremap` to map keys

```vim
nmap <leader>ax <Plug>(nvim-repl-current-line)
nmap <leader>af <Plug>(nvim-repl-current-file)
vmap <silent>aa <Plug>(nvim-repl-selection)

nmap <leader>ar <Plug>(nvim-repl-reset-interpreter)

nmap <leader>ac <Plug>(nvim-repl-win-close)
nmap <leader>ao <Plug>(nvim-repl-win-open)
nmap <leader>at <Plug>(nvim-repl-win-toggle)
nmap <leader>al <Plug>(nvim-repl-buffer-clear)
nmap <leader>as <Plug>(nvim-repl-buffer-close)

nmap <leader>am <Plug>(nvim-repl-toggle-internal-external-mode)
nmap <leader>ap <Plug>(nvim-repl-show-prompt)
```


### Settings

```lua
-- optional, and every option is optional
-- if cmdpath isn't specified, using command base on filetype of the buffer
-- and javascript will map to node
require('nvimRelp').setup({
    lua = {
        cmdpath: 'full path to lua interpreter';
        cmd:     'using cmd to search executable file instead of filetype';
        -- only valid for lua to choose between neovim's embeded lua and external command line
        internal: boolean;
        -- if this option is nil, value pass to spawn will be { "-i" }
        args: { };
        env:  { "key=value" };
        stdoutSanitizer: function(out: string): [string, string];
        stderrSanitizer: function(err: string): [string, string];
    };
    vim = {};  -- this will not produce any effect

    -- javascript, python, ...
})
```


### TODO

- [ ] spawn interpreter process with tty ?

