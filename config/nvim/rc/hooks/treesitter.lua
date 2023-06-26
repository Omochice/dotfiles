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
  textobjects = {
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
  },
  tree_docs = { enable = true, keymap = false },
})
-- }}}
