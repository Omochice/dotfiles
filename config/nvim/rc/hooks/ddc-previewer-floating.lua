-- lua_source {{{
local vimx = require("artemis")

local function resize()
  local col = vimx.go.columns
  require("ddc_previewer_floating").setup({
    ui = "pum",
    max_width = math.floor(col * 0.75)
  })
end

vimx.create_autocmd(
  "VimResized",
  {
    pattern = "*",
    callback = resize,
    group = vimx.create_augroup("myvimrc#ddc-preview", { clear = true })
  }
)

resize()
require("ddc_previewer_floating").enable()
-- }}}
