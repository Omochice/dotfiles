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

" ddu-ff-filter {{{
cnoreabbrev <buffer> q call ddu#ui#do_action('quit')
nnoremap <buffer><nowait> <C-w><C-w> <C-w><C-w>

inoremap <buffer><nowait> <CR> <Cmd>call ddu#ui#do_action('itemAction')<CR><Esc>
inoremap <buffer><nowait> <C-t> <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'tabedit' } })<CR>
inoremap <buffer><nowait> <C-v> <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'vsplit' } })<CR>
inoremap <buffer><nowait> <C-s> <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'split' } })<CR>
inoremap <buffer><nowait> <C-q> <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'quickfix' })<CR>
inoremap <buffer><nowait> <C-Space> <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
inoremap <buffer><nowait> <C-g> <Cmd>call ddu#ui#multi_actions([['clearSelectAllItems'], ['toggleAllItems'], ['itemAction', #{ name: 'quickfix' }]])<CR>
inoremap <buffer><nowait> <C-o> <Cmd>call ddu#ui#do_action('preview')<CR>
nnoremap <buffer><nowait> <CR> <Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>

nnoremap <buffer><nowait> <C-n> <Cmd>call ddu#ui#ff#execute('call cursor(line(".")+1,0)<Bar>redraw')<CR>
nnoremap <buffer><nowait> <C-p> <Cmd>call ddu#ui#ff#execute('call cursor(line(".")-1,0)<Bar>redraw')<CR>
inoremap <buffer><nowait> <C-n> <Cmd>call ddu#ui#ff#execute('call cursor(line(".")+1,0)<Bar>redraw')<CR>
inoremap <buffer><nowait> <C-p> <Cmd>call ddu#ui#ff#execute('call cursor(line(".")-1,0)<Bar>redraw')<CR>
" }}}
