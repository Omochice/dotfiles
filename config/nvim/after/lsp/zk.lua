local M = {}

require("vimrc/lsp-helper").on_attach("zk", function()
  local win = vim.api.nvim_get_current_win()
  vim.wo[win][0].foldmethod = "expr"
  vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
end)

return M
