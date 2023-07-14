-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set(
  "c",
  "<C-c>",
  "",
  {
    expr = true,
    callback = function ()
      if vimx.fn.getcmdline():match("%S+") then
        return [[<Home>Capture<Space><CR>]]
      end
      return [[<C-c>]]
    end
  }
)
-- }}}

-- lua_capture {{{
require("artemis").w.wrap = true
-- }}}
