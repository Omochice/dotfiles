-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set("n", ";o", function()
  require("oil").open()
end
)
-- }}}

-- lua_source {{{
require("oil").setup({
  use_default_keymaps = false,
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ["q"] = "actions.close",
    ["<CR>"] = "actions.select",
    ["l"] = "actions.select",
    ["h"] = "actions.parent",
  },
})
require("oil-nerdfont").setup()
-- }}}
