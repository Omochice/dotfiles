local M = {}

function M.merged(tables)
  local results = {}
  for i = 1, #tables do
    merged(results, tables[i])
  end
  return results
end

function merged(t1, t2) -- from [https://github.com/yutkat/dotfiles/blob/3576916618fa7991de69682f628ec4832cf919c7/.config/wezterm/utils.lua]
  for k, v in pairs(t2) do
    print(k)
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      merged(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end

function basename(path)
  if path == nil then
    return ""
  else
    return string.gsub(path, "(.*[/\\])(.*)", "%2")
  end
end

function M.get_process_name(p)
  return basename(string.match(p, "^(.-)%s"))
end

function M.is_opened_already()
  local res = os.capture("ps axh | grep wezterm-gui")
  return #res > 3
end

function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  io.close(f)
  local outputed = {}
  for line in string.gmatch(s, "([^\n]*)\n?") do
    table.insert(outputed, line)
  end
  return outputed
end

return M
