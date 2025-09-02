require("codecompanion").setup({
  log_level = "DEBUG",
  display = {
    action_palette = {
      provider = 'telescope'
    }
  },
  adapters = {
    azure_openai = function()
      return require("codecompanion.adapters").extend("azure_openai", {
        -- https://codecompanion.olimorris.dev/getting-started.html
        -- https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/adapters/azure_openai.lua
        env = {

          -- gpt-5-mini
          api_key = 'cmd:pas mks/services/openai-it/key2',
          endpoint = "https://azureaipowersolutioncgllm-eastus2.openai.azure.com",
          api_version = "2025-04-01-preview",

          -- -- o4-mini
          -- api_key = 'cmd:pas mks/services/openai-it/key2',
          -- endpoint = "https://azureaipowersolutioncgllm-eastus2.openai.azure.com",
          -- api_version = "2025-01-01-preview",

          -- -- gpt-4o
          -- api_key = 'cmd:pas mks/services/openai-it/key1',
          -- endpoint = "https://azureaipowersolutioncgllm.cognitiveservices.azure.com",
          -- api_version = "2025-01-01-preview",

        },
        schema = {
          model = {
            default = "gpt-5-mini",
            choices = { "gpt-5-mini" },

            -- default = "o4-mini",
            -- choices = { ["o4-mini"] = { opts = { can_reason = true } }, },

            -- default = "gpt-4o",
            -- choices = {
            --   "gpt-4o",
            --   -- ["o3-mini"] = { opts = { can_reason = true } },
            --   -- "gpt-4o-mini",
            -- }

          },
        },
      })
    end,
  },
  strategies = {
    chat = {
      adapter = "azure_openai",
      slash_commands = {
        ["file"] = {
          opts = {
            provider = "telescope", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks"
            contains_code = true,
          },
        },
      },
    },
    inline = {
      adapter = "azure_openai",
    },
  },
})
