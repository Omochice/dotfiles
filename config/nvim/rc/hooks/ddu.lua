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
        params = {
          cmd = {
            "fd",
            "--hidden",
            "--color",
            "never",
            "--type",
            "file",
            "--exclude",
            ".git",
          },
        }
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
        params = { kind = "mrw" }
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
      rg = { matchers = {
        'converter_display_word',
        'matcher_fzf',
      } }
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
-- }}}

-- lua_source {{{
local vimx = require("artemis")

local config = {
  ui = "ff",
  sources = { {
    name = "file_rec",
    params = {
      ignoredDirectories = {
        ".git",
        "node_modules",
      }
    }
  }, {
    name = "file_external",
    params = {
      cmd = {
        "fd",
        "--hidden",
        "--color",
        "never",
        "--type",
        "file",
        "--exclude",
        [[.git]],
      },
    }
  } },
  sourceOptions = {
    _ = {
      ignoreCase = true,
      matchers = { "matcher_fzf" },
    },
  },
  sourceParams = {
    rg = {
      rg = {
        matchers = {
          "converter_display_word",
          "matcher_substring",
        }
      },
      args = {
        "--json",
        "--ignore-case",
      }
    },
    mru = {
      mr = {
        kind = "mru",
        current = true,
      }
    }
  },
  filterParams = {
    matcher_fzf = {
      highlightMathced = "Search",
    },
    matcher_substring = {
      highlightMathced = "Search",
    }
  },
  kindOptions = {
    file = {
      defaultAction = "open"
    },
    ["custom-list"] = {
      defaultAction = "callback",
    },
  },
  uiParams = {
    ff = {
      ignoreEmpty = true,
      split = "floating",
      filterSplitDirection = "floating",
      filterFloatingPosition = "top",
      prompt = ">",
      previewFloating = true,
      previewSplit = "vertical",
      -- autoAction = { name = "preview" },
      startFilter = true,
      floatingBorder = {
        "┌", "─", "┐", "│", "┘", "─", "└", "│",
      },
      previewFloatingBorder = {
        "┌", "─", "┐", "│", "┘", "─", "└", "│",
      },
    }
  }
}

local function reset_size()
  local win_col = math.floor(vimx.go.columns * 0.1)
  local win_width = math.floor(vimx.go.columns * 0.8)
  local win_row = math.floor(vimx.go.lines * 0.1)
  local win_height = math.floor(vimx.go.lines * 0.8)
  config.uiParams.ff.winCol = win_col
  config.uiParams.ff.winWidth = win_width
  config.uiParams.ff.winRow = win_row
  config.uiParams.ff.winHeight = win_height

  config.uiParams.ff.previewCol = math.floor(win_col - win_width * 0.5)
  config.uiParams.ff.previewWidth = math.floor(win_width * 0.5)
  config.uiParams.ff.previewRow = win_row
  config.uiParams.ff.previewheight = win_height
  vimx.fn.ddu.custom.patch_global(config)
end

reset_size()

local group = vimx.create_augroup("ddu-reset-size", { clear = true })
vimx.create_autocmd(
  "VimResized",
  {
    group = group,
    pattern = "*",
    callback = reset_size
  }
)
-- }}}

