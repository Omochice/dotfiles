command! Mdfmt call omochice#mdfmt#prettier()
"command! Mdfmt call omochice#mdfmt#markdownlint_cli2()
command! Arto call omochice#arto#open('%:p')

nnoremap gs <Cmd>s/。\s\?/。\r/g<CR>
