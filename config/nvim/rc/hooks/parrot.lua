-- lua_source {{{
local providers = {
  ollama = {
    topic = {
      model = "qwen2.5-coder:32b",
    },
  },
}
local perplexty_api_key = os.getenv("PERPLEXITY_API_KEY")
if perplexty_api_key ~= nil and perplexty_api_key ~= "" then
  providers.pplx = {
    api_key = perplexty_api_key,
  }
end
require("parrot").setup({
  providers = providers
})
-- }}}
