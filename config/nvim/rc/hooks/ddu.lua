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
  prefix .. "<C-i>",
  function()
    vimx.fn.ddu.start({
      ui = "ff",
      sources = {{
        name = "redmine_issue",
      }}
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

-- DONT MAP DEFAULTLY {{{
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "grn")
--- }}}
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
-- }}}
