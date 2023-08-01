local wezterm = require("wezterm")
local act = wezterm.action

local M = {
  disable_default_key_bindings = true,
  key = require("keybinds.terminal_move"),
}

M.key_tables = {
  resize_pane = require("keybinds.resize_pane"),
  -- TODO: copy-modeのときにC-u/dを使えるようにする
  copy_mode = require("keybinds.copy_mode")
}

return M
