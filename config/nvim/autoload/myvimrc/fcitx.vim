let s:save_cpo = &cpo
set cpo&vim

let s:enabled_fcitx = v:false

let s:fcitx = ''

function! s:get_fcitx() abort
  for l:com in ['fcitx5', 'fcitx']
    if executable(l:com)
      return #{ ok: v:true, value: l:com }
    endif
  endfor
  return #{ ok: v:false, error: 'fcitx is not installed yet?' }
endfunction

function! myvimrc#fcitx#enable() abort
  let l:res = s:get_fcitx()
  if !l:res.ok
    call myvimrc#util#error(l:res.error)
    return
  endif
  let s:fcitx = l:res.value
  augroup fcitx_autodisable
    autocmd!
    autocmd InsertLeave * call system(printf('%s-remote -c', s:fcitx))
  augroup END
  let s:enabled_fcitx = v:true
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
