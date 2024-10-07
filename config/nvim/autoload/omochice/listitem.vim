let s:save_cpo = &cpo
set cpo&vim

function! omochice#listitem#toggle_listitem(marker) abort
  const l:lnum = line('.')
  let l:line = getline(l:lnum)
  if l:line =~# $'^\s*{a:marker}'
    " `- text` => `text`
    let l:line = substitute(l:line, $'{a:marker}\s*', '', '')
    call setline(l:lnum, l:line)
  else
    let l:line = substitute(l:line, '\(\S\)', $'{a:marker} \1', '')
    call setline(l:lnum, l:line)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
