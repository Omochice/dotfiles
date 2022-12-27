local M = {}
local wezterm = require("wezterm")

if wezterm.target_triple:find("windows") then
  M = {
    name = 'WSL:Ubuntu-20.04',
    distribution = 'Ubuntu',
  }
else
  M = {
    unix_domains = { { name = "unix" }, },
    default_gui_startup_args = { "connect", "unix" },
  }
end

return M
