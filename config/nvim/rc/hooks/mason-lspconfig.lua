-- lua_add {{{
require("vimrc/lsp-helper").on_attach(nil, function()
  local opts = { buffer = true }
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<Space>f", vim.lsp.buf.format, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<Space>d", vim.diagnostic.setloclist, opts)
  vim.keymap.set("n", "<Space>D", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ float = false, count = -1 })
  end, opts)
  vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ float = false, count = 1 })
  end, opts)
end)

vim.diagnostic.config({
  virtual_text = false,
})
-- }}}

-- lua_source {{{
local lspconfig = require("lspconfig")
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers({
  function(server_name)
    local opts = {}
    if server_name == "yamlls" then
      opts = require("vimrc/lsp/yamlls").config()
    end
    if server_name == "tsserver" or server_name == "ts_ls" then
      opts = require("vimrc/lsp/tsserver").config()
    end
    lspconfig[server_name].setup(opts)
  end,
})

lspconfig.denols.setup(require("vimrc/lsp/denols").config())
lspconfig.gopls.setup({})
lspconfig.nushell.setup({})
lspconfig.sourcekit.setup({})
lspconfig.lua_ls.setup(require("vimrc/lsp/lua_ls").config())
lspconfig.efm.setup(require("vimrc/lsp/efm").config())
lspconfig.tinymist.setup({})
lspconfig.taplo.setup({
  workspace_config = {
    formatter = {
      reorderKeys = false,
      compactArray = false,
      arrayAutoCollapse = false,
      alignEntries = true,
    }
  }
})
lspconfig.nixd.setup({})
-- }}}
