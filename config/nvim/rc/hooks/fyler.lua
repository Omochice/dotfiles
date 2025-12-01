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
        zc = "CollapseNode",
        zM = "CollapseAll",
        za = function(finder)
          -- Toggle node
          local entry = finder:cursor_node_entry()
          if entry:is_directory() then
            finder:exec_action("n_select")
          else
            finder:exec_action("n_collapse_node")
          end
        end,

        -- [[disable defaults]]
        q = false,
        ["|"] = false,
        ["-"] = false,
        ["^"] = false,
        ["="] = false,
        ["."] = false,
      },
    },
  },
})
-- }}}

-- lua_fyler {{{
require("artemis").fn.glyph_palette.apply()
-- }}}
