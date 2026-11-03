---@type vim.lsp.Config
local M = {
  cmd = { "stylua", "--lsp", "--search-parent-directories" },
}

return M
