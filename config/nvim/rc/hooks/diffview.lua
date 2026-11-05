-- lua_source {{{
local function is_landscape()
  return require("omochice.aspect").is_landscape(vim.o.columns, vim.o.lines)
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
  view = {
    cycle_layouts = {
      default = { "diff2_horizontal", "diff1_inline" },
    },
  },
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
