-- lua_source {{{
local vimx = require("artemis")

---Parse the skkeleton AZIK table definition into an ordered roman table.
---@param path string path of azik.vim
---@return string[]? keys roman keys in definition order, nil if unreadable
---@return table<string, string[]>? entries key to `{ kana, feed }`, nil if unreadable
local function parse_azik(path)
  local keys = {}
  local entries = {}
  local file = io.open(path, "r")
  if file == nil then
    return nil, nil
  end
  for line in file:lines() do
    -- NOTE: only array values are kana definitions; string values such as
    -- `"henkanFirst"` are skkeleton function bindings and have no kana.
    local key, kana, feed = line:match('^%s*\\%s*"(.-)":%s*%["(.-)",%s*"(.-)"%]')
    if key ~= nil then
      if entries[key] == nil then
        keys[#keys + 1] = key
      end
      entries[key] = { kana, feed }
    end
  end
  file:close()
  return keys, entries
end

local function build_roman_table(path)
  local keys, entries = parse_azik(path)
  if keys == nil then
    return nil
  end
  for key, override in pairs(require("vimrc/azik").overrides) do
    if override == false then
      entries[key] = nil
    elseif type(override) == "table" then
      if entries[key] == nil then
        keys[#keys + 1] = key
      end
      entries[key] = { override[1], "" }
    end
  end

  local romanTable = {}
  for _, key in ipairs(keys) do
    local entry = entries[key]
    if entry ~= nil then
      romanTable[#romanTable + 1] = { key, entry[1], #entry[2] }
    end
  end
  return romanTable
end

local path = vimx.fn.dpp.get("skkeleton-azik-kanatable").path
if path ~= nil and path ~= "" then
  local romanTable = build_roman_table(path .. "/autoload/skkeleton/azik.vim")
  if romanTable ~= nil then
    vimx.fn.kensaku.set_roman_table(romanTable)
  end
end
-- }}}
