-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set({ "n", "x", "o" }, "gc", "<Plug>(contextment)")
vimx.keymap.set("n", "gcc", "<Plug>(contextment-line)")
-- }}}
