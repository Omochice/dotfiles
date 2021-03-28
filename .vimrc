" dein.vim settings {{m
" install dir {{{
let s:dein_dir = expand('~/.vim/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" }}}

" dein installation check {{{
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . s:dein_repo_dir
endif
" }}}

" begin settings {{{
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " .toml file
  let s:rc_dir = expand('~/.vim/rc')
  if !isdirectory(s:rc_dir)
    call mkdir(s:rc_dir, 'p')
  endif
  let s:toml = s:rc_dir . '/dein.toml'
  let s:lazy_toml = s:rc_dir . '/dein_lazy.toml'

  " read toml and cache
  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " end settings
  call dein#end()
  call dein#save_state()
endif
" }}}

" plugin installation check {{{
if dein#check_install()
  call dein#install()
endif
" }}}

" plugin remove check {{{
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif
" }}}


" user settings 
syntax on
filetype plugin indent on
set nocompatible
set ignorecase
set laststatus=2
set clipboard=unnamed,autoselect
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent 
set nowritebackup
set nobackup 
set noswapfile
set number
set relativenumber
set nowrap
set hlsearch
set infercase
set showmatch
set list listchars=tab:>-
set wildmenu
set incsearch
set gdefault
set iminsert=2
set virtualedit=onemore

set completeopt=menuone,noinsert

"FIXME <C-h> is now working, it will be <BS>
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
nnoremap j gj
nnoremap k gk
noremap q: :q
noremap :qq :q!
noremap :ww :w!

command! Vterm :vs | wincmd l | :term ++curwin
command! Hterm :bo term

augroup rubySettings
    autocmd!
    autocmd BufNewFile, BufRead *.rb setlocal colorcolumn=100 tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup pythonSettings
    autocmd!
    autocmd BufNewFile, BufRead *.py setlocal colorcolumn=88 tabstop=4 softtabstop=4 shiftwidth=4 
    autocmd FileType python iabbrev <buffer> improt import
    autocmd BufWritePre *.py LspDocumentFormatSync
augroup END

augroup fortranSettings
    autocmd!
    autocmd BufWritePre *.f90,*.f08,*.f03 LspDocumentFormatSync
augroup END

augroup jsonSettings
    autocmd!
    autocmd BufNewFile, BufRead *.json setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufWritePre *.json LspDocumentFormatSync
augroup END

augroup yamlfSettings
    autocmd!
    autocmd BufNewFile, BufRead *.yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufWritePre *.yaml LspDocumentFormatSync
augroup END

augroup vueSettings
    autocmd!
    autocmd BufNewFile, BufRead *.vue setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufWritePre *.vue :w | LspDocumentFormatSync
augroup END

augroup TSSettings
    autocmd!
    autocmd BufNewFile, BufRead *.ts setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufWritePre *.ts :w | LspDocumentFormatSync
augroup END
