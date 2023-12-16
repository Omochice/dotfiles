" hook_add {{{
" cnoreabbrev gin Gin
" cnoreabbrev gins GinStatus ++opener=tabnew
" cnoreabbrev ginb GinBranch
" }}}

" gin-status {{{
nnoremap <buffer> h <Plug>(gin-action-stage)
nnoremap <buffer> l <Plug>(gin-action-unstage)
nnoremap <buffer><nowait> q <Cmd>bprevious<CR>
nnoremap <buffer> cc <Cmd>Gin commit<CR>
function! s:open_diff() abort
  if line('.') ==# 1
    return
  endif

  let l:line = getline('.')
  if l:line->len() <= 3 || l:line[3:] =~# '^\s\+\$'
    return
  endif
  let l:filename = l:line[3:]

  let diff_winids = tabpagebuflist()
        \ ->map( { -> bufwinnr(v:val) } )
        \ ->filter( { -> getwinvar(v:val, '&filetype') ==# 'gin-diff'} )
  if diff_winids->len() ==# 0
    let l:current_winid = win_getid()
    execute 'GinDiff' '++opener=botright\ vsplit' '--' l:filename
    call win_gotoid(l:current_winid)
    return
  endif

  " FIXME: if wins is over than 2?
  call win_execute(win_getid(diff_winids[0]), 'GinDiff -- ' .. l:filename)
endfunction

nnoremap <buffer><nowait> d <Cmd>call <SID>open_diff()<CR>
" }}}

" gin-branch {{{
nnoremap <buffer> i <Plug>(gin-action-new)
" }}}
