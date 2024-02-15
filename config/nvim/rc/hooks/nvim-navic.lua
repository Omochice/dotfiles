-- lua_source {{{
vim.o.winbar = "%{%v:lua.require('nvim-navic').get_location()%}"
require("nvim-navic").setup({})
require("vimrc/lsp-helper").on_attach(nil, function(client, bufnr)
  if client and client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end
end)
-- }}}
