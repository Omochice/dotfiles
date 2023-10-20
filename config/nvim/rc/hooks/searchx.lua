-- lua_add {{{
local vimx = require("artemis")
vimx.g.searchx = {
  auto_accept = true,
  scrollof = vimx.go.scrolloff,
  scrolltile = 0,
  markers = vimx.fn.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", [[.\zs]]),
}

-- NOTE: M1だとfuncrefが通らないので
vimx.cmd([[
function g:searchx.convert(input) abort
  if a:input !~# '\k'
    return '\V' .. a:input
  endif
  return join(split(a:input, ' '), '.\{-}')
endfunction
]])

vimx.keymap.set({ "n", "x" }, "?", function()
  vimx.fn.searchx.start({ dir = 0 })
end)
vimx.keymap.set({ "n", "x" }, "/", function()
  vimx.fn.searchx.start({ dir = 1 })
end)
vimx.keymap.set({ "n", "x" }, "N", function()
  vimx.fn.searchx.prev()
end)
vimx.keymap.set({ "n", "x" }, "n", function()
  vimx.fn.searchx.next()
end)
-- }}}
