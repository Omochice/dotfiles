---@type vim.lsp.Config
local M = {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false, -- NOTE: Prevent `Do you need to configure ...`
      },
      format = { enable = false },
      telemetry = { enable = false },
    },
  },
}

return M
