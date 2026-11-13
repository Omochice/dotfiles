local M = {}

---@class omochice.geometridae.Cell
---@field lnum integer
---@field col integer 0-based byte column
---@field text string

---@class omochice.geometridae.Motion
---@field cells fun(dir: 1|-1): fun(): omochice.geometridae.Cell? walks away from the cursor
---@field mark_jump boolean

---@param name string
---@return omochice.geometridae.Motion
local function motion_of(name)
  return require("omochice.geometridae." .. name)
end

---@return string?
local function read_char()
  local ok, char = pcall(vim.fn.getcharstr)
  if not ok or char == "\27" then
    return nil
  end
  return char
end

---@param text string
---@param char string
---@return boolean
local function matches(text, char)
  if char:lower() == char then
    return text:lower() == char
  end
  return text == char
end

---@param motion omochice.geometridae.Motion
---@param dir 1|-1
---@param char string
---@return omochice.geometridae.Cell?
local function locate(motion, dir, char)
  local count = vim.v.count1
  for cell in motion.cells(dir) do
    if matches(cell.text, char) then
      count = count - 1
      if count == 0 then
        return cell
      end
    end
  end
end

-- Ctrl-K is no Normal, Visual or Operator-pending command, so it fails as a builtin f without a match does: it beeps and flushes typeahead, which stops a running macro.
-- An error message would do the same, but the next redraw then waits a second for it to be read.
local FAIL = "<C-k>"

---Moves the cursor to the count-th cell in `dir` that holds a typed character.
---@param name string module name under omochice.geometridae
---@param dir 1|-1
function M.jump(name, dir)
  local motion = motion_of(name)
  local char = read_char()
  if not char then
    return
  end
  local target = locate(motion, dir, char)
  if not target then
    vim.api.nvim_feedkeys(vim.keycode(FAIL), "ni", false)
    return
  end
  if motion.mark_jump and vim.fn.mode() == "n" then
    vim.cmd("normal! m'")
  end
  vim.api.nvim_win_set_cursor(0, { target.lnum, target.col })
end

return M
