" hook_add {{{
const s:providers = #{
      \ ollama: #{
      \   name: "ollama",
      \   options : #{
      \     model : "codellama",
      \   },
      \ },
      \ bedrock: #{
      \   name: 'bedrock',
      \   options: #{
      \     model: 'us.anthropic.claude-3-7-sonnet-20250219-v1:0',
      \     region: 'us-east-1',
      \     profile: 'bedrock',
      \   },
      \ }
      \ }
function s:list_providers(...) abort
  return s:providers->keys()
endfunction
function s:start_chat(...) abort
  const provider = s:providers[get(a:000, 0, 'ollama')]
  const reltime = reltime()->reltimestr()
  const bufname = $'chat://{provider.name}#{reltime}'
  const bufnr = bufadd(bufname)
  call bufload(bufnr)
  call setbufvar(bufnr, '&buftype', 'nofile')
  call setbufvar(bufnr, '&filetype', 'markdown.chat')
  call setbufvar(bufnr, '&wrap', v:true)
  call deletebufline(bufnr, 1, '$')
  execute $'tabedit +buffer{bufnr}'
  call setbufvar(bufnr, 'tataku_chat_recipe', #{
        \   collector: #{
        \     name: 'buffer',
        \     options: #{ bufname: bufname },
        \   },
        \   processor: [
        \     #{ name: 'markdown_section', options: #{} },
        \     provider,
        \     #{ name: 'padding', options: #{ before: ["\n\n---\n"], after: ["\n\n---\n"] } }
        \   ],
        \   emitter: #{
        \     name: 'buffer',
        \     options: #{ bufname: bufname }
        \   },
        \ })
endfunction
command! -nargs=? -complete=customlist,<SID>list_providers Hey call <SID>start_chat(<f-args>)
cnoreabbrev hey Hey
augroup tataku_chat
  autocmd!
  autocmd FileType markdown.chat nnoremap <buffer> <C-g><C-g> <cmd>call tataku#call_oneshot(b:tataku_chat_recipe)<CR>
augroup END
" }}}
