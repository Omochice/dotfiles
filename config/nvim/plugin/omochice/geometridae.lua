if vim.g.loaded_omochice_geometridae then
  return
end
vim.g.loaded_omochice_geometridae = true

---@type { key: string, name: string, dir: 1|-1, desc: string }[]
local motions = {
  { key = "j", name = "vertical", dir = 1, desc = "Jump down to a line with the typed character at the cursor column" },
  { key = "k", name = "vertical", dir = -1, desc = "Jump up to a line with the typed character at the cursor column" },
}

for _, motion in ipairs(motions) do
  local plug = ("<Plug>(geometridae-%s)"):format(motion.key)
  vim.keymap.set({ "n", "x" }, plug, function()
    require("omochice.geometridae").jump(motion.name, motion.dir)
  end, { desc = motion.desc })
end

vim.keymap.set({ "n", "x" }, "<Space>j", "<Plug>(geometridae-j)")
vim.keymap.set({ "n", "x" }, "<Space>k", "<Plug>(geometridae-k)")
