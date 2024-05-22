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
  keymaps = {
    ["<CR>"] = "actions.select",
  },
})
require("oil-nerdfont").setup()
-- }}}
