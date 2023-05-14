-- lua_add {{{
local vimx = require("artemis")
vimx.g.ddc_source_options = {
  _ = {
    matchers = { "matcher_fuzzy" },
    sorters = { "sorter_fuzzy" },
    converters = { "converter_remove_overlap", "converter_fuzzy" },
    minAutoCompleteLength = 2,
    ignoreCase = true,
  }
}

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
if vimx.fn.dein.tap("vim-vsnip-integ") == 1 then
  vimx.g.ddc_source_options.vsnip = { mark = "[Snp]" }
end
-- }}}

-- lua_source {{{
local vimx = require("artemis")
vimx.fn.ddc.custom.patch_global(
  "sources",
  { "vsnip", "nvim-lsp", "around", "buffer", "rg", }
)

-- TODO: なんかよくわからんけどluaだといけない
vim.print(vimx.cast(vimx.g.ddc_source_options))
-- vimx.fn.ddc.custom.patch_global(
--   "sourceOptions",
--   vimx.g.ddc_source_options
-- )
vimx.cmd([[call ddc#custom#patch_global('sourceOptions', g:ddc_source_options)]])

vimx.fn.ddc.custom.patch_filetype(
  { "toml", "vim" },
  "sources",
  { "vsnip", "necovim", "nvim-lsp", "around", "buffer", "rg" }
)

vimx.fn.ddc.custom.patch_filetype(
  "markdown",
  "sources",
  { "vsnip", "file", "around", "buffer", "rg", }
)

vimx.fn.ddc.custom.patch_global("ui", "pum")
vimx.fn.ddc.custom.patch_global("backspaceCompletion", true)
vimx.fn.ddc.enable()
-- }}}
