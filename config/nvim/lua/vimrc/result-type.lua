local M = {}

---@class Ok<T> { value: T, error: nil, is_err: false }
---@class Err<T> { value: nil, error: T, is_err: true }

---@class Result<T, U>
---| Ok<T>
---| Err<U>

---Return ok result
---@generic T
---@param value T
---@return Ok<T>
M.ok = function(value)
  return {
    value = value,
    error = nil,
    is_err = false,
  }
end

---Return error result
---@generic T
---@param error T
---@return Err<T>
M.err = function(error)
  return {
    value = nil,
    error = error,
    is_err = true,
  }
end

return M
