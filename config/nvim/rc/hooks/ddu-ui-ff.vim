" ddu-ff {{{
setlocal cursorline
cnoreabbrev <buffer> q call ddu#ui#do_action('quit')
nnoremap <C-w><C-w> <C-w><C-w>

function s:open_or_expand()
  if b:ddu_ui_item->get('isTree', v:false)
    call ddu#ui#do_action('expandItem', #{ mode: 'toggle' })
  else
    call ddu#ui#do_action('itemAction')
  endif
endfunction

nnoremap <buffer><nowait> i <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
nnoremap <buffer><nowait> <CR> <Cmd>call <SID>open_or_expand()<CR>
nnoremap <buffer><nowait> T <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'tabedit' } })<CR>
nnoremap <buffer><nowait> V <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'vsplit' } })<CR>
nnoremap <buffer><nowait> S <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'split' } })<CR>
nnoremap <buffer><nowait> Q <Cmd>call ddu#ui#multi_actions([['clearSelectAllItems'], ['toggleAllItems'], ['itemAction', #{ name: 'quickfix' }]])<CR>
nnoremap <buffer><nowait> A <Cmd>call ddu#ui#do_action('chooseAction')<CR>
nnoremap <buffer><nowait> <S-Tab> <Cmd>call ddu#ui#do_action('toggleAllItems')<CR>
nnoremap <buffer><nowait> <Tab> <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
nnoremap <buffer><nowait> p <Cmd>call ddu#ui#do_action('togglePreview')<CR>
nnoremap <buffer><nowait> q <Cmd>call ddu#ui#do_action('quit')<CR>
" }}}
