local M = {}
local lspconfig = require("lspconfig")

function M.config()
  return {
    cmd = { "deno", "lsp" },
    root_dir = function(...)
      if lspconfig.util.root_pattern("package.json", "node_modules")(...) ~= nil then
        return nil
      end
      local found = lspconfig.util.root_pattern("deno.json", "deno.jsonc")(...)
      return found or vim.fn.getcwd()
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
end

return M
