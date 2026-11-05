--- lua_add {{{
local function is_landscape(winid)
  return require("omochice.aspect").is_landscape(vim.api.nvim_win_get_width(winid), vim.api.nvim_win_get_height(winid))
end

local function open_below(source_win)
  local height = math.floor(vim.api.nvim_win_get_height(source_win) / 3)
  vim.cmd(("noautocmd belowright %dsplit"):format(height))
  local target_win = vim.api.nvim_get_current_win()
  -- aerial resizes the width of its window, which in a horizontal split would shrink the whole column.
  vim.w[target_win].aerial_set_width = true
  require("aerial").open_in_win(target_win, source_win)
  vim.wo[target_win].winfixwidth = false
  vim.wo[target_win].winfixheight = true
  vim.api.nvim_set_current_win(source_win)
end

vim.api.nvim_create_user_command("Outline", function()
  local aerial = require("aerial")
  -- `is_open` reports false while the cursor is inside the aerial window itself.
  if vim.bo.filetype == "aerial" or aerial.is_open() then
    aerial.close()
    return
  end
  local source_win = vim.api.nvim_get_current_win()
  if is_landscape(source_win) then
    aerial.open({ focus = false })
  else
    open_below(source_win)
  end
end, { desc = "Toggle aerial below a portrait window or beside a landscape one" })
--- }}}

--- lua_source {{{
require("aerial").setup({
  layout = {
    resize_to_content = false,
  },
})
--- }}}
