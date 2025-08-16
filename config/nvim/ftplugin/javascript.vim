function! s:open_it_really() abort
  const l:current_bufnr = bufnr()
  const l:tsfile = $'{expand('%:p:r')}.ts'
  if !filewritable(l:tsfile)
    return
  endif
  if confirm($'Exists {fnamemodify(l:tsfile, ':t')}. Open it?', "&Yes\n&No\n", 1) ==# 1
    execute 'edit' l:tsfile
    execute 'bwipeout' l:current_bufnr
  endif
endfunction

call <SID>open_it_really()
