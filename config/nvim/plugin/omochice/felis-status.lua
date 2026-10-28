-- felis reads OSC 7501 only from its own PTY, and nvim drops sequences it does not handle from :terminal children.
if vim.g.loaded_omochice_felis_status or vim.env.FELIS_SESSION_ID == nil then
  return
end
vim.g.loaded_omochice_felis_status = true

local CLEAR = "\27]7501;state=clear\27\\"

---@type table<integer, true>
local reporting_bufs = {}

local group = vim.api.nvim_create_augroup("omochice.felis-status", { clear = true })

vim.api.nvim_create_autocmd("TermRequest", {
  group = group,
  callback = function(ev)
    local sequence = ev.data.sequence
    -- felis would answer a support query on nvim's stdin, where the reply turns into keystrokes instead of reaching the child.
    if not vim.startswith(sequence, "\27]7501;") or sequence == "\27]7501;?" then
      return
    end
    reporting_bufs[ev.buf] = true
    vim.api.nvim_ui_send(sequence .. ev.data.terminator)
  end,
})

-- While nvim stays in the foreground, felis never sees the shell prompt that would expire the record on its own.
vim.api.nvim_create_autocmd("TermClose", {
  group = group,
  callback = function(ev)
    if reporting_bufs[ev.buf] then
      reporting_bufs[ev.buf] = nil
      vim.api.nvim_ui_send(CLEAR)
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    if next(reporting_bufs) ~= nil then
      vim.api.nvim_ui_send(CLEAR)
    end
  end,
})
