local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")

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

local brightness = sbar.add("item", "brightness", {
  position = "right",
  icon = { string = icons.brightness, drawing = true },
  label = { string = "?%", drawing = true },
  background = { color = colors.yellow },
})

local BRIGHTNESS_TOOL = "~/Tools/brightness/brightness"
local BRIGHTNESS_STEP = 0.05

brightness:subscribe("mouse.clicked", function(env)
  local delta = env.BUTTON == "right" and -BRIGHTNESS_STEP or BRIGHTNESS_STEP
  sbar.exec(BRIGHTNESS_TOOL .. " -l | grep brightness", function(out)
    local level = tonumber(out:match("brightness%s+([%d%.]+)")) or 0
    local next_level = level + delta
    if next_level < 0 then
      next_level = 0
    elseif next_level > 1 then
      next_level = 1
    end
    next_level = math.floor(next_level * 100 + 0.5) / 100
    local percent = math.floor(next_level * 100 + 0.5)
    sbar.exec(BRIGHTNESS_TOOL .. " -m " .. next_level)
    brightness:set({
      label = percent .. "%",
      icon = { string = icons.brightness_levels[band(percent)] or icons.brightness_default },
    })
  end)
end)

local volume = sbar.add("item", "volume", {
  position = "right",
  icon = { string = icons.volume, drawing = true },
  label = { string = "?%", drawing = true },
  background = { color = colors.green },
  update_freq = 5,
})

volume:subscribe({ "routine", "forced" }, function()
  sbar.exec("osascript -e 'get volume settings'", function(out)
    local level = tonumber(out:match("output volume:(%d+)"))
    local icon
    if out:match("output muted:true") then
      icon = icons.volume_muted
    elseif level and level >= 50 then
      icon = icons.volume_high
    else
      icon = icons.volume_low
    end
    volume:set({ icon = { string = icon }, label = (level or 0) .. "%" })
  end)
end)

local battery = sbar.add("item", "battery", {
  position = "right",
  icon = { string = icons.battery, drawing = true },
  label = { string = "?%", drawing = true },
  background = { color = colors.red },
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
