local wezterm = require("wezterm");
local io = require("io")

-- utils
function merged(...)
    local results = {}
    local tables = { ... }
    for i = 1, #tables do
        _merged(results, tables[i])
    end
    return results
end

function _merged(t1, t2) -- from [https://github.com/yutkat/dotfiles/blob/3576916618fa7991de69682f628ec4832cf919c7/.config/wezterm/utils.lua]
    for k, v in pairs(t2) do
        print(k)
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            _merged(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

function basename(path)
    if path == nil then
        return ""
    else
        return string.gsub(path, "(.*[/\\])(.*)", "%2")
    end
    -- return path
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
        { family = "Firge35Nerd Console", weight = "Medium" },
        { family = "Consolas", weight = "Medium" },
    }),
    font_size = 20,
}

local keys = {
    disable_default_key_bindings = true,
    keys = {
        { key = "c", mods = "ALT", action = wezterm.action({ SpawnTab = "DefaultDomain" }) },
        { key = "n", mods = "ALT", action = wezterm.action({ ActivateTabRelative = 1 }) },
        { key = "n", mods = "ALT|SHIFT", action = wezterm.action({ ActivateTabRelative = -1 }) },
        { key = "-", mods = "ALT", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
        { key = "h", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
        { key = "j", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
        { key = "k", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
        { key = "l", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
        { key = "LeftArrow", mods = "ALT", action = wezterm.action({ AdjustPaneSize = { "Left", 3 } }) },
        { key = "DownArrow", mods = "ALT", action = wezterm.action({ AdjustPaneSize = { "Down", 3 } }) },
        { key = "UpArrow", mods = "ALT", action = wezterm.action({ AdjustPaneSize = { "Up", 3 } }) },
        { key = "RightArrow", mods = "ALT", action = wezterm.action({ AdjustPaneSize = { "Right", 3 } }) },
        { key = "q", mods = "ALT|SHIFT", action = wezterm.action({ CloseCurrentPane = { confirm = false } }) },
        { key = "q", mods = "ALT", action = "ActivateCopyMode" },
        { key = "[", mods = "ALT", action = "ActivateCopyMode" },
        { key = "r", mods = "ALT|SHIFT", action = "ReloadConfiguration" },
    }
}

local additional_bindings = {}
if wezterm.target_triple:find("darwin") then
    additional_bindings = {
        { key = "mapped:¥", mods = "ALT", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
        { key = "¥", action = wezterm.action({ SendString = "\\" }) },
        -- なぜかweztermだけyenとbackslashが反転するっぽい
    }
else -- Linux
    additional_bindings = {
        { key = "\\", mods = "ALT", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
    }
end
for _, v in pairs(additional_bindings) do
    table.insert(keys.keys, v)
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

local domains = {
    unix_domains = { name = "unix" },
    default_gui_startup_args = { "connext", "unix" },
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = wezterm.truncate_right(get_process_name(tab.active_pane.title), max_width)
    return {
        { Text = " " .. tab.tab_index + 1 .. ": " .. title .. " " },
    }
end)

local others = {
    exit_behavior = "Close",
    use_ime = true,
}

if wezterm.target_triple:find("windows") then
    others.default_prog = { "wsl.exe", "--distribution", "Ubuntu", "--exec", "bash", "-l" }
    fonts.font_size = 14
    domains = {}
end

return merged(
    keys,
    fonts,
    bars,
    domains,
    windows,
    others
)
