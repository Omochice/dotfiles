-- lua_add {{{
local group = vim.api.nvim_create_augroup("vimrc#lspsaga", {
  clear = true
})
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(_)
    vim.keymap.set("n", "<Space>a", [[<Cmd>Lspsaga code_action<CR>]], { buffer = true })
  end,
  group = group,
})
-- }}}

-- lua_source {{{
require("lspsaga").setup({})
-- }}}
