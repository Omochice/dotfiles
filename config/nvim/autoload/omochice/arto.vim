let s:save_cpo = &cpo
set cpo&vim

if has('mac')
  function! omochice#arto#open(path) abort
    execute '!open -a Arto' expand(a:path)->fnameescape()
  endfunction
else
  function! omochice#arto#open(path) abort
    echohl ErrorMsg
    echomsg 'Not support other than macos'
    echohl None
  endfunction
endif

let &cpo = s:save_cpo
unlet s:save_cpo
