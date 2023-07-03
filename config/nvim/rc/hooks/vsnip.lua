-- lua_add {{{
local vimx = require("artemis")
vimx.g.vsnip_snippet_dir = vimx.g.config_dir .. "/snippets"
vimx.g.vsnip_filetypes = {
  plaintex = { "tex" },
  objc = { "c", "objc" },
  vue = { "javascript", "typescript" },
}
-- }}}

-- lua_source {{{
local vimx = require("artemis")
vimx.keymap.set(
  "i",
  [[<Tab>]],
  "",
  {
    expr = true,
    callback = function()
      if vimx.fn.vsnip.jumpable(1) == 1 then
        return [[<Plug>(vsnip-jump-next)]]
      end
      return vimx.fn.lexima.expand([[<LT>TAB>]], "i")
    end,
  }
)
vimx.keymap.set(
  "s",
  [[<Tab>]],
  "",
  {
    expr = true,
    callback = function()
      if vimx.fn.vsnip.jumpable(1) == 1 then
        return [[<Plug>(vsnip-jump-next)]]
      end
      return [[<Tab>]]
    end
  }
)
vimx.keymap.set(
  "i",
  "[[<S-Tab>]]",
  "",
  {
    expr = true,
    callback = function()
      if vimx.fn.vsnip.jumpable(-1) == 1 then
        return [[<Plug>(vsnip-jump-prev)]]
      end
      return vimx.fn.lexima.expend([[<LT>S-TAB>]], "i")
    end
  }
)
vimx.keymap.set(
  "s",
  [[<S-Tab>]],
  "",
  {
    expr = true,
    callback = function()
      if vimx.fn.vsnip.jumpable(1) == 1 then
        return [[<Plug>(vsnip-jump-prev)]]
      end
      return [[<S-Tab>]]
    end
  }
)
-- }}}
