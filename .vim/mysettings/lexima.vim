let s:rules = []

let s:rules += [
      \ {'char': '<CR>', 'at': '"""\%#"""', 'input': '<CR>', 'input_after': '<CR>', },
      \ ]

"" ruby
let s:rules += [
      \ {'filetype': 'ruby', 'char': '<Bar>', 'at': '\(do\|{\)\s*\%#', 'input': '<Bar>', 'input_after': '<Bar>', },
      \ {'filetype': 'ruby', 'char': '<BS>', 'at': '|\%#|', 'input': '<BS>', 'delete': 1, },
      \ ]

"" markdown
let s:rules += [
      \ {'filetype': 'markdown', 'char': '<CR>', 'at': '```\w*\%#```', 'input': '<CR>', 'input_after': '<CR>'},
      \ {'filetype': 'markdown', 'char': '#', 'at': '^\%#', 'input': '#<Space>',},
      \ {'filetype': 'markdown', 'char': '#', 'at': '^#\+\s\%#', 'input': '<BS>#<Space>',},
      \ {'filetype': 'markdown', 'char': '<BS>', 'at': '^#\s\%#', 'input': '<BS><BS>',},
      \ {'filetype': 'markdown', 'char': '<BS>', 'at': '^#\{2,}\s\%#', 'input': '<BS><BS><Space>',},
      \ {'filetype': 'markdown', 'char': '<CR>', 'at': '^\s*-\s\w.*\%#', 'input': '<CR>-<Space>',},
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
      \ ]

""latex
let s:rules += [
      \ { 'filetype': ['tex', 'plaintex'], 'char': '$', 'at': '[^\$]*\%#', 'input': '$', 'input_after': '$', },
      \ { 'filetype': ['tex', 'plaintex'], 'char': '$', 'at': '\$\%#\$', 'input': '$<CR>', 'input_after': '<CR>$', 'priority': 10 },
      \ { 'filetype': ['tex', 'plaintex'], 'char': '<BS>', 'at': '\$\%#\$', 'input': '<BS>', 'delete': 1, },
      \ { 'filetype': ['tex', 'plaintex'], 'char': '<CR>', 'at': '^\s*\\item\s.\+\%#$', 'input': '<CR>\item ', },
      \ { 'filetype': ['tex', 'plaintex'], 'char': '<CR>', 'at': '\\begin{\(\w\+\*\?\)}\%#$', 'input': '<CR>', 'input_after': '<CR>\\end{\1}', 'with_submatch': v:true },
      \ ]

for s:rule in s:rules
  call lexima#add_rule(s:rule)
endfor
