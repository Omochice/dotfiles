--- lua_source {{{
require("hlchunk").setup({
  indent = {
    enable = false
  },
  line_num = {
    enable = false
  },
  blank = {
    enable = false
  },
  chunk = {
    chars = {
      horizontal_line = "─",
      vertical_line = "│",
      left_top = "╭",
      left_bottom = "╰",
      right_arrow = "→",
    },
  }
})
--- }}}
