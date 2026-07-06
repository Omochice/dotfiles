-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set("n", "<Plug>(vimrc-fyler)", "<Nop>")
vimx.keymap.set("n", ";", "<Plug>(vimrc-fyler)")
vimx.keymap.set("n", "<Plug>(vimrc-fyler);", function()
  require("fyler").toggle({ kind = "floating" })
end)
-- }}}

-- lua_source {{{

---@param finder fyler.Finder
---@return fyler.FSEntry|nil
local function cursor_node(finder)
  return require("fyler.finder").parse_cursor_line(finder)
end

---@param finder fyler.Finder
---@param target_path string
---@param callback fun(key: string)
local function walk_subtree_dirs(finder, target_path, callback)
  local libpath = require("fyler.lib.path")
  local store = require("fyler.state").store
  local target_key = libpath.to_key(target_path)
  finder.state:walk(function(node)
    local data = store[node.value]
    if not (data and data.type == "directory") then
      return
    end
    local key = libpath.to_key(data.path)
    if key == target_key or vim.startswith(key, target_key .. "/") then
      callback(key)
    end
  end, { skip_hidden = true, hidden_items = finder.cache.ui.hidden_items })
end

-- Directories inside a collapsed one are unknown until a rescan, so
-- keep expanding and refreshing until no collapsed directory remains
---@param finder fyler.Finder
---@param target_path string
local function expand_subtree(finder, target_path)
  local changed = false
  walk_subtree_dirs(finder, target_path, function(key)
    if not finder.state.meta[key] then
      finder.state.meta[key] = true
      changed = true
    end
  end)
  if not changed then
    return
  end
  finder:refresh({
    target_path = target_path,
    recursive = true,
    callback = function()
      expand_subtree(finder, target_path)
    end,
  })
end

-- Collapsing during the walk would cut the traversal at that node,
-- so collect every key first and collapse afterwards
---@param finder fyler.Finder
---@param target_path string
local function collapse_subtree(finder, target_path)
  local keys = {}
  walk_subtree_dirs(finder, target_path, function(key)
    table.insert(keys, key)
  end)
  for _, key in ipairs(keys) do
    finder.state.meta[key] = false
  end
  finder:refresh()
end

---@param finder fyler.Finder
local function toggle_tree(finder)
  local node = cursor_node(finder)
  if not node then
    return
  end
  if node.type == "directory" then
    finder:select()
  else
    finder:shrink({ parent = true })
  end
end

---@param finder fyler.Finder
local function open_node(finder)
  local node = cursor_node(finder)
  if not (node and node.type == "directory") then
    return
  end
  if finder.state.meta[require("fyler.lib.path").to_key(node.path)] then
    return
  end
  finder:select()
end

---@param finder fyler.Finder
local function open_tree(finder)
  local node = cursor_node(finder)
  if not (node and node.type == "directory") then
    return
  end
  expand_subtree(finder, node.path)
end

---@param finder fyler.Finder
local function close_node(finder)
  local node = cursor_node(finder)
  if not node then
    return
  end
  if node.type == "directory" then
    finder:shrink()
  else
    finder:shrink({ parent = true })
  end
end

---@param finder fyler.Finder
local function close_tree(finder)
  local node = cursor_node(finder)
  if not node then
    return
  end
  local libpath = require("fyler.lib.path")
  local target = node.type == "directory" and node.path or libpath.to_dirname(node.path)
  if libpath.to_key(target) == libpath.to_key(finder.state.pseudo_root_path) then
    return
  end
  collapse_subtree(finder, target)
end

---@param finder fyler.Finder
local function expand_all(finder)
  expand_subtree(finder, finder.state.pseudo_root_path)
end

---@param finder fyler.Finder
local function collapse_all(finder)
  for key in pairs(finder.state.meta) do
    finder.state.meta[key] = false
  end
  finder.state:toggle(finder.state.pseudo_root_path, true)
  finder:refresh()
end

require("fyler").setup({
  integrations = {
    icon = "vim_nerdfont",
  },
  kind = "floating",
  kind_presets = {
    floating = {
      height = "80%",
      width = "80%",
      row = "center",
      col = "center",
    },
  },
  mappings = {
    n = {
      ["<CR>"] = { action = "select" },
      ["<C-t>"] = { action = "select", args = { tabedit = true } },
      ["#"] = { action = collapse_all },
      zo = { action = open_node },
      zO = { action = open_tree },
      zc = { action = close_node },
      zC = { action = close_tree },
      zR = { action = expand_all },
      zM = { action = collapse_all },
      za = { action = toggle_tree },
      ["<Tab>"] = { action = toggle_tree },
      -- [[disable defaults]]
      q = { disabled = true },
      ["-"] = { disabled = true },
      ["="] = { disabled = true },
      ["."] = { disabled = true },
    },
  },
})

-- The upstream rewrite dropped the size column, so re-add it through
-- the extension hook using the same format as the old builtin
---@param bytes integer|nil
---@return string
local function format_size(bytes)
  if not bytes or bytes < 0 then
    return "     -"
  end
  local units = { "B", "K", "M", "G", "T" }
  local unit_index = 1
  local size = bytes
  while size >= 1024 and unit_index < #units do
    size = size / 1024
    unit_index = unit_index + 1
  end
  local formatted
  if unit_index == 1 then
    formatted = ("%d%s"):format(size, units[unit_index])
  else
    formatted = ("%.1f%s"):format(size, units[unit_index])
  end
  return ("%6s"):format(formatted)
end

require("fyler.extensions").register({
  name = "size_column",
  hooks = {
    ---@param inst fyler.Finder
    ---@param visible { path: string, type: string }[]
    ---@param hl_ns integer
    ---@param lines string[]
    finder_refresh_post = function(inst, visible, hl_ns, lines)
      local col = 0
      for _, line in ipairs(lines) do
        col = math.max(col, vim.fn.strdisplaywidth(line))
      end
      col = col + 1
      for i, item in ipairs(visible) do
        local size
        if item.type ~= "directory" then
          local stat = vim.uv.fs_stat(item.path)
          size = stat and stat.size
        end
        pcall(vim.api.nvim_buf_set_extmark, inst.buf_id, hl_ns, i - 1, 0, {
          virt_text = { { format_size(size), "Comment" } },
          virt_text_win_col = col,
          hl_mode = "combine",
        })
      end
    end,
  },
})
-- }}}

-- lua_fyler_finder {{{
require("artemis").fn.glyph_palette.apply()
-- }}}
