--- lua_add {{{
require("vimrc/lsp-helper").on_attach(nil, function()
  local opts = { buffer = true }
  vim.keymap.set("n", "K", function()
    require("hover").open()
  end, opts)
  vim.keymap.set("n", "gK", function()
    require("hover").enter()
  end, opts)
end)
--- }}}

--- lua_source {{{
require("hover").config({
  --- @type (string|Hover.Config.Provider)[]
  providers = {
    "hover.providers.diagnostic",
    "hover.providers.lsp",
    "hover.providers.dap",
    "hover.providers.man",
    "hover.providers.dictionary",
  },
  preview_opts = {
    border = "single",
  },
  preview_window = false,
  title = true,
})
--- }}
