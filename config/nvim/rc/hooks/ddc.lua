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
-- }}}
