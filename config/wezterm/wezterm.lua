local wezterm = require("wezterm");
local io = require("io")
local utils = require("utils")


local fonts = {
  font = wezterm.font_with_fallback({
    { family = "Firge35Nerd Console", weight = "Medium" },
    { family = "Consolas", weight = "Medium" },
  }),
  font_size = 20,
}


local bars = {
  use_fancy_tab_bar = false,
  colors = {
    tab_bar = {
      background = "#000000",
      active_tab = {
        bg_color = "#81d0c9",
        fg_color = "#1f1e1c",
        intensity = "Normal",
        underline = "None",
        italic = false,
        strikethrough = false,
      }
    },
  }
}

local colors = {
  window_background_opacity = 0.8,
  color_scheme = "sonokai",
  color_scheme_dirs = { "$HOME/.config/wezterm/colors/" },
}

local windows = {
  window_padding = {
    left = 5,
    right = 5,
    top = 2,
    bottom = 0,
  },
  window_close_confirmation = "NeverPrompt",
}


wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = wezterm.truncate_right(utils.get_process_name(tab.active_pane.title), max_width)
  return {
    { Text = " " .. tab.tab_index + 1 .. ": " .. title .. " " },
  }
end)

local others = {
  exit_behavior = "Close",
  use_ime = true,
  macos_forward_to_ime_modifier_mask = "SHIFT|CTRL",
}

if wezterm.target_triple:find("windows") then
  fonts.font_size = 14
end

return utils.merged(
  {
    require("keybinds"),
    require("domains"),
    fonts,
    bars,
    windows,
    colors,
    others,
  }
)
