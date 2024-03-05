-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set(
  "i",
  [[<C-y>]],
  "",
  {
    expr = true,
    callback = function()
      if not vimx.fn.pum.visible() then
        return [[<C-y>]]
      end
      vimx.fn.pum.map.confirm()
    end
  }
)
vimx.keymap.set(
  "i",
  [[<C-n>]],
  "",
  {
    expr = true,
    callback = function()
      if not vimx.fn.pum.visible() then
        return ""
      end
      return [[<Cmd>call pum#map#insert_relative(1)<CR>]]
    end
  }
)
vimx.keymap.set(
  "i",
  [[<C-p>]],
  "",
  {
    expr = true,
    callback = function()
      if not vimx.fn.pum.visible() then
        return [[<C-p>]]
      end
      return [[<Cmd>call pum#map#insert_relative(-1)<CR>]]
    end
  }
)
-- }}}

-- lua_source {{{
require("artemis").fn.pum.set_option({
  auto_select = true,
})
-- }}}
