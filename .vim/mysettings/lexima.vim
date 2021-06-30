let g:lexima_map_escape = ''
let g:lexima_enable_endwise_rules = 0

let s:rules = []

"" Parenthesis
let s:rules += [
\ { 'char': '<BS>',  'at': '(\%#)', 'input': '<BS><Del>', },
\ ]

"" Brace
let s:rules += [
\ { 'char': '<BS>',  'at': '{\%#}', 'input': '<BS><Del>', },
\ ]

"" Bracket
let s:rules += [
\ { 'char': '<BS>',  'at': '\[\%#\]', 'input': '<BS><Del>', },
\ ]

"" Sinble Quote
let s:rules += [
\ { 'char': '<BS>',  'at': "'\\%#'", 'input': '<BS><Del>', },
\ ]

"" Double Quote
let s:rules += [
\ { 'char': '<BS>',  'at': '"\%#"', 'input': '<BS><Del>', },
\ ]

"" Back Quote
let s:rules += [
\ { 'char': '<BS>',  'at': '`\%#`', 'input': '<BS><Del>', },
\ ]

"" Move closing parenthesis
let s:rules += [
\ { 'char': '<Tab>', 'at': '\%#\s*)',  'input': '<Left><C-o>f)<Right>'  },
\ { 'char': '<Tab>', 'at': '\%#\s*\}', 'input': '<Left><C-o>f}<Right>'  },
\ { 'char': '<Tab>', 'at': '\%#\s*\]', 'input': '<Left><C-o>f]<Right>'  },
\ { 'char': '<Tab>', 'at': '\%#\s*>',  'input': '<Left><C-o>f><Right>'  },
\ { 'char': '<Tab>', 'at': '\%#\s*`',  'input': '<Left><C-o>f`<Right>'  },
\ { 'char': '<Tab>', 'at': '\%#\s*"',  'input': '<Left><C-o>f"<Right>'  },
\ { 'char': '<Tab>', 'at': '\%#\s*''', 'input': '<Left><C-o>f''<Right>' },
\ ]

"" Insert semicolon at the end of the line
"" FIXME, disable in C, ex) if (i=0; i<10; i++ ) { ... }
"let s:rules += [
"\ { 'char': ';', 'at': '(.*\%#)$',   'input': '<Right>;' },
"\ { 'char': ';', 'at': '^\s*\%#)$',  'input': '<Right>;' },
"\ { 'char': ';', 'at': '(.*\%#\}$',  'input': '<Right>;' },
"\ { 'char': ';', 'at': '^\s*\%#\}$', 'input': '<Right>;' },
"\ ]

"" TypeScript
let s:rules += [
\ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '\s([a-zA-Z, ]*\%#)',            'input': '<Left><C-o>f)<Right>a=> {}<Esc>',                 },
\ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '\s([a-zA-Z]\+\%#)',             'input': '<Right> => {}<Left>',              'priority': 10 },
\ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '[a-z]((.*\%#.*))',              'input': '<Left><C-o>f)a => {}<Esc>',                       },
\ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '[a-z]([a-zA-Z]\+\%#)',          'input': ' => {}<Left>',                                    },
\ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '(.*[a-zA-Z]\+<[a-zA-Z]\+>\%#)', 'input': '<Left><C-o>f)<Right>a=> {}<Left>',                },
\ ]

"" ruby
let s:rules += [
\ { 'filetype': 'ruby', 'char': '<CR>',  'at': '^\s*\%(module\|def\|class\|if\|unless\)\s\w\+\((.*)\)\?\%#$', 'input': '<CR>',         'input_after': '<CR>end',      },
\ { 'filetype': 'ruby', 'char': '<CR>',  'at': '^\s*\%(begin\)\s*\%#',                                        'input': '<CR>',         'input_after': '<CR>end',      },
\ { 'filetype': 'ruby', 'char': '<CR>',  'at': '\%(^\s*#.*\)\@<!do\%(\s*|.*|\)\?\s*\%#',                      'input': '<CR>',         'input_after': '<CR>end',      },
\ { 'filetype': 'ruby', 'char': '<Bar>', 'at': 'do\%#',                                                       'input': '<Space><Bar>', 'input_after': '<Bar><CR>end', },
\ { 'filetype': 'ruby', 'char': '<Bar>', 'at': 'do\s\%#',                                                     'input': '<Bar>',        'input_after': '<Bar><CR>end', },
\ { 'filetype': 'ruby', 'char': '<Bar>', 'at': '{\%#}',                                                       'input': '<Space><Bar>', 'input_after': '<Bar><Space>', },
\ { 'filetype': 'ruby', 'char': '<Bar>', 'at': '{\s\%#\s}',                                                   'input': '<Bar>',        'input_after': '<Bar><Space>', },
\ ]

"" eruby
let s:rules += [
\ { 'filetype': 'eruby', 'char': '%',     'at': '<\%#',         'input': '%<Space>',                        'input_after': '<Space>%>',                 },
\ { 'filetype': 'eruby', 'char': '=',     'at': '<%\%#',        'input': '=<Space><Right>',                 'input_after': '<Space>%>',                 },
\ { 'filetype': 'eruby', 'char': '=',     'at': '<%\s\%#\s%>',  'input': '<Left>=<Right>',                                                              },
\ { 'filetype': 'eruby', 'char': '=',     'at': '<%\%#.\+%>',                                                                           'priority': 10, },
\ { 'filetype': 'eruby', 'char': '<BS>',  'at': '<%\s\%#\s%>',  'input': '<BS><BS><BS><Del><Del><Del>',                                                 },
\ { 'filetype': 'eruby', 'char': '<BS>',  'at': '<%=\s\%#\s%>', 'input': '<BS><BS><BS><BS><Del><Del><Del>',                                             },
\ ]

