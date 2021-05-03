## REPL Environment base on Neovim

### Requirements

+ neovim >= 0.5

### Features

- [X] REPL Environment for external interpreter (python, lua, node ...), still require extra code to clean prompt output from interpreter
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

### Settings

```lua
-- optional, and every option is optional
-- if cmdpath isn't specified, using command base on filetype of the buffer
-- and javascript will map to node
require('nvimRelp').setup({
    lua = {
        cmdpath: 'full path to lua interpreter';
        -- only valid for lua to choose between neovim's embeded lua and external command line
        internal: boolean;
        -- if this option is none, it value pass to spawn will be { "-i" }
        args: { };
        env:  { "key=value" };
        stdoutSanitizer: function(out: string): string;
        stderrSanitizer: function(out: string): string;
    };
    vim = {};  -- this will not produce any effect

    -- javascript, python, ...
})
```

### TODO

- [ ] spawn interpreter process with tty ?

