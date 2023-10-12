-- lua_add {{{
local vimx = require("artemis")
vimx.g.sandwich_no_default_key_mappings = true
vimx.keymap.set("n", "s", [[<nop>]])
vimx.keymap.set("n", "sa", [[<Plug>(sandwich-add)]], { remap = true })
vimx.keymap.set("x", "S", [[<Plug>(sandwich-add)]], { remap = true })
vimx.keymap.set("n", "sd", [[<Plug>(sandwich-delete)]], { remap = true })
vimx.keymap.set("n", "sdb", [[<Plug>(sandwich-delete-auto)]], { remap = true })
vimx.keymap.set("n", "sr", [[<Plug>(sandwich-replace)]], { remap = true })
vimx.keymap.set("n", "srb", [[<Plug>(sandwich-replace-auto)]], { remap = true })
-- textobj
vimx.keymap.set("o", "ib", [[<Plug>(textobj-sandwich-auto-i)]], { remap = true })
vimx.keymap.set("x", "ib", [[<Plug>(textobj-sandwich-auto-i)]], { remap = true })
vimx.keymap.set("o", "ab", [[<Plug>(textobj-sandwich-auto-a)]], { remap = true })
vimx.keymap.set("x", "ab", [[<Plug>(textobj-sandwich-auto-a)]], { remap = true })
vimx.keymap.set("o", "is", [[<Plug>(textobj-sandwich-query-i)]], { remap = true })
vimx.keymap.set("x", "is", [[<Plug>(textobj-sandwich-query-i)]], { remap = true })
vimx.keymap.set("o", "as", [[<Plug>(textobj-sandwich-query-a)]], { remap = true })
vimx.keymap.set("x", "as", [[<Plug>(textobj-sandwich-query-a)]], { remap = true })
-- }}}
