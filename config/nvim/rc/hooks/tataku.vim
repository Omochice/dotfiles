" hook_add {{{
const s:providers = #{
      \ ollama: #{
      \   name: "ollama",
      \   options : #{
      \     model : "qwen3:32b",
      \   },
      \ },
      \ bedrock: #{
      \   name: 'bedrock',
      \   options: #{
      \     model: 'us.amazon.nova-pro-v1:0',
      \     region: 'us-east-1',
      \     profile: 'bedrock',
      \   },
      \ }
      \ }
const s:default_provider = 'ollama'
function s:list_providers(...) abort
  return s:providers->keys()
endfunction
function s:start_chat(line1, line2, ...) abort
  const original_bufnr = bufnr()
  const original_filetype = getbufvar(original_bufnr, '&filetype')
  const provider = s:providers[get(a:000, 0, s:default_provider)]
  const reltime = reltime()->reltimestr()
  const lines = a:line1 ==# a:line2
        \ ? []
        \ : [
        \   '',
        \   $'```{original_filetype->empty() ? 'txt' : original_filetype}',
        \   getbufline(original_bufnr, a:line1, a:line2),
        \   '```',
        \ ]->flatten()
  const bufname = $'chat://{provider.name}#{reltime}'
  const bufnr = bufadd(bufname)
  call bufload(bufnr)
  call setbufvar(bufnr, '&buftype', 'nofile')
  call setbufvar(bufnr, '&filetype', 'markdown.chat')
  call setbufvar(bufnr, '&wrap', v:true)
  silent! call deletebufline(bufnr, 1, '$')
  call setbufline(bufnr, 1, lines)
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
command! -range -nargs=? -complete=customlist,<SID>list_providers Hey call <SID>start_chat(<line1>, <line2>, <f-args>)
cnoreabbrev hey Hey
augroup tataku_chat
  autocmd!
  autocmd FileType markdown.chat nnoremap <buffer> <C-g><C-g> <cmd>call tataku#call_oneshot(b:tataku_chat_recipe)<CR>
augroup END
" }}}
