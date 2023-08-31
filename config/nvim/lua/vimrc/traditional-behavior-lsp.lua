local M = {}

local r = require("vimrc.result-type")
local help_bufnr = nil

---@param winid integer
local function set_window_options(winid)
  vim.wo[winid].previewwindow = true
  vim.wo[winid].conceallevel = 2
  vim.wo[winid].wrap = true
end

---set options to preview buffer
---@param bufnr integer buffer-number
local function set_buffer_options(bufnr)
  vim.bo[bufnr].filetype = "markdown"
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].readonly = false
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
end

---set content to specified buffer
---@param bufnr integer buffer-number
---@param contents string[] content lines
local function set_cotents(bufnr, contents)
  vim.fn.deletebufline(bufnr, 1, "$")
  vim.fn.setbufline(bufnr, 1, contents)
end

---ensure buffer is loaded
---@return integer
local function ensure_buffer()
  if help_bufnr ~= nil then
    return help_bufnr
  end

  help_bufnr = vim.api.nvim_create_buf(false, true)
  set_buffer_options(help_bufnr)
  return help_bufnr
end

---@param bufnr integer
local function ensure_window_is_opened(bufnr)
  vim.cmd([[pclose]])
  local winid = vim.fn.bufwinid(bufnr)
  if winid ~= -1 then
    return winid
  end

  local save = vim.fn.winsaveview()
  vim.cmd(string.format("leftabove sbuffer %d", help_bufnr))
  winid = vim.api.nvim_get_current_win()
  vim.cmd([[wincmd p]])
  vim.fn.winrestview(save)
  set_window_options(winid)
  return winid
end

local function setup_contents(result)
  local lines = vim.lsp.util.trim_empty_lines(
    vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  )
  for index, line in ipairs(lines) do
    lines[index] = string.gsub(line, "%s+$", "")
  end
  return lines
end

local function ensure_contents(result, context)
  local contents = setup_contents(result)
  if vim.tbl_isempty(contents) then
    if context.client_id == nil then
      return r.err(string.format("LSP client is undefined..."))
    end
    local server_name = vim.lsp.get_client_by_id(context.client_id).name
    return r.err(string.format("No hover information found in server: %s", server_name))
  end
  return r.ok(contents)
end

M.on_hover = function(_, result, context)
  -- NOTE: hevily based on vim-lsp: under_cursor.vim
  if context == nil then
    vim.notify("Context is nil...", vim.log.levels.WARN)
    return
  end

  if context.bufnr ~= vim.api.nvim_get_current_buf() then
    -- NOTE: changed buffer before responce reach
    vim.notify("LSP mey be slow...", vim.log.levels.WARN)
    return
  end

  if result == nil then
    vim.notify("LSP return empty...", vim.log.levels.WARN)
    return
  end

  local res = ensure_contents(result, context)
  if res.is_err then
    vim.notify(res.error, vim.log.levels.WARN)
    return
  end

  local bufnr = ensure_buffer()
  set_cotents(bufnr, res.value)

  local winid = ensure_window_is_opened(bufnr)
  local height = vim.api.nvim_win_get_height(0)
  vim.api.nvim_win_set_height(winid, math.min(#res.value, math.floor(height / 2)))
end

return M
