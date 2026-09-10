-- Comments live only for one review session because the markdown written by `done()` is the durable artifact;
-- persisting them would duplicate that file with a second format to keep in sync.
local M = {}

local NAMESPACE = vim.api.nvim_create_namespace("omochice_review")
local SIGN_TEXT = "┃"
local BODY_PREFIX = "┃ "
local INPUT_BUFNAME_PREFIX = "omochicereview://"
local INPUT_HEIGHT = 10

vim.api.nvim_set_hl(0, "OmochiceReviewComment", { link = "DiagnosticVirtualTextInfo", default = true })
vim.api.nvim_set_hl(0, "OmochiceReviewSign", { link = "DiagnosticSignInfo", default = true })

---@alias omochice.review.Side "old"|"new"

---@class omochice.review.Comment
---@field id integer
---@field path string Path relative to the repository root.
---@field side omochice.review.Side
---@field start integer
---@field finish integer
---@field body string[]
---@field snapshot string[] Lines of the range at the time the comment was written.
---@field filetype string
---@field marks table<integer, { first: integer, last: integer, all: integer[] }> Extmark ids per buffer.
---@field fillers table<integer, integer> Filler extmark ids per opposite-side buffer.

---@class omochice.review.Session
---@field range string `left..right` as diffview resolved it: commit SHAs, `LOCAL`, or `:N` for the index.
---@field head string
---@field root string
---@field comments omochice.review.Comment[]
---@field next_id integer
---@field overall string[]

-- The subset of diffview's objects this module reads. Declared here because diffview is lazily
-- loaded and its own annotations are not visible to the language server at startup.
---@class omochice.review.DiffviewFile
---@field path string Path relative to the repository root.
---@field symbol string Layout slot: `"a"` for the old side, `"b"` for the new side.

---@class omochice.review.DiffviewWindow
---@field id integer
---@field file omochice.review.DiffviewFile|nil

---@class omochice.review.DiffviewLayout
---@field windows omochice.review.DiffviewWindow[]

---@class omochice.review.DiffviewView
---@field class { name: fun(self: table): string }
---@field cur_layout omochice.review.DiffviewLayout|nil
---@field adapter { ctx: { toplevel: string } }
---@field left table
---@field right table

---@type omochice.review.Session|nil
local session = nil

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "review" })
end

---@return omochice.review.DiffviewView|nil
local function current_view()
  local ok, lib = pcall(require, "diffview.lib")
  if not ok then
    return nil
  end
  local view = lib.get_current_view()
  if view == nil or view.class == nil or view.class:name() ~= "DiffView" then
    return nil
  end
  return view --[[@as omochice.review.DiffviewView]]
end

---@param view omochice.review.DiffviewView
---@param winid integer
---@return omochice.review.DiffviewFile|nil
local function window_file(view, winid)
  local layout = view.cur_layout
  if layout == nil then
    return nil
  end
  for _, win in ipairs(layout.windows) do
    if win.id == winid then
      return win.file
    end
  end
  return nil
end

-- Diffview tags the left slot "a" and the right slot "b"; three and four way layouts add slots
-- that have no old/new meaning for a review, so they are rejected rather than guessed.
---@param symbol string|nil
---@return omochice.review.Side|nil
local function side_of(symbol)
  if symbol == "a" then
    return "old"
  elseif symbol == "b" then
    return "new"
  end
  return nil
end

---@param root string
---@return string
local function head_sha(root)
  local result = vim.system({ "git", "-C", root, "rev-parse", "HEAD" }, { text = true }):wait()
  if result.code ~= 0 then
    return ""
  end
  return vim.trim(result.stdout)
end

