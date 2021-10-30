if executable('fcitx')
  augroup fcitx_autodisable
    autocmd!
    autocmd InsertLeave * call s:fcitx_disable()
  augroup END

  function! s:fcitx_disable() abort
    call system('fcitx-remote -c')
  endfunction
endif
