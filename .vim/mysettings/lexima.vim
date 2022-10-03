let s:rules = []

let s:rules += [
      \ {'char': '<CR>', 'at': '"""\%#"""', 'input': '<CR>', 'input_after': '<CR>', },
      \ {'char': '<BS>', 'at': '<\%#>', 'input': '<BS>', 'delete': 1, },
      \ ]

"" javascript
let s:rules += [
      \ {'filetype': ['javascript', 'typescript', 'vue'], 'char': '<Space>', 'at': '^\s*\(}\s*else\s\)\?if\%#', 'input': '<Space>(', 'input_after': ')' },
      \ ]

"" vue
let s:rules += [
     \ {'filetype': 'vue', 'char': '<', 'at': 'define\(Props\|Emits\)\%#', 'input': '<', 'input_after': '>',},
     \ ]

"" ruby
let s:rules += [
      \ {'filetype': 'ruby', 'char': '<Bar>', 'at': '\(do\|{\)\s*\%#', 'input': '<Bar>', 'input_after': '<Bar>', },
      \ {'filetype': 'ruby', 'char': '<BS>', 'at': '|\%#|', 'input': '<BS>', 'delete': 1, },
      \ ]

"" markdown
let s:rules += [
      \ {'filetype': 'markdown', 'char': '<CR>', 'at': '```\w*\%#```', 'input': '<CR>', 'input_after': '<CR>'},
      \ {'filetype': 'markdown', 'char': '#', 'at': '^\%#[^#]\?', 'input': '#<Space>',},
      \ {'filetype': 'markdown', 'char': '#', 'at': '^#\+\s\%#', 'input': '<BS>#<Space>',},
      \ {'filetype': 'markdown', 'char': '<BS>', 'at': '^#\s\%#[^#]\?', 'input': '<BS><BS>',},
      \ {'filetype': 'markdown', 'char': '<BS>', 'at': '^#\{2,}\s\%#[^#]\?', 'input': '<BS><BS><Space>',},
      \ {'filetype': 'markdown', 'char': '-', 'at': '^\s*\%#', 'input': '-<Space>',},
      \ {'filetype': 'markdown', 'char': '-', 'at': '^-\s\%#', 'input': '<BS>-',},
      \ {'filetype': 'markdown', 'char': '+', 'at': '^\s*\%#', 'input': '+<Space>',},
      \ {'filetype': 'markdown', 'char': '*', 'at': '^\s*\%#', 'input': '*<Space>',},
      \ {'filetype': 'markdown', 'char': '<CR>', 'at': '^\s*\([-+\*]\)\s.\+\%#\s*$', 'input': '<CR>\1<Space>', 'with_submatch': v:true,},
      \ {'filetype': 'markdown', 'char': '<Tab>', 'at': '^\s*[-+\*]\s.*\%#', 'input': '<C-t>', },
      \ {'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s*[-+\*]\s.*\%#', 'input': '<C-d>', },
      \ {'filetype': 'markdown', 'char': '<BS>', 'at': '^\s*[-+\*]\s\%#', 'input': '<BS><BS>',},
      \ {'filetype': 'markdown', 'char': '<CR>', 'at': '^\s*[-+\*]\s\w.*\%#', 'input': '<CR>-<Space>',},
      \ {'filetype': 'markdown', 'char': 'x', 'at': '\[ \%# \]', 'input': '<BS>x<Delete>',},
      \ {'filetype': 'markdown', 'char': '<Space>', 'at': '\[ \%# \]', 'input': '<BS><Space><Delete><C-g>U<Right><Space>',},
      \ {'filetype': 'markdown', 'char': '~', 'at': '\~\%#[^\~]\?', 'input': '~', 'input_after': '~~',},
      \ ]

"" vim
let s:rules += [
      \ {'filetype': 'vim', 'char': '<CR>', 'at': '[\[{]\s\?\%#[\]}]$', 'input': '<CR>\<Space>', 'input_after': '<CR>\<Space>',},
      \ {'filetype': 'vim', 'char': '<CR>', 'at': '^\s*\\.\+\%#', 'input': '<CR>\<Space>',},
      \ ]

