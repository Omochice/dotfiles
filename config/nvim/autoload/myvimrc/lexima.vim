
let s:save_cpo = &cpo
set cpo&vim

function! myvimrc#lexima#load_rules() abort
  let l:rules = []

  let l:rules += [
        \ #{char: '<CR>', at: '"""\%#"""', input: '<CR>', input_after: '<CR>', },
        \ #{char: '<BS>', at: '<\%#>', input: '<BS>', delete: 1, },
        \ #{char: '　', at: '\%#', input: ' ', },
        \ ]

  "" javascript
  let l:rules += [
        \ #{filetype: ['javascript', 'typescript', 'vue'], char: '<Space>', at: '^\s*\(}\s*else\s\)\?if\%#', input: '<Space>(', input_after: ')' },
        \ #{filetype: ['javascript', 'typescript', 'vue'], char: '>', at: '(\%#)', input: '<Right><Space>=><Space>' },
        \ #{filetype: ['typescript', 'vue'], char: '<', at: 'Record\%#', input: '<', input_after: '>' },
        \ ]

  "" vue
  let l:rules += [
       \ #{filetype: 'vue', char: '<', at: 'define\(Props\|Emits\)\%#', input: '<', input_after: '>',},
       \ ]

  "" ruby
  let l:rules += [
        \ #{filetype: 'ruby', char: '<Bar>', at: '\(do\|{\)\s*\%#', input: '<Bar>', input_after: '<Bar>', },
        \ #{filetype: 'ruby', char: '<BS>', at: '|\%#|', input: '<BS>', delete: 1, },
        \ ]

  "" markdown
  let l:rules += [
        \ #{filetype: 'markdown', char: '<CR>', at: '```\w*\%#```', input: '<CR>', input_after: '<CR>'},
        \ #{filetype: 'markdown', char: '#', at: '^\%#[^#]\?', input: '#<Space>',},
        \ #{filetype: 'markdown', char: '#', at: '^#\+\s\%#', input: '<BS>#<Space>',},
        \ #{filetype: 'markdown', char: '<BS>', at: '^#\s\%#[^#]\?', input: '<BS><BS>',},
        \ #{filetype: 'markdown', char: '<BS>', at: '^#\{2,}\s\%#[^#]\?', input: '<BS><BS><Space>',},
        \ #{filetype: 'markdown', char: '-', at: '^\s*\%#', input: '-<Space>',},
        \ #{filetype: 'markdown', char: '-', at: '^-\s\%#', input: '<BS>-',},
        \ #{filetype: 'markdown', char: '+', at: '^\s*\%#', input: '+<Space>',},
        \ #{filetype: 'markdown', char: '*', at: '^\s*\%#', input: '*<Space>',},
        \ #{filetype: 'markdown', char: '<CR>', at: '^\s*\([-+\*]\)\s.\+\%#\s*$', input: '<CR>\1<Space>', with_submatch: v:true,},
        \ #{filetype: 'markdown', char: '<Tab>', at: '^\s*[-+\*]\s.*\%#', input: '<C-t>', },
        \ #{filetype: 'markdown', char: '<S-Tab>', at: '^\s*[-+\*]\s.*\%#', input: '<C-d>', },
        \ #{filetype: 'markdown', char: '<BS>', at: '^\s*[-+\*]\s\%#', input: '<BS><BS>',},
        \ #{filetype: 'markdown', char: '<CR>', at: '^\s*[-+\*]\s\w.*\%#', input: '<CR>-<Space>',},
        \ #{filetype: 'markdown', char: 'x', at: '\[ \%# \]', input: '<BS>x<Delete>',},
        \ #{filetype: 'markdown', char: '<Space>', at: '\[ \%# \]', input: '<BS><Space><Delete><C-g>U<Right><Space>',},
        \ #{filetype: 'markdown', char: '~', at: '\~\%#[^\~]\?', input: '~', input_after: '~~',},
        \ #{filetype: ['markdown', 'gitcommit'], char: '<Space>', at: '^\s*-\s\+\%#', input: '', },
        \ #{filetype: ['markdown', 'gitcommit'], char: ':', at: '^\%#', input: ':', input_after: ':',},
        \ #{filetype: ['markdown', 'gitcommit'], char: '<BS>', at: '^:\%#:', input: '<BS>', delete: 1,},
        \ ]


  "" vim
  let l:rules += [
        \ #{filetype: 'vim', char: '<CR>', at: '[\[{]\s\?\%#[\]}]$', input: '<CR>\<Space>', input_after: '<CR>\<Space>',},
        \ #{filetype: 'vim', char: '<CR>', at: '^\s*\\.\+\%#', input: '<CR>\<Space>',},
        \ ]

  "" shell
  let l:rules += [
        \ #{filetype: ['sh', 'zsh', 'bash', 'fish'], char: '[', at: 'if\s\%#', input: '[<Space>', input_after: '<Space>]',},
        \ #{filetype: ['sh', 'zsh', 'bash'], char: '[', at: 'if\s[\s\%#', input: '<BS>[<Space>', input_after: '<Space>]', delete: 1,},
        \ #{filetype: ['sh', 'zsh', 'bash'], char: '<Space>', at: '^\s*if\%#', input: '<Space>', input_after: ';<Space>then',},
        \ ]

  "" fish
  let l:rules += [
        \ #{filetype: 'fish', char: '<CR>', at: '\s*if.*\%#', input: '<CR>', input_after: '<CR>end'},
        \ ]

  "" Python
  let l:rules += [
        \ #{filetype: 'python', char: '%', at: '^#\s%\%#', input_after: '<CR><CR># %%',},
        \ ]

  "" HTML
  let l:rules += [
        \ #{ filetype: ['html', 'htmldjango'], char: '%', at: '{\%#}', input: '%<Space>', input_after: '<Space>%',},
        \ #{ filetype: ['html', 'htmldjango', 'vue'], char: '<CR>', at: '>\%#<', input: '<CR>', input_after: '<CR>',},
        \ ]

  "" latex
  let l:rules += [
        \ #{ filetype: ['tex', 'plaintex'], char: '$', at: '[^\$]*\%#', input: '$', input_after: '$', },
        \ #{ filetype: ['tex', 'plaintex'], char: '$', at: '\$\%#\$', input: '$<CR>', input_after: '<CR>$', priority: 10 },
        \ #{ filetype: ['tex', 'plaintex'], char: '<BS>', at: '\$\%#\$', input: '<BS>', delete: 1, },
        \ #{ filetype: ['tex', 'plaintex'], char: '<CR>', at: '^\s*\\item\s.\+\%#$', input: '<CR>\item ', },
        \ #{ filetype: ['tex', 'plaintex'], char: '<CR>', at: '\\begin{\(\w\+\*\?\)}\%#$', input: '<CR>', input_after: '<CR>\\end{\1}', with_submatch: v:true },
        \ ]

  "" plantuml
  let l:rules += [
        \ #{ filetype: 'plantuml', char: '<CR>', at: '^\s*@startuml\s*\%#', input: '<CR>', input_after: '<CR>@enduml' },
        \ #{ filetype: 'plantuml', char: '<CR>', at: '^\s*\(alt\|opt\|loop\|par\|group\)\s\?.*\%#', input: '<CR>', input_after: '<CR>end' },
        \ #{ filetype: 'plantuml', char: '<CR>', at: '\s*note \(left\( of\)\?\|right\( of\)\?\|over\).*\%#', input: '<CR>', input_after: '<CR>end note' },
        \ #{ filetype: 'plantuml', char: '<CR>', at: '\s*box.*\%#', input: '<CR>', input_after: '<CR>end box' },
        \ #{ filetype: 'plantuml', char: '<CR>', at: 'then\%#', input: '<CR>', input_after: '<CR>endif' },
        \ #{ filetype: 'plantuml', char: '=', at: '^\s*=\%#', input: '=', input_after: '==' },
        \ #{ filetype: 'plantuml', char: '<Space>', at: '==\%#==', input: '<Space>', input_after: '<Space>' },
        \ #{ filetype: 'plantuml', char: '<BS>', at: '=\%#=', input: '<BS>', delete: 1, },
        \ #{ filetype: 'plantuml', char: '<BS>', at: '= \%# =', input: '<BS>', delete: 1, },
        \ ]

  "" react
  let l:rules += [
        \ #{ filetype: 'typescriptreact', char: '>', at: '<\%#', input: '>', input_after: '</>' },
        \ #{ filetype: 'typescriptreact', char: '<CR>', at: '<>\%#</>', input: '<CR>', input_after: '<CR>' },
        \ ]

  "" lua
  let l:rules += [
        \ #{ filetype: 'lua', char: '<CR>', at: '^function.*\%#', input: '<CR>', input_after: '<CR>end' },
        \ #{ filetype: 'lua', char: '<Space>', at: 'if\%#', input: '<Space>', input_after: '<Space>then<CR>end' }
        \ ]

  for l:rule in l:rules
    call lexima#add_rule(l:rule)
  endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
