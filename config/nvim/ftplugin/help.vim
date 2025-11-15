command! -range -buffer RightAlign call omochice#help#right_align(<line1>, <line2>)
nnoremap <buffer> =r <Cmd>RightAlign<CR>
