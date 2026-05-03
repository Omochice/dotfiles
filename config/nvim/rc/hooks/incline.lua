-- lua_add {{{
vim.opt.laststatus = 0
vim.opt.showtabline = 0
vim.opt.statusline = " "
vim.opt.fillchars:append({ stl = "─", stlnc = "─" })
-- }}}

-- lua_source {{{
-- FIXME: after solve https://github.com/Shougo/dpp.vim/issues/41 revert this change
local palette
local function get_palette()
  if palette then
    return palette
  end
  palette = vim
    .iter(vim.fn["sonokai#get_palette"](vim.g.sonokai_style, vim.empty_dict()))
    :fold({}, function(acc, key, value)
      acc[key] = value[1]
      return acc
    end)
  return palette
end

local icons = { error = "E:", warn = "W:", hint = "H:", info = "I:" }

--- @class Prop
--- @field buf number
--- @field win number
--- @field focused boolean

--- @param props Prop
local function get_diagnostic_label(props)
  local label = {}

  for severity, icon in pairs(icons) do
    local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
    if n > 0 then
      table.insert(label, {
        icon .. n .. " ",
        group = props.focused and ("DiagnosticSign" .. severity) or "NonText",
      })
    end
  end
  if #label > 0 then
    table.insert(label, 1, { ": ", guifg = get_palette().grey_dim })
  end
  return label
end

local well_known_files = {
  [""] = function()
    return "[NO FILES]"
  end,
  [".git/COMMIT_EDITMSG"] = function()
    return vim.fn["gitbranch#name"]()
  end,
}

--- @param bufnr integer
local function get_fileinfo(bufnr)
  local filename = vim.fn.bufname(bufnr)
  local icon = filename == "" and "" or vim.fn["nerdfont#find"](filename)
  local convert = well_known_files[filename]
  if convert == nil then
    return filename, icon
  end
  return convert(), icon
end

---@param props Prop
local function get_file_highlight(props)
  local p = get_palette()
  if not props.focused then
    return p.grey_dim
  end
  if vim.bo[props.buf].modified then
    return p.red
  end
  return p.fg
end

--- @param props Prop
local function render(props)
  local p = get_palette()
  local filename, ft_icon = get_fileinfo(props.buf)
  local is_readonly = vim.bo[props.buf].readonly
  local fg_filename = props.focused and p.fg or p.grey_dim

  return {
    {
      (ft_icon and ft_icon .. " " or ""),
      guifg = props.focused and fg_filename or p.grey_dim,
    },
    {
      (is_readonly and "RO " or ""),
      guifg = fg_filename,
    },
    {
      vim.fn.pathshorten(filename),
      guifg = get_file_highlight(props),
    },
    { get_diagnostic_label(props) },
  }
end

require("incline").setup({
  window = {
    options = {
      winblend = 0,
      filetype = "incline",
    },
    placement = {
      horizontal = "right",
      vertical = "bottom",
    },
    margin = { horizontal = 0, vertical = 0 },
    padding = 2,
  },
  render = render,
})
-- }}}

-- lua_incline {{{
vim.fn["glyph_palette#apply"]()
-- }}}
