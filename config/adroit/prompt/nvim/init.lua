for lhs, action in pairs({
  ["<M-h>"] = "window.left",
  ["<M-j>"] = "window.down",
  ["<M-k>"] = "window.up",
  ["<M-l>"] = "window.right",
  ["<M-n>"] = "tab.next",
  ["<M-N>"] = "tab.prev",
  ["<M-c>"] = "session.new",
  ["<M-t>"] = "session.pick",
  ["<M-w>"] = "waiting.next",
  ["<M-W>"] = "session.pick",
}) do
  vim.keymap.set("i", lhs, "<Cmd>Adroit " .. action .. "<CR>")
end
