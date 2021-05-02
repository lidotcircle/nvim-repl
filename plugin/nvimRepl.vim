
noremap  <silent><Plug>(nvim-repl-current-line) <Cmd>lua require('nvimRepl').execCurrentLine()<cr>
noremap  <silent><Plug>(nvim-repl-current-file) <Cmd>lua require('nvimRepl').execFile()<cr>
vnoremap <silent><Plug>(nvim-repl-selection)    :<c-u>call luaeval("require('nvimRepl').execSelection()")<cr>

