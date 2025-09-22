--- lua_source {{{
-- Use upper case for treesitter, it prevent to confuse at Vim's one.
require("nvim-treesitter-textobjects").setup({
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      ["aF"] = "@function.outer",
      ["iF"] = "@function.inner",
      ["aC"] = "@class.outer",
      ["iC"] = "@class.inner",
      ["iL"] = "@loop.inner",
      ["aL"] = "@loop.outer",
      ["iP"] = "@parameter.inner",
      ["aP"] = "@parameter.outer",
    },
  },
})
--- }}}
