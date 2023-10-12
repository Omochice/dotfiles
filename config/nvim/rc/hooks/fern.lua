-- lua_add {{{
local vimx = require("artemis")
vimx.g["fern#disable_default_mappings"] = true
vimx.keymap.set("ca", "fe", "Fern .")
vimx.keymap.set("ca", "fep", "Fern . -reveal=%")
vimx.create_command("TFern", function()
    vimx.cmd("tabnew")
    vimx.cmd("Fern .")
  end,
  { bang = true }
)
vimx.keymap.set("ca", "tf", "TFern")
vimx.create_command("Drawer", function()
    vimx.cmd("Fern . -reveal=% -drawer")
  end,
  { bang = true }
)
vimx.keymap.set("ca", "drawer", "Drawer")
-- }}}

-- lua_fern {{{
local vimx = require("artemis")
vimx.keymap.set("n", "q", "<Cmd>bprevious<CR>", { buffer = true, nowait = true })
vimx.keymap.set("n", "i", "<Plug>(fern-action-new-file)", { buffer = true, nowait = true })
vimx.keymap.set("n", "o", "<Plug>(fern-action-new-dir)", { buffer = true })
vimx.keymap.set("n", "r", "<Plug>(fern-action-rename)", { buffer = true })
vimx.keymap.set("n", "dd", "<Plug>(fern-action-remove=)", { buffer = true })
vimx.keymap.set("n", "yy", "<Plug>(fern-action-clipboard-copy)", { buffer = true })
vimx.keymap.set("n", "p", "<Plug>(fern-action-paste)", { buffer = true })
vimx.keymap.set("n", "h", "<Plug>(fern-action-collapse)", { buffer = true })
vimx.keymap.set("n", "l", "<Plug>(fern-action-open-or-expand)", { buffer = true })
vimx.keymap.set("n", "!", "<Plug>(fern-action-hidden:toggle)", { buffer = true })
vimx.keymap.set("n", "?", "<Plug>(fern-action-help)", { buffer = true })
vimx.keymap.set("n", "t", "<Plug>(fern-action-open:tabedit)", { buffer = true })
vimx.keymap.set("n", "<Plug>(fern-action-open-or-expand:stay)",
  function()
    return vimx.fn.fern.smart.leaf("<Plug>(fern-action-open)", "<Plug>(fern-action-expand:stay)")
  end,
  { buffer = true, expr = true }
)
vimx.keymap.set("n", "<CR>",
  function()
    return vimx.fn.fern.smart.leaf("<CR>", "<Plug>(fern-action-open-or-expand:stay)", "<Plug>(fern-action-collapse)")
  end,
  { buffer = true, expr = true }
)
-- }}}
