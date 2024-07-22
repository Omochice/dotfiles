-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set(
  "i",
  [[<C-y>]],
  function()
    if not vimx.fn.pum.visible() then
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<C-y>", true, false, true),
        "n",
        false
      )
      return
    end
    vimx.fn.pum.map.confirm()
  end
)
vimx.keymap.set(
  "i",
  [[<C-n>]],
  function()
    if not vimx.fn.pum.visible() then
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<C-n>", true, false, true),
        "n",
        false
      )
      return
    end
    vimx.fn.pum.map.insert_relative(1)
  end
)
vimx.keymap.set(
  "i",
  [[<C-p>]],
  function()
    if not vimx.fn.pum.visible() then
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<C-p>", true, false, true),
        "n",
        false
      )
      return
    end
    vimx.fn.pum.map.insert_relative(-1)
  end
)
-- }}}

-- lua_source {{{
require("artemis").fn.pum.set_option({
  auto_select = true,
})
-- }}}
