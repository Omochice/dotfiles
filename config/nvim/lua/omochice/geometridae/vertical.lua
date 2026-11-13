---@param lnum integer
---@param vcol integer
---@return omochice.geometridae.Cell?
local function cell_at(lnum, vcol)
  if vim.fn.virtcol({ lnum, "$" }) <= vcol then
    return nil
  end
  local byte = vim.fn.virtcol2col(0, lnum, vcol)
  if byte <= 0 then
    return nil
  end
  return { lnum = lnum, col = byte - 1, text = vim.fn.strpart(vim.fn.getline(lnum), byte - 1, 1, true) }
end

---@param from integer
---@param dir 1|-1
---@return fun(): integer?
local function unfolded_lines(from, dir)
  -- Stopping at the window edge keeps jumps on the hinted lines, as easymotion did, and spares a miss from walking the whole buffer.
  local first, last = vim.fn.line("w0"), vim.fn.line("w$")
  local fold_edge = dir == 1 and vim.fn.foldclosedend or vim.fn.foldclosed
  local lnum = from
  return function()
    lnum = lnum + dir
    while lnum >= first and lnum <= last do
      if vim.fn.foldclosed(lnum) == -1 then
        return lnum
      end
      lnum = fold_edge(lnum) + dir
    end
  end
end

---Searches the cells at the cursor's screen column on the lines above or below.
---@type omochice.geometridae.Motion
return {
  mark_jump = true,
  cells = function(dir)
    local vcol = vim.fn.virtcol(".", true)[1]
    local next_line = unfolded_lines(vim.fn.line("."), dir)
    return function()
      for lnum in next_line do
        local cell = cell_at(lnum, vcol)
        if cell then
          return cell
        end
      end
    end
  end,
}
