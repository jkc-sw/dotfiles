require("codecompanion").setup({
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
          endpoint = "https://openai-neovim.openai.azure.com/",
          api_key = 'cmd:pass mks/services/openai/key1',
          api_version = "2024-12-01-preview",
        },
        schema = {
          model = {
            default = "gpt-4o",
            choices = {
              "gpt-4o",
              ["o3-mini"] = { opts = { can_reason = true } },
              "gpt-4o-mini",
            }
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
