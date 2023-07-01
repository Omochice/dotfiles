" hook_add {{{
function! s:enable_current_lsp(server_func) abort
  return !(lsp#get_server_names()
        \         ->filter({_, v -> lsp#get_server_status(v) ==# 'running'
        \                         && funcref(a:server_func)(v)})
        \         ->empty())
endfunction

let g:is_node_project = v:false

augroup myvimrc#is_node_project#internal
  autocmd!
  autocmd BufEnter * call <SID>is_node_project(fnamemodify(expand('%'), ':p:h'))
augroup END

function! s:is_node_project(path='') abort
  if has('win32')
    " NOTE: if windows then this function dont anything
    return g:is_node_project
  endif
  if a:path->empty()

  endif

  let l:path = a:path->empty() ? expand('%')->fnamemodify(':p:h') : a:path
  while v:true
    if l:path ==# '/'
      " NOTE: reach root
      return g:is_node_project
    endif

    if isdirectory(l:path .. '/node_modules') || filereadable(l:path . '/package.json')
      " NOTE: find root maker
      let g:is_node_project = v:true
      return g:is_node_project
    endif

    let l:next = fnamemodify(l:path, ':h')
    if l:next ==# l:path
      " NOTE: parse is failed
      return g:is_node_project
    endif
    let l:path = l:next
  endwhile
endfunction

let g:lsp_diagnostics_enabled = v:true
let g:lsp_diagnostics_virtual_text_enabled = v:false
let g:lsp_diagnostics_echo_cursor = v:true
let g:lsp_diagnostics_echo_delay = 100
let g:lsp_log_verbose = v:true
let g:lsp_log_file = '/tmp/vim-lsp.log'
let g:lsp_preview_float = v:false
let g:lsp_hover_ui = 'preview'
let g:lsp_signature_help_enabled = v:false
nmap <expr> K <SID>enable_current_lsp('lsp#capabilities#has_hover_provider') ? "\<Plug>(lsp-hover)" : 'K'
nmap <expr> gd <SID>enable_current_lsp('lsp#capabilities#has_definition_provider') ? "\<Plug>(lsp-definition)" : 'gd'
nmap <silent> <Space>f <Plug>(lsp-document-format)
nmap <silent> <Space>d <Plug>(lsp-document-diagnostics)
nmap <silent> <Space>r <Plug>(lsp-rename)

let g:lsp_text_edit_enabled = v:true
let g:lsp_document_code_action_signs_enabled = v:false
let g:lsp_diagnostics_signs_error = {'text': '🥺'}
let g:lsp_diagnostics_signs_warning = {'text': '🤔'}
let g:lsp_settings_filetype_objc = ['clangd']
let g:lsp_settings_filetype_typescript = [<SID>is_node_project() ? 'typescript-language-server' : 'deno']
" }}}
