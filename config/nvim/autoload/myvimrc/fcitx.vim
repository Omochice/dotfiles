let s:save_cpo = &cpo
set cpo&vim

let s:enabled_fcitx = v:false

function! myvimrc#fcitx#enable() abort
  if s:enabled_fcitx
    call myvimrc#util#error('fcitx is enabled already')
    return
  endif
  if !executable('fcitx')
    call myvimrc#util#error('fcitx.exe is not executable')
  endif
  augroup fcitx_autodisable
    autocmd!
    autocmd InsertLeave * call system('fcitx-remote -c')
  augroup END
  let s:enabled_fcitx = v:true
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
