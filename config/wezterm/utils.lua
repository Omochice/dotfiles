local M = {}

local function merged(t1, t2) -- from [https://github.com/yutkat/dotfiles/blob/3576916618fa7991de69682f628ec4832cf919c7/.config/wezterm/utils.lua]
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      merged(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end

function M.merged(tables)
  local results = {}
  for i = 1, #tables do
    merged(results, tables[i])
  end
  return results
end

function M.basename(path)
  if path == nil then
    return ""
  else
    return string.gsub(path, "(.*[/\\])(.*)", "%2")
  end
end

function M.get_process_name(p)
  return M.basename(string.match(p, "^(.-)%s"))
end

return M
