-- lua_source {{{
-- A terminal cell is about twice as tall as it is wide.
local function is_landscape()
  return vim.o.columns > vim.o.lines * 2
end

local actions = require("diffview.actions")
local function comment()
  require("omochice.review").comment()
end
local panel_keys = {
  { "n", "<Space>b", actions.toggle_files, { desc = "Toggle the file panel" } },
  { "n", "<Space>e", actions.focus_files, { desc = "Focus the file panel" } },
}

require("diffview").setup({
  file_panel = {
    win_config = function()
      if is_landscape() then
        return { type = "split", position = "left", width = "auto" }
      end
      return { type = "split", position = "bottom", height = 10 }
    end,
  },
  keymaps = {
    view = vim.list_extend({
      { { "n", "x" }, "i", comment, { desc = "Add a review comment" } },
      { { "n", "x" }, "a", comment, { desc = "Add a review comment" } },
      { { "n", "x" }, "o", comment, { desc = "Add a review comment" } },
    }, panel_keys),
    file_panel = panel_keys,
  },
})
-- }}}
