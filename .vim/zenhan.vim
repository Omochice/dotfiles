if executable('zenhan.exe')
  augroup zenhan_autodisable
    autocmd!
    autocmd InsertLeave * call system('zenhan.exe 0')
  augroup END
endif
