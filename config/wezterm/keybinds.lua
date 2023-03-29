local wezterm = require("wezterm")
local act = wezterm.action

local M = {
  disable_default_key_bindings = true,
  keys = {
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
    { key = "r", mods = "ALT", action = act({
      ActivateKeyTable = {
        name = "resize_pane",
        one_shot = false,
        timeout_milliseconds = 3000,
        replace_current = false,
      }
    }),
    },
  },
}

M.key_tables = {
  resize_pane = {
    { key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 3 }) },
    { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 3 }) },
    { key = "UpArrow", action = act.AdjustPaneSize({ "Up", 3 }) },
    { key = "DownArrow", action = act.AdjustPaneSize({ "Down", 3 }) },
    { key = "h", action = act.AdjustPaneSize({ "Left", 3 }) },
    { key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
    { key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
    { key = "l", action = act.AdjustPaneSize({ "Right", 3 }) },
    -- Cancel the mode by pressing escape
    { key = "Escape", action = "PopKeyTable" },
  },
  -- TODO: copy-modeのときにC-u/dを使えるようにする
  copy_mode = {
    {
      key = "Escape",
      mods = "NONE",
      action = act.Multiple({
        act.ClearSelection,
        act.CopyMode("ClearPattern"),
        act.CopyMode("Close"),
      }),
    },
    { key = "q", mods = "NONE", action = act.CopyMode("Close") },
    -- move cursor
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
    -- move word
    { key = "RightArrow", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
    { key = "f", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
    { key = "\t", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "LeftArrow", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
    { key = "b", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
    { key = "\t", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
    { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
    {
      key = "e",
      mods = "NONE",
      action = act({
        Multiple = {
          act.CopyMode("MoveRight"),
          act.CopyMode("MoveForwardWord"),
          act.CopyMode("MoveLeft"),
        },
      }),
    },
    -- move start/end
    { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = "\n", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
    { key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "e", mods = "CTRL", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "m", mods = "ALT", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "a", mods = "CTRL", action = act.CopyMode("MoveToStartOfLineContent") },
    -- select
    { key = " ", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    {
      key = "v",
      mods = "SHIFT",
      action = act({
        Multiple = {
          act.CopyMode("MoveToStartOfLineContent"),
          act.CopyMode({ SetSelectionMode = "Cell" }),
          act.CopyMode("MoveToEndOfLineContent"),
        },
      }),
    },
    -- copy
    {
      key = "y",
      mods = "NONE",
      action = act({
        Multiple = {
          act({ CopyTo = "ClipboardAndPrimarySelection" }),
          act.CopyMode("Close"),
        },
      }),
    },
    {
      key = "y",
      mods = "SHIFT",
      action = act({
        Multiple = {
          act.CopyMode({ SetSelectionMode = "Cell" }),
          act.CopyMode("MoveToEndOfLineContent"),
          act({ CopyTo = "ClipboardAndPrimarySelection" }),
          act.CopyMode("Close"),
        },
      }),
    },
    -- scroll
    { key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
    { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
    { key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
    { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
    { key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
    { key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
    { key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
    { key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
    { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
    { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
    {
      key = "Enter",
      mods = "NONE",
      action = act.CopyMode("ClearSelectionMode"),
    },
    -- search
    { key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
    {
      key = "n",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode("NextMatch"),
        act.CopyMode("ClearSelectionMode"),
      }),
    },
    {
      key = "N",
      mods = "SHIFT",
      action = act.Multiple({
        act.CopyMode("PriorMatch"),
        act.CopyMode("ClearSelectionMode"),
      }),
    },
  }
}

if wezterm.target_triple:find("windows") then
  table.insert(M.keys, {
    key = "c",
    mods = "ALT|SHIFT",
    action = act.SpawnCommandInNewTab({
      args = { "nu.exe" }, cwd = "~", domain = { DomainName = "local" }
    })
  })
end

if wezterm.target_triple:find("darwin") then
  table.insert(M.keys, {
    key = "mapped:¥",
    mods = "ALT",
    action = act.SplitHorizontal({
      domain = "CurrentPaneDomain",
    })
  })
  -- なぜかweztermだけyenとbackslashが反転するっぽい
  table.insert(M.keys, {
    key = "¥",
    action = act.SendString("\\"),
  })
else -- Linux / windows
  table.insert(M.keys, {
    key = "\\",
    mods = "ALT",
    action = act.SplitHorizontal({
      domain = "CurrentPaneDomain",
    })
  })
end

return M
