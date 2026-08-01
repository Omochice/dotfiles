let s:save_cpo = &cpo
set cpo&vim

" NOTE: same as vim-gin
const s:prefixes = #{
      \ added: '[+]',
      \ deleted: '[-]',
      \ modified: '[.]',
      \ renamed: '[/]',
      \ }

" Find the `--- old` line of the file section covered by the current fold.
" Returns 0 when the section carries no path header.
function! s:find_header(start, end) abort
  for l:lnum in range(a:start, a:end - 1)
    let l:line = getline(l:lnum)
    if l:line =~# '^@@'
      break
    endif
    if l:line =~# '^--- ' && getline(l:lnum + 1) =~# '^+++ '
      return l:lnum
    endif
  endfor
  return 0
endfunction

" Describe a file section of a unified diff as `[.] path`.
function! omochice#difffold#foldtext() abort
  const l:header = s:find_header(v:foldstart, v:foldend)
  if l:header == 0
    return foldtext()
  endif

  const l:old = getline(l:header)->matchstr('^--- \zs.\{-}\ze\%(\t\|$\)')->substitute('^a/', '', '')
  const l:new = getline(l:header+1)->matchstr('^+++ \zs.\{-}\ze\%(\t\|$\)')->substitute('^b/', '', '')
  if l:old ==# '/dev/null'
    let l:prefix = s:prefixes['added']
    let l:path = l:new
  elseif l:new ==# '/dev/null'
    let l:prefix = s:prefixes['deleted']
    let l:path = l:old
  elseif l:old !=# l:new
    let l:prefix = s:prefixes['renamed']
    let l:path = l:old . ' -> ' . l:new
  else
    let l:prefix = s:prefixes['modified']
    let l:path = l:new
  endif

  return printf('%s %s', l:prefix, l:path)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
