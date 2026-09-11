-- Comments live only for one review session because the markdown written by `done()` is the durable artifact;
-- persisting them would duplicate that file with a second format to keep in sync.
local diffview = require("omochice.review.diffview")
local marks = require("omochice.review.marks")
local input = require("omochice.review.input")
local export = require("omochice.review.export")

local M = {}

---@class omochice.review.Comment
---@field id integer
---@field path string Path relative to the repository root.
---@field side omochice.review.Side
---@field start integer
---@field finish integer
---@field body string[]
---@field snapshot string[] Lines of the range at the time the comment was written.
---@field filetype string
---@field marks table<integer, integer[]> Extmark ids per buffer, one per line of the range.
---@field fillers table<integer, integer> Filler extmark ids per opposite-side buffer.

---@class omochice.review.Session
---@field range string `left..right` as diffview resolved it: commit SHAs, `LOCAL`, or `:N` for the index.
---@field head string
---@field root string
---@field comments omochice.review.Comment[]
---@field next_id integer
---@field overall string[]

---@type omochice.review.Session|nil
local session = nil

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "review" })
end

---@param view omochice.review.DiffviewView
local function open_session(view)
  session = {
    -- The resolved revs are recorded instead of the user's argument so the file still identifies
    -- the compared trees after `HEAD` or a branch name has moved on.
    range = diffview.range(view),
    head = diffview.head(view),
    root = diffview.root(view),
    comments = {},
    next_id = 1,
    overall = {},
  }
  -- :ReviewDone exists only while a session does, so completion never offers an action that has nothing to close.
  vim.api.nvim_create_user_command("ReviewDone", function()
    M.done()
  end, { desc = "Write the review markdown and close the session" })
end

local function close_session()
  if session == nil then
    return
  end
  for _, comment in ipairs(session.comments) do
    marks.clear(comment)
  end
  session = nil
  pcall(vim.api.nvim_del_user_command, "ReviewDone")
end

---@return { view: omochice.review.DiffviewView, file: omochice.review.DiffviewFile, side: omochice.review.Side }|nil
local function current_context()
  local view = diffview.current_view()
  if view == nil then
    notify("not inside a diffview", vim.log.levels.WARN)
    return nil
  end
  local winid = vim.api.nvim_get_current_win()
  local file = diffview.window_file(view, winid)
  if file == nil then
    notify("not inside a diff buffer", vim.log.levels.WARN)
    return nil
  end
  local side = diffview.side_of(file.symbol)
  if side == nil then
    notify("this layout slot cannot take a comment", vim.log.levels.WARN)
    return nil
  end
  return { view = view, file = file, side = side }
end

---@return integer, integer
local function cursor_or_visual_range()
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

---@param comment omochice.review.Comment
local function remove_comment(comment)
  if session == nil then
    return
  end
  marks.clear(comment)
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
    local first, last = marks.marked_range(comment, bufnr)
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
  local view = diffview.current_view()
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
    marks.sync_range(comment)
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
  marks.sync_range(comment)
  marks.clear(comment)
  marks.render(view, comment)
  refresh_quickfix()
end

---Add a comment on the cursor line, or on the visual selection when called from visual mode.
function M.comment()
  local ctx = current_context()
  if ctx == nil then
    return
  end
  if session == nil then
    open_session(ctx.view)
  end
  local current = assert(session)
  local first, last = cursor_or_visual_range()
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
  input.open(string.format("comment/%d", id), {}, function(lines)
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
  input.open(string.format("comment/%d", comment.id), comment.body, function(lines)
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
local function synced_snapshot(comment)
  marks.sync_range(comment)
  return marks.current_snapshot(comment)
end

local function finish_session()
  assert(session ~= nil)
  if #session.comments > 0 or #session.overall > 0 then
    local path = export.write(session, synced_snapshot)
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
  input.open("overall", {}, function(lines)
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
    local view = diffview.current_view()
    if view ~= nil and session ~= nil then
      marks.render_current_entry(view, session.comments)
    end
  end,
})

return M
