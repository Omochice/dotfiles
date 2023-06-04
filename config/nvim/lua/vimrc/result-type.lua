local M = {}

---Return ok result
---@generic T
---@alias ok { value: T, error: nil, is_err: false }
---@param value T
---@return ok
M.ok = function(value)
  return {
    value = value,
    error = nil,
    is_err = false,
  }
end

---Return error result
---@generic T
---@alias err { value: nil, error: T, is_err: true }
---@param error T
---@return err
M.err = function(error)
  return {
    value = nil,
    error = error,
    is_err = true,
  }
end

return M

---@alias result
---| ok
---| err
