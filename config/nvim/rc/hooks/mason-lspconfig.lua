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

---Get client id from client name
---@param name string The language server client name
---@return nil | number
local function get_client_id(name)
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.name == name then
      return client.id
    end
  end
  return nil
end

local lspconfig = require("lspconfig")
lspconfig.denols.setup({
  cmd = { "deno", "lsp" },
  root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
  single_file_support = true,
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
  on_attach = function()
    if vim.fn.findfile("package.json", ".;") == "" then
      return
    end
    local id = get_client_id("denols")
    if id == nil then
      return
    end
    vim.lsp.stop_client(id)
  end,
})
require("mason-lspconfig").setup_handlers({
  function(server_name)
    local opts = {}
    local is_node_repo = vim.fn.findfile("package.json", ".;") ~= ""

    if server_name == "vtsls" or server_name == "tsserver" then
      -- Must be node directory
      if not is_node_repo then
        return
      end
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
    require("lspconfig")[server_name].setup(opts)
  end,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(require("vimrc/traditional-behavior-lsp").on_hover, {})
-- }}}
