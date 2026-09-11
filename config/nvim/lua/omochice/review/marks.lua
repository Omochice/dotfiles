local diffview = require("omochice.review.diffview")

local M = {}

local NAMESPACE = vim.api.nvim_create_namespace("omochice_review")
local SIGN_TEXT = "┃"
local BODY_PREFIX = "┃ "

vim.api.nvim_set_hl(0, "OmochiceReviewComment", { link = "DiagnosticVirtualTextInfo", default = true })
vim.api.nvim_set_hl(0, "OmochiceReviewSign", { link = "DiagnosticSignInfo", default = true })

---@param comment omochice.review.Comment
---@param bufnr integer
---@return integer|nil, integer|nil
function M.marked_range(comment, bufnr)
  local marks = comment.marks[bufnr]
  if marks == nil or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil, nil
  end
  local first = vim.api.nvim_buf_get_extmark_by_id(bufnr, NAMESPACE, marks[1], { details = true })
  local last = vim.api.nvim_buf_get_extmark_by_id(bufnr, NAMESPACE, marks[#marks], { details = true })
  if first[1] == nil or last[1] == nil or first[3].invalid or last[3].invalid then
    return nil, nil
  end
  return first[1] + 1, last[1] + 1
end

-- Extmarks follow edits made during the session, so they are the source of truth while a buffer
-- holding them is alive; the stored numbers only bridge the gap between buffer reloads.
---@param comment omochice.review.Comment
function M.sync_range(comment)
  for bufnr, _ in pairs(comment.marks) do
    local first, last = M.marked_range(comment, bufnr)
    if first ~= nil and last ~= nil then
      comment.start, comment.finish = first, last
      return
    end
  end
end

---@param comment omochice.review.Comment
function M.clear(comment)
  for bufnr, marks in pairs(comment.marks) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      for _, id in ipairs(marks) do
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
  comment.marks[bufnr] = ids
end

---@param bufnr integer
---@return string
local function buffer_text(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
end

---Map a line of `from_buf` to the line of `to_buf` that diff mode aligns it with.
---@param from_buf integer
---@param lnum integer
---@param to_buf integer
---@return integer
function M.aligned_line(from_buf, lnum, to_buf)
  local hunks = vim.diff(buffer_text(from_buf), buffer_text(to_buf), { result_type = "indices" })
  local delta = 0
  for _, hunk in ipairs(hunks) do
    local start_a, count_a, start_b, count_b = hunk[1], hunk[2], hunk[3], hunk[4]
    if count_a == 0 then
      if lnum <= start_a then
        break
      end
      delta = delta + count_b
    else
      if lnum < start_a then
        break
      end
      if lnum < start_a + count_a then
        if count_b == 0 then
          return math.max(1, start_b)
        end
        return start_b + math.min(lnum - start_a, count_b - 1)
      end
      delta = delta + count_b - count_a
    end
  end
  return math.max(1, math.min(lnum + delta, vim.api.nvim_buf_line_count(to_buf)))
end

---@param comment omochice.review.Comment
---@param from_buf integer
---@param to_buf integer
local function place_filler(comment, from_buf, to_buf)
  local lnum = M.aligned_line(from_buf, comment.finish, to_buf)
  local filler = {}
  for _ = 1, #comment.body do
    table.insert(filler, { { "", "OmochiceReviewComment" } })
  end
  comment.fillers[to_buf] = vim.api.nvim_buf_set_extmark(to_buf, NAMESPACE, lnum - 1, 0, {
    virt_lines = filler,
  })
end

---Draw the comment in the window showing its side, and keep the opposite side aligned.
---@param view omochice.review.DiffviewView
---@param comment omochice.review.Comment
function M.render(view, comment)
  local layout = view.cur_layout
  if layout == nil then
    return
  end
  local own_win, other_win
  for _, win in ipairs(layout.windows) do
    if win.file ~= nil and win.file.path == comment.path and vim.api.nvim_win_is_valid(win.id) then
      if diffview.side_of(win.file.symbol) == comment.side then
        own_win = win.id
      elseif diffview.side_of(win.file.symbol) ~= nil then
        other_win = win.id
      end
    end
  end
  if own_win == nil then
    return
  end
  place_marks(comment, vim.api.nvim_win_get_buf(own_win))
  if other_win ~= nil then
    place_filler(comment, vim.api.nvim_win_get_buf(own_win), vim.api.nvim_win_get_buf(other_win))
  end
end

---Redraw every comment that belongs to the file currently shown in the view.
---@param view omochice.review.DiffviewView
---@param comments omochice.review.Comment[]
function M.render_current_entry(view, comments)
  local path = diffview.current_path(view)
  if path == nil then
    return
  end
  for _, comment in ipairs(comments) do
    if comment.path == path then
      M.sync_range(comment)
      M.clear(comment)
      M.render(view, comment)
    end
  end
end

---Lines of the commented range as they are now, or the snapshot taken when the comment was written.
---@param comment omochice.review.Comment
---@return string[]
function M.current_snapshot(comment)
  for bufnr, _ in pairs(comment.marks) do
    local first, last = M.marked_range(comment, bufnr)
    if first ~= nil and last ~= nil then
      return vim.api.nvim_buf_get_lines(bufnr, first - 1, last, false)
    end
  end
  return comment.snapshot
end

return M
