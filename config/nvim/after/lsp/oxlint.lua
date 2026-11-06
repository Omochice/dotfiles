---@type vim.lsp.Config
local M = {
  root_dir = function(bufnr, callback)
    local markers = require("lspconfig.util").root_markers_with_field(
      { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" },
      { "vite.config.ts" },
      { "vite%-plus", "lint:" },
      vim.api.nvim_buf_get_name(bufnr),
      "all"
    )
    local root = vim.fs.root(bufnr, markers)
    if root then
      callback(root)
    end
  end,
}

return M
