local sbar = require("sketchybar")
local colors = require("colors")

local HEIGHT = 28
local PADDING = 20
local GAP = 5
local MARGIN = 10
local RADIUS = HEIGHT // 2

local FONT = "Firge35Nerd Console:Regular:18.0"

sbar.bar({
  height = HEIGHT,
  blur_radius = 50,
  position = "top",
  y_offset = 5,
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

require("items.spaces")
require("items.left")
require("items.right")
