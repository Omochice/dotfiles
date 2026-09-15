local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")
local paths = require("paths")

local function band(percent)
  if percent >= 100 then
    return 100
  end
  return math.floor(percent / 10) * 10
end

-- Right-side items are appended right to left, so the declaration order below
-- mirrors the on-screen order from the bar's right edge inward.
local clock = sbar.add("item", "clock", {
  position = "right",
  icon = { string = icons.clock, drawing = true },
  label = { drawing = true },
  background = { color = colors.blue },
  update_freq = 10,
})

clock:subscribe({ "routine", "forced", "mouse.entered", "mouse.exited" }, function(env)
  local format = env.SENDER == "mouse.entered" and "%m/%d" or "%H:%M"
  clock:set({ label = os.date(format) })
end)

local battery = sbar.add("item", "battery", {
  position = "right",
  icon = { string = icons.battery, drawing = true },
  label = { string = "?%", drawing = true },
  background = { color = colors.yellow },
  update_freq = 5,
})

battery:subscribe({ "routine", "forced" }, function()
  sbar.exec("pmset -g batt", function(out)
    local percent = tonumber(out:match("(%d+)%%"))
    local charging = out:match("AC Power") ~= nil
    local icon
    if not percent then
      icon = charging and icons.battery_charging_default or icons.battery_discharging_default
    elseif charging then
      icon = icons.battery_charging[band(percent)] or icons.battery_charging_default
    else
      icon = icons.battery_discharging[band(percent)] or icons.battery_discharging_default
    end
    battery:set({ icon = { string = icon }, label = (percent or 0) .. "%" })
  end)
end)

local ccusage = sbar.add("item", "ccusage", {
  position = "right",
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
