-- lua_source {{{
local gitsign = require("gitsigns")
gitsign.setup({
  on_attach = function(_bufnr)
    vim.keymap.set("n", "<C-g><C-p>", gitsign.prev_hunk, { buffer = true })
    vim.keymap.set("n", "<C-g><C-n>", gitsign.next_hunk, { buffer = true })
    vim.keymap.set("n", "<Space>gm", gitsign.blame_line, { buffer = true })
  end,
})
-- }}}
