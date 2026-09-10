-- lua_source {{{
local gitsign = require("gitsigns")

---@param direction "next"|"prev"
---@param native string
local function nav_hunk(direction, native)
  return function()
    if vim.wo.diff then
      vim.cmd.normal({ native, bang = true })
      return
    end
    gitsign.nav_hunk(direction)
  end
end

gitsign.setup({
  on_attach = function(bufnr)
    vim.keymap.set("n", "[c", nav_hunk("prev", "[c"), { buffer = bufnr })
    vim.keymap.set("n", "]c", nav_hunk("next", "]c"), { buffer = bufnr })
    vim.keymap.set("n", "<Space>gm", gitsign.blame_line, { buffer = bufnr })
  end,
  preview_config = {
    border = "single",
  },
})
-- }}}
