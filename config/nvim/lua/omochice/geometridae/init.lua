local M = {}

---@class omochice.geometridae.Cell
---@field lnum integer
---@field col integer 0-based byte column
---@field text string
---@field land omochice.geometridae.Cell? where the cursor goes instead when the cell matches, as t does

---@class omochice.geometridae.Motion
---@field cells fun(dir: 1|-1): fun(): omochice.geometridae.Cell? walks away from the cursor
---@field mark_jump boolean
---@field wise fun(dir: 1|-1): string keys forcing the motion type under an operator, such as "V" for linewise

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
        return cell.land or cell
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

---Builds the keys for an operator-pending mapping with `expr`.
---@param name string module name under omochice.geometridae
---@param dir 1|-1
---@return string
function M.operator(name, dir)
  local motion = motion_of(name)
  local char = read_char()
  -- Escaping here cancels the operator, which a motion that leaves the cursor in place cannot do.
  if not char then
    return "<Esc>"
  end
  if not locate(motion, dir, char) then
    return FAIL
  end
  -- Embedding the character instead of reading it in apply lets `.` replay the edit without asking again.
  local bytes = table.concat({ char:byte(1, -1) }, ",")
  return ("%s<Cmd>lua require('omochice.geometridae').apply(%q, %d, string.char(%s))<CR>"):format(
    motion.wise(dir),
    name,
    dir,
    bytes
  )
end

---Moves the cursor for the motion an operator acts on.
---@param name string module name under omochice.geometridae
---@param dir 1|-1
---@param char string
function M.apply(name, dir, char)
  local target = locate(motion_of(name), dir, char)
  if not target then
    -- The operator runs right after this command returns, so only an error, not FAIL fed after it, aborts it when `.` replays it where no candidate is left.
    vim.api.nvim_echo({ { "geometridae: no candidate" } }, false, { err = true })
    return
  end
  vim.api.nvim_win_set_cursor(0, { target.lnum, target.col })
end

return M
