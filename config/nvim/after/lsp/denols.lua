local helper = require("vimrc/lsp-helper")

---@type vim.lsp.Config
local M = {
  cmd = { "deno", "lsp" },
  root_dir = function(bufnr, callback)
    local node = helper.root_pattern("package.json", "node_modules")(bufnr)
    if node ~= nil then
      return
    end
    local deno = helper.root_pattern("deno.json", "deno.jsonc")(bufnr)
    if deno ~= nil then
      return callback(vim.fs.dirname(deno))
    end
    return callback(vim.fn.getcwd())
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
