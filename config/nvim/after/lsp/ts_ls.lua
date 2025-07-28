local helper = require("vimrc/lsp-helper")

---@type vim.lsp.Config
local M = {
  root_dir = function(bufnr, callback)
    local node = helper.root_pattern("tsconfig.json", "package.json", "node_modules")(bufnr)
    if node == nil then
      return
    end
    return callback(vim.fs.dirname(node))
  end,
  single_file_support = false,
}

return M
