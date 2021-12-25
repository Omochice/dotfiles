if executable('fcitx')
  augroup fcitx_autodisable
    autocmd!
    autocmd InsertLeave * call system('fcitx-remote -c')
  augroup END
endif
