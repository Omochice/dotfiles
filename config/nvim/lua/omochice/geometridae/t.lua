local f = require("omochice.geometridae.f")

---Searches like f but lands on the character next to the candidate, as t does.
---@type omochice.geometridae.Motion
return vim.tbl_extend("force", f, {
  cells = function(dir)
    local next_cell = f.cells(dir)
    -- The cell next to the cursor is never a candidate, since landing before it would leave the cursor in place.
    local prev = next_cell()
    return function()
      local cell = next_cell()
      if cell then
        cell.land = prev
        prev = cell
      end
      return cell
    end
  end,
})
