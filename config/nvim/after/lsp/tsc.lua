---@type vim.lsp.Config
local M = {
  root_dir = function(bufnr, callback)
    local runtime, root = require("vimrc/lsp-helper").detect_js_runtime(bufnr)
    if runtime == "node" then
      callback(root)
    end
  end,
  single_file_support = false,
}

return M
