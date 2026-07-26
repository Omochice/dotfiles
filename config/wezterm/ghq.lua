local wezterm = require("wezterm")

local M = {}

-- The GUI process inherits launchd's PATH on macOS, which has no nix profile,
-- so a bare "ghq" fails to resolve whenever wezterm is started from the Dock.
local candidates = {
  wezterm.home_dir .. "/.nix-profile/bin/ghq",
  "ghq",
}

-- run_child_process raises instead of returning false when the executable does
-- not exist, so a bare call would abort before reaching the next candidate.
local function executable()
  for _, candidate in ipairs(candidates) do
    local called, succeeded = pcall(wezterm.run_child_process, { candidate, "--version" })
    if called and succeeded then
      return candidate
    end
  end
  return nil
end

local function lines(text)
  local result = {}
  for line in text:gmatch("[^\r\n]+") do
    table.insert(result, line)
  end
  return result
end

local function split_root(roots, path)
  for index, root in ipairs(roots) do
    if path:sub(1, #root + 1) == root .. "/" then
      return index, path:sub(#root + 2)
    end
  end
  return nil, nil
end

-- A repository cloned under more than one ghq root yields the same name from
-- every copy, so keep the copy whose root comes first in `ghq root --all` to
-- match how the `f` shell function resolves the same ambiguity.
function M.deduplicated(roots, paths)
  local preferred = {}
  local names = {}
  for _, path in ipairs(paths) do
    local index, name = split_root(roots, path)
    if index ~= nil then
      local known = preferred[name]
      if known == nil then
        preferred[name] = { index = index, path = path }
        table.insert(names, name)
      elseif index < known.index then
        preferred[name] = { index = index, path = path }
      end
    end
  end
  table.sort(names)

  local results = {}
  for _, name in ipairs(names) do
    table.insert(results, { name = name, path = preferred[name].path })
  end
  return results
end

--- Lists every repository ghq knows about, one entry per repository name.
--- @return table|nil repositories `{name, path}` entries sorted by name, or nil on failure
--- @return string|nil error human readable reason when the listing failed
function M.repositories()
  local ghq = executable()
  if ghq == nil then
    return nil, "ghq is not found"
  end
  local roots_ok, roots_out, roots_err = wezterm.run_child_process({ ghq, "root", "--all" })
  if not roots_ok then
    return nil, "`ghq root --all` failed: " .. roots_err
  end
  local list_ok, list_out, list_err = wezterm.run_child_process({ ghq, "list", "--full-path" })
  if not list_ok then
    return nil, "`ghq list --full-path` failed: " .. list_err
  end
  return M.deduplicated(lines(roots_out), lines(list_out)), nil
end

return M
