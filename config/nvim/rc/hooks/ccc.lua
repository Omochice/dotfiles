-- lua_source {{{
local ccc = require("ccc")
ccc.setup({
  disable_default_mappings = true,
  highlighter = {
    auto_enable = true,
    lsp = true,
  },
  pickers = {
    ccc.picker.trailing_whitespace({
      palette = {},
      default_color = "#db7093",
      enable = true,
      disable = function(bufnr)
        if vim.bo[bufnr].buftype == "terminal" then
          return true
        end
        local filetype = vim.bo[bufnr].filetype
        for _, ft in ipairs({ "floaterm", "help", "ddu-ff", "aibo-console" }) do
          if vim.startswith(filetype, ft) then
            return true
          end
        end
        return false
      end,
    }),
  },
})
-- }}}
