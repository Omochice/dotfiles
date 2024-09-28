set nocompatible

augroup momomo#vimrc
  autocmd!
augroup END

const s:dpp_base = '~/.cache/dpp'
let $DEIN_RC_DIR = expand('~/.config/nvim/rc')

function s:init_plugin(repo) abort
  if &runtimepath =~# $'/{a:repo}'
    return
  endif
  const l:dst = expand($'{s:dpp_base}/repos/github.com/{a:repo}')
  execute $'set runtimepath^={l:dst}'
  if isdirectory(l:dst)
    return
  endif
  execute $'!git clone https://github.com/{a:repo} {l:dst}'
endfunction

const s:prepends = [
      \ 'Shougo/dpp.vim',
      \ 'vim-denops/denops.vim',
      \ 'tani/vim-artemis',
      \ 'Shougo/dpp-protocol-git',
      \ 'Shougo/dpp-ext-lazy',
      \ 'Shougo/dpp-ext-toml',
      \ 'Shougo/dpp-ext-installer',
      \ ]

for s:repo in s:prepends
  call s:init_plugin(s:repo)
endfor

if s:dpp_base->dpp#min#load_state()
  " NOTE: when fail to load state, create new state
  autocmd User DenopsReady
  \ : echohl WarningMsg
  \ | echomsg 'dpp load_state() is failed'
  \ | echohl NONE
  \ | call dpp#make_state(s:dpp_base, '~/.config/nvim-dark/rc/dpp.ts')
else
  autocmd momomo#vimrc BufWritePost *.lua,*.vim,*.toml,*.ts,vimrc,.vimrc
        \ call dpp#check_files()

  " Check new plugins
  autocmd momomo#vimrc BufWritePost *.toml
        \ : if !dpp#sync_ext_action('installer', 'getNotInstalled')->empty()
        \ |  call dpp#async_ext_action('installer', 'install')
        \ | endif
endif

command! DppInstall call dpp#async_ext_action('installer', 'install')

autocmd User Dpp:makeStatePost
      \ : echohl WarningMsg
      \ | echomsg 'dpp make_state() is done'
      \ | echohl NONE

filetype indent plugin on

if has('syntax')
  syntax on
endif
