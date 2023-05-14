-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set(
  "i",
  [[<C-y>]],
  function()
    vimx.fn.pum.map.confirm()
  end
)
vimx.keymap.set(
  "i",
  [[<C-n>]],
  "",
  {
    expr = true,
    callback = function()
      if vimx.fn.pum.visible() == 1 then
        vimx.fn.pum.map.insert_relative(1)
      end
      return [[<C-y]]
    end
  }
)
vimx.keymap.set(
  "i",
  [[<C-p>]]
)
-- }}}
