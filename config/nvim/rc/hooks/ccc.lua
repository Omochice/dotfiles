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
      disable = { "floaterm", "help", "mason" },
    }),
  },
})
-- }}}
