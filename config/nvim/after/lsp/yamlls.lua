---@type vim.lsp.Config
local M = {
  settings = {
    yaml = {
      keyOrdering = false,
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}

return M
