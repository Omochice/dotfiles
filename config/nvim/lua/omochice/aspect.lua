local M = {}

--- Reports whether an area measured in terminal cells looks wider than it is tall.
---@param width integer
---@param height integer
---@return boolean
function M.is_landscape(width, height)
  return width > height * 2
end

return M
