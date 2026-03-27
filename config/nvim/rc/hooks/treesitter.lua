-- lua_source {{{
require("nvim-treesitter").setup({})
local disabled_filetypes = {
  -- keep-sorted start
  ["fish"] = true,
  ["gitcommit"] = true,
  ["help"] = true,
  ["html"] = true,
  ["json"] = true,
  ["make"] = true,
  -- keep-sorted end
}
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
  callback = function(ctx)
    local ft = vim.bo[ctx.buf].filetype
    if disabled_filetypes[ft] then
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
