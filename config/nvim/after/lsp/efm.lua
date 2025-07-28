local eslint = {
  prefix = "eslint",
  lintSource = "efm/eslint",
  lintCommand = 'pnpm eslint --no-color --format visualstudio --stdin-filename "${INPUT}" --stdin',
  lintStdin = true,
  lintFormats = { "%f(%l,%c): %trror %m", "%f(%l,%c): %tarning %m" },
  lintIgnoreExitCode = true,
  rootMarkers = {
    "eslint.config.js",
  },
}

---@type vim.lsp.Config
local M = {
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
    codeAction = true,
  },
  filetypes = { "typescript" },
  settings = {
    typescript = { eslint },
  },
}

return M
