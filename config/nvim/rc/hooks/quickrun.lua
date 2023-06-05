-- lua_add {{{
local vimx = require("artemis")

vimx.cmd("cnoreabbrev qr QuickRun")
vimx.keymap.set(
  "n",
  "<Space>q",
  "<Plug>(quickrun)"
)
vimx.g.quickrun_config = {
  _ = {
    ["outputter/buffer/close_on_empty"] = true,
    ["outputter/buffer/opener"] = "vertical botright new",
    ["hook/time/enable"] = true,
    runner = vimx.fn.has("nvim") == 1 and "neovim_job" or "job",
  },
  typescript = {
    command = "deno",
    cmdopt = "run --allow-all --unstable",
    exec = "NO_COLOR=1 %c %o %s",
  },
  elm = {
    command = "elm",
    exec = "%c make %S --output %a",
  },
  tex = {
    command = "make",
    exec = "%c",
  },
  objc = {
    type = "c",
    cmdopt = "-fmodules",
  },
  fennel = {
    command = "fennel",
    exec = "%c --compile %s | lua",
  },
}
-- }}}

-- lua_vim {{{
local vimx = require("artemis")
vimx.keymap.set(
  "n",
  [[<Space>q]],
  function()
    local lines = vimx.fn.getline(1, 3)
    for _, line in ipairs(lines) do
      if string.match(line, "themis#") ~= nil then
        vimx.fn.quickrun.run({
          command = "themis",
          exec = "%c %c",
          runner = vimx.g.quickrun_config["_"].runner
        })
        return
      end
    end
    vimx.fn.quickrun.run()
  end,
  { buffer = true }
)
-- }}}
