local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")

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
