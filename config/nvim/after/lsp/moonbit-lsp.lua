---@type vim.lsp.Config
local M = {
  cmd = { "moonbit-lsp" },
  filetypes = { "moonbit" },
  root_markers = { "moon.mod.json", ".git" },
}

return M
