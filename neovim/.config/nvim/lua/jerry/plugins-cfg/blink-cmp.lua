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
      }
    }
  },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" }
})
