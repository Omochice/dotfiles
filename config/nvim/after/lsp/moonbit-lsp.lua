---@type vim.lsp.Config
local M = {
  cmd = { "moon", "lsp" },
  filetypes = { "moonbit" },
  root_markers = { "moon.mod.json", ".git", "moon.mod", "moon.work" },
}

return M
