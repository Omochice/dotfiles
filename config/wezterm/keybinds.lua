local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")

local M = {
  disable_default_key_bindings = true,
  keys = utils.concatenated({
    require("keybinds.terminal_move"),
    require("keybinds.workspace"),
  }),
}

M.key_tables = {
  resize_pane = require("keybinds.resize_pane"),
  copy_mode = require("keybinds.copy_mode"),
}

return M
