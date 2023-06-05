-- lua_add {{{
local vimx = require("artemis")

vimx.go.showmode = false


local function get_filetype()
  if vimx.fn.winwidth(0) <= 70 then
    return ""
  end
  local ft = vimx.bo.filetype
  if string.len(ft) == 0 then
    return "no ft"
  end
  return string.format("%s %s", ft, vimx.fn.nerdfont.find())
end

local function get_format()
  if vimx.fn.winwidth(0) <= 70 then
    return ""
  end
  return string.format("%s %s", vimx.bo.fileformat, vimx.fn.nerdfont.fileformat.font())
end

local function get_recording()
  local reg = vimx.fn.reg_recording()
  if reg == "" then
    return ""
  end
  return string.format("REC: %s", reg)
end

function get_branch()
	return vimx.fn.gitbranch.name()
end

vimx.g.GetBranch = get_branch
vimx.g.GetRecording = get_recording
vimx.g.lightline_component_function = vimx.dict({
	get_filetype = get_filetype,
	get_format = get_format,
	get_branch = get_branch,
	get_recording = get_recording,
})

vimx.g.lightline = vimx.dict({
  colorscheme = "default",
  active = {
    left = {
      { "mode", "paste", "recording" },
      { "gitbranch", "readonly", "filename", "modified" },
    },
  },
  component_function = {
    gitbranch = "gitbranch#name",
    -- Filetype = get_filetype,
    -- Fileformat = get_format,
    -- recording = get_recording,
  },
})
local group = vimx.create_augroup(
  "vimrc#ligjtline-update-highlight",
  { clear = true }
)
vimx.create_autocmd(
  "ColorScheme",
  {
    pattern = "*",
    group = group,
    callback = function()
      -- タイミングかなんかの問題かluaだとうまくいかんので
      vimx.cmd("let g:lightline.colorscheme = g:colors_name")
      -- vimx.g.lightline.colorscheme = vimx.g.colors_name
      vimx.fn.lightline.disable()
      vimx.fn.lightline.enable()
    end
  }
)
-- }}}
