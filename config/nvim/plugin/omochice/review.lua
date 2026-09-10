if vim.g.loaded_omochice_review then
  return
end
vim.g.loaded_omochice_review = true

vim.api.nvim_create_user_command("ReviewStart", function(opts)
  require("omochice.review").start(opts.args)
end, { nargs = "*", desc = "Open a diffview and start a review session" })
