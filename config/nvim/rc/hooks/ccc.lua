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
        if vim.iter({ "floaterm", "help", "ddu-ff" }):find(filetype) ~= nil then
          return true
        end
        return false
      end,
    }),
  },
})
-- }}}
