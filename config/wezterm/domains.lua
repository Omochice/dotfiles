local M = {}
local wezterm = require("wezterm")

if wezterm.target_triple:find("windows") then
  M = {
    wsl_domains = { {
      name = 'WSL:main',
      distribution = 'Ubuntu',
      default_cwd = "~",
    }, },
    default_gui_startup_args = { "connect", "WSL:main" },
  }
else
  M = {
    unix_domains = { { name = "unix" }, },
    default_gui_startup_args = { "connect", "unix" },
  }
end

return M
