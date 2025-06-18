-- lua_source {{{
local gitsign = require("gitsigns")
gitsign.setup({
  on_attach = function(bufnr)
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
    if filetype ~= "diff" then
      vim.keymap.set("n", "[c", gitsign.prev_hunk, { buffer = bufnr })
      vim.keymap.set("n", "]c", gitsign.next_hunk, { buffer = bufnr })
    end
    vim.keymap.set("n", "<Space>gm", gitsign.blame_line, { buffer = bufnr })
  end,
  preview_config = {
    border = "single",
  },
})
-- }}}
