-- lua_add {{{
local vimx = require("artemis")
local prefix = "<Plug>(ddu-prefix)"

vimx.keymap.set("n", "<C-p>", prefix)
vimx.keymap.set(
  "n",
  prefix .. "<C-p>",
  function()
    vimx.fn.ddu.start({
      ui = "ff",
      sources = { {
        name = "file_external",
      } }
    })
  end
)

vimx.keymap.set(
  "n",
  prefix .. "<C-w>",
  function()
    vimx.fn.ddu.start({
      ui = "ff",
      sources = { {
        name = "mr",
      } }
    })
  end
)

vimx.keymap.set(
  "n",
  prefix .. "<C-b>",
  function()
    vimx.fn.ddu.start({
      ui = "ff",
      sources = { {
        name = "buffer"
      } }
    })
  end
)

vimx.keymap.set(
  "n",
  prefix .. "<C-l>",
  function()
    vimx.fn.ddu.start({
      ui = "ff",
      sources = { {
        name = "rg",
        options = { marcher = {} }
      } },
      uiParams = {
        ff = { ignoreEmpty = false }
      },
      volatile = true,
    })
  end
)

vimx.keymap.set(
  "n",
  prefix .. "<C-t>",
  function()
    local id = vimx.fn.denops.callback.register(
      function(s)
        vimx.fn.sonictemplate.apply(s, "n")
      end,
      { once = true }
    )
    vimx.fn.ddu.start({
      sources = {
        {
          name = "custom-list",
          params = {
            texts = vimx.fn.sonictemplate.complete("", "", 0),
            callbackId = id,
          }
        }
      }
    })
  end
)

function grepWrapper(word)
  if word == "" then
    return
  end
  vimx.fn.ddu.start({
    ui = "ff",
    sources = { {
      name = "rg",
      params = { input = word },
    } },
    sourceOptions = {
      rg = {
        matchers = {
          'converter_display_word',
          'matcher_fzf',
        }
      }
    }
  })
end

vimx.create_command(
  "DduGrep",
  function(opts)
    grepWrapper(opts.args)
  end,
  { nargs = 1 }
)

vimx.keymap.set(
  "n",
  prefix .. "<C-g>",
  ":<C-u>DduGrep "
)

vimx.keymap.set(
  "n",
  prefix .. "g",
  function()
    grepWrapper(vimx.fn.expand("<cword>"))
  end
)

vimx.keymap.set(
  "n",
  "gd",
  function()
    vimx.fn.ddu.start({
      ui = "ff",
      sources = { {
        name = "anyjump_definition",
      } }
    })
  end
)

vimx.keymap.set(
  "n",
  "gr",
  function()
    vimx.fn.ddu.start({
      ui = "ff",
      sources = { {
        name = "anyjump_reference",
      } }
    })
  end
)

vimx.create_autocmd(
  "LspAttach",
  {
    pattern = "*",
    group = vimx.create_augroup("vimrc#ddu#lsp", { clear = true }),
    callback = function()
      vimx.keymap.set(
        "n",
        "gr",
        function()
          vimx.fn.ddu.start({
            ui = "ff",
            sources = { {
              name = "lsp_references",
            } }
          })
        end,
        { buffer = true }
      )

      vimx.keymap.set(
        "n",
        "gd",
        function()
          vimx.fn.ddu.start({
            ui = "ff",
            uiParams = {
              ff = {
                immediateAction = "open",
              },
            },
            sources = { {
              name = "lsp_definition",
              params = { method = "textDocument/definition" }
            } },
            sync = true,
          })
        end,
        { buffer = true }
      )

      vimx.keymap.set(
        "n",
        "<Space>a",
        function()
          vimx.fn.ddu.start({
            ui = "ff",
            sources = { {
              name = "lsp_codeAction"
            } }
          })
        end,
        { buffer = true }
      )
    end
  }
)
-- }}}

-- lua_source {{{
local vimx = require("artemis")
vimx.fn.ddu.custom.load_config(vimx.fn.expand("$DEIN_RC_DIR/ts/ddu.ts"))

local function reset_size()
  local size = {
    col = math.floor(vimx.go.columns * 0.1),
    row = math.floor(vimx.go.lines * 0.1),
    width = math.floor(vimx.go.columns * 0.8),
    height = math.floor(vimx.go.lines * 0.8),
  }
  local config = {
    ff = {
      winCol = size.col,
      winRow = size.row,
      winWidth = size.width,
      winHeight = size.height,
      previewCol = math.floor(size.col - size.width * 0.5),
      previewWidth = math.floor(size.width * 0.5),
      previewRow = size.row,
      previewheight = size.height,
    }
  }
  vimx.fn.ddu.custom.patch_global("uiParams", config)
end

reset_size()

vimx.create_autocmd(
  "VimResized",
  {
    group = vimx.create_augroup("vimrc#ddu_resize", { clear = true }),
    pattern = "*",
    callback = reset_size
  }
)
-- }}}
