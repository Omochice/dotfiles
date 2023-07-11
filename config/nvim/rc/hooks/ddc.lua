-- lua_add {{{
local vimx = require("artemis")
local sources = {
  snippet = { "vsnip" },
  lsp = vimx.fn.has("nvim") and { "nvim-lsp" } or { "vim-lsp" },
  ["in-vim"] = { "around", "buffer" },
  ["out-vim"] = { "rg" },
  file = { "file" },
}

vimx.keymap.set(
  "i",
  "<C-Space>",
  function()
    vimx.fn.ddc.map.manual_complete()
  end
)

vimx.keymap.set(
  "i",
  "<C-x><C-f>",
  function()
    vimx.fn.ddc.map.manual_complete({ sources = { "file" } })
  end
)

vimx.keymap.set(
  "i",
  "<C-x><C-n>",
  function()
    vimx.fn.ddc.map.manual_complete({ sources = { "buffer" } })
  end
)

vimx.keymap.set(
  "i",
  "<C-x><C-s>",
  function()
    vimx.fn.ddc.map.manual_complete({ sources = { "vsnip" } })
  end
)

vimx.keymap.set(
  "i",
  "<C-x><C-l>",
  function()
    vimx.fn.ddc.map.manual_complete({ sources = { "line" } })
  end
)
-- TODO: use instead omnifunc = ddu#...?
-- vimx.keymap.set(
--   "i",
--   "<C-x><C-o>",
--   function()
--     vimx.fn.ddc.map.manual_complete(sources.lsp)
--   end
-- )
-- }}}

-- lua_source {{{
local vimx = require("artemis")
vimx.fn.ddc.custom.load_config(vimx.fn.expand("$DEIN_RC_DIR/ts/ddc.ts"))
vimx.fn.ddc.enable()
-- }}}
