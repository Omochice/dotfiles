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
  vim.cmd(string.format("botright %dsplit", HEIGHT))
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.keymap.set("n", "<CR>", "<Cmd>wq<CR>", { buffer = bufnr, nowait = true, desc = "Confirm and close" })
  if #initial == 0 then
    vim.cmd("startinsert")
  end
end

return M
