---@param text string?
---@return boolean
local function alpha(text)
  return text ~= nil and text:match("^%a$") ~= nil
end

---@param text string?
---@return boolean
local function upper(text)
  return text ~= nil and text:match("^%u$") ~= nil
end

---@param text string?
---@return boolean
local function blank(text)
  return text ~= nil and text:match("^%s$") ~= nil
end

---Reports whether a character sits where vim-eft hints, such as the head or tail of a word.
---@param prev string?
---@param text string
---@param next string?
---@return boolean
local function at_boundary(prev, text, next)
  return prev == nil
    or next == nil
    or (not alpha(prev) and alpha(text))
    or (alpha(text) and not alpha(next))
    or (not upper(prev) and upper(text))
    or (not blank(text) and not alpha(text))
    or (not blank(prev) and blank(text))
end

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
      return { lnum = lnum, col = starts[i] - 1, text = text, hint = at_boundary(chars[i - 1], text, chars[i + 1]) }
    end
  end,
}
