-- lua_add {{{
local vimx = require("artemis")
vimx.g["toy_postfix#rule_dir"] = vimx.g.config_dir .. "/postfix"
vimx.g["toy_postfix#extends"] = {
  typescript = "javascript",
  vue = { "typescript", "javascript" },
}
-- }}}
