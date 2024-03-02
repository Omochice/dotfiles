local M = {}
local util = require("lspconfig.util")

function M.config()
  return {
    root_dir = util.root_pattern("tsconfig.json", "package.json", "node_modules"),
    single_file_support = false,
  }
end

return M
