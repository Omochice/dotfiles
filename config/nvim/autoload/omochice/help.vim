" Padding the text to the right with spaces
function! s:padding(text, width) abort
  const l:text = a:text->substitute('\s\+$', '', '')
  if strwidth(l:text) >= a:width
    return l:text
  endif
  return ' '->repeat(a:width - strwidth(l:text)) .. l:text
endfunction

" Align the text right
" - If first word is a tag then align the rest to right
" - Else align the last word to right
function! s:right_align(text, width) abort
  if strwidth(a:text) >= a:width
    return a:text
  endif
  const l:words = a:text->split('\s\+')
  if len(l:words) ==# 0
    return a:text
  endif
  if len(l:words) ==# 1
    return s:padding(a:text, a:width)
  endif
  const l:is_head_tag = l:words[0] =~# '^\*\S\+\*$'
  const l:head = l:is_head_tag
        \ ? l:words[0]
        \ : a:text[0:stridx(a:text, l:words[-1]) - 1]
  const l:tail = a:text[l:head->len():]->substitute('^\s\+', '', '')
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

