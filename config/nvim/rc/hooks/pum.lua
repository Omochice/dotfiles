-- lua_add {{{
local vimx = require("artemis")
vimx.keymap.set("i", [[<C-y>]], function()
  if not vimx.fn.pum.visible() then
    vim.api.nvim_feedkeys(vim.keycode("<C-y>"), "n", false)
    return
  end
  vimx.fn.pum.map.confirm()
end)
vimx.keymap.set("i", [[<C-n>]], function()
  if not vimx.fn.pum.visible() then
    vim.api.nvim_feedkeys(vim.keycode("<C-n>"), "n", false)
    return
  end
  vimx.fn.pum.map.insert_relative(1)
end)
vimx.keymap.set("i", [[<C-p>]], function()
  if not vimx.fn.pum.visible() then
    vim.api.nvim_feedkeys(vim.keycode("<C-p>"), "n", false)
    return
  end
  vimx.fn.pum.map.insert_relative(-1)
end)
for key, direction in pairs({ ["<C-d>"] = 1, ["<C-u>"] = -1 }) do
  vimx.keymap.set("i", key, function()
    if not vimx.fn.pum.preview_visible() then
      vim.api.nvim_feedkeys(vim.keycode(key), "n", false)
      return
    end
    local half = math.floor(vim.api.nvim_win_get_height(vimx.fn.pum._get().preview_id) / 2)
    vimx.fn.pum.map.scroll_preview(direction * math.max(half, 1))
  end)
end
-- }}}

-- lua_source {{{
local vimx = require("artemis")

vimx.fn.pum.set_option({
  auto_select = true,
  preview = true,
  preview_border = "single",
  preview_delay = 50,
  preview_width = 100,
  previewer = "ddc#get_previewer",
})

vimx.create_autocmd("User", {
  pattern = "PumPreview",
  callback = function()
    vim.api.nvim_win_call(vimx.fn.pum._get().preview_id, function()
      vim.opt_local.fillchars:append({ lastline = "." })
    end)
  end,
  group = vimx.create_augroup("vimrc.pum-preview", { clear = true }),
})
-- }}}
