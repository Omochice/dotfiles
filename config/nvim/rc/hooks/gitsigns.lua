-- lua_source {{{
local gitsign = require("gitsigns")
gitsign.setup({
  on_attach = function(_bufnr)
    local vimx = require("artemis")
    vimx.keymap.set("n", "<C-g><C-p>", gitsign.prev_hunk, { buffer = true })
    vimx.keymap.set("n", "<C-g><C-n>", gitsign.next_hunk, { buffer = true })
  end
})
-- }}}
