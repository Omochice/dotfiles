-- lua_add {{{
vim.opt.laststatus = 0
vim.opt.showtabline = 0
vim.opt.statusline = " "
vim.opt.fillchars:append({ stl = "─", stlnc = "─" })
-- }}}

-- lua_source {{{
-- NOTE: This configuration is based on https://github.com/izumin5210/dotfiles/blob/15a954676994c3710926d4c9bbf1f635f3a145f4/config/.config/nvim/lua/utils/colors.lua
local palette = vim
  .iter(vim.fn["sonokai#get_palette"](vim.g.sonokai_style, vim.empty_dict()))
  :fold({}, function(acc, key, value)
    acc[key] = value[1]
    return acc
  end)
-- local fg_active = palette.text
local fg_inactive = palette.grey_dim
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
    table.insert(label, 1, { ": ", guifg = fg_inactive })
  end
  return label
end

--- @param props Prop
local function render(props)
  local filename = vim.fn.bufname(props.buf)
  local ft_icon = vim.fn["nerdfont#find"](filename)
  local is_readonly = vim.bo[props.buf].readonly
  local fg_filename = props.focused and palette.fg or fg_inactive

  return {
    {
      (ft_icon and ft_icon .. " " or ""),
      guifg = props.focused and fg_filename or fg_inactive,
    },
    {
      (is_readonly and "RO " or ""),
      guifg = fg_filename,
    },
    {
      filename,
      guifg = fg_filename,
    },
    {
      vim.bo[props.buf].modified and " +" or "",
      guifg = props.focused and palette.purple or fg_inactive,
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
