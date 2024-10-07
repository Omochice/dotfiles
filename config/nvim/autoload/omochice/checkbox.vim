let s:save_cpo = &cpo
set cpo&vim

" Determine is current line checkbox
function! omochice#checkbox#is_checkbox() abort
  return getline(line('.')) =~# '^\s*\(- \)\?\[[x ]\]'
endfunction

" Toggle current line checkbox
function! omochice#checkbox#toggle_checkbox() abort
  let l:lnum = line('.')
  let l:line = getline(l:lnum)
  if l:line =~# '\[x\]'
    let l:line = substitute(l:line, '\[x\]', '[ ]', '')
    call setline(l:lnum, l:line)
    return
  elseif l:line =~# '\[\s\]'
    let l:line = substitute(l:line, '\[\s\]', '[x]', '')
    call setline(l:lnum, l:line)
    return
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
