-- lua_source {{{
require("nvim-treesitter").setup({})
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
  callback = function(ctx)
    local ft = vim.bo[ctx.buf].filetype
    if ft == "help" then
      return
    end
    pcall(vim.treesitter.start)
  end,
})
-- }}}

-- lua_markdown {{{
-- vim.wo.foldmethod = "expr"
-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- }}}
