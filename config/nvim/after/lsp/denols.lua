---@type vim.lsp.Config
local M = {
  cmd = { "deno", "lsp" },
  root_dir = function(bufnr, callback)
    local runtime, root = require("vimrc/lsp-helper").detect_js_runtime(bufnr)
    if runtime == "deno" then
      callback(root)
    end
  end,
  single_file_support = false,
  init_options = {
    lint = true,
    unstable = true,
    suggest = {
      autoImports = true,
      completeFunctionCalls = true,
      names = true,
      paths = true,
      imports = {
        autoDiscover = true,
        hosts = {
          ["https://deno.land"] = true,
        },
      },
    },
  },
}

return M
