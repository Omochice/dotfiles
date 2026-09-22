-- lua_source {{{
require("aibo").setup({
  prompt_blend_insert = 0,
  prompt_blend_normal = 0,
  prompt = {
    no_default_mappings = true,
    on_attach = function(bufnr)
      local opts = { buffer = bufnr, nowait = true, silent = true }
      vim.keymap.set({ "n", "i" }, "<C-g><C-o>", "<Plug>(aibo-send)", { buffer = bufnr, nowait = true })
      vim.keymap.set("n", "<CR>", "<Plug>(aibo-submit)", opts)
      vim.keymap.set("n", "<C-Enter>", "<Plug>(aibo-submit)<Cmd>q<CR>", opts)
      vim.keymap.set("n", "<F5>", "<Plug>(aibo-submit)<Cmd>q<CR>", opts)
      vim.keymap.set("i", "<C-Enter>", "<Esc><Plug>(aibo-submit)<Cmd>q<CR>", opts)
      vim.keymap.set("i", "<F5>", "<Esc><Plug>(aibo-submit)<Cmd>q<CR>", opts)
      vim.keymap.set({ "n", "i" }, "<C-c>", "<Plug>(aibo-send)<Esc>", opts)
      vim.keymap.set({ "n", "i" }, "g<C-c>", "<Plug>(aibo-send)<C-c>", opts)
      vim.keymap.set({ "n", "i" }, "<C-l>", "<Plug>(aibo-send)<C-l>", opts)
      vim.keymap.set({ "n", "i" }, "<Down>", "<Plug>(aibo-send)<Down>", opts)
      vim.keymap.set({ "n", "i" }, "<Up>", "<Plug>(aibo-send)<Up>", opts)
    end,
  },
  tools = {
    claude = {
      no_default_mappings = true,
      on_attach = function(bufnr, info)
        local opts = { buffer = bufnr, nowait = true, silent = true }
        vim.keymap.set("n", "<Tab>", "<Plug>(aibo-send)<Tab>", opts)
        vim.keymap.set("i", "<Tab>", function()
          local ok, suggestion = pcall(require, "copilot.suggestion")
          if ok and suggestion.is_visible() then
            suggestion.accept()
            return
          end
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(aibo-send)<Tab>", true, false, true), "m", false)
        end, opts)
        vim.keymap.set({ "n", "i" }, "<S-Tab>", "<Plug>(aibo-send)<S-Tab>", opts)
        vim.keymap.set({ "n", "i" }, "<F2>", "<Plug>(aibo-send)<F2>", opts)
        vim.keymap.set({ "n", "i" }, "<C-o>", "<Plug>(aibo-send)<C-o>", opts)
        vim.keymap.set({ "n", "i" }, "<C-t>", "<Plug>(aibo-send)<C-t>", opts)
        vim.keymap.set({ "n", "i" }, "<C-_>", "<Plug>(aibo-send)<C-_>", opts)
        vim.keymap.set({ "n", "i" }, "<C-->", "<Plug>(aibo-send)<C-_>", opts)
        if info.type == "prompt" then
          vim.bo[bufnr].filetype = "markdown.claude"
        end
        if info.type == "console" then
          local hyperlink = require("omochice/term-hyperlink").attach(bufnr)
          vim.keymap.set("n", "gx", function()
            if not hyperlink.gx() then
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<Plug>(openbrowser-open)", true, false, true),
                "m",
                false
              )
            end
          end, opts)
          vim.keymap.set("n", "gf", function()
            if not hyperlink.gf() then
              vim.cmd("normal! gf")
            end
          end, opts)
          vim.keymap.set("n", "gF", function()
            if not hyperlink.gF() then
              vim.cmd("normal! gF")
            end
          end, opts)
          ---@param text string
          local function submit_shell_command(text)
            local command = text:match("^%s*!%s+(.-)%s*$")
            if command == nil then
              vim.notify("No `! <command>` found", vim.log.levels.WARN)
              return
            end
            command = command:gsub("`+$", "")
            require("aibo").submit("! " .. command, bufnr)
            vim.cmd("normal! G")
          end
          vim.keymap.set("n", "<C-Enter>", function()
            submit_shell_command(vim.api.nvim_get_current_line())
          end, opts)
          vim.keymap.set("x", "<C-Enter>", function()
            local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
            local lines = vim.tbl_map(vim.trim, region)
            vim.cmd.normal({ "\27", bang = true })
            submit_shell_command(table.concat(lines, " "))
          end, opts)
        end
      end,
    },
    duckdb = {
      on_attach = function(bufnr, info)
        if info.type == "prompt" then
          vim.bo[bufnr].filetype = "sql"
        end
      end,
    },
  },
})
-- }}}
