let s:save_cpo = &cpo
set cpo&vim

function! omochice#mdfmt#rumdl() abort
  let l:bufnr = bufnr('.')
  let l:contents = getline(1, '$')->join("\n")
  if trim(l:contents)->empty()
    return
  endif
  let l:curpos = getcurpos('.')
  let l:formatted = systemlist('rumdl fmt --stdin --silent', l:contents)
  if l:formatted->empty()
    return
  endif
  silent! normal! ggVGd
  call setline(1, l:formatted)
  call setpos('.', l:curpos)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
