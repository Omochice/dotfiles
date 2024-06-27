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
    enable = true,
    duration = 0,
    delay = 0,
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
