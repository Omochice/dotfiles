-- lua_add {{{
local vimx = require("artemis")
local sources = {
  snippet = { "vsnip" },
  lsp = { "lsp" },
  internal = { "around", "buffer" },
  external = { "rg" },
  file = { "file" },
  line = { "line" },
}

vimx.keymap.set(
  "i",
  "<C-x>",
  "<Nop>"
)

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
    vimx.fn.ddc.map.manual_complete({ sources = sources.file })
  end
)

vimx.keymap.set(
  "i",
  "<C-x><C-n>",
  function()
    vimx.fn.ddc.map.manual_complete({ sources = sources.internal })
  end
)

vimx.keymap.set(
  "i",
  "<C-x><C-s>",
  function()
    vimx.fn.ddc.map.manual_complete({ sources = sources.snippet })
  end
)

vimx.keymap.set(
  "i",
  "<C-x><C-l>",
  function()
    vimx.fn.ddc.map.manual_complete({ sources = sources.line })
  end
)

vimx.create_autocmd("LspAttach", {
  callback = function()
    vimx.keymap.set(
      "i",
      "<C-x><C-o>",
      function()
        vimx.fn.ddc.map.manual_complete({ sources = sources.lsp })
      end,
      { buffer = true }
    )
  end,
  group = vimx.create_augroup("vimrc#ddc-omni", {
    clear = true
  })
})
-- }}}

-- lua_source {{{
local vimx = require("artemis")
vimx.fn.ddc.custom.load_config(vimx.fn.expand("$DEIN_RC_DIR/ts/ddc.ts"))
vimx.fn.ddc.enable()
-- }}}
