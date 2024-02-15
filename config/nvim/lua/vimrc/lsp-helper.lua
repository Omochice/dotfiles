local M = {}

local group = vim.api.nvim_create_augroup("lsp-helper", { clear = true })

---@param name string|nil LSP name
---@param callback fun(client: lsp.Client, bufnr: integer)
function M.on_attach(name, callback)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (name == nil or client.name == name) then
        callback(client, bufnr)
      end
    end,
    group = group
  })
end

return M
