local M = {}

local BUFNAME_PREFIX = "omochicereview://"
local HEIGHT = 10

---@param lines string[]
---@return string[]
local function trim_trailing_blank(lines)
  local last = #lines
  while last > 0 and vim.trim(lines[last]) == "" do
    last = last - 1
  end
  return vim.list_slice(lines, 1, last)
end

---Open a scratch buffer below the current window. `:w` hands its lines to `on_write`,
---closing it hands control to `on_close`.
---@param name string
---@param initial string[]
---@param on_write fun(lines: string[])
---@param on_close? fun()
function M.open(name, initial, on_write, on_close)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(bufnr, BUFNAME_PREFIX .. name)
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
  local origin_view = vim.fn.winsaveview()
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = bufnr,
    once = true,
    callback = function()
      if on_close ~= nil then
        vim.schedule(on_close)
      end
    end,
  })
  vim.cmd(string.format("botright %dsplit", HEIGHT))
  local input_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(input_win, bufnr)
  -- Vim hands focus to its own choice of window when the split closes (here the file panel), and
  -- the detour re-syncs the diff windows' scroll; going straight back and restoring the saved view
  -- keeps the reviewer on the line they were reading.
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(input_win),
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(origin_win) then
        vim.api.nvim_set_current_win(origin_win)
        vim.fn.winrestview(origin_view)
      end
    end,
  })
  vim.keymap.set("n", "<CR>", "<Cmd>wq<CR>", { buffer = bufnr, nowait = true, desc = "Confirm and close" })
  if #initial == 0 then
    vim.cmd("startinsert")
  end
end

return M