---@param view omochice.review.DiffviewView
local function open_session(view)
  local root = view.adapter.ctx.toplevel
  session = {
    -- The resolved revs are recorded instead of the user's argument so the file still identifies
    -- the compared trees after `HEAD` or a branch name has moved on.
    range = tostring(view.left) .. ".." .. tostring(view.right),
    head = head_sha(root),
    root = root,
    comments = {},
    next_id = 1,
    overall = {},
  }
  -- :ReviewDone exists only while a session does, so completion never offers an action that has nothing to close.
  vim.api.nvim_create_user_command("ReviewDone", function()
    M.done()
  end, { desc = "Write the review markdown and close the session" })
end

---@param comment omochice.review.Comment
---@param bufnr integer
---@return integer|nil, integer|nil
local function marked_range(comment, bufnr)
  local marks = comment.marks[bufnr]
  if marks == nil or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil, nil
  end
  local first = vim.api.nvim_buf_get_extmark_by_id(bufnr, NAMESPACE, marks.first, { details = true })
  local last = vim.api.nvim_buf_get_extmark_by_id(bufnr, NAMESPACE, marks.last, { details = true })
  if first[1] == nil or last[1] == nil or first[3].invalid or last[3].invalid then
    return nil, nil
  end
  return first[1] + 1, last[1] + 1
end

-- Extmarks follow edits made during the session, so they are the source of truth while a buffer
-- holding them is alive; the stored numbers only bridge the gap between buffer reloads.
---@param comment omochice.review.Comment
local function sync_range(comment)
  for bufnr, _ in pairs(comment.marks) do
    local first, last = marked_range(comment, bufnr)
    if first ~= nil and last ~= nil then
      comment.start, comment.finish = first, last
      return
    end
  end
end

