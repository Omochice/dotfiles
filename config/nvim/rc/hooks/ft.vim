" ruby {{{
setlocal colorcolumn=100
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
inoreabbrev <buffer> ;; ->
" }}}

" python {{{
setlocal colorcolumn=88
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4

inoreabbrev <buffer> improt import
inoreabbrev <buffer> ;; ->
" }}}

" javascript_typescript {{{
setlocal commentstring=//\ %s
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
" }}}

" yaml {{{
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal spell
" }}}

" vue {{{
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
" }}}

" go {{{
inoreabbrev <buffer> ;; :=
" }}}

" htmldjango {{{
setlocal filetype=html
" }}}

" vim {{{
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
" }}}

" json {{{
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
" }}}

" toml {{{
setlocal spell
" }}}

" plaintex {{{
setlocal filetype=tex
" }}}

" tex {{{
setlocal wrap
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
" }}}

" qf {{{
setlocal wrap
nnoremap <buffer> j j
nnoremap <buffer> k k
" }}}

" quickrun {{{
setlocal wrap
" }}}

" gitcommit {{{
setlocal spell
setlocal formatoptions=q
" }}}

" help {{{
" from https://thinca.hatenablog.com/entry/20110903/1314982646
nnoremap <buffer> K K
if &l:buftype !=# 'help'
  setlocal list spell tabstop=8 shiftwidth=8 softtabstop=8 textwidth=78
  if exists('+colorcolumn')
    setlocal colorcolumn=+1
  endif
  if has('conceal')
    setlocal conceallevel=0
  endif
endif
" }}}

" elm {{{
inoreabbrev <buffer> ;; ->
" }}}

" gitcommit_markdown {{{
nnoremap <buffer><expr> <C-x> omochice#checkbox#is_checkbox() ? '<CMD>call omochice#checkbox#toggle_checkbox()<CR>' : '<C-x>'
nnoremap <buffer>- <Cmd>call omochice#listitem#toggle_listitem('-')<CR>
inoreabbrev <buffer> ;; ->
" }}}

" plantuml {{{
inoreabbrev <buffer> ;; ->
inoreabbrev <buffer> :: -->
" }}}

" fish {{{
setlocal comments=:#
setlocal commentstring=#%s
" }}}
