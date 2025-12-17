let s:save_cpo = &cpo
set cpo&vim

function! omochice#mdfmt#prettier() abort
  const l:bufnr = bufnr()
  const l:saved_cursor = getcurpos()
  silent execute '%!nix run nixpkgs\#prettier -- --tab-width 4 --stdin-filepath example.md'
  call setpos('.', l:saved_cursor)
endfunction

function! omochice#mdfmt#markdownlint_cli2() abort
  const l:tmpfile = $'{tempname()}.md'
  const l:cmd = $'write! ++p {l:tmpfile}'
  echom l:cmd
  execute l:cmd
  silent execute $'%!nix run nixpkgs\#markdownlint-cli2 -- --fix {l:tmpfile->shellescape()}'
  silent execute '%delete _'
  silent execute '0r ' .. fnameescape(l:tmpfile)

  call delete(l:tmpfile)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
