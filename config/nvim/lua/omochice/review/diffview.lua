local M = {}

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
---@field adapter { ctx: { toplevel: string }, head_rev: fun(self: table): { commit: string }|nil }
---@field left table
---@field right table

---@alias omochice.review.Side "old"|"new"

---@return omochice.review.DiffviewView|nil
function M.current_view()
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
function M.window_file(view, winid)
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
function M.side_of(symbol)
  if symbol == "a" then
    return "old"
  elseif symbol == "b" then
    return "new"
  end
  return nil
end

---@param view omochice.review.DiffviewView
---@return string
function M.root(view)
  return view.adapter.ctx.toplevel
end

---@param view omochice.review.DiffviewView
---@return string
function M.head(view)
  local head = view.adapter:head_rev()
  return head and head.commit or ""
end

---@param view omochice.review.DiffviewView
---@return string
function M.range(view)
  return tostring(view.left) .. ".." .. tostring(view.right)
end

---Path of the file shown in the current layout, if any.
---@param view omochice.review.DiffviewView
---@return string|nil
function M.current_path(view)
  if view.cur_layout == nil then
    return nil
  end
  local path
  for _, win in ipairs(view.cur_layout.windows) do
    if win.file ~= nil then
      path = win.file.path
    end
  end
  return path
end

return M
