-- lua_add {{{
local vimx = require("artemis")
vimx.g.lexima_map_escape = ""
vimx.g.lexima_enable_endwise_rules = true
vimx.g.lexima_enable_newline_rules = true
vimx.g.lexima_disable_on_nofile = false
vimx.g.lexima_ctrlh_as_backspace = true
if vimx.fn.dein.tap("pum.vim") then
  vimx.keymap.set(
    "i",
    [[<CR>]],
    function()
      if vimx.fn.pum.visible() then
        if vimx.fn.vim.size() == 1 then
          return [[<CR>]]
        end
        vimx.fn.pum.map.confirm()
        return
      end
      return vimx.fn.lexima.expand([[<LT>CR>]], "i")
    end
  )
end
-- }}}

-- lua_source {{{
local vimx = require("artemis")

local ft = {
  js = { "javascript", "typescript" },
  md = { "markdown", "text", "gitcommit" },
  ruby = "ruby",
  sh = { "sh", "zsh", "bash" },
  fish = "fish",
  py = "python",
  html = { "html", "htmldjango", "vue" },
  tex = { "latex", "tex" },
  uml = { "plantuml" },
  react = { "typescriptreact" },
  lua = "lua",
  java = "java",
}

local char = {
  cr = [[<CR>]],
  sp = [[<Space>]],
  bs = [[<BS>]],
  tab = [[<Tab>]],
  stab = [[<S-Tab]],
}

local rules = {
  -- general settings
  { char = char.cr, at = [["""\%#"""]], input = char.cr, input_after = char.cr },
  { char = char.bs, at = [[<\%#>]], input = char.bs, delete = 1 },
  { char = "　", at = [[\%#]], input = " " },
  { char = char.bs, at = [[=\%#=]], input = char.bs, delete = 1 },
  -- js/ts
  { filetype = ft.js, char = char.sp, at = [[^\s*\(}\s*else\s\)\?if\%#]], input = [[<Space>(]], input_after = ")" },
  { filetype = ft.js, char = ">", at = [[(\%#)]], input = [[<Right><Space>=><Space>]] },
  { filetype = ft.js, char = "*", at = [[^\s*/\%#]], input = [[*<Space>]], input_after = [[<Space>*/]] },
  { filetype = ft.js, char = "*", at = [[/*\s\%#]], input = [[<BS>*<Space>]] },
  { filetype = ft.js, char = char.bs, at = [[/\*\*\s\%#\s\*/]], input = [[<BS><BS><Space>]] },
  -- ruby
  { filetype = ft.ruby, char = [[<Bar>]], at = [[\(do\|{\)\s*\%#}]], input = [[<Bar>]], input_after = [[<Bar>]] },
  { filetype = ft.ruby, char = char.bs, at = [[|\%#|]], input = char.bs, delete = 1 },
  -- markdown
  { filetype = ft.md, char = char.cr, at = [[```\w*\%#```]], input = char.cr, input_after = char.cr },
  { filetype = ft.md, char = "#", at = [[^\%#]], input = [[#<Space>]] },
  { filetype = ft.md, char = "#", at = [[^#\+\s\%#]], input = [[<BS>#<Space>]] },
  { filetype = ft.md, char = char.bs, at = [[^#\s\%#[^#]\?]], input = [[<BS><BS>]] },
  { filetype = ft.md, char = char.bs, at = [[^#\{2,}\s\%#[^#]\?]], input = [[<BS><BS><Space>]] },
  { filetype = ft.md, char = "-", at = [[^\s*\%#]], input = [[-<Space>]] },
  { filetype = ft.md, char = "-", at = [[^\s*-\s\%#]], input = [[<BS>-]] },
  { filetype = ft.md, char = "+", at = [[^\s*\%#]], input = [[+<Space>]] },
  { filetype = ft.md, char = "*", at = [[^\s*\%#]], input = [[*<Space>]] },
  {
    filetype = ft.md,
    char = char.cr,
    at = [[^\s*\([-+\*]\)\s.\+\%#\s*$]],
    input = [[<CR>\1<Space>]],
    with_submatch = true,
  },
  { filetype = ft.md, char = char.bs, at = [[^\s*[-+\*]\s\%#]], input = [[<BS><BS>]] },
  { filetype = ft.md, char = char.cr, at = [[^\s*[-+\*]\s\w.*\%#]], input = [[<CR>-<Space>]] },
  { filetype = ft.md, char = "~", at = [[\~\%#[^\~]\?]], input = "~", input_after = "~~" },
  { filetype = ft.md, char = char.bs, at = [[\~\%#\~]], input = char.bs, delete = 1 },
  { filetype = ft.md, char = char.sp, at = [[^\s*-\s\+\%#]], input = "" },
  { filetype = ft.md, char = ":", at = [[^\%#]], input = ":", input_after = ":" },
  { filetype = ft.md, char = char.bs, at = [[^:\%#:]], input = char.bs, delete = 1 },
  -- checkbox on markdown
  { filetype = ft.md, char = char.sp, at = [=[^\s*[-+\*]\s\+\[\%#\]]=], input = [[<Space><Right><Space>]] },
  -- vim
  { filetype = ft.md, char = char.cr, at = [[[\[{]\s\?\%#[\]}]$]], input = [[<CR>\<Space>]] },
  { filetype = ft.md, char = char.cr, at = [[^\s*\\.\+\%#]], input = [[<CR>\<Space>]] },
  -- sh
  { filetype = ft.sh, char = "[", at = [[if\s\%#]], input = [=[[<Space>]=], input_after = [=[<Space>]]=] },
  {
    filetype = ft.sh,
    char = "[",
    at = [=[if\s[\s\%#]]=],
    input = [[<BS>[<Space>]],
    input_after = char.sp,
    delete = 1,
  },
  { filetype = ft.sh, char = char.sp, at = [[^\s*if\%#]], input = char.sp, input_after = [[;<Space>then]] },
  -- fish
  { filetype = ft.fish, char = char.cr, at = [[\s*if.*\%#]], input = char.cr, input_after = [[<CR>end]] },
  -- python
  { filetype = ft.py, char = "%", at = [[^#\s%\%#]], input_after = [[<CR><CR># %%]] },
  -- HTML
  { filetype = ft.html, char = "%", at = [[{\%#}]], input = [[%<Space>]], input_after = [[<Space>%]] },
  { filetype = ft.html, char = char.cr, at = [[>\%#<]], input = char.cr, input_after = char.cr },
  -- latex
  { filetype = ft.tex, char = "$", at = [=[[^\$]*\%#]=], input = "$", input_after = "$" },
  { filetype = ft.tex, char = "$", at = [[\$\%#\$]], input = [[$<CR>]], input_after = [[<CR>$]] },
  { filetype = ft.tex, char = char.bs, at = [[\$\%#\$]], input = char.bs, delete = 1 },
  { filetype = ft.tex, char = char.cr, at = [[^\s*\\item\s.\+\%#$]], input = [[<CR>\item]] },
  {
    filetype = ft.tex,
    char = char.cr,
    at = [[\\begin{\(\w\+\*\?\)}\%#$]],
    input = char.cr,
    input_after = [[<CR>\\end{\1}]],
    with_submatch = true,
  },
  -- plantuml
  { filetype = ft.uml, char = char.cr, at = [[^\s*@startuml\s*\%#]], input = char.cr, input_after = [[<CR>@enduml]] },
  {
    filetype = ft.uml,
    char = char.cr,
    at = [[^\s*\(alt\|opt\|loop\|par\|group\)\s\?.*\%#]],
    input = char.cr,
    input_after = [[<CR>end]],
  },
  {
    filetype = ft.uml,
    char = char.cr,
    at = [[\s*note \(left\( of\)\?\|right\( of\)\?\|over\).*\%#]],
    input = char.cr,
    input_after = [[<CR>end note]],
  },
  { filetype = ft.uml, char = char.cr, at = [[then\%#]], input = char.cr, input_after = [[<CR>end if]] },
  { filetype = ft.uml, char = char.cr, at = [[\s*box.*\%#]], input = char.cr, input_after = [[<CR>end box]] },
  { filetype = ft.uml, char = "=", at = [[^\s*=\%#]], input = "=", input_after = "==" },
  { filetype = ft.uml, char = char.sp, at = [[==\%#==]], input = char.sp, input_after = char.sp },
  { filetype = ft.uml, char = char.bs, at = [[=\%#=]], input = char.bs, delete = 1 },
  { filetype = ft.uml, char = char.bs, at = [[= \%# =]], input = char.bs, delete = 1 },
  -- react
  { filetype = ft.react, char = ">", at = [[<\%#]], input = ">", input_after = "</>" },
  { filetype = ft.react, char = char.cr, at = [[<>\%#</>]], input = char.cr, input_after = char.cr },
  -- lua
  {
    filetype = ft.lua,
    char = char.cr,
    at = [[^\s*\(local\s\+\)\?function.*\%#]],
    input = char.cr,
    input_after = [[<CR>end]],
  },
  { filetype = ft.lua, char = "=", at = [=[\[=*\%#=*\]]=], input = "=", input_after = "=" },
  { filetype = ft.lua, char = char.sp, at = [[if\%#]], input = char.sp, input_after = [[<Space>then<CR>end]] },
  -- java
  { filetype = ft.java, char = char.sp, at = [[^\s*\(}\s*else\s\)\?if\%#]], input = [[<Space>(]], input_after = ")" },
}

for _, rule in ipairs(rules) do
  vimx.fn.lexima.add_rule(rule)
end
-- }}}
