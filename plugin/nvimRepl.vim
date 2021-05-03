
noremap  <silent><Plug>(nvim-repl-current-line) <Cmd>lua require('nvimRepl').execCurrentLine()<cr>
noremap  <silent><Plug>(nvim-repl-current-file) <Cmd>lua require('nvimRepl').execFile()<cr>
vnoremap <silent><Plug>(nvim-repl-selection)    :<c-u>call luaeval("require('nvimRepl').execSelection()")<cr>

noremap  <silent><Plug>(nvim-repl-win-close) <Cmd>lua require('nvimRepl').winClose()<cr>
noremap  <silent><Plug>(nvim-repl-win-open) <Cmd>lua require('nvimRepl').winOpen()<cr>
noremap  <silent><Plug>(nvim-repl-win-toggle) <Cmd>lua require('nvimRepl').winToggle()<cr>
noremap  <silent><Plug>(nvim-repl-buffer-close) <Cmd>lua require('nvimRepl').bufferClose()<cr>
noremap  <silent><Plug>(nvim-repl-buffer-clear) <Cmd>lua require('nvimRepl').bufferClear()<cr>

