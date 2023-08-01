local wezterm = require("wezterm")
local act = wezterm.action

--- Merge list2 into list1
--- @param list1 table base table
local function merge(list1, ...)
  for _, list in ipairs({ ... }) do
    for i = 1, #list do
      list1[#list1 + i] = list[i]
    end
  end
end

local M = {}

local generic = {
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
}

local move_one_char = {
  { key = "h",          mods = "NONE", action = act.CopyMode("MoveLeft") },
  { key = "LeftArrow",  mods = "NONE", action = act.CopyMode("MoveLeft") },
  { key = "j",          mods = "NONE", action = act.CopyMode("MoveDown") },
  { key = "DownArrow",  mods = "NONE", action = act.CopyMode("MoveDown") },
  { key = "k",          mods = "NONE", action = act.CopyMode("MoveUp") },
  { key = "UpArrow",    mods = "NONE", action = act.CopyMode("MoveUp") },
  { key = "l",          mods = "NONE", action = act.CopyMode("MoveRight") },
  { key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
}

local move_one_word = {
  { key = "RightArrow", mods = "ALT",   action = act.CopyMode("MoveForwardWord") },
  { key = "f",          mods = "ALT",   action = act.CopyMode("MoveForwardWord") },
  { key = "\t",         mods = "NONE",  action = act.CopyMode("MoveForwardWord") },
  { key = "w",          mods = "NONE",  action = act.CopyMode("MoveForwardWord") },
  { key = "LeftArrow",  mods = "ALT",   action = act.CopyMode("MoveBackwardWord") },
  { key = "b",          mods = "ALT",   action = act.CopyMode("MoveBackwardWord") },
  { key = "\t",         mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
  { key = "b",          mods = "NONE",  action = act.CopyMode("MoveBackwardWord") },
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
}

local move_start_end = {
  { key = "0",  mods = "NONE",  action = act.CopyMode("MoveToStartOfLine") },
  { key = "\n", mods = "NONE",  action = act.CopyMode("MoveToStartOfNextLine") },
  { key = "$",  mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
  { key = "$",  mods = "NONE",  action = act.CopyMode("MoveToEndOfLineContent") },
  { key = "e",  mods = "CTRL",  action = act.CopyMode("MoveToEndOfLineContent") },
  { key = "m",  mods = "ALT",   action = act.CopyMode("MoveToStartOfLineContent") },
  { key = "^",  mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
  { key = "^",  mods = "NONE",  action = act.CopyMode("MoveToStartOfLineContent") },
  { key = "a",  mods = "CTRL",  action = act.CopyMode("MoveToStartOfLineContent") },
}


local select = {
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
}

local search = {
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
  {
    key = "Enter",
    mods = "NONE",
    action = act.CopyMode("ClearSelectionMode"),
  },
}

local copy = {
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
}

local scroll = {
  { key = "G",        mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
  { key = "G",        mods = "NONE",  action = act.CopyMode("MoveToScrollbackBottom") },
  { key = "g",        mods = "NONE",  action = act.CopyMode("MoveToScrollbackTop") },
  { key = "H",        mods = "NONE",  action = act.CopyMode("MoveToViewportTop") },
  { key = "H",        mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
  { key = "M",        mods = "NONE",  action = act.CopyMode("MoveToViewportMiddle") },
  { key = "M",        mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
  { key = "L",        mods = "NONE",  action = act.CopyMode("MoveToViewportBottom") },
  { key = "L",        mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
  { key = "o",        mods = "NONE",  action = act.CopyMode("MoveToSelectionOtherEnd") },
  { key = "O",        mods = "NONE",  action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
  { key = "O",        mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
  { key = "PageUp",   mods = "NONE",  action = act.CopyMode("PageUp") },
  { key = "PageDown", mods = "NONE",  action = act.CopyMode("PageDown") },
  { key = "b",        mods = "CTRL",  action = act.CopyMode("PageUp") },
  { key = "f",        mods = "CTRL",  action = act.CopyMode("PageDown") },
}

merge(
  M,
  generic,
  move_one_char,
  move_one_word,
  move_start_end,
  select,
  search,
  copy,
  scroll
)

return M
