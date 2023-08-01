local wezterm = require("wezterm")
local act = wezterm.action

local M = {
  { key = "LeftArrow",  action = act.AdjustPaneSize({ "Left", 3 }) },
  { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 3 }) },
  { key = "UpArrow",    action = act.AdjustPaneSize({ "Up", 3 }) },
  { key = "DownArrow",  action = act.AdjustPaneSize({ "Down", 3 }) },
  { key = "h",          action = act.AdjustPaneSize({ "Left", 3 }) },
  { key = "j",          action = act.AdjustPaneSize({ "Down", 3 }) },
  { key = "k",          action = act.AdjustPaneSize({ "Up", 3 }) },
  { key = "l",          action = act.AdjustPaneSize({ "Right", 3 }) },
  -- Cancel the mode by pressing escape
  { key = "Escape",     action = "PopKeyTable" },
}

return M
