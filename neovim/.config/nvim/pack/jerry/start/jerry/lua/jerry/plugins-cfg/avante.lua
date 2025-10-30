require("avante_lib").load()
require("avante").setup({
  provider = "azure",
  providers = {
    azure = {

      api_key_name = {'pas', 'mks/services/openai-it/key2'},
      endpoint = "https://azureaipowersolutioncgllm-eastus2.openai.azure.com", -- example: "https://<your-resource-name>.openai.azure.com"

      -- deployment = "gpt-5-pro", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
      -- api_version = "2024-12-01-preview",

      deployment = "gpt-5", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
      api_version = "2025-01-01-preview",

      -- -- Doesn't work
      -- deployment = "gpt-5-codex", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
      -- api_version = "2025-04-01-preview",

      -- deployment = "gpt-5-mini", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
      -- api_version = "2025-04-01-preview",

      -- api_key_name = {'pas', 'mks/services/openai-it/key2'},
      -- endpoint = "https://azureaipowersolutioncgllm-eastus2.openai.azure.com", -- example: "https://<your-resource-name>.openai.azure.com"
      -- deployment = "o4-mini", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
      -- api_version = "2025-01-01-preview",

      -- api_key_name = {'pas', 'mks/services/openai-it/key1'},
      -- endpoint = "https://azureaipowersolutioncgllm.cognitiveservices.azure.com", -- example: "https://<your-resource-name>.openai.azure.com"
      -- deployment = "gpt-4o", -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
      -- api_version = "2025-01-01-preview",

      timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
      extra_request_body = {
        temperature = 1, -- gpt-5-mini
        reasoning_effort = "low", -- low|medium|high, only used for reasoning models
        max_completion_tokens = 16384, -- Increase this to include reasoning tokens (for reasoning models)
      },
    },
  },
  behaviour = {
    enable_claude_text_editor_tool_mode = false,
  },
})
