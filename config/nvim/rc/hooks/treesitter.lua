-- lua_source {{{
require("nvim-treesitter.configs").setup({
  ensure_installed = "all",
  highlight = {
    enable = true,
    disable = { "help" },
  },
  disable = function(lang)
    local ok = pcall(function()
      vim.treesitter.get_query(lang, "highlights")
    end)
    return not ok
  end,
  ignore_install = { "phpdoc", "help" },
  playground = {
    enable = true,
  },
})
-- }}}

-- lua_markdown {{{
-- vim.wo.foldmethod = "expr"
-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- }}}
