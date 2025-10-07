-- lua_source {{{
require("aibo").setup({
  prompt = {
    no_default_mappings = true,
    on_attach = function(bufnr)
      local opts = { buffer = bufnr, nowait = true, silent = true }
      vim.keymap.set({ "n", "i" }, "<C-g><C-o>", "<Plug>(aibo-send)", { buffer = bufnr, nowait = true })
      vim.keymap.set("n", "<CR>", "<Plug>(aibo-submit)", opts)
      vim.keymap.set("n", "<C-Enter>", "<Plug>(aibo-submit)<Cmd>q<CR>", opts)
      vim.keymap.set("n", "<F5>", "<Plug>(aibo-submit)<Cmd>q<CR>", opts)
      vim.keymap.set("i", "<C-Enter>", "<Esc><Plug>(aibo-submit)<Cmd>q<CR>", opts)
      vim.keymap.set("i", "<F5>", "<Esc><Plug>(aibo-submit)<Cmd>q<CR>", opts)
      vim.keymap.set({ "n", "i" }, "<C-c>", "<Plug>(aibo-send)<Esc>", opts)
      vim.keymap.set({ "n", "i" }, "g<C-c>", "<Plug>(aibo-send)<C-c>", opts)
      vim.keymap.set({ "n", "i" }, "<C-l>", "<Plug>(aibo-send)<C-l>", opts)
      vim.keymap.set({ "n", "i" }, "<C-n>", "<Plug>(aibo-send)<C-n>", opts)
      vim.keymap.set({ "n", "i" }, "<C-p>", "<Plug>(aibo-send)<C-p>", opts)
      vim.keymap.set({ "n", "i" }, "<Down>", "<Plug>(aibo-send)<Down>", opts)
      vim.keymap.set({ "n", "i" }, "<Up>", "<Plug>(aibo-send)<Up>", opts)
    end,
  },
})
-- }}}
