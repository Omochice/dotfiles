-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set({ "i", "c" }, "<C-j>", "<Plug>(skkeleton-enable)")
-- }}}

-- lua_source {{{
local vimx = require("artemis")

local augroup = vimx.create_augroup("vimrc#skkeleton", {
  clear = true,
})

vimx.create_autocmd("User", {
  pattern = "skkeleton-initialize-pre",
  callback = function()
    local dictPath = vimx.fn.dpp.get("dict").path
    vimx.fn.skkeleton.azik.add_table("jis")
    vimx.fn.skkeleton.config({
      kanaTable = "azik",
      globalDictionaries = {
        dictPath .. "/SKK-JISYO.L",
      },
      immediatelyCancel = false,
      registerConvertResult = true,
      lowercaseMap = { ["+"] = ";" },
    })
    vimx.fn.skkeleton.register_kanatable("azik", {
      l = "disable",
      la = false,
      li = false,
      lu = false,
      le = false,
      lo = false,
      lya = false,
      lyu = false,
      lyo = false,
      [":"] = "henkanPoint",
      -- NOTE: from https://github.com/NI57721/dotfiles
      xxa = { "ぁ" },
      xxi = { "ぃ" },
      xxu = { "ぅ" },
      xxe = { "ぇ" },
      xxo = { "ぉ" },
      xxya = { "ゃ" },
      xxyu = { "ゅ" },
      xxyo = { "ょ" },
      xxwa = { "ゎ" },
      -- NOTE: override azik table
      rr = { "れる" },
      -- NOTE: my extend table
      nn = { "なん" },
    })
  end,
  group = augroup,
})

vimx.create_autocmd("User", {
  pattern = "skkeleton-enable-pre",
  callback = function()
    vimx.b.ddc_dumped = vimx.fn.ddc.custom.get_buffer()
    vimx.fn.ddc.custom.patch_buffer({
      sources = { "skkeleton" },
      sourceOptions = {
        ["_"] = {
          matchers = {},
          sorters = {},
          isVolatile = true,
        },
      },
    })
    vimx.fn.pum.set_buffer_option({ auto_select = false })
  end,
  group = augroup,
})

vimx.create_autocmd("User", {
  pattern = "skkeleton-disable-pre",
  callback = function()
    -- NOTE: use `vim` instead of `vimx` because `vimx` return metatable
    local dumped = vim.b.ddc_dumped
    if dumped == nil then
      return
    end
    vimx.fn.ddc.custom.set_buffer(dumped)
    vimx.fn.pum.set_buffer_option({ auto_select = true })
    vimx.b.ddc_dumped = nil
  end,
  group = augroup,
})
-- }}}
