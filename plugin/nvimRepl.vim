
noremap  <Plug>(nvim-repl-current-line) <Cmd>lua require('nvimRepl').execCurrentLine()<cr>
noremap  <Plug>(nvim-repl-current-file) <Cmd>lua require('nvimRepl').execFile()<cr>
vnoremap <Plug>(nvim-repl-selection)    <Cmd>lua require('nvimRepl').execSelection()<cr>

