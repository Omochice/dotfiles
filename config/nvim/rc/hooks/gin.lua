-- lua_add {{{
local vimx = require("artemis")
local prefix = "<C-g>"
vimx.g.gin_proxy_apply_without_confirm = true
vimx.keymap.set("n", prefix .. "<C-g>", "<Cmd>GinStatus<CR>")
vimx.keymap.set("n", prefix .. "<C-b>", "<Cmd>GinBranch<CR>")
vimx.keymap.set("n", prefix .. "<C-l>", "<Cmd>GinLog<CR>")
vimx.create_autocmd("BufWinLeave", {
  pattern = "ginstatus://*",
  group = vimx.create_augroup("myvimrc#gin", {
    clear = true
  }),
  callback = function()
    local winids = vimx.fn.tabpagebuflist()
    for _, val in ipairs(winids) do
      local winnr = vimx.fn.bufwinnr(val)
      local winvar = vimx.fn.getwinvar(winnr, "&filetype")
      if winvar == "gin-diff" then
        vimx.cmd(string.format("%dclose", winnr))
      end
    end
  end
})
-- }}}

-- lua_gin-diff {{{
local vimx = require("artemis")
vimx.bo.buflisted = false
-- }}}

-- lua_gin-status {{{
local vimx = require("artemis")
vimx.keymap.set("n", "h", "<Plug>(gin-action-stage)", { buffer = true })
vimx.keymap.set("n", "l", "<Plug>(gin-action-unstage)", { buffer = true })
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
  if vimx.bo.filetype ~= "gin-status" then
    return
  end
  if vimx.fn.line(".") == 1 then
    return
  end
  local line = vimx.fn.getline(".")
  if string.len(line) <= 3 then
    return
  end
  local filename = string.sub(line, 4)
  if string.match(filename, "^%s+$") ~= nil then
    return
  end
  local diff_type = string.sub(line, 0, 2)
  -- local is_tracked = string.match(diff_type, "^%?%?") == nil
  local is_staged = string.match(diff_type, "^M") ~= nil
  local staged = is_staged and "--staged" or ""
  local winid = get_winid_by_filetype("gin-diff")
  -- FIXME: I want to show untracked file as all new code
  -- but, there are some problem:
  -- 1. gin replace `/dev/null` to relative path
  --   ref: https://github.com/lambdalisue/gin.vim/blob/5f27fb643056e725476234f27141859415cd31ed/denops/gin/command/diff/command.ts#L36
  -- 1. Return 1 as status code when exec `git diff -- /dev/null path/to/file`.
  --    And gin throw if get error code...
  --   ref: https://github.com/lambdalisue/gin.vim/blob/5f27fb643056e725476234f27141859415cd31ed/denops/gin/git/executor.ts#L85+L87
  -- local dev_null = is_tracked and "" or "/dev/null"
  if winid == nil then
    local current_winid = vimx.fn.win_getid()
    local cmd = string.format([[GinDiff HEAD %s ++opener=botright\ vsplit -- %s]], staged, filename)
    vimx.cmd(cmd)
    vimx.fn.win_gotoid(current_winid)
    return
  end
  local cmd = string.format("GinDiff HEAD %s -- %s", staged, filename)
  vimx.fn.win_execute(vimx.fn.win_getid(winid), cmd)
end, { buffer = true, nowait = true })

vimx.keymap.set("n", "q", function()
  vimx.cmd("silent! bprevious")
end, { buffer = true, nowait = true })
vimx.keymap.set("n", "A", "<Cmd>Gin commit --amend --no-edit --allow-empty<CR>", { buffer = true, nowait = true })
vimx.keymap.set("n", "D", function()
  if vimx.fn.line(".") == 1 then
    return
  end
  local line = vimx.fn.getline(".")
  local filename = string.sub(line, 4)
  if filename == nil then
    return
  end
  vimx.cmd(string.format("Gin checkout -- %s", filename))
  -- vimx.cmd(string.format("echo 'Checkout %s'", filename))
end, { buffer = true, nowait = true })
-- }}}

-- lua_gin-branch {{{
local vimx = require("artemis")
vimx.keymap.set("n", "c", "<Plug>(gin-action-new)", { buffer = true, nowait = true })
-- }}}
