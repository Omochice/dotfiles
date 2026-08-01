setlocal foldmethod=syntax

setlocal foldtext=omochice#difffold#foldtext()

" The staged file list is the part worth reading while writing the message.
let s:selected = search('\C^[#;@!$%^&|:] Changes to be committed:$', 'cnW')
if s:selected
  execute s:selected .. 'foldopen'
endif
unlet s:selected

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '') .. '|setl foldmethod< foldtext<'
