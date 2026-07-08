-- lua_add {{{
local vimx = require("artemis")
local prefix = "<C-g>"
vimx.g.gin_proxy_apply_without_confirm = true
vimx.keymap.set("n", prefix .. "<C-g>", "<Cmd>GinStatus<CR>")
vimx.keymap.set("n", prefix .. "<C-b>", "<Cmd>GinBranch<CR>")
vimx.keymap.set("n", prefix .. "<C-l>", "<Cmd>GinLog<CR>")
vimx.create_autocmd("BufWinLeave", {
  pattern = "ginstatus://*",
  group = vimx.create_augroup("vimrc.gin", {
    clear = true,
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
  end,
})
-- }}}

-- lua_gin-diff {{{
local vimx = require("artemis")
vimx.bo.buflisted = false
-- }}}

-- lua_gin-status {{{
local vimx = require("artemis")
vimx.keymap.set("n", "<Space>", function()
  if string.sub(vimx.fn.getline("."), 2, 2) ~= " " then
    return "<Plug>(gin-action-stage)"
  else
    return "<Plug>(gin-action-unstage)"
  end
end, { buffer = true, nowait = true, expr = true })
vimx.keymap.set("n", "cc", "<Cmd>Gin commit<CR>", { buffer = true })
vimx.keymap.set("n", "P", "<Cmd>Gin push<CR>", { buffer = true })
vimx.keymap.set("n", "<CR>", "<Plug>(gin-action-patch)", { buffer = true })
vimx.keymap.set("n", "e", "<Plug>(gin-action-edit)zv", { buffer = true })

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

--- Show given diff lines in the shared gin-diff window as a scratch buffer.
--- @param worktree string path to worktree that has the diffs
--- @param lines string[] the diff text to display
local function show_scratch_diff(worktree, lines)
  local status_winid = vimx.fn.win_getid()
  local winnr = get_winid_by_filetype("gin-diff")
  if winnr == nil then
    vimx.cmd("botright vsplit")
  else
    vimx.fn.win_gotoid(vimx.fn.win_getid(winnr))
  end
  vimx.cmd("enew")
  vimx.bo.buftype = "nofile"
  vimx.bo.bufhidden = "wipe"
  vimx.bo.swapfile = false
  vimx.fn.setline(1, lines)
  vimx.bo.modifiable = false
  vimx.cmd("file " .. vimx.fn.fnameescape("gindiff://" .. worktree))
  for _, target in ipairs({ "old", "new", "smart" }) do
    vimx.keymap.set(
      "n",
      string.format("<Plug>(gin-diffjump-%s)", target),
      string.format("<Cmd>call denops#request('gin', 'diff:diffjump:%s', [])<CR>", target),
      { buffer = true }
    )
  end
  vimx.bo.filetype = "gin-diff"
  pcall(vim.treesitter.start, vimx.fn.bufnr(), "diff")
  vimx.fn.win_gotoid(status_winid)
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
  local is_tracked = string.match(diff_type, "^%?%?") == nil
  if not is_tracked then
    local worktree = vimx.fn.gin.util.worktree()
    -- NOTE: gin throw error when exit 1, but comparing new file is only way.
    -- `git diff --no-index -- /dev/null {target}` exits with 1.
    local diff = vimx.fn.systemlist({
      "git",
      "-C",
      worktree,
      "diff",
      "--no-index",
      "--no-color",
      "--",
      "/dev/null",
      filename,
    })
    show_scratch_diff(worktree, diff)
    return
  end
  local is_staged = string.match(diff_type, "^M") ~= nil
  local staged = is_staged and "--staged" or ""
  local winid = get_winid_by_filetype("gin-diff")
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
