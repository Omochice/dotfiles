-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set(
  "i",
  [[<C-y>]],
  "",
  {
    expr = true,
    callback = function()
      if vimx.fn.pum.visible() then
        vimx.fn.pum.map.confirm()
        return
      end
      return [[<C-y>]]
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
      if vimx.fn.pum.visible() then
        vimx.fn.pum.map.insert_relative(1)
        return
      end
      return [[<C-n>]]
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
      if vimx.fn.pum.visible() then
        vimx.fn.pum.map.insert_relative(-1)
        return
      end
      return [[<C-p>]]
    end
  }
)
-- }}}

-- lua_source {{{
require("artemis").fn.pum.set_option("auto_select", true)
-- }}}
