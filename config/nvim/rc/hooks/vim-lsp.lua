-- lua_add {{{
local vimx = require("artemis")
vimx.g.lsp_settings = {
  ["efm-langserver"] = { disabled = false },
  ["html-langserver"] = { allowlist = { "html", "htmldjango" } },
  ["taplo-lsp"] = {
    workspace_cofig = {
      formatter = {
        reorderKeys = false,
        compactArray = false,
        arrayAutoCollapse = false,
        alignEntries = true,
      }
    }
  }
}
-- }}}
