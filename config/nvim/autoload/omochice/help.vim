" Padding the text to the right with spaces
function! s:padding(text, width) abort
  const l:text = a:text->substitute('\s\+$', '', '')
  if strwidth(l:text) >= a:width
    return l:text
  endif
  return ' '->repeat(a:width - strwidth(l:text) - 1) .. l:text
endfunction

" Align the text after the first word to the right
function! s:right_align(text, width) abort
  if strwidth(a:text) >= a:width
    return a:text
  endif
  const l:words = a:text->split('\s\+')
  if len(l:words) ==# 0
    return a:text
  endif
  const l:head = l:words[0]
  if len(l:words) ==# 1
    return s:padding(a:text, a:width)
  endif
  const l:tail = a:text[l:head->len():]
  return l:head .. s:padding(l:tail, a:width - strwidth(l:head))
endfunction

" Right align the selected lines with |textwidth| (default: 78)
function! omochice#help#right_aligh(line1, line2) abort
  const l:bufnr = bufnr('%')
  const l:textwidth = &textwidth > 0 ? &textwidth : 78
  const l:start = a:line1 < a:line2 ? a:line1 : a:line2
  const l:end = a:line1 < a:line2 ? a:line2 : a:line1
  const l:lines = l:bufnr
        \ ->getbufline(l:start, l:end)
        \ ->map({_, line -> s:right_align(line, l:textwidth)})
  call setbufline(l:bufnr, l:start, l:lines)
endfunction

