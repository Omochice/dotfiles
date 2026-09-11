local M = {}

---@param comment omochice.review.Comment
---@return string
local function location_label(comment)
  if comment.start == comment.finish then
    return string.format("%s:L%d", comment.path, comment.start)
  end
  return string.format("%s:L%d-L%d", comment.path, comment.start, comment.finish)
end

---@param session omochice.review.Session
---@param snapshot fun(comment: omochice.review.Comment): string[] Current lines of the range; also refreshes `start`/`finish`.
---@return string[]
local function render_markdown(session, snapshot)
  local lines = {
    string.format("# Review %s", os.date("!%Y-%m-%dT%H:%M:%SZ")),
    "",
    string.format("- target: `%s`", session.range),
    string.format("- HEAD: `%s`", session.head),
    "",
  }
  if #session.overall > 0 then
    vim.list_extend(lines, session.overall)
    table.insert(lines, "")
  end
  for _, comment in ipairs(session.comments) do
    local code = snapshot(comment)
    table.insert(lines, string.format("## `%s` (%s)", location_label(comment), comment.side))
    table.insert(lines, "")
    table.insert(lines, "```" .. comment.filetype)
    vim.list_extend(lines, code)
    table.insert(lines, "```")
    table.insert(lines, "")
    vim.list_extend(lines, comment.body)
    table.insert(lines, "")
  end
  return lines
end

---Write the review as markdown under `.momomo/ai/review/` and copy it to the `+` register.
---@param session omochice.review.Session
---@param snapshot fun(comment: omochice.review.Comment): string[]
---@return string path
function M.write(session, snapshot)
  local dir = vim.fs.joinpath(session.root, ".momomo", "ai", "review")
  vim.fn.mkdir(dir, "p")
  local path = vim.fs.joinpath(dir, os.date("%Y%m%dT%H%M%S") .. ".md")
  local lines = render_markdown(session, snapshot)
  vim.fn.writefile(lines, path)
  vim.fn.setreg("+", table.concat(lines, "\n") .. "\n")
  return path
end

return M
