-- lua_source {{{
require("parrot").setup({
  providers = {
    ollama = {
      topic = {
        model = "qwen2.5-coder:32b",
      },
    },
  },
})
-- }}}
