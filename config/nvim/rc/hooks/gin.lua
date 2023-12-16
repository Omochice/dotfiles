-- lua_add {{{
local vimx = require("artemis")
local prefix = "<C-g>"
vimx.g.gin_proxy_apply_without_confirm = true
vimx.keymap.set("n", prefix .. "<C-g>", "<Cmd>GinStatus<CR>")
vimx.keymap.set("n", prefix .. "<C-b>", "<Cmd>GinBranch<CR>")
vimx.keymap.set("n", prefix .. "<C-l>", "<Cmd>GinLog<CR>")
-- }}}

-- lua_gin-diff {{{
local vimx = require("artemis")
vimx.bo.buflisted = false
-- }}}

-- lua_gin-status {{{
local vimx = require("artemis")
vimx.keymap.set("n", "h", "<Plug>(gin-action-stage)", { buffer = true })
vimx.keymap.set("n", "l", "<Plug>(gin-action-unstage)", { buffer = true })
-- vimx.keymap.set("n", "q", "<Cmd>bprevious<CR>", { buffer = true, nowait = true })
vimx.keymap.set("n", "cc", "<Cmd>Gin commit<CR>", { buffer = true })

--- Get winid by filetype
--- @param filetype string the name of filetype
--- @return number|nil winid The winid that found first
local function get_winid_by_filetype(filetype)
  local winids = vimx.fn.tabpagebuflist()
  for _, val in ipairs(winids) do
    local winnr = vimx.fn.bufwinnr(val)
    local winvar = vimx.fn.getwinvar(winnr, "&filetype")
    if winvar == filetype then
      return winnr
    end
  end
  return nil
end

vimx.keymap.set("n", "d", function()
  if vimx.fn.line(".") == 1 then
    return
  end
  local line = vimx.fn.getline(".")
  if string.len(line) <= 3 then
    return
  end
  local filename = string.sub(line, 3)
  if not string.match(filename, "^%s+$") == nil then
    return
  end
  local winid = get_winid_by_filetype("gin-diff")
  if winid == nil then
    local current_winid = vimx.fn.win_getid()
    vimx.cmd(string.format([[GinDiff HEAD ++opener=botright\ vsplit -- %s]], filename))
    vimx.fn.win_gotoid(current_winid)
    return
  end
  vimx.fn.win_execute(vimx.fn.win_getid(winid), string.format("GinDiff HEAD -- %s", filename))
end, { buffer = true, nowait = true })

vimx.keymap.set("n", "q", function()
  local diff_winid = get_winid_by_filetype("gin-diff")
  if not (diff_winid == nil) then
    vimx.cmd(string.format("%dclose", diff_winid))
  end
  vimx.cmd("silent! bprevious")
end, { buffer = true, nowait = true })
-- }}}

-- lua_gin-branch {{{
local vimx = require("artemis")
vimx.keymap.set("n", "i", "<Plug>(gin-action-new)", { buffer = true })
-- }}}
