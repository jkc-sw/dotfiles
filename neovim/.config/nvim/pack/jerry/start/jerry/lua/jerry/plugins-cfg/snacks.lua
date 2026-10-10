local snacks = require 'snacks'

snacks.setup {
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      header = 'Neovim',
      keys = {
        {
          key = 'f',
          desc = 'Find File',
          action = function()
            snacks.picker.files()
          end,
        },
        { key = 'n', desc = 'New File', action = ':ene | startinsert' },
        {
          key = 'g',
          desc = 'Find Text',
          action = function()
            snacks.picker.grep()
          end,
        },
        {
          key = 'r',
          desc = 'Recent Files',
          action = function()
            snacks.picker.recent()
          end,
        },
        {
          key = 's',
          desc = 'Restore Session',
          action = function()
            require('persistence').load()
          end,
        },
        { key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    sections = { { section = 'header' }, { section = 'keys', gap = 1, padding = 1 } },
  },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  picker = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
}
