if exists('g:loaded_omochice_clipboard')
  finish
endif
let g:loaded_omochice_clipboard = v:true

let s:save_cpo = &cpo
set cpo&vim

if has('nvim') && !empty($SSH_TTY)
  " Terminals commonly refuse OSC 52 reads.
  lua << EOF
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
EOF
elseif has('mac')
  let g:clipboard = #{
    \   name: 'pbcopy',
    \   copy: {
    \     '+': ['pbcopy'],
    \     '*': ['pbcopy'],
    \   },
    \   paste: {
    \     '+': ['pbpaste'],
    \     '*': ['pbpaste'],
    \   },
    \   cache_enabled: v:false,
    \ }
elseif has('linux') && has('wsl')
  let g:clipboard = #{
    \   name: 'win32yank',
    \   copy: {
    \     '+': ['win32yank.exe', '-i', '--crlf'],
    \     '*': ['win32yank.exe', '-i', '--crlf'],
    \   },
    \   paste: {
    \     '+': ['win32yank.exe', '-o', '--lf'],
    \     '*': ['win32yank.exe', '-o', '--lf'],
    \   },
    \   cache_enabled: v:false,
    \ }
elseif has('linux') && !has('wsl')
  let g:clipboard = #{
    \   name: 'xsel',
    \   copy: {
    \     '+': ['xsel', '--nodetach', '--input', '--clipboard'],
    \     '*': ['xsel', '--nodetach', '--input', '--primary'],
    \   },
    \   paste: {
    \     '+': ['xsel', '--output', '--clipboard'],
    \     '*': ['xsel', '--output', '--primary'],
    \   },
    \   cache_enabled: v:true,
    \ }
endif

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
