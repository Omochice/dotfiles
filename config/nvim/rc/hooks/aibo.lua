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
      vim.keymap.set({ "n", "i" }, "<Down>", "<Plug>(aibo-send)<Down>", opts)
      vim.keymap.set({ "n", "i" }, "<Up>", "<Plug>(aibo-send)<Up>", opts)
    end,
  },
  tools = {
    claude = {
      no_default_mappings = true,
      on_attach = function(bufnr)
        local opts = { buffer = bufnr, nowait = true, silent = true }
        vim.keymap.set({ "n", "i" }, "<Tab>", "<Plug>(aibo-send)<Tab>", opts)
        vim.keymap.set({ "n", "i" }, "<S-Tab>", "<Plug>(aibo-send)<S-Tab>", opts)
        vim.keymap.set({ "n", "i" }, "<F2>", "<Plug>(aibo-send)<F2>", opts)
        vim.keymap.set({ "n", "i" }, "<C-o>", "<Plug>(aibo-send)<C-o>", opts)
        vim.keymap.set({ "n", "i" }, "<C-t>", "<Plug>(aibo-send)<C-t>", opts)
        vim.keymap.set({ "n", "i" }, "<C-_>", "<Plug>(aibo-send)<C-_>", opts)
        vim.keymap.set({ "n", "i" }, "<C-->", "<Plug>(aibo-send)<C-_>", opts)
        vim.keymap.set({ "n", "i" }, "<C-v>", "<Plug>(aibo-send)<C-v>", opts)
      end,
    },
  },
})
-- }}}
