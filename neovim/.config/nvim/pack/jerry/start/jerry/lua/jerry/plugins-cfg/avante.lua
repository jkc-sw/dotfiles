require("avante_lib").load()
require("avante").setup({
  provider = "azure",
  azure = {
    endpoint = "https://openai-neovim.openai.azure.com/", -- example: "https://<your-resource-name>.openai.azure.com"

    deployment = "o3-mini", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
    api_version = "2024-12-01-preview",

    -- deployment = "gpt-4o", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
    -- api_version = "2024-12-01-preview",
    -- temperature = 0,

    -- deployment = "gpt-4o-mini", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
    -- api_version = "2024-12-01-preview",
    -- temperature = 0,

    timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
    max_completion_tokens = 16384, -- Increase this to include reasoning tokens (for reasoning models)
    reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
  },
  behaviour = {
    enable_claude_text_editor_tool_mode = false,
  },
})