---@param comment omochice.review.Comment
local function clear_marks(comment)
  for bufnr, marks in pairs(comment.marks) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      for _, id in ipairs(marks.all) do
        pcall(vim.api.nvim_buf_del_extmark, bufnr, NAMESPACE, id)
      end
    end
  end
  for bufnr, id in pairs(comment.fillers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      pcall(vim.api.nvim_buf_del_extmark, bufnr, NAMESPACE, id)
    end
  end
  comment.marks = {}
  comment.fillers = {}
end

local function close_session()
  if session == nil then
    return
  end
  for _, comment in ipairs(session.comments) do
    clear_marks(comment)
  end
  session = nil
  pcall(vim.api.nvim_del_user_command, "ReviewDone")
end

---@param comment omochice.review.Comment
---@return string[][]
local function body_virt_lines(comment)
  local lines = {}
  for _, line in ipairs(comment.body) do
    table.insert(lines, { { BODY_PREFIX .. line, "OmochiceReviewComment" } })
  end
  return lines
end

---@param comment omochice.review.Comment
---@param bufnr integer
local function place_marks(comment, bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local start = math.min(comment.start, line_count)
  local finish = math.min(comment.finish, line_count)
  local ids = {}
  for lnum = start, finish do
    -- A whole-buffer reload (diffview refresh) deletes every line, which drags a plain extmark to
    -- the deletion point; an invalidated mark is ignored so the stored range survives instead.
    local opts = { sign_text = SIGN_TEXT, sign_hl_group = "OmochiceReviewSign", invalidate = true }
    if lnum == finish then
      opts.virt_lines = body_virt_lines(comment)
    end
    table.insert(ids, vim.api.nvim_buf_set_extmark(bufnr, NAMESPACE, lnum - 1, 0, opts))
  end
  comment.marks[bufnr] = { first = ids[1], last = ids[#ids], all = ids }
end

-- Neovim offers no API mapping a line to its diff-aligned counterpart, so the counterpart is
-- found by matching screen rows while both windows are scroll-bound. When the line is scrolled
-- out of view the same line number is used, which misaligns only until the next re-render.
---@param from_win integer
---@param lnum integer
---@param to_win integer
---@return integer
local function aligned_line(from_win, lnum, to_win)
  local row = vim.fn.screenpos(from_win, lnum, 1).row
  local to_buf = vim.api.nvim_win_get_buf(to_win)
  local fallback = math.min(lnum, vim.api.nvim_buf_line_count(to_buf))
  if row == 0 then
    return fallback
  end
  local top = vim.fn.line("w0", to_win)
  local bottom = vim.fn.line("w$", to_win)
  for candidate = top, bottom do
    if vim.fn.screenpos(to_win, candidate, 1).row == row then
      return candidate
    end
  end
  return fallback
end

---@param comment omochice.review.Comment
---@param from_win integer
---@param to_win integer
local function place_filler(comment, from_win, to_win)
  local to_buf = vim.api.nvim_win_get_buf(to_win)
  local lnum = aligned_line(from_win, comment.finish, to_win)
  local filler = {}
  for _ = 1, #comment.body do
    table.insert(filler, { { "", "OmochiceReviewComment" } })
  end
  comment.fillers[to_buf] = vim.api.nvim_buf_set_extmark(to_buf, NAMESPACE, lnum - 1, 0, {
    virt_lines = filler,
  })
end

---@param view omochice.review.DiffviewView
---@param comment omochice.review.Comment
local function render(view, comment)
  local layout = view.cur_layout
  if layout == nil then
    return
  end
  local own_win, other_win
  for _, win in ipairs(layout.windows) do
    if win.file ~= nil and win.file.path == comment.path and vim.api.nvim_win_is_valid(win.id) then
      if side_of(win.file.symbol) == comment.side then
        own_win = win.id
      elseif side_of(win.file.symbol) ~= nil then
        other_win = win.id
      end
    end
  end
  if own_win == nil then
    return
  end
  place_marks(comment, vim.api.nvim_win_get_buf(own_win))
  if other_win ~= nil then
    place_filler(comment, own_win, other_win)
  end
end

---@param view omochice.review.DiffviewView
local function render_current_entry(view)
  if session == nil or view.cur_layout == nil then
    return
  end
  local path
  for _, win in ipairs(view.cur_layout.windows) do
    if win.file ~= nil then
      path = win.file.path
    end
  end
  if path == nil then
    return
  end
  for _, comment in ipairs(session.comments) do
    if comment.path == path then
      sync_range(comment)
      clear_marks(comment)
      render(view, comment)
    end
  end
end

---@return { view: omochice.review.DiffviewView, file: omochice.review.DiffviewFile, side: omochice.review.Side }|nil
local function current_context()
  local view = current_view()
  if view == nil then
    notify("not inside a diffview", vim.log.levels.WARN)
    return nil
  end
  local winid = vim.api.nvim_get_current_win()
  local file = window_file(view, winid)
  if file == nil then
    notify("not inside a diff buffer", vim.log.levels.WARN)
    return nil
  end
  local side = side_of(file.symbol)
  if side == nil then
    notify("this layout slot cannot take a comment", vim.log.levels.WARN)
    return nil
  end
  return { view = view, file = file, side = side }
end

---@param range? { [1]: integer, [2]: integer }
---@return integer, integer
local function cursor_or_visual_range(range)
  if range ~= nil then
    return math.min(range[1], range[2]), math.max(range[1], range[2])
  end
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! \27")
    local first = vim.fn.line("'<")
    local last = vim.fn.line("'>")
    return math.min(first, last), math.max(first, last)
  end
  local lnum = vim.fn.line(".")
  return lnum, lnum
end

---@param lines string[]
---@return string[]
local function trim_trailing_blank(lines)
  local last = #lines
  while last > 0 and vim.trim(lines[last]) == "" do
    last = last - 1
  end
  return vim.list_slice(lines, 1, last)
end

---@param name string
---@param initial string[]
---@param on_write fun(lines: string[])
---@param on_close? fun()
local function open_input(name, initial, on_write, on_close)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(bufnr, INPUT_BUFNAME_PREFIX .. name)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, initial)
  -- acwrite makes `:w` reach BufWriteCmd without touching the filesystem, so `:wq` works as in any file.
  vim.bo[bufnr].buftype = "acwrite"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "markdown"
  vim.bo[bufnr].modified = false
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = bufnr,
    callback = function()
      on_write(trim_trailing_blank(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)))
      vim.bo[bufnr].modified = false
    end,
  })
  local origin_win = vim.api.nvim_get_current_win()
  -- Closing a bottom split lands in whichever window Vim picks; the reviewer expects to be back on the diff.
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = bufnr,
    once = true,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(origin_win) then
          vim.api.nvim_set_current_win(origin_win)
        end
        if on_close ~= nil then
          on_close()
        end
      end)
    end,
  })
  vim.cmd(string.format("botright %dsplit", INPUT_HEIGHT))
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.keymap.set("n", "<CR>", "<Cmd>wq<CR>", { buffer = bufnr, nowait = true, desc = "Confirm and close" })
  if #initial == 0 then
    vim.cmd("startinsert")
  end