"" markdown
let s:rules += [
\ { 'filetype': 'markdown', 'char': '`',       'at': '``\%#',                                                                        'input_after': '<CR><CR>```', 'priority': 10, },
\ { 'filetype': 'markdown', 'char': '#',       'at': '^\%#\%(#\)\@!',                  'input': '#<Space>'                                                                         },
\ { 'filetype': 'markdown', 'char': '#',       'at': '#\s\%#',                         'input': '<BS>#<Space>',                                                                    },
\ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^#\s\%#',                        'input': '<BS><BS>'                                                                         },
\ { 'filetype': 'markdown', 'char': '<BS>',    'at': '##\s\%#',                        'input': '<BS><BS><Space>',                                                                 },
\ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\%#',                     'input': '<Home><Tab><End>',                                                                },
\ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\w.*\%#',                 'input': '<Home><Tab><End>',                                                                },
\ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\%#',                    'input': '<Home><Del><Del><End>',                                                           },
\ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\w.*\%#',                'input': '<Home><Del><Del><End>',                                                           },
\ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^-\s\w.*\%#',                    'input': '',                                                                                },
\ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^-\s\%#',                        'input': '<C-w><BS>',                                                                       },
\ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^\s\+-\s\%#',                    'input': '<C-w><C-w><BS>',                                                                  },
\ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^-\s\%#',                        'input': '<C-w><CR>',                                                                       },
\ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s\+-\s\%#',                    'input': '<C-w><C-w><CR>',                                                                  },
\ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s*-\s\w.*\%#',                 'input': '<CR>-<Space>',                                                                    },
\ { 'filetype': 'markdown', 'char': '[',       'at': '^\s*-\s\%#',                     'input': '<Left><Space>[]<Left>',                                                           },
\ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\[\%#\]\s',               'input': '<Home><Tab><End><Left><Left>',                                                    },
\ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^-\s\[\%#\]\s',                  'input': '',                                                                                },
\ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\[\%#\]\s',              'input': '<Home><Del><Del><End><Left><Left>',                                               },
\ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^\s*-\s\[\%#\]',                 'input': '<BS><Del><Del>',                                                                  },
\ { 'filetype': 'markdown', 'char': '<Space>', 'at': '^\s*-\s\[\%#\]',                 'input': '<Space><End>',                                                                    },
\ { 'filetype': 'markdown', 'char': 'x',       'at': '^\s*-\s\[\%#\]',                 'input': 'x<End>',                                                                          },
\ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^-\s\[\%#\]',                    'input': '<End><C-w><C-w><C-w><CR>',                                                        },
\ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s\+-\s\[\%#\]',                'input': '<End><C-w><C-w><C-w><C-w><CR>',                                                   },
\ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\[\(\s\|x\)\]\s\%#',      'input': '<Home><Tab><End>',                                                                },
\ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\[\(\s\|x\)\]\s\w.*\%#',  'input': '<Home><Tab><End>',                                                                },
\ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<Home><Del><Del><End>',                                                           },
\ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\[\(\s\|x\)\]\s\w.*\%#', 'input': '<Home><Del><Del><End>',                                                           },
\ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^-\s\[\(\s\|x\)\]\s\w.*\%#',     'input': '',                                                                                },
\ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^-\s\[\(\s\|x\)\]\s\%#',         'input': '<C-w><C-w><C-w><BS>',                                                             },
\ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<C-w><C-w><C-w><C-w><BS>',                                                        },
\ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^-\s\[\(\s\|x\)\]\s\%#',         'input': '<C-w><C-w><C-w><CR>',                                                             },
\ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<C-w><C-w><C-w><C-w><CR>',                                                        },
\ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s*-\s\[\(\s\|x\)\]\s\w.*\%#',  'input': '<CR>-<Space>[',                     'input_after': ']<Space>',                    },
\ ]

"" vim
let s:rules += [
\ { 'filetype': 'vim', 'char': '{', 'at': '^".*{\%#$', 'input': '{{', 'input_after': '<CR>" }}}', 'priority': 10, },
\ ]

"" shell
let s:rules += [
\ { 'filetype': ['sh', 'zsh', 'bash', 'fish'], 'char': '[',    'at': '\[\%#\]',  'input': '[<Space>', 'input_after': '<Space>]', 'priority': 10 },
\ { 'filetype': ['sh', 'zsh', 'bash', 'fish'], 'char': '{',    'at': '{\%#}',    'input': '{<Space>', 'input_after': '<Space>}', 'priority': 10 },
\ { 'filetype': ['sh', 'zsh', 'bash', 'fish'], 'char': '<CR>', 'at': '{\%#}',    'input': '<CR>',     'input_after': '<CR>',     'priority': 10 },
\ ]

"" HTML
let s:rules += [
\ { 'filetype': ['html', 'htmldjango'], 'char': '%', 'at': '{\%#}', 'input': '%<Space>', 'input_after': '<Space>%', 'priority': 10, },
\ ]

for s:rule in s:rules
    call lexima#add_rule(s:rule)
endfor
