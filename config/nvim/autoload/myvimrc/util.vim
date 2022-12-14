let s:save_cpo = &cpo
set cpo&vim

function! myvimrc#util#error(msg) abort
  echohl ErrorMsg
  echomsg printf('%s', type(a:msg) ==# v:t_string ? a:msg : string(a:msg))
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
