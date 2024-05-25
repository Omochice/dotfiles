" ddu-ff {{{
setlocal cursorline
cnoreabbrev <buffer> q call ddu#ui#do_action('quit')
nnoremap <C-w><C-w> <C-w><C-w>

nnoremap <buffer><nowait> i <Cmd>call ddu#ui#do_action("openFilterWindow")<CR>
nnoremap <buffer><nowait> <CR> <Cmd>call ddu#ui#do_action('itemAction')<CR>
nnoremap <buffer><nowait> T <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'tabedit' } })<CR>
nnoremap <buffer><nowait> V <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'vsplit' } })<CR>
nnoremap <buffer><nowait> S <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'split' } })<CR>
nnoremap <buffer><nowait> Q <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'quickfix' })<CR>
nnoremap <buffer><nowait> A <Cmd>call ddu#ui#do_action('chooseAction')<CR>
nnoremap <buffer><nowait> <C-Space> <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
nnoremap <buffer><nowait> p <Cmd>call ddu#ui#do_action('preview')<CR>
nnoremap <buffer><nowait> q <Cmd>call ddu#ui#do_action('quit')<CR>
" }}}
