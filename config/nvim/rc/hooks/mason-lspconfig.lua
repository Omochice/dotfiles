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
  vim.keymap.set("n", "[d", function()
    vim.diagnostic.goto_prev({ float = false })
  end, opts)
  vim.keymap.set("n", "]d", function()
    vim.diagnostic.goto_next({ float = false })
  end, opts)
end
local group = vim.api.nvim_create_augroup("vimrc#nvim-lsp", {
  clear = true,
})
vim.api.nvim_create_autocmd("LspAttach", {
  callback = enableLspKeymaps,
  group = group,
})

vim.diagnostic.config({
  virtual_text = false,
})
-- }}}

-- lua_source {{{
local lspconfig = require("lspconfig")
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers({
  function(server_name)
    local opts = {}
    if server_name == "lua_ls" then
      opts.settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false, -- NOTE: Prevent `Do you need to configure ...`
          },
          format = {
            defaultConfig = {
              indent_style = "space",
              indent_size = "2",
              quote_style = "double",
              call_arg_parentheses = "keep",
              align_continuous_assign_statement = "false",
              align_continuous_rect_table_field = "false",
              align_array_table = "false",
            },
          },
          telemetry = { enable = false },
        },
      }
    end
    if server_name == "yamlls" then
      opts.settings = {
        yaml = {
          keyOrdering = false,
        },
      }
    end
    lspconfig[server_name].setup(opts)
  end,
})

lspconfig.denols.setup({
  cmd = { "deno", "lsp" },
  root_dir = function(...)
    if lspconfig.util.root_pattern("package.json", "node_modules")(...) ~= nil then
      return nil
    end
    local found = lspconfig.util.root_pattern("deno.json", "deno.jsonc")(...)
    return found or vim.fn.getcwd()
  end,
  single_file_support = false,
  init_options = {
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
        },
      },
    },
  },
})
lspconfig.nushell.setup({})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(require("vimrc/traditional-behavior-lsp").on_hover, {})
-- }}}
