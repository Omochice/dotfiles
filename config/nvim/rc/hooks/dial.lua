-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set("n", "<C-a>", function()
  require("dial.map").manipulate("increment", "normal")
end)
vimx.keymap.set("n", "<C-x>", function()
  require("dial.map").manipulate("decrement", "normal")
end)
vimx.keymap.set("n", "g<C-a>", function()
  require("dial.map").manipulate("increment", "gnormal")
end)
vimx.keymap.set("n", "g<C-x>", function()
  require("dial.map").manipulate("decrement", "gnormal")
end)
vimx.keymap.set("v", "<C-a>", function()
  require("dial.map").manipulate("increment", "visual")
end)
vimx.keymap.set("v", "<C-x>", function()
  require("dial.map").manipulate("decrement", "visual")
end)
vimx.keymap.set("v", "g<C-a>", function()
  require("dial.map").manipulate("increment", "gvisual")
end)
vimx.keymap.set("v", "g<C-x>", function()
  require("dial.map").manipulate("decrement", "gvisual")
end)

vimx.keymap.set("n", "g~", function()
  require("dial.map").manipulate("increment", "gnormal", "case")
end)
vimx.keymap.set("n", "~", function()
  require("dial.map").manipulate("increment", "normal", "case")
end)
-- }}}

-- lua_source {{{
local augend = require("dial.augend")
require("dial.config").augends:register_group({
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
  },
  case = {
    augend.case.new({
      types = { "camelCase", "snake_case", "kebab-case", "PascalCase" },
      cyclic = true,
    }),
  },
})
require("dial.config").augends:on_filetype({
  markdown = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.constant.new({
      elements = { "- [ ]", "- [x]" },
      word = false,
      cyclic = true,
      match_before_cursor = true,
    }),
  },
})
-- }}}
