local helper = require("vimrc/lsp-helper")

---@type vim.lsp.Config
local M = {
  root_dir = function(bufnr, callback)
    local found = helper.root_pattern("tsconfig.json", "node_modules")(bufnr)
    if found == nil then
      return
    end
    callback(vim.fs.dirname(found))
  end,
  single_file_support = false,
}

return M
