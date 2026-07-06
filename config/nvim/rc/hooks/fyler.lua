-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set("n", "<Plug>(vimrc-fyler)", "<Nop>")
vimx.keymap.set("n", ";", "<Plug>(vimrc-fyler)")
vimx.keymap.set("n", "<Plug>(vimrc-fyler);", function()
  require("fyler").toggle({ kind = "floating" })
end)
-- }}}

-- lua_source {{{

--- Toggle node
local function toggle_tree(finder)
  local node = require("fyler.finder").parse_cursor_line(finder)
  if not node then
    return
  end
  if node.type == "directory" then
    finder:select()
  else
    finder:shrink({ parent = true })
  end
end

local function collapse_all(finder)
  for key in pairs(finder.state.meta) do
    finder.state.meta[key] = false
  end
  finder.state:toggle(finder.state.pseudo_root_path, true)
  finder:refresh()
end

require("fyler").setup({
  integrations = {
    icon = "vim_nerdfont",
  },
  kind = "floating",
  kind_presets = {
    floating = {
      height = "80%",
      width = "80%",
      row = "center",
      col = "center",
    },
  },
  mappings = {
    n = {
      ["<CR>"] = { action = "select" },
      ["<C-t>"] = { action = "select", args = { tabedit = true } },
      ["#"] = { action = collapse_all },
      zc = { action = "shrink" },
      zM = { action = collapse_all },
      za = { action = toggle_tree },
      ["<Tab>"] = { action = toggle_tree },
      -- [[disable defaults]]
      q = { disabled = true },
      ["-"] = { disabled = true },
      ["="] = { disabled = true },
      ["."] = { disabled = true },
    },
  },
})
-- }}}

-- lua_fyler_finder {{{
require("artemis").fn.glyph_palette.apply()
-- }}}
