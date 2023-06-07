-- lua_add {{{
local function enableLspKeymaps()
  local opts = { buffer = true }
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<Space>f", vim.lsp.buf.format, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<Space>d", vim.diagnostic.setloclist, opts)
  vim.keymap.set("n", "<Space>D", vim.diagnostic.open_float, opts)
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
    local is_node_repo = vim.fn.findfile("package.json", ".;") ~= ""

    if server_name == "vtsls" or server_name == "tsserver" then
      -- Must be node directory
      if not is_node_repo then
        return
      end
    elseif server_name == 'denols' then
      -- Must not be node directory
      if is_node_repo then
        return
      end

      opts.root_dir = require("lspconfig").util.root_pattern('deno.json', 'deno.jsonc')
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

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  require("vimrc/traditional-behavior-lsp").on_hover,
  {}
)
-- }}}
