---@type vim.lsp.Config
local M = {
  root_dir = function(bufnr, callback)
    local root = require("vimrc/lsp-helper").root_pattern(".zk")(bufnr)
    if root == nil then
      return
    end
    callback(vim.fs.dirname(root))
  end,
}

require("vimrc/lsp-helper").on_attach("zk", function()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_option_value("foldmethod", "expr", { win = win })
  vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.treesitter.foldexpr()", { win = win })
end)

return M
