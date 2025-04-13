require("avante_lib").load()
require("avante").setup({
  provider = "azure",
  azure = {
    endpoint = "https://openai-neovim.openai.azure.com/", -- example: "https://<your-resource-name>.openai.azure.com"
    deployment = "gpt-4o-mini", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
    api_version = "2024-12-01-preview",
    timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
    temperature = 0,
    max_completion_tokens = 16384, -- Increase this to include reasoning tokens (for reasoning models)
    reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
  },
})