end

---@param comment omochice.review.Comment
local function remove_comment(comment)
  if session == nil then
    return
  end
  clear_marks(comment)
  for i, c in ipairs(session.comments) do
    if c.id == comment.id then
      table.remove(session.comments, i)
      return
    end
  end
end

---@return omochice.review.Comment|nil
local function comment_at_cursor()
  if session == nil then
    return nil
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.fn.line(".")
  local found, found_span
  for _, comment in ipairs(session.comments) do
    local first, last = marked_range(comment, bufnr)
    if first ~= nil and last ~= nil and first <= lnum and lnum <= last then
      local span = last - first
      if found == nil or span < found_span then
        found, found_span = comment, span
      end
    end
  end
  return found
end

---Open a diffview and start a new review session, replacing any open one.
---@param args? string Arguments passed to `:DiffviewOpen`; defaults to `HEAD`.
function M.start(args)
  if args == nil or vim.trim(args) == "" then
    args = "HEAD"
  end
  close_session()
  vim.cmd("DiffviewOpen " .. args)
  local view = current_view()
  if view == nil then
    notify("diffview did not open", vim.log.levels.ERROR)
    return
  end
  open_session(view)
end

local QUICKFIX_TITLE = "Review comments"

-- The list is replaced in place when it is already ours so that every confirmed comment does not
-- push another entry onto the quickfix history.
local function refresh_quickfix()
  if session == nil then
    return
  end
  local items = {}
  for _, comment in ipairs(session.comments) do
    sync_range(comment)
    table.insert(items, {
      filename = vim.fs.joinpath(session.root, comment.path),
      lnum = comment.start,
      end_lnum = comment.finish,
      text = string.format("(%s) %s", comment.side, comment.body[1] or ""),
    })
  end
  local action = vim.fn.getqflist({ title = 0 }).title == QUICKFIX_TITLE and "r" or " "
  vim.fn.setqflist({}, action, { title = QUICKFIX_TITLE, items = items })
end

---@param view omochice.review.DiffviewView
---@param comment omochice.review.Comment
---@param lines string[]
local function commit_body(view, comment, lines)
  if #lines == 0 then
    remove_comment(comment)
    refresh_quickfix()
    return
  end
  comment.body = lines
  if session ~= nil and not vim.tbl_contains(session.comments, comment) then
    table.insert(session.comments, comment)
  end
  sync_range(comment)
  clear_marks(comment)
  render(view, comment)
  refresh_quickfix()
end

---Add a comment on the cursor line, on the visual selection when called from visual mode,
---or on an explicit line range.
---@param range? { [1]: integer, [2]: integer } Inclusive line range overriding cursor and selection.
function M.comment(range)
  local ctx = current_context()
  if ctx == nil then
    return
  end
  if session == nil then
    open_session(ctx.view)
  end
  local current = assert(session)
  local first, last = cursor_or_visual_range(range)
  local bufnr = vim.api.nvim_get_current_buf()
  local id = current.next_id
  current.next_id = id + 1
  ---@type omochice.review.Comment
  local comment = {
    id = id,
    path = ctx.file.path,
    side = ctx.side,
    start = first,
    finish = last,
    body = {},
    snapshot = vim.api.nvim_buf_get_lines(bufnr, first - 1, last, false),
    filetype = vim.bo[bufnr].filetype,
    marks = {},
    fillers = {},
  }
  local view = ctx.view
  open_input(string.format("comment/%d", id), {}, function(lines)
    commit_body(view, comment, lines)
  end)
