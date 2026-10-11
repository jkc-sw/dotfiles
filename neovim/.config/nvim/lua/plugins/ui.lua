return {
  {
    'folke/snacks.nvim',
    dependencies = { 'jerry' },
    opts = function(_, opts)
      local snacks = require 'snacks'
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.keymaps = {
        transform = require('jerry.keymap_categories').transform,
        matcher = { sort_empty = true },
        sort = { fields = { 'score:desc', 'category', 'key', 'mode' } },
        format = function(item)
          local align = snacks.picker.util.align
          return {
            { item.mode, 'SnacksPickerKeymapMode' },
            { ' ' },
            { align(snacks.util.normkey(item.key), 16), 'SnacksPickerKeymapLhs' },
            { ' ' },
            { align(item.category, 15), 'Title' },
            { ' ' },
            { item.keymap_description, 'SnacksPickerDesc' },
          }
        end,
      }
    end,
  },
  {
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<leader>,', group = 'buffers / evaluation', mode = { 'n', 'x' } },
        { '<leader>.', group = 'journal' },
        { '<leader>e', group = 'explorer / Perforce' },
        { '<leader>H', group = 'highlight tests' },
        { '<leader>n', group = 'notifications / code blocks' },
        { '<leader>o', group = 'tmux repeat' },
        { '<leader>p', group = 'paste / snippets' },
        { '<leader>t', group = 'text tools', mode = { 'n', 'x' } },
      },
    },
  },
}
