---Searches the characters on the cursor line before or after the cursor.
---@type omochice.geometridae.Motion
return {
  mark_jump = false,
  wise = function(dir)
    -- Forward f is inclusive while a motion that only sets the cursor is exclusive; backward F is exclusive as it is.
    return dir == 1 and "v" or ""
  end,
  cells = function(dir)
    local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local starts = vim.str_utf_pos(line)
    local chars = {}
    local last_before, last_through = 0, 0
    for k, start in ipairs(starts) do
      chars[k] = line:sub(start, (starts[k + 1] or #line + 1) - 1)
      if start - 1 < col then
        last_before = k
      end
      if start - 1 <= col then
        last_through = k
      end
    end
    local i = dir == 1 and last_through or last_before + 1
    return function()
      i = i + dir
      local text = chars[i]
      if not text then
        return nil
      end
      return { lnum = lnum, col = starts[i] - 1, text = text }
    end
  end,
}
