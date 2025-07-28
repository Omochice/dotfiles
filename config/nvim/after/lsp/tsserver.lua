local util = require("lspconfig.util")

local M = {
  root_dir = util.root_pattern("tsconfig.json", "package.json", "node_modules"),
  single_file_support = false,
}

return M
