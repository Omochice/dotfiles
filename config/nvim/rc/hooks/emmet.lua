-- lua_add {{{
local vimx = require("artemis")
vimx.g.user_emmet_install_global = false
vimx.keymap.set("i", "<Plug>(emmet-expand-abbr-with-cmd)", function()
  vimx.fn.emmet.util.closePopup()
  vimx.fn.emmet.expandAbbr(0, "")
  -- NOTE: after expand. cursor position is: `div` => `<div|></div>`
  vimx.cmd([[silent! normal! 1l]])
end)
-- }}}
