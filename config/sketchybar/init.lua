local sbar = require("sketchybar")
local colors = require("colors")
local paths = require("paths")

-- This bar shares the strip OmniWM draws its islands in, so the height is
-- measured rather than fixed and the two stay aligned on any display.
local function read_number(command, fallback)
  local handle = io.popen(command .. " 2>/dev/null")
  if handle == nil then
    return fallback
  end
  local value = tonumber(handle:read("*l"))
  handle:close()
  return value or fallback
end

local STRIP = read_number(
  paths.omniwmctl
    .. " query displays --main --format json | "
    .. paths.jq
    .. " '.result.payload.displays[0] | .frame.height - .visibleFrame.height'",
  32
)

local PADDING = 20
local GAP = 5
local MARGIN = 10
local HEIGHT = STRIP - 4
local RADIUS = HEIGHT // 2

local FONT = "Firge35Nerd Console:Regular:18.0"

sbar.bar({
  height = STRIP,
  blur_radius = 50,
  position = "top",
  y_offset = 0,
  padding_left = 8,
  padding_right = 8,
  color = colors.transparent,
})

sbar.default({
  icon = {
    drawing = false,
    align = "center",
    font = FONT,
    color = colors.black,
    padding_left = PADDING,
    padding_right = GAP,
    background = { color = colors.transparent },
  },
  label = {
    drawing = false,
    align = "center",
    font = FONT,
    color = colors.black,
    padding_left = GAP,
    padding_right = PADDING,
    background = { color = colors.transparent },
  },
  background = {
    height = HEIGHT,
    corner_radius = RADIUS,
    padding_left = MARGIN,
    padding_right = MARGIN,
  },
})

require("items.left")
require("items.right")
