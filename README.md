## REPL Environment base on Neovim

### Requirements

+ neovim >= 0.5

### Features

* REPL Environment for external interpreter (python, lua, node ...)
* Support lua and vimscript embeded in neovim

### Binding

|Binding | Action |
|---|---|
| `<Plug>(nvim-repl-current-line)` | execute current line          |
| `<Plug>(nvim-repl-current-file)` | execute current file (buffer) |
| `<Plug>(nvim-repl-selection)`    | execute selection zone        |
| `<Plug>(nvim-repl-win-open)`      | open REPL window in current tabpage |
| `<Plug>(nvim-repl-win-close)`     | close REPL window |
| `<Plug>(nvim-repl-win-toggle)`    | toggle REPL window |
| `<Plug>(nvim-repl-buffer-clear)`    | clear buffer |
| `<Plug>(nvim-repl-buffer-close)`    | close buffer (also close window) |

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
        stdoutSanitizer: function(out: string): string;
        stderrSanitizer: function(out: string): string;
    };
    vim = {};  -- this will not produce any effect

    -- javascript, python, ...
})
```

### TODO

- [ ] improve code quality
- [ ] support interactive input
- [ ] spawn interpreter process with tty ?

