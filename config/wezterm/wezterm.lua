local wezterm = require("wezterm");
local io = require("io")

-- utils

function merged(...)
    local results = {}
    local tables = {...}
    for i = 1, #tables do
        results = _merged(results, tables[i])
    end
    return results
end

function _merged(t1, t2) -- from [https://github.com/yutkat/dotfiles/blob/3576916618fa7991de69682f628ec4832cf919c7/.config/wezterm/utils.lua]
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			merge_tables(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

function basename(path)
	return string.gsub(path, "(.*[/\\])(.*)", "%2")
end

function get_process_name(p)
    return basename(string.match(p, "^(.-)%s"))
end

function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  io.close(f)
  local outputed = {}
  for line in string.gmatch(s, "([^\n]*)\n?") do
      table.insert(outputed, line)
  end
  return outputed
end

function is_opened_already()
    local res = os.capture("ps axh | grep wezterm-gui")
    return #res > 3
end

-- setting variables

local fonts = {
    font = wezterm.font_with_fallback({
        {family="Firge35Nerd Console", weight="Medium"},
        {family="Consolas", weight="Medium"},
    }),
    font_size = 20,
}

local keys = {
    disable_default_key_bindings = true,
    keys = {
        { key = "c", mods = "ALT", action = wezterm.action({ SpawnTab = "DefaultDomain" }) },
        { key = "n", mods = "ALT", action = wezterm.action({ ActivateTabRelative = 1 }) },
        { key = "n", mods = "ALT|SHIFT", action = wezterm.action({ ActivateTabRelative = -1 }) },
        { key = "-", mods = "ALT", action = wezterm.action({ SplitVertical = {domain = "CurrentPaneDomain"} }) },
        { key = "h", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
        { key = "j", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
        { key = "k", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
        { key = "l", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
        { key = "LeftArrow", mods = "ALT", action = wezterm.action({ AdjustPaneSize = {"Left", 3} })},
        { key = "DownArrow", mods = "ALT", action = wezterm.action({ AdjustPaneSize = {"Down", 3} })},
        { key = "UpArrow", mods = "ALT", action = wezterm.action({ AdjustPaneSize = {"Up", 3} })},
        { key = "RightArrow", mods = "ALT", action = wezterm.action({ AdjustPaneSize = {"Right", 3} })},
        { key = "q", mods = "ALT|SHIFT", action = wezterm.action({ CloseCurrentPane = {confirm = false} })},
        { key = "q", mods = "ALT", action = "ActivateCopyMode" },
        { key = "[", mods = "ALT", action = "ActivateCopyMode" },
        { key = "r", mods = "ALT|SHIFT", action = "ReloadConfiguration" },
    }
}
if os.capture("uname")[1] == "Darwin" then
    local mac_bindings = {
        { key = "mapped:¥", mods = "ALT", action = wezterm.action({ SplitHorizontal = {domain = "CurrentPaneDomain"} }) },
        { key = "¥", action = wezterm.action({ SendString="\\" }) },
        -- なぜかweztermだけyenとbackslashが反転するっぽい
    }
    for _,v in pairs(mac_bindings) do
        table.insert(keys.keys, v)
    end
else -- Linux
    local linux_bindings = {
        { key = "raw:132", mods = "ALT", action = wezterm.action({ SplitHorizontal = {domain = "CurrentPaneDomain"} }) }, -- 132 = backslash
    }
end

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

local _sessions = {}
for i = 1, 3 do
    table.insert(_sessions, {name = "session" .. tostring(i)})
end

local domains = {
    unix_domains = _sessions,
}
if not is_opened_already() then
    domains.default_gui_startup_args = {"connect", "session1"}
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = wezterm.truncate_right(get_process_name(tab.active_pane.title), max_width)
	return {
		{ Text = " " .. tab.tab_index + 1 .. ": " .. title .. " "},
	}
end)

others = {
    -- default_prog = os.capture("echo $SHELL"),
    exit_behavior = "Close",
    use_ime = true,
}

return merged(
    keys,
    fonts,
    bars,
    colors,
    windows,
    domains,
    others
)
