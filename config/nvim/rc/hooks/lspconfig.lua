-- lua_add {{{
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
  "nixd",
  "nushell",
  "pyright",
  "rust_analyzer",
  "sourcekit",
  "stylua",
  "svelte",
  "taplo",
  "tinymist",
  "ts_ls",
  "typos_lsp",
  "yamlls",
  "zk",
  -- keep-sorted end
})
-- }}}
