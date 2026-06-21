local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")
local paths = require("paths")

local PADDING = 20

local apple = sbar.add("item", "apple", {
  position = "left",
  icon = {
    string = icons.apple,
    drawing = true,
    color = colors.white,
    y_offset = 1,
    padding_left = PADDING,
    padding_right = PADDING,
    background = { color = colors.transparent },
  },
  background = {
    color = colors.black,
    border_color = colors.green,
  },
  popup = {
    background = {
      color = 0xA0000000,
      border_width = 2,
      corner_radius = 3,
      border_color = colors.green,
    },
  },
})

apple:subscribe("mouse.clicked", function()
  apple:set({ popup = { drawing = "toggle" } })
end)

local function popup_item(name, icon, label, command)
  local item = sbar.add("item", name, {
    position = "popup.apple",
    icon = { string = icon, drawing = true, align = "left", color = colors.white },
    label = { string = label, drawing = true, align = "left", color = colors.white },
  })
  item:subscribe("mouse.clicked", function()
    sbar.exec(command)
    apple:set({ popup = { drawing = false } })
  end)
end

popup_item(
  "apple.shutdown",
  icons.shutdown,
  "Shutdown",
  "osascript -e 'tell app \"loginwindow\" to \u{AB}event aevtrsdn\u{BB}'"
)
popup_item(
  "apple.reboot",
  icons.reboot,
  "Reboot",
  "osascript -e 'tell app \"loginwindow\" to \u{AB}event aevtrrst\u{BB}'"
)
popup_item("apple.sleep", icons.lock, "Lock Screen", "pmset displaysleepnow")

local cpu = sbar.add("item", "cpu", {
  position = "left",
  icon = { string = icons.cpu, drawing = true, y_offset = 1 },
  label = { string = "?%", drawing = true },
  background = {
    color = colors.green,
    border_color = colors.green,
  },
  update_freq = 3,
})

local cpu_threads = tonumber(io.popen("sysctl -n machdep.cpu.thread_count"):read("*l")) or 1

cpu:subscribe({ "routine", "forced" }, function()
  sbar.exec("ps -eo pcpu", function(out)
    local total = 0
    for value in out:gmatch("[%d%.]+") do
      total = total + tonumber(value)
    end
    cpu:set({ label = string.format("%.0f%%", total / cpu_threads) })
  end)
end)

local ram = sbar.add("item", "ram", {
  position = "left",
  icon = { string = icons.ram, drawing = true },
  label = { string = "?%", drawing = true },
  background = { color = colors.yellow },
  update_freq = 3,
})

ram:subscribe({ "routine", "forced" }, function()
  sbar.exec("memory_pressure", function(out)
    local free = out:match("System%-wide memory free percentage:%s*([%d%.]+)")
    if free then
      ram:set({ label = string.format("%g%%", 100 - tonumber(free)) })
    end
  end)
end)

local ccusage = sbar.add("item", "ccusage", {
  position = "left",
  icon = { string = icons.ccusage, drawing = true },
  label = { string = "?", drawing = true },
  background = { color = colors.red },
  update_freq = 30,
})

-- Long-bracket string so jq's backslash interpolation needs no escaping.
local ccusage_filter =
  [[{ cost: .totals.totalCost, daily: .daily[-1].totalCost } | map_values((. * 100 | ceil ) / 100) | "$\(.cost) ($\(.daily)/d)"]]
local ccusage_command = paths.ccusage .. " --offline --json | " .. paths.jq .. " -r '" .. ccusage_filter .. "'"

ccusage:subscribe({ "routine", "forced" }, function()
  sbar.exec(ccusage_command, function(out)
    ccusage:set({ label = (out:gsub("%s+$", "")) })
  end)
end)