"" shell
let s:rules += [
      \ {'filetype': ['sh', 'zsh', 'bash', 'fish'], 'char': '[', 'at': 'if\s\%#', 'input': '[<Space>', 'input_after': '<Space>]',},
      \ {'filetype': ['sh', 'zsh', 'bash'], 'char': '[', 'at': 'if\s[\s\%#', 'input': '<BS>[<Space>', 'input_after': '<Space>]', 'delete': 1,},
      \ {'filetype': ['sh', 'zsh', 'bash'], 'char': '<Space>', 'at': '^\s*if\%#', 'input': '<Space>', 'input_after': ';<Space>then',},
      \ ]

"" fish
let s:rules += [
      \ {'filetype': 'fish', 'char': '<CR>', 'at': '\s*if.*\%#', 'input': '<CR>', 'input_after': '<CR>end'},
      \ ]

"" Python
let s:rules += [
      \ {'filetype': 'python', 'char': '%', 'at': '^#\s%\%#', 'input_after': '<CR><CR># %%',},
      \ ]

"" HTML
let s:rules += [
      \ { 'filetype': ['html', 'htmldjango'], 'char': '%', 'at': '{\%#}', 'input': '%<Space>', 'input_after': '<Space>%',},
      \ { 'filetype': ['html', 'htmldjango', 'vue'], 'char': '<CR>', 'at': '>\%#<', 'input': '<CR>', 'input_after': '<CR>',},
      \ ]

"" latex
let s:rules += [
      \ { 'filetype': ['tex', 'plaintex'], 'char': '$', 'at': '[^\$]*\%#', 'input': '$', 'input_after': '$', },
      \ { 'filetype': ['tex', 'plaintex'], 'char': '$', 'at': '\$\%#\$', 'input': '$<CR>', 'input_after': '<CR>$', 'priority': 10 },
      \ { 'filetype': ['tex', 'plaintex'], 'char': '<BS>', 'at': '\$\%#\$', 'input': '<BS>', 'delete': 1, },
      \ { 'filetype': ['tex', 'plaintex'], 'char': '<CR>', 'at': '^\s*\\item\s.\+\%#$', 'input': '<CR>\item ', },
      \ { 'filetype': ['tex', 'plaintex'], 'char': '<CR>', 'at': '\\begin{\(\w\+\*\?\)}\%#$', 'input': '<CR>', 'input_after': '<CR>\\end{\1}', 'with_submatch': v:true },
      \ ]

"" plantuml
let s:rules += [
      \ { 'filetype': 'plantuml', 'char': '<CR>', 'at': '^\s*@startuml\s*\%#', 'input': '<CR>', 'input_after': '<CR>@enduml' },
      \ { 'filetype': 'plantuml', 'char': '<CR>', 'at': '^\s*\(alt\|opt\|loop\|par\|group\)\s\?.*\%#', 'input': '<CR>', 'input_after': '<CR>end' },
      \ { 'filetype': 'plantuml', 'char': '<CR>', 'at': '\s*note \(left\( of\)\?\|right\( of\)\?\|over\).*\%#', 'input': '<CR>', 'input_after': '<CR>end note' },
      \ { 'filetype': 'plantuml', 'char': '<CR>', 'at': '\s*box.*\%#', 'input': '<CR>', 'input_after': '<CR>end box' },
      \ { 'filetype': 'plantuml', 'char': '<CR>', 'at': 'then\%#', 'input': '<CR>', 'input_after': '<CR>endif' },
      \ { 'filetype': 'plantuml', 'char': '=', 'at': '^\s*=\%#', 'input': '=', 'input_after': '==' },
      \ { 'filetype': 'plantuml', 'char': '<Space>', 'at': '==\%#==', 'input': ' ', 'input_after': ' ' },
      \ { 'filetype': 'plantuml', 'char': '<BS>', 'at': '=\%#=', 'input': '<BS>', 'delete': 1, },
      \ { 'filetype': 'plantuml', 'char': '<BS>', 'at': '= \%# =', 'input': '<BS>', 'delete': 1, },
      \ ]

for s:rule in s:rules
  call lexima#add_rule(s:rule)
endfor
