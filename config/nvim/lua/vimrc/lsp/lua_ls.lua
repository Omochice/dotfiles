local M = {}

function M.config()
  return {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false, -- NOTE: Prevent `Do you need to configure ...`
        },
        format = {
          defaultConfig = {
            indent_style = "space",
            indent_size = "2",
            quote_style = "double",
            call_arg_parentheses = "keep",
            align_continuous_assign_statement = "false",
            align_continuous_rect_table_field = "false",
            align_array_table = "false",
          },
        },
        telemetry = { enable = false },
      },
    }
  }
end

return M
