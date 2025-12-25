-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set("n", "<Plug>(vimrc-fyler)", "<Nop>")
vimx.keymap.set("n", ";", "<Plug>(vimrc-fyler)")
vimx.keymap.set("n", "<Plug>(vimrc-fyler);", function()
  require("fyler").toggle({ kind = "float" })
end)
-- }}}

-- lua_source {{{

--- Toggle node
local function toggle_tree(finder)
  local entry = finder:cursor_node_entry()
  if entry:is_directory() then
    finder:exec_action("n_select")
  else
    finder:exec_action("n_collapse_node")
  end
end

require("fyler").setup({
  integrations = {
    icon = "vim_nerdfont",
  },
  views = {
    finder = {
      columns = {
        git = {
          enabled = false,
        },
      },
      mappings = {
        ["<CR>"] = "Select",
        ["<C-t>"] = "SelectTab",
        ["#"] = "CollapseAll",
        zc = "CollapseNode",
        zM = "CollapseAll",
        za = toggle_tree,
        ["<Tab>"] = toggle_tree,
        -- [[disable defaults]]
        q = false,
        ["|"] = false,
        ["-"] = false,
        ["^"] = false,
        ["="] = false,
        ["."] = false,
      },
      win = {
        kinds = {
          float = {
            height = "80%",
            width = "80%",
            top = "10%",
            left = "10%",
          },
        },
      },
    },
  },
})
-- }}}

-- lua_fyler {{{
require("artemis").fn.glyph_palette.apply()
-- }}}
