local wezterm = require("wezterm")
local act = wezterm.action

local M = {
  { key = "c", mods = "ALT", action = act.SpawnTab("DefaultDomain") },
  { key = "n", mods = "ALT", action = act.ActivateTabRelative(1) },
  { key = "n", mods = "ALT|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "-", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "LeftArrow", mods = "ALT", action = act.AdjustPaneSize({ "Left", 3 }) },
  { key = "DownArrow", mods = "ALT", action = act.AdjustPaneSize({ "Down", 3 }) },
  { key = "UpArrow", mods = "ALT", action = act.AdjustPaneSize({ "Up", 3 }) },
  { key = "RightArrow", mods = "ALT", action = act.AdjustPaneSize({ "Right", 3 }) },
  { key = "q", mods = "ALT|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "q", mods = "ALT", action = "ActivateCopyMode" },
  { key = "[", mods = "ALT", action = "ActivateCopyMode" },
  { key = "r", mods = "ALT|SHIFT", action = "ReloadConfiguration" },
  { key = "1", mods = "ALT", action = act.ActivateTab(0) },
  { key = "2", mods = "ALT", action = act.ActivateTab(1) },
  { key = "3", mods = "ALT", action = act.ActivateTab(2) },
  { key = "4", mods = "ALT", action = act.ActivateTab(3) },
  { key = "5", mods = "ALT", action = act.ActivateTab(4) },
  { key = "6", mods = "ALT", action = act.ActivateTab(5) },
  { key = "7", mods = "ALT", action = act.ActivateTab(6) },
  { key = "8", mods = "ALT", action = act.ActivateTab(7) },
  { key = "9", mods = "ALT", action = act.ActivateTab(8) },
  { key = "Enter", mods = "ALT", action = act.QuickSelect },
  { key = "/", mods = "ALT", action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "v", mods = "ALT", action = act.PasteFrom("Clipboard") },
  {
    key = "r",
    mods = "ALT",
    action = act({
      ActivateKeyTable = {
        name = "resize_pane",
        one_shot = false,
        timeout_milliseconds = 3000,
        replace_current = false,
      }
    }),
  },
}

if wezterm.target_triple:find("windows") then
  table.insert(M, {
    key = "c",
    mods = "ALT|SHIFT",
    action = act.SpawnCommandInNewTab({
      args = { "nu.exe" }, cwd = "~", domain = { DomainName = "local" }
    })
  })
end

if wezterm.target_triple:find("darwin") then
  table.insert(M, {
    key = "mapped:¥",
    mods = "ALT",
    action = act.SplitHorizontal({
      domain = "CurrentPaneDomain",
    })
  })
  -- なぜかweztermだけyenとbackslashが反転するっぽい
  table.insert(M, {
    key = "¥",
    action = act.SendString("\\"),
  })
else -- Linux / windows
  table.insert(M, {
    key = "\\",
    mods = "ALT",
    action = act.SplitHorizontal({
      domain = "CurrentPaneDomain",
    })
  })
end

return M
