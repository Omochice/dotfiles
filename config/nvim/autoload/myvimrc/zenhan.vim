let s:save_cpo = &cpo
set cpo&vim

let s:enabled_zenhan = v:false

function! myvimrc#zenhan#enable() abort
  if s:enabled_zenhan
    call myvimrc#util#error('zenhan is enabled already')
    return
  endif
  if !executable('zenhan.exe')
    call myvimrc#util#error('zenhan.exe is not executable')
  endif
  augroup zenhan_autodisable
    autocmd!
    autocmd InsertLeave * call system('zenhan.exe 0')
  augroup END
  let s:enabled_zenhan = v:true
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
