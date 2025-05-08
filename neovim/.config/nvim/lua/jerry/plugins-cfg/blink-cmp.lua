require("blink.cmp").setup({
  keymap = {
    preset = "default"
  },
  appearance = {
    nerd_font_variant = "mono"
  },
  completion = {
    trigger = {
      show_on_keyword = true
    },
    list = {
      selection = { preselect = false, auto_insert = true }
    },
    documentation = {
      auto_show = true
    },
    menu = {
      draw = {
        columns = {
          { 'kind_icon' },
          { 'label', 'label_description', gap = 1 },
          { 'source_name' },
        }
        -- -- colorful-menu config. I probably don't need it
        -- columns = { { "kind_icon" }, { "label", gap = 1 } },
        -- components = {
        --   label = {
        --     text = function(ctx)
        --       return require("colorful-menu").blink_components_text(ctx)
        --     end,
        --     highlight = function(ctx)
        --       return require("colorful-menu").blink_components_highlight(ctx)
        --     end,
        --   },
        -- },
      }
    }
  },
  signature = { enabled = true },
  sources = {
    default = { "avante", "lsp", "path", "snippets", "buffer" },
    providers = {
        avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {
                -- options for blink-cmp-avante
            }
        }
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" }
})
