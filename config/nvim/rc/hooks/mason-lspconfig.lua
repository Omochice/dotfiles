-- lua_add {{{
local function enableLspKeymaps()
  local opts = { buffer = true }
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<Space>f", vim.lsp.buf.format, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<Space>d", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev({ float = false }) end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next({ float = false }) end, opts)
end
local group = vim.api.nvim_create_augroup("vimrc#nvim-lsp", {
  clear = true
})
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(_)
    enableLspKeymaps()
  end,
  group = group,
})

vim.diagnostic.config({
  virtual_text = false,
})
-- }}}

-- lua_source {{{
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers({
  function(server_name)
    local opts = {}
    if server_name == "denols" then
      opts.root_dir =
          require("lspconfig").util.root_pattern('deno.json', 'deno.jsonc')
      opts.single_file_support = true
      opts.init_options = {
        lint = true,
        unstable = true,
        suggest = {
          autoImports = true,
          completeFunctionCalls = true,
          names = true,
          paths = true,
          imports = {
            autoDiscover = true,
            hosts = {
              ["https://deno.land"] = true,
            }
          }
        }
      }
    end
    if server_name == "lua_ls" then
      opts.settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false, -- NOTE: Prevent `Do you need to configure ...`
          },
          telemetry = { enable = false },
        }
      }
    end
    require("lspconfig")[server_name].setup(opts)
  end
})

local help_bufnr = nil

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  function(_, result, context)
    -- NOTE: hevily based on vim-lsp: under_cursor.vil
    if context.bufnr ~= vim.fn.bufnr() then
      -- NOTE: changed buffer before responce reach
      vim.notify("LSP mey be slow...", vim.log.levels.WARN)
      return
    end

    local contents = vim.lsp.util.trim_empty_lines(
      vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    )
    if vim.tbl_isempty(contents) then
      local server_name = vim.lsp.get_client_by_id(context.client_id).name
      vim.notify(
        string.format("No hover information found in server: %s", server_name),
        vim.log.levels.WARN
      )
      return
    end

    help_bufnr = help_bufnr == nil and vim.api.nvim_create_buf(false, true) or help_bufnr
    vim.bo[help_bufnr].filetype = "markdown"
    vim.bo[help_bufnr].buftype = "nofile"
    vim.bo[help_bufnr].buflisted = false
    vim.bo[help_bufnr].readonly = false
    vim.bo[help_bufnr].bufhidden = "hide"
    vim.bo[help_bufnr].swapfile = false

    vim.fn.deletebufline(help_bufnr, 1, "$")
    vim.fn.setbufline(help_bufnr, 1, contents)

    vim.cmd(string.format("leftabove sbuffer %d", help_bufnr))
    local winid = vim.api.nvim_get_current_win()
    vim.wo[winid].previewwindow = true
    vim.wo[winid].conceallevel = 2
    vim.wo[winid].wrap = true
  end,
  {}
)
-- }}}
