-- lua_add {{{
local vimx = require("artemis")

local function reset()
  vimx.g.tataku_recipes = {
    translate_en_to_ja = {
      collector = {
        name = "current_line",
      },
      processor = {
        {
          name = "intl_segmenter",
          options = { locale = "en" }
        },
        {
          name = "google_translate",
          options = {
            source = "en",
            target = "ja",
          }
        },
        {
          name = "intl_segmenter",
          options = { locale = "ja" }
        },
        {
          name = "split_by_displaywidth",
          options = {
            width = vimx.go.columns - 2,
            float = "left",
            is_wrap = true,
          }
        },
      },
      emitter = {
        name = "nvim_floatwin",
        options = { border = "single" }
      }
    },
    translate_ja_to_en = {
      collector = {
        name = "current_line",
      },
      processor = {
        {
          name = "intl_segmenter",
          options = { locale = "ja" }
        },
        {
          name = "google_translate",
          options = {
            source = "ja",
            target = "en",
          }
        },
        {
          name = "intl_segmenter",
          options = { locale = "en" }
        },
        {
          name = "split_by_displaywidth",
          options = {
            width = vimx.go.columns - 2,
            float = "left",
            is_wrap = true,
          }
        },
      },
      emitter = {
        name = "nvim_floatwin",
        options = { border = "single" }
      }
    },
    review = {
      collector = {
        name = "buffer"
      },
      processor = {
        {
          name = "eta",
          options = {
            type = "file",
            templateDirectory = vimx.fn.expand("$DEIN_RC_DIR") .. "/eta",
            templateFileName = "review.eta",
          }
        },
        {
          name = "ollama",
          options = {
            model = "codellama",
          }
        }
      },
      emitter = {
        name = "window",
        options = { cmd = "tabedit", bufname = "ollama:///review" }
      }
    },
  }
end

reset()

vimx.create_autocmd(
  "VimResized",
  {
    pattern = "*",
    callback = reset,
    group = vimx.create_augroup("tataku-setting", { clear = true })
  }
)

vimx.g.tataku_enable_operator = true
vimx.keymap.set({ "n", "x" }, "tr", "<Plug>(operator-tataku-translate_en_to_ja)")
vimx.keymap.set({ "n", "x" }, "tR", "<Plug>(operator-tataku-translate_ja_to_en)")
vimx.keymap.set(
  "n",
  "trr",
  function()
    vimx.fn.tataku.call_recipe("translate_en_to_ja")
  end
)
vimx.keymap.set(
  "n",
  "tRR",
  function()
    vimx.fn.tataku.call_recipe("translate_ja_to_en")
  end
)
-- }}}
