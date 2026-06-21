local sbar = require("sketchybar")
local colors = require("colors")

-- Resolved synchronously because the space items must exist before sketchybar
-- finishes loading the config.
local function read_lines(command)
  local handle = assert(io.popen(command))
  local lines = {}
  for line in handle:lines() do
    lines[#lines + 1] = line
  end
  handle:close()
  return lines
end

local displays = read_lines("yabai --message query --displays | jq -c '.[].spaces'")

for index, spaces_json in ipairs(displays) do
  local position = index == 1 and "q" or "center"

  for _, space in ipairs(read_lines("echo '" .. spaces_json .. "' | jq 'reverse[]'")) do
    local id = index .. "-" .. space
    sbar.add("space", id, {
      position = position,
      associated_display = index,
      associated_space = tonumber(space),
      click_script = "yabai --message space --focus " .. space,
      icon = {
        string = space,
        drawing = true,
        color = colors.white,
        highlight_color = colors.black,
        padding_left = 8,
        padding_right = 8,
      },
      background = {
        padding_left = 4,
        padding_right = 4,
      },
    })
  end

  sbar.add("bracket", "space-" .. index, { "/" .. index .. "-.*/" }, {
    background = { color = colors.red },
  })
end
