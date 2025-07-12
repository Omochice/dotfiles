-- lua_add {{{
require("vimrc/lsp-helper").on_attach(nil, function()
  local opts = { buffer = true }
  vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover({ border = "single" })
  end, opts)
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
  severity_sort = true,
  virtual_text = false,
})
-- }}}

-- lua_source {{{
local lspconfig = require("lspconfig")
-- keep-sorted start block=yes
lspconfig.astro.setup({})
lspconfig.biome.setup({})
lspconfig.denols.setup(require("vimrc/lsp/denols").config())
lspconfig.efm.setup(require("vimrc/lsp/efm").config())
lspconfig.elmls.setup({})
lspconfig.gitlab_ci_ls.setup({})
lspconfig.gopls.setup({})
lspconfig.jsonls.setup({})
lspconfig.lua_ls.setup(require("vimrc/lsp/lua_ls").config())
lspconfig.nixd.setup(require("vimrc/lsp/nixd").config())
lspconfig.nushell.setup({})
lspconfig.pyright.setup({})
lspconfig.rust_analyzer.setup({})
lspconfig.sourcekit.setup({})
lspconfig.svelte.setup({})
lspconfig.taplo.setup(require("vimrc/lsp/taplo").config())
lspconfig.tinymist.setup({})
lspconfig.ts_ls.setup(require("vimrc/lsp/tsserver").config())
lspconfig.typos_lsp.setup({})
lspconfig.yamlls.setup(require("vimrc/lsp/yamlls").config())
lspconfig.zk.setup(require("vimrc/lsp/zk").config())
-- keep-sorted end
-- }}}
