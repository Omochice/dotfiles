-- nvim exposes OSC 8 targets neither as extmarks nor via nvim_get_hl, so they are recorded from TermRequest.
local M = {}

local MAX_LINKS = 500

---@class omochice.term_hyperlink.Link
---@field row integer
---@field col_start integer
---@field col_end integer
---@field uri string
---@field text string|nil

---@type table<integer, omochice.term_hyperlink.Link[]>
local links_by_buf = {}
---@type table<integer, { row: integer, col: integer, uri: string }>
local pending_by_buf = {}

---@param bufnr integer
---@param link omochice.term_hyperlink.Link
---@return string|nil
local function current_text(bufnr, link)
  local ok, lines =
    pcall(vim.api.nvim_buf_get_text, bufnr, link.row - 1, link.col_start, link.row - 1, link.col_end, {})
  if not ok then
    return nil
  end
  return lines[1]
end

---@param bufnr integer
---@param data { sequence: string, cursor: integer[] }
local function on_termrequest(bufnr, data)
  local params, uri = data.sequence:match("^\27%]8;([^;]*);(.*)$")
  if params == nil then
    return
  end
  local row, col = data.cursor[1], data.cursor[2]
  if row <= 0 then
    pending_by_buf[bufnr] = nil
    return
  end
  if uri ~= "" then
    pending_by_buf[bufnr] = { row = row, col = col, uri = uri }
    return
  end
  local pending = pending_by_buf[bufnr]
  pending_by_buf[bufnr] = nil
  if pending == nil or pending.row ~= row or pending.col >= col then
    return
  end
  local link = { row = row, col_start = pending.col, col_end = col, uri = pending.uri, text = nil }
  local links = links_by_buf[bufnr]
  table.insert(links, link)
  if #links > MAX_LINKS then
    table.remove(links, 1)
  end
end

-- The buffer is not yet updated when TermRequest fires; the text is read once on_lines reports the row.
---@param bufnr integer
---@param first integer
---@param last integer
local function on_lines(bufnr, first, last)
  for _, link in ipairs(links_by_buf[bufnr] or {}) do
    if link.text == nil and first < link.row and link.row <= last then
      link.text = current_text(bufnr, link)
    end
  end
end

---@param bufnr integer
---@return omochice.term_hyperlink.Link|nil
local function link_at_cursor(bufnr)
  local links = links_by_buf[bufnr]
  if links == nil then
    return nil
  end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  for i = #links, 1, -1 do
    local link = links[i]
    if link.row == row and link.col_start <= col and col < link.col_end then
      local text = current_text(bufnr, link)
      if link.text == nil then
        link.text = text
      end
      if text == link.text then
        return link
      end
      table.remove(links, i)
    end
  end
  return nil
end

---@param ref string
---@return string path, integer|nil line
local function split_line(ref)
  local path, line = ref:match("^(.-):(%d+):%d+$")
  if path == nil then
    path, line = ref:match("^(.-):(%d+)$")
  end
  if path == nil or path == "" then
    return ref, nil
  end
  return path, tonumber(line)
end

---@param link omochice.term_hyperlink.Link
---@return string|nil path, integer|nil line
local function file_target(link)
  if not link.uri:match("^file://") then
    return nil, nil
  end
  local path, line = split_line(vim.uri_to_fname(link.uri))
  if line == nil then
    local _, text_line = split_line(link.text or "")
    line = text_line
  end
  return path, line
end

---@param path string
---@param line integer|nil
local function open_file(path, line)
  local target = nil
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(winid)].buftype == "" then
      target = winid
      break
    end
  end
  if target then
    vim.api.nvim_set_current_win(target)
  else
    vim.cmd("vsplit")
  end
  vim.cmd.edit(vim.fn.fnameescape(path))
  if line then
    vim.api.nvim_win_set_cursor(0, { math.min(line, vim.api.nvim_buf_line_count(0)), 0 })
  end
end

---@param bufnr integer
---@param with_line boolean
---@return boolean handled
local function open_link_file(bufnr, with_line)
  local link = link_at_cursor(bufnr)
  if link == nil then
    return false
  end
  local path, line = file_target(link)
  if path == nil then
    return false
  end
  open_file(path, with_line and line or nil)
  return true
end

---@class omochice.term_hyperlink.Handle
---@field gx fun(): boolean
---@field gf fun(): boolean
---@field gF fun(): boolean

---@param bufnr integer
---@return omochice.term_hyperlink.Handle
function M.attach(bufnr)
  links_by_buf[bufnr] = {}
  local group = vim.api.nvim_create_augroup("omochice.term-hyperlink." .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd("TermRequest", {
    group = group,
    buffer = bufnr,
    callback = function(args)
      on_termrequest(bufnr, args.data)
    end,
  })
  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function(_, _, _, first, _, new_last)
      on_lines(bufnr, first, new_last)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = bufnr,
    callback = function()
      links_by_buf[bufnr] = nil
      pending_by_buf[bufnr] = nil
    end,
  })
  return {
    gx = function()
      local link = link_at_cursor(bufnr)
      if link == nil then
        return false
      end
      local _, err = vim.ui.open(link.uri)
      if err then
        vim.notify(err, vim.log.levels.WARN)
      end
      return true
    end,
    gf = function()
      return open_link_file(bufnr, false)
    end,
    gF = function()
      return open_link_file(bufnr, true)
    end,
  }
end

return M