end

---Edit the comment covering the cursor line. Writing an empty body deletes it.
function M.edit()
  local ctx = current_context()
  if ctx == nil then
    return
  end
  local comment = comment_at_cursor()
  if comment == nil then
    notify("no comment under the cursor", vim.log.levels.WARN)
    return
  end
  local view = ctx.view
  open_input(string.format("comment/%d", comment.id), comment.body, function(lines)
    commit_body(view, comment, lines)
  end)
end

---Open the quickfix list holding the session's comments.
function M.list()
  if session == nil or #session.comments == 0 then
    notify("no comments", vim.log.levels.WARN)
    return
  end
  refresh_quickfix()
  vim.cmd("copen")
end

---@param comment omochice.review.Comment
---@return string[]
local function current_snapshot(comment)
  for bufnr, _ in pairs(comment.marks) do
    local first, last = marked_range(comment, bufnr)
    if first ~= nil and last ~= nil then
      return vim.api.nvim_buf_get_lines(bufnr, first - 1, last, false)
    end
  end
  return comment.snapshot
end

---@param comment omochice.review.Comment
---@return string
local function location_label(comment)
  if comment.start == comment.finish then
    return string.format("%s:L%d", comment.path, comment.start)
  end
  return string.format("%s:L%d-L%d", comment.path, comment.start, comment.finish)
end

---@return string[]
local function render_markdown()
  assert(session ~= nil)
  local lines = {
    string.format("# Review %s", os.date("!%Y-%m-%dT%H:%M:%SZ")),
    "",
    string.format("- target: `%s`", session.range),
    string.format("- HEAD: `%s`", session.head),
    "",
  }
  if #session.overall > 0 then
    vim.list_extend(lines, session.overall)
    table.insert(lines, "")
  end
  for _, comment in ipairs(session.comments) do
    sync_range(comment)
    table.insert(lines, string.format("## `%s` (%s)", location_label(comment), comment.side))
    table.insert(lines, "")
    table.insert(lines, "```" .. comment.filetype)
    vim.list_extend(lines, current_snapshot(comment))
    table.insert(lines, "```")
    table.insert(lines, "")
    vim.list_extend(lines, comment.body)
    table.insert(lines, "")
  end
  return lines
end

local function finish_session()
  assert(session ~= nil)
  if #session.comments > 0 or #session.overall > 0 then
    local dir = vim.fs.joinpath(session.root, ".momomo", "ai", "review")
    vim.fn.mkdir(dir, "p")
    local path = vim.fs.joinpath(dir, os.date("%Y%m%dT%H%M%S") .. ".md")
    local lines = render_markdown()
    vim.fn.writefile(lines, path)
    local text = table.concat(lines, "\n") .. "\n"
    vim.fn.setreg("+", text)
    notify("review written to " .. vim.fn.fnamemodify(path, ":~:."))
  end
  close_session()
  pcall(vim.cmd.DiffviewClose)
end

---Ask for an overall comment, then write the review markdown, copy it, and close the session.
function M.done()
  if session == nil then
    notify("no review session", vim.log.levels.WARN)
    return
  end
  open_input("overall", {}, function(lines)
    if session ~= nil then
      session.overall = lines
    end
  end, function()
    if session ~= nil then
      finish_session()
    end
  end)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "DiffviewDiffBufWinEnter",
  group = vim.api.nvim_create_augroup("omochice.review", { clear = true }),
  callback = function()
    local view = current_view()
    if view ~= nil then
      render_current_entry(view)
    end
  end,
})

return M
