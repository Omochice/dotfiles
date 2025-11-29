-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set("n", ";o", function()
  require("fyler").toggle({ kind = "float" })
end)
-- }}}
-- lua_source {{{
require("fyler").setup({
  integrations = {
    icon = "vim_nerdfont",
  },
  views = {
    finder = {
      mappings = {
        ["<CR>"] = "Select",
        ["<C-t>"] = "SelectTab",
        ["#"] = "CollapseAll",
        ["<BS>"] = "CollapseNode",
      },
    },
  },
})
-- }}}

-- lua_fyler {{{
require("artemis").fn.glyph_palette.apply()
-- }}}
