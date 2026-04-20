-- lua_add {{{
vim.lsp.inlay_hint.enable(true)
require("vimrc/lsp-helper").on_attach(nil, function()
  local opts = { buffer = true }
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

  vim.keymap.set("n", "<Space>[h", function()
    vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
  end)
  vim.keymap.set("n", "<Space>]h", function()
    vim.lsp.inlay_hint.enable(false, { bufnr = 0 })
  end)
end)

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = false,
})
-- }}}

-- lua_source {{{
vim.lsp.enable({
  -- keep-sorted start
  "astro",
  "biome",
  "clangd",
  "denols",
  "elmls",
  "gitlab_ci_ls",
  "gopls",
  "jsonls",
  "lua_ls",
  "moonbit-lsp",
  "nixd",
  "nushell",
  "oxlint",
  "pyright",
  "rumdl",
  "rust_analyzer",
  "sourcekit",
  "stylua",
  "svelte",
  "taplo",
  "tinymist",
  "tsgo",
  "typos_lsp",
  "vue_ls",
  "yamlls",
  "zk",
  -- keep-sorted end
})
-- }}}
