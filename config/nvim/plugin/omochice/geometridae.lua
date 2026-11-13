if vim.g.loaded_omochice_geometridae then
  return
end
vim.g.loaded_omochice_geometridae = true

---@type { key: string, name: string, dir: 1|-1, desc: string }[]
local motions = {
  { key = "j", name = "vertical", dir = 1, desc = "Jump down to a line with the typed character at the cursor column" },
  { key = "k", name = "vertical", dir = -1, desc = "Jump up to a line with the typed character at the cursor column" },
  { key = "f", name = "f", dir = 1, desc = "Jump forward onto the typed character" },
  { key = "F", name = "f", dir = -1, desc = "Jump backward onto the typed character" },
  { key = "t", name = "t", dir = 1, desc = "Jump forward till the typed character" },
  { key = "T", name = "t", dir = -1, desc = "Jump backward till the typed character" },
}

for _, motion in ipairs(motions) do
  local plug = ("<Plug>(geometridae-%s)"):format(motion.key)
  vim.keymap.set({ "n", "x" }, plug, function()
    require("omochice.geometridae").jump(motion.name, motion.dir)
  end, { desc = motion.desc })
  vim.keymap.set("o", plug, function()
    return require("omochice.geometridae").operator(motion.name, motion.dir)
  end, { expr = true, desc = motion.desc })
end

vim.keymap.set({ "n", "x", "o" }, "<Space>j", "<Plug>(geometridae-j)")
vim.keymap.set({ "n", "x", "o" }, "<Space>k", "<Plug>(geometridae-k)")
vim.keymap.set({ "n", "x", "o" }, "f", "<Plug>(geometridae-f)")
vim.keymap.set({ "n", "x", "o" }, "F", "<Plug>(geometridae-F)")
vim.keymap.set({ "n", "x", "o" }, "t", "<Plug>(geometridae-t)")
vim.keymap.set({ "n", "x", "o" }, "T", "<Plug>(geometridae-T)")
vim.keymap.set({ "n", "x", "o" }, "<Space>l", "<Plug>(geometridae-f)")
vim.keymap.set({ "n", "x", "o" }, "<Space>h", "<Plug>(geometridae-F)")
