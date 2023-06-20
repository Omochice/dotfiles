" hook_add {{{
let g:fern#disable_default_mappings = v:true
cnoreabbrev fe Fern .
cnoreabbrev fep Fern . -reveal=%
command! TFern tabnew | Fern .
cnoreabbrev tf TFern
command! Drawer Fern . -reveal=% -drawer
cnoreabbrev drawer Drawer
" }}}

" fern {{{
nmap <buffer><nowait> q <Cmd>bprevious<CR>
nmap <buffer><nowait> i <Plug>(fern-action-new-file)
nmap <buffer> o <Plug>(fern-action-new-dir)
nmap <buffer> r <Plug>(fern-action-rename)
nmap <buffer> dd <Plug>(fern-action-remove=)
nmap <buffer> yy <Plug>(fern-action-clipboard-copy)
nmap <buffer> p <Plug>(fern-action-clipboard-paste)
nmap <buffer> h <Plug>(fern-action-collapse)
nmap <buffer> l <Plug>(fern-action-open-or-expand)
nmap <buffer> ! <Plug>(fern-action-hidden:toggle)
" This may be redundant
nmap <buffer> ? <Plug>(fern-action-help)
nmap <buffer> t <Plug>(fern-action-open:tabedit)
nmap <buffer><expr> <Plug>(fern-action-open-or-expand:stay) fern#smart#leaf("<Plug>(fern-action-open)", "<Plug>(fern-action-expand:stay)")
nmap <buffer><expr> <CR> getline('.') =~# '^\s*\|-\s'
      \ ? '<Plug>(fern-action-collapse)'
      \ : '<Plug>(fern-action-open-or-expand:stay)'
" }}}
