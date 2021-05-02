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

### Settings

```lua
-- optional, and every option is optional
-- if cmdpath isn't specified, using command base on filetype of the buffer
-- and javascript will map to node
require('nvimRelp').setup({
    lua = {
        cmdpath: 'full path to lua interpreter'
        -- only valid for lua to choose between neovim's embeded lua and external command line
        internal: boolean
        args: { }
    }
    vim = {}  -- this will not produce any effect

    -- javascript, python, ...
})
```

### TODO

- [ ] improve code quality
- [ ] support interactive input

