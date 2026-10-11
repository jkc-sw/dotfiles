local snacks = require 'snacks'
local notify = vim.notify

snacks.setup {
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      header = [[
          ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
          ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z
          ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z
          ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z
          ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
          ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]],
      keys = {
        {
          icon = ' ',
          key = 'f',
          desc = 'Find File',
          action = function()
            snacks.picker.files()
          end,
        },
        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        {
          icon = ' ',
          key = 'g',
          desc = 'Find Text',
          action = function()
            snacks.picker.grep()
          end,
        },
        {
          icon = ' ',
          key = 'r',
          desc = 'Recent Files',
          action = function()
            snacks.picker.recent()
          end,
        },
        {
          icon = ' ',
          key = 's',
          desc = 'Restore Session',
          action = function()
            require('persistence').load()
          end,
        },
        {
          icon = ' ',
          key = 'c',
          desc = 'Config',
          action = function()
            snacks.picker.files { cwd = vim.fn.stdpath 'config' }
          end,
        },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    sections = { { section = 'header' }, { section = 'keys', gap = 1, padding = 1 } },
  },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  picker = {
    enabled = true,
    sources = {
      keymaps = {
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
      },
    },
  },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
}

-- Let Noice capture early messages before delegating notifications to Snacks.
vim.notify = notify
