-- lua_add {{{
local vimx = require("artemis")
vimx.g.searchx = {
  auto_accept = true,
  scrollof = vimx.go.scrolloff,
  scrolltile = 0,
  markers = vimx.fn.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", [[.\zs]]),
  convert = function(input)
    if vimx.fn.matchstr(input, [[\k]]) == "" then
      return [[\V]] .. input
    end
    return table.concat(vimx.fn.split(input, " "), [[.\{-}]])
  end
}

vimx.keymap.set({ "n", "x" }, "?", function()
  vimx.fn.searchx.start({ dir = 0 })
end)
vimx.keymap.set({ "n", "x" }, "/", function()
  vimx.fn.searchx.start({ dir = 1 })
end)
vimx.keymap.set({"n", "x"}, "N", function()
  vimx.fn.searchx.prev()
end)
vimx.keymap.set({"n", "x"}, "n", function()
  vimx.fn.searchx.next()
end)
-- }}}
