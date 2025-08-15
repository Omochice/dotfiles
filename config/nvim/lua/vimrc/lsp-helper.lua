local M = {}

local group = vim.api.nvim_create_augroup("vimrc.lsp-helper", { clear = true })

---@param name string|nil LSP name
---@param callback fun(client: vim.lsp.Client, bufnr: integer)
function M.on_attach(name, callback)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (name == nil or client.name == name) then
        callback(client, bufnr)
      end
    end,
    group = group,
  })
end

---@param ... string
function M.root_pattern(...)
  local markers = ...
  ---@param bufnr integer
  return function(bufnr)
    local path = vim.fs.dirname(vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr)))
    local founds = vim.fs.find(markers, {
      upward = true,
      path = path,
    })
    if #founds > 0 then
      return founds[1]
    end
    return nil
  end
end

return M
