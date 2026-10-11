local snippets = require 'jerry.integrations.home_manager.snippets'
require('blink.cmp').setup {
  snippets = { preset = 'default', expand = snippets.expand },
  keymap = {
    preset = 'enter',
    ['<C-y>'] = { 'select_and_accept' },
    ['<Tab>'] = {
      function()
        if vim.snippet.active { direction = 1 } then
          vim.schedule(function()
            vim.snippet.jump(1)
          end)
          return true
        end
      end,
      'fallback',
    },
  },
  appearance = {
    nerd_font_variant = 'mono',
    kind_icons = require('jerry.integrations.home_manager.icons').kinds,
  },
  completion = {
    accept = { auto_brackets = { enabled = true } },
    menu = { draw = { treesitter = { 'lsp' } } },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = vim.g.ai_cmp },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    per_filetype = { lua = { inherit_defaults = true, 'lazydev' } },
    providers = {
      lazydev = { module = 'lazydev.integrations.blink', name = 'LazyDev', score_offset = 100 },
    },
  },
  cmdline = {
    enabled = true,
    keymap = { preset = 'cmdline', ['<Right>'] = false, ['<Left>'] = false },
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function()
          return vim.fn.getcmdtype() == ':'
        end,
      },
      ghost_text = { enabled = true },
    },
  },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
}
