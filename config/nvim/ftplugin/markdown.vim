command! Mdfmt call omochice#mdfmt#rumdl()

command! -range -buffer SplitSentences
      \ keeppatterns <line1>,<line2>substitute/。\s\?\ze./。\r/ge

nnoremap <buffer> gs <Cmd>SplitSentences<CR>
xnoremap <buffer> gs :SplitSentences<CR>

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
      \ .. '|delcommand -buffer SplitSentences|nunmap <buffer> gs|xunmap <buffer> gs'
