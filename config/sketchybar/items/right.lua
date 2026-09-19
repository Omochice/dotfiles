local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")

local function band(percent)
  if percent >= 100 then
    return 100
  end
  return math.floor(percent / 10) * 10
end

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

local usage = sbar.add("item", "usage", {
  position = "right",
  icon = { string = icons.ccusage, drawing = true },
  label = { string = "?", drawing = true },
  background = { color = colors.red },
  popup = {
    background = {
      color = 0xA0000000,
      border_width = 2,
      corner_radius = 3,
      border_color = colors.red,
    },
  },
})

usage:subscribe("mouse.clicked", function()
  usage:set({ popup = { drawing = "toggle" } })
end)

local function usage_row(name)
  return sbar.add("item", name, {
    position = "popup.usage",
    drawing = false,
    label = { drawing = true, align = "left", color = colors.white },
  })
end

local five_hour_row = usage_row("usage.five_hour")
local seven_day_row = usage_row("usage.seven_day")

local function reset_suffix(resets_at)
  local epoch = tonumber(resets_at or "")
  if not epoch then
    return ""
  end
  return os.date(" (%m-%d %H:%M)", math.floor(epoch))
end

local function render_row(row, tag, left, resets_at)
  local percent = tonumber(left or "")
  if not percent or percent == -1 then
    row:set({ drawing = false })
    return nil
  end
  percent = math.floor(percent)
  row:set({ drawing = true, label = { string = tag .. "  " .. percent .. "%" .. reset_suffix(resets_at) } })
  return percent
end

sbar.add("event", "claude_usage")

usage:subscribe("claude_usage", function(env)
  local five_hour = render_row(five_hour_row, "5h", env.FIVE_HOUR_LEFT, env.FIVE_HOUR_RESETS_AT)
  render_row(seven_day_row, "7d", env.SEVEN_DAY_LEFT, env.SEVEN_DAY_RESETS_AT)
  if five_hour then
    usage:set({ label = "5h " .. five_hour .. "%" })
  end
end)
